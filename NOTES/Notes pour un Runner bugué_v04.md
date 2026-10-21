Errore 404: Sprint Non Trovato! (un jeu qui bugue)

Tentative de description du jeu plus claire :
Une partie oppose toujours 4 concurrents (1 joueur et 3 Bots). Les concurrents courent en permanence, ne peuvent pas s'arrêter et tracent un mur temporaire derrière eux. Le terrain se transforme continuellement (glissements de portions de terrain, cellules qui s'abaissent ou disparaissent, colonnes, etc.), modifiant les trajets possibles pendant toute la course. Des Bonus/Malus apparaissent régulièrement ; chaque couleur est associée à un Bonus et à un Malus, le joueur ne sait donc jamais lequel il ramasse. Des "bugs" viennent également perturber l'affichage pendant la partie. La course prend fin lorsqu'il ne reste plus qu'un seul concurrent vivant ou lorsqu'un concurrent passe la porte de sortie que celle-ci est apparue.
Les coureurs s’appellent :
- Woman_A : _b4sTa,  Woman_B : dA1!, Man_A : cOnØ et Man_B : sTrn2Ø!


- Ce « Runner » va se « rapprocher » de la (fameuse) séquence de course de moto dans Tron (1982) qu’on va mélanger avec un peu du film Cube (les connexions entre les salles changent régulièrement comme un Rubik’s Cube).

- Un jeu en 2D (vue isométrique).
- Un champ de course qui sera carré au départ et deviendra « plus du tout carré » par les transformations successives.
- Le champ de course se structurera sous forme de grille dont les lignes et colonnes (complètes, même s’il y a des trous dans une ligne/colonne) vont être poussées ou tirées par le jeu transformant ainsi le terrain en permanence.
- Des cases s’élèveront et/ou se baisseront également.
- L’aire de course sera composée, au choix du joueur, de base de 9x9 à 21x21 (uniquement impaires pour avoir la case « 404 » au centre) cellules de terrain (ou plus ?).
- Un jeu pour 1 joueur mais il y aura toujours 4 concurrents en piste. Les 3  concurrents non-humains seront pris en charge par l’IA (Bots). Il y a toujours 2 hommes et 2 femmes en course.
- L’écran est divisé en 4 avec les vues de chaque concurrent. Le 1er joueur sera toujours dans le quart supérieur gauche. Puis à droite du 1er puis sous le 1er et enfin le dernier en bas à droite.
- À chaque fois que le jeu va bouger une ligne/colonne ou baisser un pylône (qui n’écrase pas et laisse passer dessous) ou baisser une cellule ou lâcher un pylône ou faire disparaître une cellule, une alarme (Cell_Pylon_Alarms/ dans Sounds.tscn) se fera d’abord entendre pendant 1’’ ET jusqu’à la fin de l’animation (sauf exceptions).
- Une cellule baissée ou disparue ou un pylône (baissé ou arrivé au sol) reste dans cette position 10 à 20’’. S’il font partie d’une ligne/colonne qui glisse pendant qu’ils sont dans l’état évoqué ici, alors ils suivent le mouvement de la ligne/colonne.
- On ne fait pas tomber/descendre de pylône sur une cellule disparue ou descendue.
- Dès le début, la case centrale (404) est baissée. Au dessus du vide flotte Artefact.tscn. Au bout de (Taille de la map + Difficulté) / 10 minutes Artefact disparaît. (2 × Difficulté) secondes plus tard, la case 404 remonte et (2 × Difficulté) secondes plus tard, la porte de sortie (Door.tscn) apparaît. Aléatoirement, la porte de sortie sera tournée vers la droite ou vers la gauche.
- La case centrale 404 ne subit QUE des glissements (pas de bug, de disparition, de pylone, etc.).
- Pour les concurrents, 4 directions de mouvement (les diagonales).
- Les concurrents ne peuvent pas faire directement demi-tour (à cause du mur qu’ils tracent).
- Les concurrents ne peuvent tourner qu’à 90°.
- Les concurrents ne peuvent pas arrêter de courir !
- Ils tracent un mur temporaire derrière eux (qui s’efface au fur et à mesure en fonction du niveau de difficulté et de la taille de la map – voir plus loin).
- Un tronçon de mur est la partie du mur sur une case du terrain.
- Le but du jeu est de tenir le plus longtemps possible et être le dernier survivant ou être le premier à passer la porte de sortie.

