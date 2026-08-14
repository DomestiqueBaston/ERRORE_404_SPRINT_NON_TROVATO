Errore 404: Sprint Non Trovato! (un jeu qui bugue)

Tentative de description du jeu plus claire :
Une partie oppose toujours 4 concurrents (1 joueur et 3 Bots). Les concurrents courent en permanence, ne peuvent pas s'arrêter et tracent un mur temporaire derrière eux. Le terrain se transforme continuellement (glissements de portions de terrain, cellules qui s'abaissent ou disparaissent, colonnes, etc.), modifiant les trajets possibles pendant toute la course. Des Bonus/Malus apparaissent régulièrement ; chaque couleur est associée à un Bonus et à un Malus, le joueur ne sait donc jamais lequel il ramasse. Des "bugs" viennent également perturber l'affichage pendant la partie. La course prend fin lorsqu'il ne reste plus qu'un seul concurrent vivant ou lorsqu'un concurrent passe la porte de sortie que celle-ci est apparue.


- Ce « Runner » va se « rapprocher » de la (fameuse) séquence de course de moto dans Tron (1982) qu’on va mélanger avec un peu du film Cube (les connexions entre les salles changent régulièrement comme un Rubik’s Cube).

- Un jeu en 2D (vue isométrique).
- Un champ de course qui sera carré au départ et deviendra « plus du tout carré » par les transformations successives.
- Le champ de course se structurera sous forme de grille dont les lignes et colonnes (complètes, même s’il y a des trous dans une ligne/colonne) vont être poussées ou tirées par le jeu transformant ainsi le terrain en permanence.
- Des cases s’élèveront et/ou se baisseront également.
- L’aire de course sera composée, au choix du joueur, de base de 9x9 à 21x21 (uniquement impaires pour avoir la case « 404 » au centre) cellules de terrain (ou plus ?).
- Un jeu pour 1 joueur mais il y aura toujours 4 concurrents en piste. Les 3  concurrents non-humains seront pris en charge par l’IA (Bots). Il y a toujours 2 hommes et 2 femmes en course.
- L’écran est divisé en 4 avec les vues de chaque concurrent. Le joueur sera toujours dans le quart supérieur gauche.
- À chaque fois que le jeu va bouger une ligne/colonne ou baisser un pylône (qui n’écrase pas et laisse passer dessous) ou baisser une cellule ou lâcher un pylône ou faire disparaître une cellule, une alarme (Cell_Pylon_Alarms/ dans Sounds.tscn) se fera d’abord entendre pendant 1’’ ET jusqu’à la fin de l’animation (sauf exceptions).
- Une cellule baissée ou disparue ou un pylône (baissé ou arrivé au sol) reste dans cette position 10 à 20’’. S’il font partie d’une ligne/colonne qui glisse pendant qu’ils sont dans l’état évoqué ici, alors ils suivent le mouvement de la ligne/colonne.
- On ne fait pas tomber/descendre de pylône sur une cellule disparue ou descendue.
- Dès le début, sur le terrain, au centre, la cellule 404 est levée. C’est sur cette case, une fois la cellule redescendue au bout de (Taille de la map + (2 × Difficulté)) / 10 minutes qu’apparaîtra la porte de sortie de la zone. Une fois la cellule centrale 404 descendue, la porte de sortie apparaîtra au bout de (2 × Difficulté) secondes. Il pourra malgré tout arriver que la porte ne soit plus accessible à cause de mouvements de terrain.
- La case centrale 404 ne subit QUE des glissements (pas de bug, de disparition, de pylone, etc.).
- Pour les concurrents, 4 directions de mouvement (les diagonales).
- Les concurrents ne peuvent pas faire directement demi-tour (à cause du mur qu’ils tracent).
- Les concurrents ne peuvent tourner qu’à 90°.
- Les concurrents ne peuvent pas arrêter de courir !
- Ils tracent un mur temporaire derrière eux (qui s’efface au fur et à mesure par tronçons en fonction du niveau de difficulté et de la taille de la map – voir plus loin).
- Un tronçon de mur est la partie du mur sur une case du terrain.
- Le but du jeu est de tenir le plus longtemps possible et être le dernier survivant ou être le premier à passer la porte de sortie.

