shader_type canvas_item;

// Paramètres ajustables
uniform float density : hint_range(0.1, 1.0) = 1.0;  // Opacité globale
uniform float min_size : hint_range(0.01, 0.05) = 0.01;  // Taille minimale
uniform float max_size : hint_range(0.1, 2.0) = 0.5;  // Taille maximale
uniform float min_life : hint_range(0.1, 4.0) = 1.0;  // Durée de vie minimale (secondes)
uniform float max_life : hint_range(0.5, 10.0) = 3.0;  // Durée de vie maximale (secondes)
uniform float rectangle_count : hint_range(1.0, 50.0) = 5.0;  // Nombre de rectangles

// Fonction de hash pour l'aléatoire
float hash(vec2 p) {
    return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x))));
}

// Calcul de la luminance d'une couleur RGB
float luminance(vec3 color) {
    return 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
}

void fragment() {
    vec2 uv = UV;
    float time = TIME;
    vec3 final_color = vec3(0.0);
    float final_alpha = 0.0;

    // Pour chaque rectangle, on le dessine de manière aléatoire
    for (float i = 0.0; i < rectangle_count; i++) {
        // Calculer un identifiant unique pour chaque rectangle
        vec2 id = vec2(i, time);  // Utilisation de 'i' et 'time' pour obtenir une valeur différente par rectangle

        // Position aléatoire pour chaque rectangle
        vec2 pos = vec2(hash(id + 1.0), hash(id + 2.0));  // Position aléatoire en UV
        
        // Taille aléatoire pour chaque rectangle
        float size = mix(min_size, max_size, hash(id + 3.0));  // Taille aléatoire entre min_size et max_size

        // Dessine le rectangle (bords nets)
        bool inside_x = (uv.x >= pos.x) && (uv.x < pos.x + size);
        bool inside_y = (uv.y >= pos.y) && (uv.y < pos.y + size);
        float rect = inside_x && inside_y ? 1.0 : 0.0;

        // Durée de vie aléatoire entre min_life et max_life
        float life_start = hash(id + 4.0) * 100.0;
        float life_duration = mix(min_life, max_life, hash(id + 5.0));
        float life_time = time - life_start;
        float is_visible = step(0.0, life_time) * step(life_time, life_duration);

        // Calcul de l'Overlay
        vec3 background = texture(TEXTURE, uv).rgb;  // Récupère la couleur de l'arrière-plan
        vec3 overlay_color = vec3(1.0);  // La couleur du rectangle est toujours blanche

        // Calcul de la luminance de l'arrière-plan
        float bg_luminance = luminance(background);

        // Applique la logique Overlay
        vec3 blended_color;
        if (bg_luminance < 0.5) {
            // Si l'arrière-plan est sombre, on éclaircit
            blended_color = 2.0 * overlay_color * background;
        } else {
            // Si l'arrière-plan est clair, on assombrit
            blended_color = 1.0 - 2.0 * (1.0 - background) * (1.0 - overlay_color);
        }

        // Applique la couleur du rectangle en mode Overlay
        float alpha = rect * is_visible;
        
        // On additionne l'alpha et la couleur du rectangle pour tous les rectangles
        if (alpha > 0.0) {
            final_color += blended_color * alpha;  // Ajoute la couleur du rectangle à la couleur finale
            final_alpha += alpha;  // Ajoute l'alpha à l'alpha total
        }
    }

    // Normalise l'alpha pour éviter des valeurs trop fortes
    final_alpha = min(final_alpha, 1.0);
    COLOR.rgb = final_color;
    COLOR.a = final_alpha * density;
}