Un runner bugué :
-  Chaque vue de concurrent a un timer de bug indépendant des autres vues.
- Les bugs durent de 3’’ en difficulté 1 à 10’’ en difficulté 5.
- Après chaque bug, on attend 10’’ en difficulté 1 à  5’’ en difficulté 5 avant d’avoir 1/5 chance d’en déclencher un nouveau. Ainsi on n’a jamais 2 bugs simultanés dans une vue caméra.
- Au lancement des bugs, on joue le son Bug_Sound (dans The_Game.tscn) et on le coupe à la fin du bug. Pas d’intro/outro, effets directs !
    1. L’image globale se décale dans la vue du joueur (la caméra se centre sur le joueur – voir Notes de fabrication plus bas) → Ça se fait : ✔
    2. La palette de couleurs change → ✔
    3. Image floue → Ça se fait : ✔
    4. La caméra vibre → ✔
    5. Couleurs inversées → ✔
    6. Sur-pixelisation → ✔
    7. Jpeg →  ✔

- Bug permanent (supprimé du jeu pour le moment !) : toutes les 3 à 5’’ (on ne joue pas Frames/Bug_Sound mais Sound/Flashing_Cell dans Cell.tscn) :
    1. Texture de sol change (sauf les 4 cases de coins et la case 404) – (permanent)→ ✔ /!\ ATTENTION /!\ une texture de bord reste tout de même une texture de bord et une texture « normale » reste tout de même une texture « normale ».

- Bug inutile (juste pour faire chier) :
    1. Toutes les 10 secondes, on a 1/10 chance de jouer le son Sounds/Misc/Useless_Alarm_1 ou Sounds/Misc/Useless_Alarm_2 dans Sounds.tscn ! Il est à noter que ces sons ne déclenchent absolument rien !

Les bonus et malus en jeu (Cube.tscn) :
- En course, il n’y aura qu’1 exemplaire de chaque Bonus et 1 exemplaire de chaque Malus sur le terrain.
- Chaque concurrent ne peut porter qu’1 Bonus/Malus. On peut ramasser un Bonus/Malus si on en porte déjà un mais le nouveau remplace le précédent.
- Un Bonus/Malus apparaît toutes les (30 - taille + difficulté) secondes.
- Il ne peut pas y avoir plus de (Taille de la map ÷ 3) Bonus/Malus simultanément à ramasser → celui « en trop » supprime automatiquement le plus ancien restant pendant que le nouveau apparaît.
- On ne fait pas apparaître de Bonus/Malus sur une cellule avec au moins un mur et/ou tout autre obstacle.
- Pour chaque couleur correspondent un bonus et un malus (le joueur ne sait donc pas s’il voit un bonus ou un malus).
- Ramassage de Bonus/Malus :
- Au ramassage d’un Bonus ou Malus, on joue le clignotement du concurrent (Animation_Bonus_Malus). Puis à l’activation (automatique) du Bonus/Malus, on change la couleur de l’outline du joueur pour la durée de l’effet (voir codes couleur juste en dessous), on jouera également le son correspondant au bonus/malus (sous Sound/Bonus_Malus). On jouera également le clignotement du concurrent (Animation_Bonus_Malus/Bonus_Malus) à chaque utilisation du bonus (Dash uniquement à ce jour).
- Lorsque l’effet du Bonus/Malus durera plus longtemps que le son et l’animation du Bonus/Malus, à la fin de l’effet du Bonus/Malus, on rejouera le clignotement du coureur et le son Sound/Bonus_Malus/Bonus_Malus_Over dans la scène du coureur et l’outline retrouvera sa couleur par défaut (noir) à la fin du clignotement.
- Tout effet sur la vitesse du joueur se répercute sur la vitesse du mur (thanks, Cap’tain Obvious!).