Un runner bugué :
-  Chaque vue de concurrent a un timer de bug indépendant des autres vues.
- Les bugs durent de 5’’ en difficulté 1 à 20’’ en difficulté 5.
- Après chaque bug, on attend 10’’ en difficulté 1 à  5’’ en difficulté 5 avant d’avoir 1/5 chance d’en déclencher un nouveau.
- Au lancement des bugs, on joue le son Frames/Bug_Sound (dans The_Game.tscn) et on le coupe à la fin du bug. Pas d’intro/outro, effets directs !
    1. L’image globale se décale dans la vue du joueur (la caméra se centre sur le joueur) → Ça se fait : ✔
    2. La palette de couleurs change → ✔
    3. Image floue → Ça se fait : ✔
    4. La caméra vibre → ✔
    5. Couleurs inversées → ✔
    6. Sur-pixelisation → ✔
    7. Jpeg →  ✔

- Bug permanent : toutes les 3 à 5’’ (on ne joue pas Frames/Bug_Sound mais Sound/Flashing_Cell dans Cell.tscn) :
    1. Texture de sol change (sauf les 4 cases de coins et la case 404) – (permanent)→ ✔

Les bonus et malus en jeu (Cube.tscn) :
- En jeu, il n’y aura que 2 exemplaires max. de chaque Bonus/Malus (y compris en possession d’un joueur).
- Chaque concurrent ne peut porter qu’1 Bonus/Malus. On peut ramasser un Bonus/Malus si on en porte déjà un mais le nouveau remplace le précédent. On ne peut pas ramasser de nouveau Bonus/Malus tant qu’un est en cours d’utilisation.
- Les Bonus/Malus apparaissent en jeu toutes les 5 à 10 secondes.
- Il ne peut pas y avoir plus de 5 Bonus/Malus simultanément à ramasser → le 6ème supprime d’abord automatiquement le plus ancien restant pendant qu’il apparaît.
- Pour chaque couleur correspondent un bonus et un malus (le joueur ne sait donc pas s’il voit un bonus ou un malus).
- Au ramassage d’un Bonus/Malus, on joue le son correspondant au Bonus/Malus et on joue le clignotement du concurrent (Animation_Bonus_Malus).
- À l’activation (automatique ou au déclenchement du joueur) du Bonus/Malus on joue également le son correspondant et on joue le clignotement du concurrent.
- Si le ramassage et l’activation se font en même temps, on ne joue qu’une fois le son correspondant et pareil pour le clignotement du concurrent.

Les bonus :
    1. Invulnérabilité – Rouge (annule le prochain malus récolté) – dure (5 ÷ difficulté)’’ → ✔ Invincible – Automatique !
    2. Dash – Vert (course uniquement – dure 1/2’’ – ne peut pas être interrompu ET virage impossible !) : 66% plus rapide (animation aussi). → ✔ Dash – Activable !
    3. Passe-muraille – Bleu (uniquement les murs des concurrents) – 1 seul mur → ✔ Through – Automatique !
    4. Virus – Violet (envoie automatiquement le prochain malus récolté à un adversaire aléatoire) → ✔ Virus – Automatique !
    5. Téléportation – Jaune (destination aléatoire sur une « cellule saine »)→ ✔ Teleport – Activable !
    6. Débogueur – Noir (vire un bug actif)→ ✔ Debug – Activable !
    7. Les murs tracés jusqu’à présent par les concurrents disparaissent – Blanc → ✔ Last_Longer – Automatique !

