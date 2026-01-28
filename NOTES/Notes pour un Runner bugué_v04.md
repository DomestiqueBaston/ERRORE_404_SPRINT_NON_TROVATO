PIXEL ART V

Errore 404: Sprint Non Trovato!

Un jeu basé sur les bugs (se souvenir du site e13.com)
Pour le moment, on part pour de la 2D !

Un runner à pied (étonnant !)

Ce « Runner » va se « rapprocher » de la (fameuse) séquence de course de moto dans Tron (1982) qu’on va mélanger avec un peu du film Cube.

Un espace de course qui sera carré au départ et deviendra « plus du tout carré » avec les transformations ultérieures.
Le champs de course se structurera sous forme de grille dont les lignes et colonnes (complètes, pas des tronçons) vont être poussées ou tirées par le jeu transformant ainsi le terrain en permanence.
Des cases s’élèveront ou se baisseront également.
L’aire de course sera composée de base de 9x9 à 21x21 (uniquement impaires) cellules de terrain (ou plus ?). Impaires pour avoir la case 404 au centre.
Au départ, les joueurs auront la possibilité de choisir la taille de l’aire dans laquelle ils veulent courir.
À chaque fois que le jeu va bouger une ligne/colonne (complète, donc!), une alarme se fera entendre.
Sur le terrain, au centre, une case est levée (colonne verticale, cette fois). C’est sur cette case, une fois la colonne redescendue qu’apparaîtra la porte de sortie de la zone au bout de 14 secondes + Difficulté (de 1 à 5).
Un jeu pour 1 à 4. Il y aura toujours 4 concurrents en piste. Quel que soit le nombres de joueurs humains, les concurrents manquants seront pris en charge par l’IA (Bots).
Pour les coureurs, 4 directions de mouvement (les diagonales).
Les joueurs ne peuvent pas faire directement demi-tour (à cause du mur qu’ils tracent).
Les joueurs ne peuvent tourner qu’à 90°.
Les joueurs ne peuvent pas arrêter de courir ! S’arrêter → mort !
Les joueurs peuvent stocker jusqu’à 2 bonus.
Ils tracent un mur temporaire derrière eux (s’efface au fur et à mesure après 10 secondes – à préciser plus tard).


Le but du jeu est ici de tenir le plus longtemps possible et être le dernier survivant ou éventuellement être le premier à atteindre la sortie qui se manifestera aléatoirement au bout d’un certain temps.

Un runner bugué :
    1. Téléportation
    2. Joueur « hors phase » (shader) ✔ 
    3. Décors ou cellules de décor « hors phase » (shader) ✔ (bonus/malus?)
    4. Plus aucune musique/bug de la musique
    5. Plus aucun bruitages/bug des bruitages
    6. Son(s) chiant(s) qui dure(nt)...
    7. Le jeu prend le contrôle du joueur et donne le sien au joueur
    8. Des éléments de décor disparaissent/apparaissent ✔

Des bugs (graphiques) qui font vraiment bug :
    1. Les sprites se mélangent (?) (changer des frames à la volée dans les cycles de course) → Ça se fait : ✔
    2. Les textures de sol changent → Ça se fait (tween?) : ✔
    3. La palette de couleurs change ✔ 
    4. Des artefacts graphiques : des carrés blancs sur les cellules dans le plan de la caméra → Ça se fait : ✔
    5. Des glitches sonores ✔
    6. L’image globale se décale dans la vue du joueur (la caméra se décentre du joueur) → Ça se fait : ✔
    7. La caméra vibre ✔
    8. Des messages d’erreur apparaissent masquant une partie de l'écran : ✔
    9. Couleurs inversées ✔ 
    10. Sur-pixelisation ✔ 

Les bonus et malus en jeu :
- Il n’y a que 2 exemplaires de chaque Bonus/Malus (y compris en possession d’un joueur).
- Les Bonus/Malus apparaissent en jeu toutes les 10 secondes.
- Il ne peut pas y avoir plus de 5 Bonus/Malus simultanément à ramasser → le 6ème supprime d’abord automatiquement le plus ancien restant et apparaît 1’’ après.
- Ils ont une couleur aléatoire en jeu (voir Cube.gd). Avec la couleur par défaut, ce sera toujours un Bonus.
- Au ramassage d’un Bonus/Malus, on joue le son correspondant et on joue le clignotement du coureur (Animation_Bonus_Malus).
- À l’activation (automatique ou au déclenchement du joueur) on joue également le son correspondant et on joue le clignotement du coureur.
- Si le ramassage et l’activation se font en même temps, on ne joue qu’une fois le son correspondant et le clignotement du coureur.

