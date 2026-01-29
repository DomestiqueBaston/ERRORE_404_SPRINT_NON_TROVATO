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
Un jeu pour 1 joueur mais il y aura toujours 4 concurrents en piste. Les 3 autres concurrents manquants seront pris en charge par l’IA (Bots). Il y a toujours 2 hommes et 2 femmes en course.
L’écran est divisé en 4 avec les vues de chaque concurrent. Le joueur sera toujours dans le quart supérieur gauche.
Au départ, le joueur aura la possibilité de choisir la taille de l’aire dans laquelle il veut courir.
À chaque fois que le jeu va bouger une ligne/colonne (complète, donc!), une alarme se fera entendre.
Sur le terrain, au centre, une case est levée (colonne verticale, cette fois). C’est sur cette case, une fois la colonne redescendue qu’apparaîtra la porte de sortie de la zone au bout de 14 secondes + Difficulté (de 1 à 5).
Pour les concurrents, 4 directions de mouvement (les diagonales).
Les concurrents ne peuvent pas faire directement demi-tour (à cause du mur qu’ils tracent).
Les concurrents ne peuvent tourner qu’à 90°.
Les concurrents ne peuvent pas arrêter de courir ! S’arrêter → mort !
Ils tracent un mur temporaire derrière eux (s’efface au fur et à mesure après 10 secondes – à préciser plus tard).


Le but du jeu est ici de tenir le plus longtemps possible et être le dernier survivant ou éventuellement être le premier à atteindre la sortie qui se manifestera aléatoirement au bout d’un certain temps.

Un runner bugué :
Aléatoirement, 1/10 chance d’en déclencher 1 toutes les 10 à 15 secondes. Les bugs liés au son concernent forcément tout le monde !
	1. Joueur « hors phase » (shader) ✔ Dure 10 à 20’’
	2. Plus aucune musique ✔ Dure 10 à 20’’
	3. Plus aucun bruitages ✔ Dure 10 à 20’’
	4. Son chiant qui… ✔ Dure 10 à 20’’ (toujours un seul à la fois)
	5. Cellules à sens unique  ✔ Dure 10 à 20’’
	6. Cellule hors phase ✔ Dure 10 à 20’’ (Screen_Glitch : Fait tourner aléatoirement à droite, Glitch_Only : fait tourner à gauche)
	7. Les sprites se mélangent (?) (changer des frames à la volée dans les cycles de course) → Ça se fait : ✔ Dure 10 à 20’’
	8. Les textures de sol changent → Ça se fait (tween?) : ✔ Dure 10 à 20’’
	9. La palette de couleurs change → ✔  Dure 10 à 20’’
	10. Image floue → Ça se fait : ✔ Dure 10 à 20’’
	11. L’image globale se décale dans la vue du joueur (la caméra se décentre du joueur) → Ça se fait : ✔ Dure 10 à 20’’
	12. La caméra vibre → ✔ Dure 10 à 20’’
	13. Couleurs inversées → ✔  Dure 10 à 20’’
	14. Sur-pixelisation → ✔  Dure 10 à 20’’

Les bonus et malus en jeu (Cube.tscn) :
- Il n’y a que 2 exemplaires de chaque Bonus/Malus (y compris en possession d’un joueur).
- Les Bonus/Malus apparaissent en jeu toutes les 10 secondes.
- Il ne peut pas y avoir plus de 5 Bonus/Malus simultanément à ramasser → le 6ème supprime d’abord automatiquement le plus ancien restant et apparaît 1’’ après.
- Ils ont une couleur aléatoire en jeu (voir Cube.gd). Avec la couleur par défaut, ce sera toujours un Bonus.
- Au ramassage d’un Bonus/Malus, on joue le son correspondant et on joue le clignotement du concurrent (Animation_Bonus_Malus).
- À l’activation (automatique ou au déclenchement du joueur) on joue également le son correspondant et on joue le clignotement du concurrent.
- Si le ramassage et l’activation se font en même temps, on ne joue qu’une fois le son correspondant et le clignotement du concurrent.