Les bonus (applications activables) :
    1. Invulnérabilité – Rouge (annule le prochain malus récolté ou renvoyé par le malus Virus) – dure : (11 – difficulté)’’ → ✔ Invincible – 
    2. Course, saut et glissade : 15% plus rapide (animation aussi et le tout avec un tween d’1/2 seconde) – Vert – dure : ((2 × difficulté) + 3)’’ → ✔ Dash
    3. Passe-muraille – Bleu (uniquement les light walls) – dure : ((6 – difficulté) + 2)’’ → ✔ Through – 
    4. Virus – Violet (envoie automatiquement le prochain malus récolté à un adversaire aléatoire) – dure : (11 – difficulté)’’  → ✔ Virus – 
    5. Auto-dodge – Jaune (les obstacles et trous évitables par glissement ou saut (pas en tournant) sont évités automatiquement si le joueur ne le fait pas) – dure : ((6 – difficulté) + 2)’’→ ✔ Auto_Dodge – 
    6. Débogueur – Gris (vire le bug de caméra) – dure : (11 – difficulté)’’→ ✔ Debug – 
    7. Les murs tracés jusqu’à présent par les concurrents disparaissent (avec l’animation Disappearing) – dure : Instantané – Blanc → ✔ Last_Longer – (à la fin de la disparition des murs, les coureurs recommencent à tracer des murs).