Les bonus :
    1. Invulnérabilité (à quoi?) → ✔ Invincible
    2. Freeze adversaire aléatoire (exceptionnellement ≠ mort !)
    3. Dash (permet de parcourir 2 cases dans le temps d’1) : 4% plus rapide. → ✔ Dash
    4. Passe-muraille (uniquement les murs des coureurs) → ✔ Through
    5. Virus (envoie automatiquement le prochain malus récolté à un adversaire aléatoire) → ✔ Virus
    6. Téléportation (destination aléatoire)→ ✔ Teleport
    7. Débogueur (vire un bug actif)→ ✔ Debug
    8. Les murs tracés par le joueur durent 1.5 fois plus longtemps.→ ✔ Last_Longer

Les malus :
    1. Inversion de commandes (droite/gauche) → ✔ Invert
    2. Lenteur de réaction (on ajoute un délai d’1/10’’ (à préciser) dans les commandes des joueurs) → ✔ Slow
    3. Les murs tracés par le joueur durent 2 fois moins longtemps → ✔ Last_Shorter
    4. Course, saut et glissade : 4% plus lent → ✔ Anti_Dash
    5. Rien ! → ✔ Empty
    6. Virus (envoie automatiquement le prochain Bonus récolté à un adversaire aléatoire) → ✔ Anti_Virus
    7. Téléportation (le joueur ne choisit pas le moment de l’activation et destination aléatoire)

Les obstacles :
Toutes les X secondes (voir Options à proposer au joueur dans Settings) un des obstacles est déclenché. 1 sur 4 est un glissement de Ligne/Colonne.
    1. Ligne/Colonne (de cellules) qui glisse d’1 à 2 cases → ✔
    2. Trous (cellules qui descendent) → ✔
    3. Murs des coureurs → ✔ (voir avec Geoff comment faire)
    4. Cellule à sens unique → ✔
    5. Colonnes tombantes → ✔
    6. Dalles disparaissant → Cellules qui disparaissent ✔

Liste des animations des personnages :
    1. Courir ✔ ✔
    2. Sauter ✔ ✔
    3. Glissade ✔ ✔
    4. Pose de départ ✔ ✔
    5. Intro ✔ ✔
    6. Tomber dans le vide → Mort ! ✔ ✔
    7. Bim ! Dans un mur → Mort ! ✔ ✔