Les malus (applications automatiques) :
    1. Inversion de commandes – Rouge – dure (difficulté)’’ → ✔ Invert
    2. Lenteur de réaction (on ajoute un délai d’1/10’’ (à préciser) dans les commandes du concurrent) – Noir – dure (2 × difficulté)’’ → ✔ Slow
    3. Les murs tracés par les concurrents durent plus longtemps – Blanc – (durée des tronçons de mur × 2) → ✔ Last_Shorter – Au bout de (durée des tronçons de mur × 1), l’effet du malus disparaît et la durée de vie normale de chaque tronçon reprend sa valeur normale et tous les tronçons qui ont vécu ce temps ou plus disparaissent !
    4. Course, saut et glissade : 4% plus lent (animation aussi et le tout avec un tween d’1 seconde) – Vert – dure ((2 × difficulté) + 3)’’ → ✔ Anti_Dash
    5. « Hors phase » (shader) – Bleu – dure (2 × difficulté)’’ → ✔ Phase
    6. Virus (envoie automatiquement le prochain Bonus (pas malus) récolté à un adversaire aléatoire, quitte à remplacer celui qu’il porte – Violet → ✔ Anti_Virus
    7. Téléportation (instantané et destination aléatoire) – Jaune → ✔ Anti_Teleport

Les obstacles :
- Toutes les X secondes (voir Options nécessaires dans Settings) un des obstacles est déclenché. 25% du temps, il s’agira d’1 glissement de Ligne/Colonne. La « quantité » de glissement des Ligne/Colonne se font aléatoirement d’1 à (longueur d’un côté au départ/3) cases (pour ne pas dire cellule qui pourrait être perturbant). On fait TOUJOURS glisser une ligne/colonne complète (« trous » inclus).
    1. Ligne/Colonne (de cellules) qui glisse – Permanent → ✔ (1’’ avant, on joue Cell_Pylon_Alarms/Cell_Slide dans Sounds.tscn ET jusqu’à la fin de l’animation)
    2. Trous (cellules qui descendent) – 5’’ en difficulté 1 à 20’’ en difficulté 5 → ✔
    3. Murs des concurrents – (Durée : comme précisé plus loin) → ✔ (voir avec Geoff comment faire)
    4. Sens unique – 5’’ en difficulté 1 à 20’’ en difficulté 5 → ✔ /!\ATTENTION/!\  c’est le collider du panneau qui fait changer de direction, pas la cellule elle-même !
    5. Colonne descendante – 5’’ en difficulté 1 à 20’’ en difficulté 5 → ✔
    6. Colonne écrasante – 5’’ en difficulté 1 à 20’’ en difficulté 5 → ✔
    7. Cellule « disparaissante » – 5’’ en difficulté 1 à 20’’ en difficulté 5 → ✔
    8. 1 Cellule hors phase – 5’’ en difficulté 1 à 20’’ en difficulté 5 → ✔ (Screen_Glitch : Fait tourner à droite ou Glitch_Only : fait tourner à gauche)

Liste des animations des personnages :
    1. Courir ✔ ✔ ✔ ✔
    2. Sauter ✔ ✔ ✔ ✔
    3. Glissade ✔ ✔ ✔ ✔
    4. Pose de départ ✔ ✔ ✔ ✔
    5. Intro ✔ ✔ ✔ ✔
    6. Tomber dans le vide → Mort ! ✔ ✔ ✔ ✔
    7. Bim ! Dans un mur → Mort ! ✔ ✔ ✔ ✔

Notes de fabrication :
- Au lancement du jeu, la musique qui joue en boucle en permanence, c’est Intro. Jusqu’au moment dans le jeu proprement dit où le Départ est donné. À cet instant précis, on passe à Music (en boucle). Music ne s’arrête qu’en finissant la partie (soit en relançant une nouvelle partie directement soit en retournant à l’écran de Titre. Au moment de lancer à nouveau Intro, il faudra jouer une fois le son Bang tout en démarrant en même temps Intro.
- /!\ ATTENTION /!\ On ne joue jamais Bang au lancement de Music car il est intégré dans la musique.
- /!\ ATTENTION /!\  Il est fort probable que pas mal de sons ne soient au final pas utilisés car inaudibles et/ou inutiles et/ou trop pénibles à entendre en permanence. Je pense à la respiration des concurrents qui courent, le « hum » des light walls ou ce genre de chose qui existent en plusieurs exemplaires (il y a 4 concurrents!) en jeu.
- Sauf pendant la sélection de joueur, par défaut, la caméra de chaque joueur ne montre pas le joueur centré mais se décale afin d’avoir plus de visibilité devant le joueur en fonction de la direction dans laquelle il court. On utilisera systématiquement un tween d’1/4 de seconde pour déplacer la caméra. Au démarrage de la course, dès la première frame de course, la caméra rejoindra sa place avec le tween décrit précédemment.
    • Position de caméra par défaut par rapport au root d’un coureur : px = -240, py = -170 (afin de centrer le personnage visuellement dans la caméra). Animations concernées : Intro, Start, Death et Falling.
    • Position de caméra par rapport au root d’un concurrent tourné vers le bas à droite : px = -120, py = -110.
    • Position de caméra par rapport au root d’un concurrent tourné vers le bas à gauche : px = -360, py = -110.
    • Position de caméra par rapport au root d’un concurrent tourné vers le haut à gauche : px = -360, py = -230.
    • Position de caméra par rapport au root d’un concurrent tourné vers le haut à droite : px = -120, py = -230.
- Le mur tracé derrière un concurrent lorsqu’il se déplace est Light_Wall.tscn. À chaque entrée d’un concurrent sur une Cell ou virage, on commence le tracé d’un nouveau Light_Wall.tscn qui sera raccord avec le précédent. Lorsqu’un concurrent quitte une Cell ou fait un virage sur une Cell, on coupe le précédent Light_Wall.tscn et on en commence un autre raccord également. On ne trace pas de Light_Wall.tscn lorsqu’un concurrent fait autre chose que courir, sauter (sauf lorsqu’il saute au dessus d’un trou) ou glisser.
- Au démarrage de chaque concurrent (lorsqu’il commence à courir), on joue l’animation Light_Wall_Animations/Appearing dans Light_Wall.tscn pour commencer son mur. On joue également Light_Wall_Sounds/Wall_Hum en boucle (jusqu’à ce que le mur disparaissent complètement).
- À la mort d’un concurrent, lorsque son mur disparaît, joue l’animation Light_Wall_Animations/Disappearing dans Light_Wall.tscn.
- À la fin de l’animation de mort d’un concurrent (Death) et que son mur aussi a disparu, on joue l’animation Animation_Disappearing_Death/Disappearing du concurrent afin de faire disparaître son cadavre (c’est dommage mais le laisser, ça risque de trop compliquer les choses).
- Lorsqu’un concurrent traverse une case (donc en traçant son mur) et que la cellule bouge (glissement), alors le concurrent se décale AVEC la cellule. Et le mur qu’il trace également afin que le morceau de mur sur la cellule puisse se déplacer avec la case si celle-ci est amenée à se déplacer de nouveau.
- Cas particuliers de mort de concurrent : il existe une animation alternative, un AnimationPlayer avec une animation « toute bête » pour ces cas-là (Animation_Disappearing_Death/Disappearing). Si par exemple se présente un cas avec deux colonnes baissées et que le concurrent veut passer dessous à vitesse normale, il ne pourra pas (distance trop grande pour un slide), mourra donc et on utilisera cette animation. Écrasé par une colonne, ce sera pareil ! Etc.
- Un concurrent ne peut pas courir sur un autre cadavre → Le jeu forcera le concurrent à tourner aléatoirement à droite ou à gauche. On jouera ici aussi l’Animation_Bonus_Malus et le son Alert. Si le concurrent se retrouve coincé entre des cadavres et/ou d’autres concurrents (vraiment super pas de bol), alors on le fera mourir en jouant son animation de mort à lui aussi (Animation_Disappearing_Death/Disappearing) ! Ça ne sera pas très « joli » mais c’est un cas vraiment peu probable.
- À la mort d’un concurrent, ce qui reste de son mur disparaît (on joue l’animation de disparition du mur dès la première frame de l’animation de mort du concurrent)! Pour cela on jouera l’animation Light_Wall_Animations/Disappearing dans Light_Wall.tscn.
- Seule l’animation de course peut être interrompue (pour changer de direction, sauter, etc.) par le joueur. Toutes les autres doivent finir avant d’enchaîner sur autre chose (on parle toujours d’interruption par le joueur, cela ne concerne pas sa mort, par exemple). Par défaut, à la fin d’une animation d’interruption (saut, glissade, etc.), on retourne toujours à la course.
- Toutes les 10 à 20’’, chaque coureur va gagner/perdre 4% de vitesse. Et toutes les 10 à 20’’ perdre/récupérer ces 4% de vitesse. Les animations seront également accélérées et ralenties de la même proportion pour que ce soit plus « joli ». On utilisera également un tween d’1/2 seconde pour appliquer la modification (si possible). Chaque concurrent à un timer personnel indépendant de celui des autres.
- Passer sur un sens unique qui forcerait à partir un sens inverse fait mourir.

Options (nécessaires) dans Settings:
    1. Taille de la map (de 9 à 21) ✔
    2. Volume sonore général (de 50% à 100%) ✔
    3. Volume de la musique (de 50% à 100%) ✔
    4. Difficulté (de 1 à 5) ✔
        ◦ Temps avant l’apparition de la porte de sortie : (Taille de la map + (2 × Difficulté)) / 10 minutes.
        ◦ Délai entre les déclenchements d’obstacles : 5.5 - (0.5 × Difficulté) secondes.
        ◦ Délai avant disparition des tronçons de mur : (Difficulté + Taille de la map) / 2 secondes après apparition.
        ◦ /!\ ATTENTION/!\ , il y a un mode de difficulté 6 « caché » (accessible en gagnant 3 courses en Difficulté 5) qui rend tous les obstacles PERMANENTS (le reste est traîté comme Difficulté 5 si rien n’est précisé !) SAUF les murs des concurrents. Voir également à la fin du doc. : Liste des scènes (et – succinctes – descriptions de leurs contenus).

Les personnalités des « IA »/Bots :
    1. Par défaut, un Bot tendra bien évidemment à ne pas mourir en évitant les collisions et les chutes. Un Bot essayera également de sortir par la porte lorsqu’elle est présente et accessible (il peut arriver qu’elle ne le soit pas à cause des glissements de lignes/colonnes).
    2. On définira des valeurs « par défaut » pour un bot afin de faire varier ces valeurs en fonction du comportement sélectionné.
        ◦ Un passage de moins d1/2 case de large n’est pas emprunté par un bot (quitte à en mourir).
        ◦ Temps de réaction de base : 300ms (surlignés en jaune : pas concerné).
    3. Pour former un bot, on combine 3 comportements choisi aléatoirement (1 dans dans chaque catégorie).

Comportements face aux obstacles :

    1. Anticipatif : Voit plus loin.
    2. Fuyant : S’éloigne des concurrents (tout concurrent dans son détecteur poussera ce coureur à partir en direction opposée).
    3. Téméraire : Tente des passage plus étroits (moins d’1/2 case de large mais moins d’1/3).
    4. Agressif : Essaye de bloquer les concurrents (avec son mur).

Comportements face aux Bonus/malus :

    1. Cupide : Fonce sur les bonus/malus (dès qu’il en voit un accessible dans son détecteur, il devient son objectif).
    2. Sélectif : Ne ramasse que les bonus/malus à 1 case de lui.
    3. Méfiant : Évite les bonus/malus autant que possible.
    4. Hésitant : Priorise le ramassage ou non d’un bonus aléatoirement (à 50%).

Comportements face aux bugs du jeu (continuer tout droit, tourner et/ou utiliser un bonus – pas d’autre option pour le moment, il me semble) :

    1. Prudent : Réagit plus tôt (si possible) face aux obstacles.
    2. Inconscient : Collider de vision plus court.
    3. Panique : Réaction totalement aléatoire face à un obstacle.
    4. Maladroit : Confond les obstacles (1/5 fois saute au lieu de glisser, tourne à droite au lieu de tourner à gauche, etc.).
Script de déroulement d’une partie (depuis le lancement d’Errore_404.exe)

Préambule :
    • À chaque chargement de scène (sauf contre-indication), on joue 1 fois Music/Bang (dans Sounds.tscn).
    • Sauf contre-indication, on ne joue jamais le Bang quand on va jouer Music (car il est intégré dedans).
    • Les sons de validation (Validation) et d’annulation (Cancel) sont dans la scène UI_Sounds.tscn.
    • Par défaut, Intro et Music sont en boucle, pas besoin de le dire dans le code (théoriquement) !
    • En permanence on aura accès au bouton Quit (Quit_Button_tscn) pour quitter le jeu définitivement. 
    • Utilisation des boutons :
        ◦ ui_a_button : Valider et Sauter (A)
        ◦ ui_b_button : Annuler et Glisser (B)
        ◦ ui_x_button ou ui_y_button : Activer le Bonus/Malus
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
    4. Transition brutale vers The_Game.tscn. Les 4 caméras sont centrées sur les 4 coins de la zone de course. L’écran en haut à gauche affiche en overlay la sélection de joueur (Portraits.tscn) qui commence sur la fille et les 3 autres vues affichent aléatoirement les 3 autres personnages : pas de doublons !
    5. On sélectionne le personnage avec droite et gauche, on valide avec A. Lorsque le joueur change de personnage, à chaque fois, dans les autres quarts d’écran les personnages changent et sont re-sélectionnés aléatoirement. Ils disparaissent/apparaissent en jouant l’animation Animation_Bonus_Malus/Bonus_Malus ET avec le son UI_Sounds/Disappearing (un seul son est joué pour tous). ui_quit_button renvoie à Menu.tscn (transition brutale, pour rappel). Valider fait disparaître l’overlay de sélection des personnages et apparaître le bouton de lancement de la course. Ce bouton ne peut être activé (ui_a_button) que lorsque le joueur a validé son personnage.
        ◦ Ceci est pour la cas où il n’y aurait qu’1 joueur humain et 3 bots mais pour ajouter 1 autre (ou plusieurs autres) joueur humain, il suffira de presser un des boutons d’un autre contrôleur pour que le quart d’écran suivant lui soit attribué. Le reste se fait comme pour le premier joueur… Overlay des portraits, etc. Il ne peut pas avoir de doublons de personnage ! On ne peut plus ajouter de joueur quand il n’y a plus d’overlay de sélection de personnage. C’est seulement à partir du moment ou tous les joueurs (humains) on validé leur choix de personnage que le bouton de lancement de la course apparaîtra.
    6. Tous les Personnages passent alors en animation Start. Au bout d’1/2 seconde, on joue UI_Sounds/3_2_1 puis on coupe Music/Intro, on lance UI_Sounds/Go et Music/Music en boucle (sans Music/Bang cette fois-ci car il est inclus dans la musique) et les coureurs (Bot) partent aléatoirement dans l’une des deux directions qu’il ont de possible dans, au plus tard, la 1/2 de seconde qui suit ! Au pire, 1 seconde après le « top départ », tous les concurrents restants partiront automatiquement avec un décalage de 1/5 de seconde les uns des autres pasque tous synchros, c’est pas joli.

Ici, la course elle-même prend place !

    7. Fin de course (humain ou bot, tant qu’il y a au moins 2 concurrents vivants, la course continu) :
        ◦ Lorsque les concurrents meurent et tant que le joueur humain est vivant, pour chaque bot mort, on affiche l’Overlay Frames/Bug_0X/Death (X est le numéro de la zone d’écran concernée) et on lance l’animation Blink dans Animation_Overlays (AnimationPlayer), tout ça dans la scène The_Game.tscn. À noter : il n’y en a pas pour le joueur humain en haut à gauche.
            a) Lorsque le joueur perd, on stoppe le jeu, on coupe les sons, les musiques (même les bus audio sauf Master afin de couper les réverbs et égalisations net), on désactive les glitchs, etc. et on affiche Info_Win_Lose_Overlay/Lose et on joue le son Disconnection et l’animation Blink. Une pression sur « A » relance une partie (avec les mêmes paramètres de jeu, restauration du son, etc.) à partir du point 5 de cette liste et tout autre bouton fait retourner à Menu.tscn (on jouera le Bang, etc.) ! Exceptionnellement, à ce « BSOD », on n’utilise pas Start_Button.tscn ni Quit_Button.tscn !
            b) Lorsque le joueur gagne (soit parce qu’il est le dernier en course ou soit parce qu’il a franchi la porte de sortie), on affiche Frames/Info_Win_Lose/Win, on joue les animations Writing (qui intègre le son Disconnection) puis lorsque c’est fini Final_Blink en boucle (on laisse le son Disconnection jouer) ! /!\ À l’instant où on a un gagnant : Music/Music va voir son Pitch qui va descendre et pour cela on utilisera l’AnimationPlayer Music_Pitch/Pitch_Down. /!\ 
        ◦ Ensuite, n’importe quel bouton (sauf A) retourne brutalement (toujours) à Menu.tscn. On coupe alors Music/Music et on lance Music/Intro avec Music/Bang. Presser A relance une course avec les mêmes paramètres.