Les malus (applications automatiques) :
    1. Inversion de commandes – Rouge – dure : (difficulté)’’ → ✔ Invert
    2. Lenteur de réaction (on ajoute un délai de 15ms (à préciser) dans les commandes du concurrent) – Gris – dure : (3 × difficulté)’’ → ✔ Slow
    3. Les murs tracés par les concurrents durent plus longtemps – Blanc – (durée des tronçons de mur × 1.5) → ✔ Last_Shorter – Au bout de la durée des tronçons de mur normale, l’effet du malus disparaît et la durée de vie normale de chaque tronçon reprend sa valeur normale et tous les tronçons qui ont vécu ce temps ou plus disparaissent (avec l’animation Disappearing) ! Ainsi le malus a surtout pour effet de faire durer plus longtemps les tronçons de mur déjà et encore en place avant l’activation du malus. En difficulté 6, le Malus devient : Inversion des boutons Saut et Glissade – dure : (difficulté)’’ → on garde le même son.
    4. Course, saut et glissade : 15% plus lent (animation aussi et le tout avec un tween d’1/2 seconde) – Vert – dure : ((2 × difficulté) + 3)’’ → ✔ Anti_Dash
    5. « Hors phase » (shader) – Bleu – dure : ((2 × difficulté) + 10)’’ → ✔ Phase
    6. Virus (envoie automatiquement le prochain Bonus (pas malus) récolté à un adversaire aléatoire, quitte à remplacer celui que porte l’adversaire – Violet – dure : (10 – difficulté)’’ → ✔ Anti_Virus
    7. Tout droit (le coureur ne peut plus tourner pendant (difficulté)’’ – Jaune → ✔ No_turn

Codes couleurs à appliquer à l’outline du joueur :
    • Rouge : Color(1.0, 0.25, 0.25)
    • Vert : Color(0.25, 1.0, 0.25)
    • Bleu : Color(0.25, 0.25, 1.0)
    • Gris : Color(0.45, 0.45, 0.45)
    • Blanc : Color(0.75, 0.75, 0.75)
    • Violet : Color(0.71, 0.33, 1.0)
    • Jaune : Color(0.7, 0.68, 0.0)
    • Noir (couleur par défaut) : Color(0.0, 0.0, 0.0)
Codes couleurs à appliquer aux Bonus/Malus (Cube.tscn et voir ’’sprite_color’’) :
    • Rouge : Color(1.523, 0.865, 0.865)
    • Vert : Color(0.748, 1.164, 0.621)
    • Bleu : Color(0.783, 0.883, 1.382)
    • Gris : Color(0.666, 0.666, 0.666)
    • Blanc : Color(1.0, 1.0, 1.0) (par défaut)
    • Violet : Color(1.037, 0.775, 1.523)
    • Jaune : Color(1.231, 1.269, 0.698)

Les obstacles :
- Toutes les X secondes (voir Options nécessaires dans Settings) un des obstacles est déclenché. 25% du temps, il s’agira d’1 glissement de Ligne/Colonne. La « quantité » de glissement des Ligne/Colonne se font aléatoirement d’1 à (longueur d’un côté au départ/3) cases (pour ne pas dire cellule qui pourrait être perturbant). On fait TOUJOURS glisser une ligne/colonne complète (« trous » inclus).
    1. Ligne/Colonne (de cellules) qui glisse – Permanent → ✔ (1’’ avant, on joue Cell_Pylon_Alarms/Cell_Slide dans Sounds.tscn ET jusqu’à la fin de l’animation)
    2. Trous (cellules qui descendent) – 5’’ en difficulté 1 à 20’’ en difficulté 5 → ✔
    3. Murs des concurrents – (Durée : comme précisé plus loin) → ✔
    4. Sens unique – 5’’ en difficulté 1 à 20’’ en difficulté 5 → ✔ /!\ATTENTION/!\  c’est le collider du panneau qui fait changer de direction, pas la cellule elle-même ! On fait disparaître (avec l’animation Disappearing) le Sens unique dès qu’il est déclenché par un concurrent.
    5. Colonne descendante – 5’’ en difficulté 1 à 20’’ en difficulté 5 → ✔
    6. Colonne écrasante – 5’’ en difficulté 1 à 20’’ en difficulté 5 → ✔
    7. Cellule « disparaissante » – 5’’ en difficulté 1 à 20’’ en difficulté 5 → ✔
    8. 2 Cellules « hors phase » (téléporteurs) – 5’’ en difficulté 1 à 20’’ en difficulté 5 → ✔ Apparaissent par paire et disparaissent après utilisation. La vitesse et la direction du coureur sont conservés pendant la téléportation pour un des deux types de téléporteurs seulement. L’autre type de téléporteur fait tourner le coureur en sortie de téléportation vers la droite ou la gauche (aléatoirement). On utilise les deux shaders pour pouvoir différencier 2 sets de téléporteurs différents.
Notes de fabrication :
- Au lancement du jeu, la musique qui joue en boucle en permanence, c’est Intro. Jusqu’au moment dans le jeu proprement dit où le Départ est donné. À cet instant précis, on passe à Music (en boucle). Music ne s’arrête qu’en finissant la partie (soit en relançant une nouvelle partie directement soit en retournant à l’écran de Titre. Au moment de lancer à nouveau Intro, il faudra jouer une fois le son Bang tout en démarrant en même temps Intro.
- /!\ ATTENTION /!\ On ne joue jamais Bang au lancement de Music car il est intégré dans la musique.
- Sauf pendant la sélection de joueur, par défaut, la caméra de chaque joueur ne montre pas le joueur centré mais se décale afin d’avoir plus de visibilité devant le joueur en fonction de la direction dans laquelle il court. On utilisera systématiquement un tween d’3/4 de seconde pour déplacer la caméra. Au démarrage de la course, dès la première frame de course, la caméra rejoindra sa place avec le tween décrit précédemment.
    • Position de caméra par rapport au root d’un coureur pour l’animation Intro :
        ◦ Coin nord : py +15.
        ◦ Coin Sud : py -75.
        ◦ Coin Ouest : px -120, py -40.
        ◦ Coin Est : px +120, py -40.
    • Position de caméra par rapport au root d’un concurrent pour les animations Death et Falling : par défaut.
Pour les animations Start, Run, Slide et Jump:
        ◦ Position de caméra par rapport au root d’un concurrent tourné vers le sud-est : px = +100, py = +30.
        ◦ Position de caméra par rapport au root d’un concurrent tourné vers le sud-ouest : px = -100, py = +30.
        ◦ Position de caméra par rapport au root d’un concurrent tourné vers le nord-ouest : px = -100, py = -85.
        ◦ Position de caméra par rapport au root d’un concurrent tourné vers le nord-est : px = -10, py = -85.
    • Position de caméra par rapport au root d’un concurrent pour le bug qui décalle la caméra : px = 0, py = -28.
- Le mur tracé derrière un concurrent lorsqu’il se déplace est Wall.tscn. À chaque entrée d’un concurrent sur une Cell ou virage, on commence le tracé d’un nouveau Wall.tscn qui sera raccord avec le précédent. Lorsqu’un concurrent quitte une Cell ou fait un virage sur une Cell, on coupe le précédent Wall.tscn et on en commence un autre qui sera raccord. On ne trace pas de Wall.tscn lorsqu’un concurrent saute au dessus d’un trou ou passe sous un obstacle (sauf s’il saute ou glisse dans toute autre condition).
- Au démarrage (uniquement) de chaque concurrent (lorsqu’il commence à courir), on joue l’animation Light_Wall_Animations/Appearing dans Wall.tscn pour commencer son mur. On joue également Light_Wall_Sounds/Wall_Hum en boucle (jusqu’à ce que le mur complet disparaisse).
- Le Light_Wall commence 60px et 30py derrière le coureur pour qu’il ne « tape » pas dedans avec ses pieds. À présent réglé avec un délai de 100ms.
- Le tracé du mur se fait au fur et à mesure de la progression du coureur.
- À la mort d’un concurrent, lorsque son mur disparaît, joue l’animation Light_Wall_Animations/Disappearing dans Wall.tscn.
- À la fin de l’animation de mort d’un concurrent (Death) et que son mur aussi a disparu, on joue l’animation Animation_Disappearing_Death/Disappearing du concurrent afin de faire disparaître son cadavre (c’est dommage mais le laisser, ça risque de trop compliquer les choses).
- Lorsqu’un concurrent traverse une case (donc en traçant son mur) et que la cellule bouge (glissement), alors le concurrent se décale AVEC la cellule. Et le mur qu’il trace également afin que le morceau de mur sur la cellule puisse se déplacer avec la case si celle-ci est amenée à se déplacer de nouveau.
- Cas particuliers de mort de concurrent : il existe une animation alternative, un AnimationPlayer avec une animation « toute bête » pour ces cas-là (Animation_Disappearing_Death/Disappearing). Si par exemple se présente un cas avec deux colonnes baissées et que le concurrent veut passer dessous à vitesse normale, il ne pourra pas (distance trop grande pour un slide), mourra donc et on utilisera cette animation. Écrasé par une colonne, ce sera pareil ! Etc.
- Un concurrent ne peut pas courir sur un autre cadavre → Mort (animation Death).
- À la mort d’un concurrent, ce qui reste de son mur disparaît (on joue l’animation de disparition du mur dès la première frame de l’animation de mort du concurrent)! Pour cela on jouera l’animation Light_Wall_Animations/Disappearing dans Wall.tscn.
- Seule l’animation de course peut être interrompue (pour changer de direction, sauter, etc.) par le joueur. Toutes les autres doivent finir avant d’enchaîner sur autre chose (on parle toujours d’interruption par le joueur, cela ne concerne pas sa mort, par exemple). Par défaut, à la fin d’une animation d’interruption (saut, glissade, etc.), on retourne toujours à la course.
- Passer sur un sens unique qui forcerait à partir un sens inverse fait mourir.
- A propos de spatialisation du son à plus de 2 joueurs humains, mon prendra soin de placer l’AudioListener2D au milieu des joueurs humains. Lorsqu’un joueur humain mourra, le déplacement de l’AudioListener2D à sa nouvelle position se fera à l’aide d’un Tween d’1/2 seconde.

Options (nécessaires) dans Settings:
    1. Taille de la map (de 9 à 21) ✔
    2. Volume sonore général (de 50% à 100%) ✔
    3. Volume de la musique (de 50% à 100%) ✔
    4. Difficulté (de 1 à 5) ✔
        ◦ Temps avant la disparition de l’artefact : (Taille de la map + (2 × Difficulté)) / 10 minutes.
        ◦ Temps avant le déclenchement du processus d’apparition de Door.tscn : (5 + (Difficulté − 1) × 1,25 ) secondes
        ◦ Délai entre les déclenchements d’obstacles : 5.5 - (0,5 × Difficulté) secondes.
        ◦ Délai avant disparition des tronçons de mur : 3 + ((Difficulté + Taille de la map − 10) / 16) × 4 secondes après apparition.
        ◦ /!\ ATTENTION/!\ , il y a un mode de difficulté 6 « caché » (accessible en survivant au moins 4 minutes et 04 secondes en Difficulté 5) qui rend tous les obstacles PERMANENTS (le reste est traîté comme Difficulté 5 si rien n’est précisé !), Y COMPRIS les murs des concurrents.
        ◦ Modifications pour Difficulté 6 dans Settings.tscn :
            ▪ On change Hslider_Difficulty.tick = 6 (au lieu de 5) et Hslider_Difficulty.max = 6 (au lieu de 5)
            ▪ On cache les deux nodes Difficulty_1_5 et on affiche les deux nodes Difficulty_1_6

Les personnalités de base des Bots :
    1. Par défaut, un Bot tendra bien évidemment à éviter les collisions et les chutes. Un Bot essayera également de sortir par la porte lorsqu’elle est présente et accessible. Un bot sait toujours où se trouve la porte de sortie (une fois qu’elle est en place). Seuls les coureurs, light walls, colonnes, trous, pylônes, sens unique à contre-sens et piles de la porte de sortie sont considérés comme des obstacles. Confronté à plusieurs choix face à un obstacle, il décidera aléatoirement quelle solution est choisie (par exe. : face à un trou, on tourne ou on saute ou on utilise son bonus (auto-dodge), etc.). Une cellule avec plus de 2 light walls est évitée (si possible). Un bot n’a pas de raison de changer de direction si rien ne se présente devant lui dans son champs de vision.
    2. Pour former un bot, on combine 3 comportements choisi aléatoirement (1 dans dans chaque catégorie).
    3. Un comportement ne sera donné qu’à 1 seul bot.
    4. Les comportements choisis sont prioritaires par rapport à leurs versions du comportement de base (si ils existent).
    5. On définira des valeurs « par défaut » pour un bot afin de faire varier ces valeurs en fonction du comportement sélectionné.
        ◦ Temps de réaction de base face aux obstacles et imprévus : 300ms. À chaque fois, on variera de +/-10 % (et une fois fait, on revient à 300ms, c’est juste pour ne pas avoir toujours le même temps de réaction).
        ◦ Un bot peut enchaîner au maximum 2 actions en 150ms. Ex. : tourner 2 fois, tourner puis sauter, tourner activer un Bonus, etc.
        ◦ Taille du collider Vision de base : scale à 0,75 en x et y.
        ◦ Un bot affecté par un bug graphique de sa vue caméra a un temps de réaction augmenté de 50ms.
    6. Les malus qui inversent les directions ou les boutons sont aussi valables pour les bots, ce qui signifie qu’ils vont toujours aller à gauche quand il veulent aller à droite (pareil pour saut/glissade). En revanche, ce malus + les comportements « de base » qui agissent sur les directions vont rendre le bot « normal » en se cumulant (même si c’est très temporaire) et c’est très bien comme ça !
    7. Un bot utilisera son Dash à 1 chance sur 2 après obtention et à chaque fois qu’il a fini de l’utiliser à 1 chance sur 2 également.

Comportements additionnels :

    1. Normal : On ne change rien.
    2. Jusqu’au-boutiste : Ne prendra jamais la porte de sortie.
    3. Stupide : Confond les obstacles (1/25 fois saute au lieu de glisser et inversement).
    4. Distrait : ne voit pas l’obstacle devant lui 1/50 fois.
    5. Dyslexique : Confond sa gauche et sa droite 1/25 fois.
    6. Épileptique : Saute à 25% ou glisse à 25%, ou tourne sans raison à 50% (dont 50 % à droite et 50 % à gauche)s’il n’a rien fait de tel depuis 1 à 1,5 secondes.

Comportements face aux Bonus/malus :

    1. Cupide : Fonce sur les bonus/malus dès qu’il en voit un accessible (qu’il en ait déjà un ou pas) dans son détecteur.
    2. Normal : On ne change rien.
    3. Méfiant : Évite les bonus/malus (il peut arriver qu’il en ramasse un si l’éviter signifie mourir).
    4. Monomaniaque : ne vise que les bonus/malus d’une couleur (choisie aléatoirement) dans son détecteur.
    5. Hésitant : Priorise le ramassage ou non d’un bonus dans son détecteur aléatoirement (à 50%).
    6. Conservateur : Ne ramasse un bonus/malus que s’il n’en a pas déjà un.

Comportements de réaction et perception :

    1. Anticipatif : Voit plus loin. On augmente la taille du collider Vision à scale 1,0.
    2. Inconscient : Voit moins loin. On réduit la taille du collider Vision à scale 0,5.
    3. Vif : Temps de réaction réduit de 50ms.
    4. Lent : Temps de réaction augmenté de 50ms.
    5. Empoté : On ajoute 50ms à sa limite d’enchaînement d’actions.
    6. Dextre : On soustrait 50ms à sa limite d’enchaînement d’actions.
    7. Normal : On ne change rien.




Script de déroulement d’une partie (depuis le lancement d’Errore_404.exe)
Il se peut que depuis quelques modifications faites dans le jeu, ce script ne soit plus complètement à jour.

Préambule :
    • À chaque chargement de scène (sauf contre-indication), on joue 1 fois Music/Bang (dans Sounds.tscn).
    • Sauf contre-indication, on ne joue jamais le Bang quand on va jouer Music (car il est intégré dedans).
    • Les sons de validation (Validation) et d’annulation (Cancel) sont dans la scène UI_Sounds.tscn.
    • Par défaut, Intro et Music sont en boucle, pas besoin de le dire dans le code (théoriquement) !
    • En permanence on aura accès au bouton Quit (Quit_Button_tscn) pour quitter le jeu définitivement. 
    • Utilisation des boutons :
        ◦ ui_a_button : Valider et Sauter (A)
        ◦ ui_b_button : Annuler et Glisser (B)
        ◦ ui_x_button : Activer le Bonus/Malus
        ◦ ui_y_button : Affiche la Minimap tant que la pression est maintenue
        ◦ ui_left_button, ui_right_button, ui_up_button et ui_down_button : Direction et navigation menu (en course, on n’utilise que les diagonales)
        ◦ ui_fullscreen : Plein écran/Fenêtré
        ◦ ui_quit_button : Quitter (pression longue, voir Quit_Button.tscn)

Avant le jeu :
    1. Chargement de l’écran titre Title.tscn. L’overlay qui dit de presser un bouton, peu importe lequel, apparaît au bout de qqs secondes si je joueur n’a rien fait jusque là). À partir du démarrage (on commence avec Title.tscn), Music/Intro joue en boucle. Une pression longue sur ui_quit_button fait quitter le jeu et le bouton A amène à…
    2. Transition brutale (sans effet de transition) vers Menu.tscn. À l’ouverture de la scène, on jouera juste Music/Bang (Music/Intro continue de jouer depuis le lancement du jeu). Ici, on navigue avec la manette (haut/bas). On navigue dans le menu avec les direction haut et bas on valide avec A. Et on va directement, en fonction du choix, à…
    3. Transition brutale vers… en fonction du choix :
        ◦ Settings.tscn (sans effet de transition, juste avec le Bang) : encore une fois, à l’ouverture de la scène, on jouera juste Music/Bang (Music/Intro continue donc de jouer). On navigue dans les paramètres avec haut et bas, on change les valeurs avec droite et gauche, on valide avec A. On revient à Menu.tscn avec B. Si on valide sur le premier choix du menu, on lance une partie !
        ◦ Credits.tscn : on revient à Menu.tscn avec B.
        ◦ Tutorial.tscn : on revient à Menu.tscn avec B.
        ◦ Ou…

Le jeu :
    4. Transition brutale vers The_Game.tscn. Les 4 caméras sont centrées sur les 4 coins de la zone de course. L’écran en haut à gauche affiche TOUJOURS en overlay la sélection de joueur (Portraits.tscn) qui commence sur la fille et les 3 autres vues affichent aléatoirement les 3 autres personnages : pas de doublons ! Chaque quart d’écran est numéroté de 1 à 4.
        ◦ La vue en haut à gauche est TOUJOURS la vue du joueur humain.
        ◦ Le joueur partira aléatoirement d’un des 4 coins de la map.
        ◦ Dans la Minimap, le repère des joueurs humains sont bleus alors que les bots sont blancs. Elle n’est accessible qu’en course !
    5. On sélectionne le personnage avec droite et gauche, on valide avec A (et on joue Sounds/UI_Sounds/Validation). Lorsque le joueur change de personnage, à chaque fois, dans les autres quarts d’écran les personnages changent et sont re-sélectionnés aléatoirement. Ils disparaissent/apparaissent en jouant l’animation Animation_Bonus_Malus/Bonus_Malus ET avec le son UI_Sounds/Disappearing (un seul son est joué pour tous). ui_quit_button renvoie à Menu.tscn (transition brutale, pour rappel). Valider fait disparaître l’overlay de sélection des personnages et apparaître le bouton de lancement de la course. Ce bouton ne peut être activé (ui_a_button) que lorsque tous les joueurs humains ont validé leur personnage.
        ◦ Pour ajouter 1 autre joueur humain (ou plusieurs autres), il suffira de presser un des boutons d’un autre contrôleur pour que le quart d’écran suivant lui soit attribué (l’ordre est haut gauche/haut droit/bas gauche/bas droit). Le reste se fait comme pour le premier joueur… Overlay des portraits, etc. Il ne peut pas y avoir de doublons de personnages ! On ne peut plus ajouter de joueur humain quand tous les joueurs humains jusque là déclarés ont validé leurs choix de personnages. C’est seulement à partir de ce moment que le bouton de lancement de la course apparaîtra.
    6. On cache les numéros de quarts d’écran (dans The_Game.tscn) avec l’animation Frames/Black_Frames_And_Numbers/Screen_Numbers/Animation_Numbers/Flashing. Tous les Personnages passent alors en animation Start. Au bout d’1/2 seconde, on joue UI_Sounds/3_2_1 puis on coupe Music/Intro ET on lance UI_Sounds/Go et Music/Music en boucle (sans Music/Bang cette fois-ci car il est inclus dans la musique) et les coureurs (Bot) partent aléatoirement dans l’une des deux directions possibles dans, au plus tard, la 1/2 de seconde qui suit (en faisant en sorte qu’ils ne soient pas synchro) !

Ici, la course elle-même prend place !
Petite note concernant la Minimap : elle s’affiche tant qu’on presse le bouton Y. Quand la minimap est affichée, on joue le son Sounds/UI_Sounds/minimap_Alarm dans Sounds.tscn (qui est par défaut en boucle).

    7. Fin de course (humain ou bot, tant qu’il y a au moins 2 concurrents vivants, la course continu) :
        ◦ Lorsque les concurrents meurent et tant qu’un joueur humain est vivant, pour chaque adversaire mort, on affiche l’Overlay Frames/Bug_0X/Death (X est le numéro de la zone d’écran concernée) et on lance l’animation Blink dans Animation_Overlays (AnimationPlayer), tout ça dans la scène The_Game.tscn. Rappel : s’il ne reste plus qu’un joueur humain, il a automatiquement gagné ! /!\  Il n’y a donc que deux cas : soit le dernier joueur humain perd, soit le premier humain gagne. N’importe quel autre cas amène à l’un de ces deux cas. /!\ 
            a) Lorsque le dernier joueur humain perd, on stoppe le jeu, on coupe les sons, les musiques (même les bus audio sauf Master afin de couper les réverbs et égalisations net), on désactive les glitchs, etc. et on affiche Info_Win_Lose_Overlay/Lose et on joue le son Disconnection et l’animation Blink. Une pression sur « A » relance une partie (avec les mêmes paramètres de jeu, restauration du son, etc.) à partir du point 5 de cette liste et tout autre bouton fait retourner à Menu.tscn (on jouera le Bang, etc.) ! Exceptionnellement, à ce « BSOD », on n’utilise pas Start_Button.tscn ni Quit_Button.tscn !
            b) Lorsqu’un joueur humain gagne (soit parce qu’il est le dernier en course ou soit parce qu’il a franchi la porte de sortie), on affiche Frames/Info_Win_Lose/Win, on joue les animations Writing (qui intègre le son Disconnection) puis lorsque c’est fini Final_Blink en boucle (on laisse le son Disconnection jouer) ! /!\  À l’instant où on a un gagnant : Music/Music va voir son Pitch qui va descendre et pour cela on utilisera l’AnimationPlayer Music_Pitch/Pitch_Down. /!\ 
        ◦ Ensuite, n’importe quel bouton (sauf A) retourne brutalement (toujours) à Menu.tscn. On coupe alors Music/Music et on lance Music/Intro avec Music/Bang. Sinon, presser « A » relance une course avec les mêmes paramètres.