Notes de fabrication :
SON :
- Au lancement du jeu, la musique qui joue en boucle en permanence, c’est Intro. Jusqu’au moment où le Départ est donné. À cet instant précis, on passe à Music (en boucle). Music ne s’arrête qu’en finissant la partie (soit en relançant une nouvelle partie directement soit en retournant à l’écran de Titre (ou de Settings, je ne sais pas encore présentement). Au moment de lancer à nouveau Intro, il faudra jouer une fois démarrant en même temps qu’Intro le song Bang.
JEU :
- Lorsqu’un coureur traverse une case (donc en traçant son mur) et que la case bouge, alors le coureur se décale AVEC la case. Et le mur qu’il trace également. Il faudra donc « tronçonner » les murs à chaque fois qu’un coureur sort d’une case afin que le morceau de mur puisse éventuellement se déplacer avec la case si celle-ci est amenée à se déplacer de nouveau.
- Cas particuliers de mort : il existe un AnimationPlayer avec une animation « toute bête » pour ces cas-là (Animation_Disappearing_Death). Si par exemple se présent un cas avec deux colonnes baissées et que le joueur veut passer dessous à vitesse normale, il ne pourra pas et mourra donc et on utilisera cette animation. Écrasé par une colonne, pareil ! Etc.

Options à proposer au joueur dans Settings:
- Taille de la map ✔
- Volume sonore général ✔
- Volume de la musique ✔
- Difficulté ✔ :
    • Temps avant l’apparition de la porte de sortie : (Taille de la map + (3 × Difficulté)) / 4 en minutes
    • Délai entre les déclenchements d’obstacles : 5.5’’ - (0.5 × Difficulté)  en secondes



	
Les personnalités des « IA »/Bots :

Comportements face aux obstacles :

    1. Survivaliste : Évite de se faire coincer (par les murs des adversaires, les vides et murs/colonnes), se concentre sur sa route et bloque les autres coureurs.
    2. Idiot : Comporte de manière aléatoire.
    3. Peureux : Va là où il y a le moins de monde et d’obstacles (murs des coureurs, vides et murs/colonnes).

Comportements face aux Bonus/malus – Part 1 :

    1. Agressif : Fonce sur les bonus. S’il est "mineur", il s'en débarrasse immédiatement, sinon il le garde pour plus tard ou pour empêcher un autre joueur de le prendre.
    2. Aléatoire : Utilise n'importe quand ses bonus/malus sans logique.
    3. Prudent : Évite les bonus/malus autant que possible car il a peur des malus.
Comportements face aux Bonus/Malus – Part 2 :

    1. Conservateur : Privilégie les Bonus/Malus pour soi (tend à rejeter vite les autres).
    2. Belliqueux : Privilégie les Bonus/Malus contre les autres (tend à rejeter vite les autres).
    3. Indifférent : Ne privilégie rien en particulier et tire avantage de ce qu’il a.

Comportements face aux bugs du jeu (continuer tout droit, tourner ou utiliser un bonus – pas d’autre option pour le moment, il me semble) :

    1. Prudent : réfléchit plus tôt (si possible) face aux obstacles et réagit plus tôt.
    2. Inconscient : réagit avec les mêmes délais impliquant qu’1 fois sur 3 il fera un choix différent de celui qu’il aurait fait sans bug.
    3. Suicidaire (tricheur) : face à un obstacle fera un choix aléatoire ! 1 fois sur 3, si cela le condamne à mourir, alors il ne mourra pas en évitant l’obstacle ou utilisant un bonus « inventé » qu’il n’avait pas.

Une autre vue de la chose décomposée plus simplement ou à ajouter… :

Tout d’abord, chaque bot doit avoir pour priorité d'éviter la mort sur la prochaine case. Cela signifie :
    • Si une case est un adversaire, un mur, un obstacle ou un vide → éviter (changement de direction, ou d’action comme glisser ou sauter).
    1. Casse-coup : +50% chance de foncer sur un bonus/malus
    2. Prudent : tend à garder les bonus > 8 sec avant usage
    3. Saboteur : priorise les cibles adverses avec les bonus/malus actifs
    4. Couard : fuit si ≥2 joueurs ou ≥2 murs adverses dans rayon de 2 cases 
    5. Bloqueur : essaie de croiser la trajectoire d’un humain quand il est devant 
    6. Cupide : dévie de ≥2 cases pour ramasser un bonus connu positif 
    7. Nettoyeur : utilise immédiatement Débogueur dès qu’un bug actif le gêne (s’il a le bonus)
    8. Flambeur : 33% chance d’utiliser un bonus/malus aléatoire toutes les 5 sec (s’il a un bonus/malus)
    9. Trouillard : préfère la direction qui a le moins de murs adversaires restants 
    10. Crétin : 20% chance de ne pas éviter un danger
    11. Anticipateur : anticipe 1 case plus loin pour tourner
    12. Survireur : change de direction toutes les 4-8 sec même si chemin libre 
    13. Appel des bords : préfère longer les murs/rebords plutôt que centre 
    14. Fonceur : utilise Dash ou Slide en priorité s’il le peut, au lieu de tourner 
    15. Troll : 25% chance de garder un malus visible juste pour bloquer les autres
    16. Chasseur : si un humain est à ≤3 cases devant, le suit (ignore un peu les bonus)
    17. Lâche : si sa vie/visibilité est menacée par un bug visuel, tourne immédiatement à 90° quel que soit le chemin 
    18. Lâche : si sa vie/visibilité est menacée par un bug visuel, tourne immédiatement à 90° quel que soit le chemin 
    19. Lâche : si sa vie/visibilité est menacée par un bug visuel, tourne immédiatement à 90° quel que soit le chemin
    20. Frimeur : utilise un bonus actif dès qu’un humain le regarde (est dans rayon 4 cases) 
    21. Kamikaze : si coincé (aucun move safe), 50% chance d’utiliser un Dash/Saut/Teleport même si ça le tue probablement 
    22. Suicidaire passif : 10% chance par seconde de ne RIEN faire (continue tout droit même si danger imminent) 
    23. Économe : n’utilise jamais un bonus actif s’il a une piste sûre devant 
    24. Vengeur : si un adversaire vient de lui envoyer un malus, priorise immédiatement un retour à l’envoyeur (Virus/Sabotage) 
    25. Glouton : ramasse TOUT ce qui est sur sa case actuelle, même si c’est un malus évident 
    26. Danseur : toutes les 6-10 sec, fait volontairement une glissade ou un saut décoratif même si inutile
    27. Radar : augmente de +1 case son anticipation quand un humain est dans un rayon de 5 cases
    28. Peur du vide : refuse toute direction où la case suivante est un trou (même si c’était safe avant)
    29. Aimant à bugs : +30 % chance de déclencher un bug global quand il ramasse un item
    30. Psychopathe : si un humain est exactement aligné (même ligne/colonne), fonce tout droit dessus
    31. Parano : change de direction dès qu’un autre coureur entre dans un rayon de 3 cases
    32. Sprinter tardif : n’utilise Dash/Slide que quand il reste <3 cases safe devant lui