Les bonus :
	1. Invulnérabilité (annule le prochain malus récolté) → ✔ Invincible
	2. Dash (permet de parcourir 2 cases dans le temps d’1) : 4% plus rapide. → ✔ Dash
	3. Passe-muraille (uniquement les murs des concurrents) → ✔ Through
	4. Virus (envoie automatiquement le prochain malus récolté à un adversaire aléatoire) → ✔ Virus
	5. Téléportation (destination aléatoire sur une « cellule saine »)→ ✔ Teleport
	6. Débogueur (vire un bug actif)→ ✔ Debug
	7. Le murs tracé par le concurrent dure 1.5 fois plus longtemps.→ ✔ Last_Longer

Les malus :
	1. Inversion de commandes (droite/gauche) → ✔ Invert
	2. Lenteur de réaction (on ajoute un délai d’1/10’’ (à préciser) dans les commandes du concurrent) → ✔ Slow
	3. Les murs tracés par le concurrent durent 2 fois moins longtemps → ✔ Last_Shorter
	4. Course, saut et glissade : 4% plus lent → ✔ Anti_Dash
	5. Rien ! → ✔ Empty
	6. Virus (envoie automatiquement le prochain Bonus récolté à un adversaire aléatoire) → ✔ Anti_Virus
	7. Téléportation (le concurrent ne choisit pas le moment de l’activation et destination aléatoire)→ ✔ Anti_Teleport

Les obstacles :
Toutes les X secondes (voir Options à proposer au joueur dans Settings) un des obstacles est déclenché. 1 sur 4 est un glissement de Ligne/Colonne.
	1. Ligne/Colonne (de cellules) qui glisse d’1 à 2 cases → ✔ (On joue Alarm_Before_Movement dans Cell.tscn 1’’ avant ET pendant le glissement, jusqu’à la fin du glissement)
	2. Trous (cellules qui descendent) → ✔
	3. Murs des concurrents → ✔ (voir avec Geoff comment faire)
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
- Lorsqu’un concurrent traverse une case (donc en traçant son mur) et que la case bouge, alors le concurrent se décale AVEC la case. Et le mur qu’il trace également. Il faudra donc « tronçonner » les murs à chaque fois qu’un concurrent sort d’une case afin que le morceau de mur puisse éventuellement se déplacer avec la case si celle-ci est amenée à se déplacer de nouveau.
- Cas particuliers de mort : il existe un AnimationPlayer avec une animation « toute bête » pour ces cas-là (Animation_Disappearing_Death). Si par exemple se présent un cas avec deux colonnes baissées et que le concurrent veut passer dessous à vitesse normale, il ne pourra pas et mourra donc et on utilisera cette animation. Écrasé par une colonne, pareil ! Etc.
- Un concurrent ne peut pas courir sur un autre cadavre → Le jeu forcera le concurrent à tourner aléatoirement à droite ou à gauche. On jouera ici aussi l’Animation_Bonus_Malus et Alert (dans UI_Sounds.tscn). Si par vraiment super pas de bol, le concurrent se retrouve coincé entre des cadavres et/ou d’autres concurrents, alors on lui fera jouer son animation de mort à lui aussi et il sera donc mort ! Ça ne sera pas très joli mais c’est un cas vraiment très peu probable et il faut l’envisager (et faire une animation pour un tel cas…).

Options à proposer au joueur dans Settings:
- Taille de la map (de 9 à 21) ✔
- Volume sonore général (de 0 à 100) ✔
- Volume de la musique (de 0 à 100) ✔
- Difficulté (de 1 à 5) ✔ :
	• Temps avant l’apparition de la porte de sortie : (Taille de la map + (3 × Difficulté)) / 4 en minutes
	• Délai entre les déclenchements d’obstacles : 5.5’’ - (0.5 × Difficulté)  en secondes



	
Les personnalités des « IA »/Bots :
- Avant tout, on va considérer que les Bots voient tout le terrain (contrairement au joueur).
- Par défaut, un Bot tendra bien évidemment à ne pas mourir en évitant les collisions et les chutes.

Comportements face aux obstacles :

	1. Survivaliste : Évite de se faire coincer (par les murs des adversaires, les vides et murs/colonnes → cône de vision plus long et plus large), se concentre sur sa route et bloque les autres concurrents.
	2. Idiot : Se comporte de manière aléatoire.
	3. Peureux : Va là où il y a le moins de monde et d’obstacles (murs des concurrents, vides et murs/colonnes).

Comportements face aux Bonus/malus – Part 1 :

	1. Agressif : Fonce sur les bonus. S’il est "mineur", il s'en débarrasse immédiatement, sinon il le garde pour plus tard ou pour empêcher un autre concurrent de le prendre.
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
