shader_type canvas_item;

uniform int rect_count : hint_range(1, 50) = 25;
uniform float min_size = 50.0;
uniform float max_size = 200.0;
uniform float lifetime = 1.0; // durée moyenne d’un rectangle
uniform float instance_offset : hint_range(0.0, 10000.0); // Valeur unique par instance pour la variation
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

float hash2(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;
    vec4 col = vec4(0.0);

    // Temps global, pour faire avancer l'animation de manière continue
    float global_time = fract(TIME / lifetime);

    for (int i = 0; i < rect_count; i++) {
        float fi = float(i);

        // Créer un décalage aléatoire unique par instance, à l'aide de `instance_offset`
        float offset = instance_offset + fi;

        // Position aléatoire (plus haut et plus à gauche)
        // Ajout d'un facteur pour décaler la position dans l'espace de l'écran
        vec2 pos = vec2(
            hash2(vec2(offset - 50.0, global_time - 50.0)),  // Décalage plus à gauche
            hash2(vec2(offset, global_time))                 // Décalage plus en haut
        );

        // Appliquer un facteur d'échelle pour agrandir l'espace de déplacement
        // Déplacer les rectangles dans une plage plus grande
        pos = (pos * 2.0) - 1.0;  // De [0.0, 1.0] à [-1.0, 1.0]

        // Taille aléatoire des rectangles
        vec2 size = vec2(
            mix(min_size, max_size, hash2(vec2(offset + 20.0, global_time))),
            mix(min_size, max_size, hash2(vec2(offset + 30.0, global_time)))
        ) / vec2(textureSize(SCREEN_TEXTURE, 0));

        // Définir un délai aléatoire pour chaque rectangle, basé sur l'index `fi`
        float start = hash(offset + 100.0) * lifetime;
        float end = start + (hash(offset + 200.0) * lifetime);

        // Vérifier si le rectangle doit être visible (en fonction de son délai d'apparition)
        if (global_time >= start && global_time < end) {
            vec2 minp = pos;
            vec2 maxp = pos + size;

            // Vérifier si le pixel est à l'intérieur du rectangle
            if (uv.x >= minp.x && uv.x <= maxp.x &&
                uv.y >= minp.y && uv.y <= maxp.y) {
                col = vec4(1.0);  // Rectangle visible
            }
        }
    }

    COLOR = col;
}