Liste des scènes (et – succinctes – descriptions de leurs contenus) :
    1. Cell.tscn : contient toutes les cellules de sol, contient également les modificateurs de sens de passage One_Way_Direction (voir Un runner bugué #5), les 2 glitchs de surface Top_Cell_FX_Mask (voir Un runner bugué #6) et les points de départ des 4 concurrents (qu’on n’applique qu’aux 4 coins du terrain).
    2. Credits.tscn : contient la scène de générique du jeu (intègre également le bouton pour quitter le jeu).
    3. Cube.tscn : contient les bonus/malus à ramasser en course.
    4. Door.tscn : contient la porte de sortie du jeu. La porte est scindée en 2 couches (l’avant et l’arrière pour que les concurrents puisse la franchir puisqu’elle ressemble à une arche).
    5. The_Game.tscn : il s’agit de la scène (théorique) de composition du jeu avec ses 4 vues, ses layers de glitch, etc. (intègre également le bouton pour quitter le jeu ET le bouton pour lancer la course).
    6. Light_Wall.tscn : contient le (prototype de) mur que tracent les concurrents en courant. Inclus un AnimationPlayer qui sert de démo pour voir à quoi ça doit ressembler. Les sons se trouvent dans Sounds.tscn.
    7. Man_A.tscn, Man_B.tscn, Woman_A.tscn et Woman_B.tscn : contiennent les 4 concurrents du jeu.
    8. Menu.tscn : contient le menu principal du jeu (intègre également le bouton pour quitter le jeu).
    9. Music.tscn : contient les musiques du jeu (et le « bang » nécessaire à certaines transitions entre musiques).
    10. Portraits.tscn : contient le sélecteur de concurrent pour le joueur (humain).
    11. Pylon.tscn : contient les pylônes qui tombent et qui peuvent écraser les concurrents (voir Les obstacles #6).
    12. Quit_Button.tscn : contient le bouton pour quitter le jeu.
    13. Settings.tscn* : contient la scène permettant de régler la taille du terrain de course, la difficulté du jeu, le volume général du son du jeu et le volume de la musique (intègre également le bouton pour quitter le jeu).
    14. Sounds.tscn : contient les sons de l’UI du jeu, les musiques du jeu (et le « bang » nécessaire à certaines transitions entre musiques ainsi que Win_Glitchy_Sound pour le son ralenti de victoire) et les alarmes de Cellules/Pylones/Colonnes-Lignes de cellules.
    15. Start_Button.tscn : contient le bouton pour démarrer la course.
    16. Tutorial.tscn : contient la scène qui dit comment jouer (intègre également le bouton pour quitter le jeu).
Dans le dossier TMP, on trouve (dossier à supprimer ultérieurement) :
    1. Test_Split_Screen.tscn : contient une maquette (très rough) montrant à quoi ressemble le jeu lui-même. Cette scène m’a surtout servi à tester les animations des concurrents, faire des mises en place… C’est pour ça que les 4 personnages sont regroupés et bougent tous avec une seule manette.

* Dans Settings, pour Difficulté 6, on passe :
    1. Hslider_Difficulty.tick = 6 (au lieu de 5)
    2. Hslider_Difficulty.max = 6 (au lieu de 5)
    3. On cache les deux Difficulty_1_5
    4. On affiche les deux Difficulty_1_6
