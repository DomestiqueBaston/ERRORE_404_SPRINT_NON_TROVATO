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
Ils tracent un mur temporaire derrière eux (s’efface au fur et à mesure par tronçons après 10 secondes – à préciser plus tard).


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
	1. Invulnérabilité (annule le prochain malus récolté) – dure 5’’ → ✔ Invincible – Automatique !
	2. Dash (course uniquement – dure 1’’ – changement de direction seulement pendant la seconde !) : 66% plus rapide (animation aussi). → ✔ Dash – Activable !
	3. Passe-muraille (uniquement les murs des concurrents) – 1 seul mur → ✔ Through – Automatique !
	4. Virus (envoie automatiquement le prochain malus récolté à un adversaire aléatoire) → ✔ Virus – Automatique !
	5. Téléportation (destination aléatoire sur une « cellule saine »)→ ✔ Teleport – Activable !
	6. Débogueur (vire un bug actif)→ ✔ Debug – Activable !
	7. Le mur tracé par le concurrent dure 1.5 fois plus longtemps.→ ✔ Last_Longer – Automatique !

Les malus (automatiques) :
	1. Inversion de commandes (droite/gauche) – dure 2’’ → ✔ Invert
	2. Lenteur de réaction (on ajoute un délai d’1/10’’ (à préciser) dans les commandes du concurrent) – dure 5’’ → ✔ Slow
	3. Les murs tracés par le concurrent durent 2 fois moins longtemps – dure 10’’ → ✔ Last_Shorter
	4. Course, saut et glissade : 4% plus lent (animation aussi) – dure 5’’ → ✔ Anti_Dash
	5. Rien ! → ✔ Empty
	6. Virus (envoie automatiquement le prochain Bonus (pas malus) récolté à un adversaire aléatoire) → ✔ Anti_Virus
	7. Téléportation (instantané et destination aléatoire)→ ✔ Anti_Teleport

Les obstacles :
Toutes les X secondes (voir Options à proposer au joueur dans Settings) un des obstacles est déclenché. 1 sur 4 est un glissement de Ligne/Colonne.
	1. Ligne/Colonne (de cellules) qui glisse d’1 à 2 cases → ✔ (On joue Alarm_Before_Movement dans Cell.tscn 1’’ avant ET pendant le glissement, jusqu’à la fin du glissement)
	2. Trous (cellules qui descendent) → ✔
	3. Murs des concurrents → ✔ (voir avec Geoff comment faire)
	4. Cellule à sens unique → ✔
	5. Colonnes descendantes → ✔
	6. Colonnes écrasantes → ✔
	7. Dalles disparaissant → Cellules qui disparaissent ✔

Liste des animations des personnages :
	1. Courir ✔ ✔ ✔
	2. Sauter ✔ ✔
	3. Glissade ✔ ✔
	4. Pose de départ ✔ ✔ ✔
	5. Intro ✔ ✔ ✔
	6. Tomber dans le vide → Mort ! ✔ ✔ ✔
	7. Bim ! Dans un mur → Mort ! ✔ ✔

Notes de fabrication :
SON :
- Au lancement du jeu, la musique qui joue en boucle en permanence, c’est Intro. Jusqu’au moment où le Départ est donné. À cet instant précis, on passe à Music (en boucle). Music ne s’arrête qu’en finissant la partie (soit en relançant une nouvelle partie directement soit en retournant à l’écran de Titre (ou de Settings, je ne sais pas encore présentement). Au moment de lancer à nouveau Intro, il faudra jouer une fois démarrant en même temps qu’Intro le song Bang.
JEU :
- Sauf pendant la sélection de joueur, par défaut, la caméra de chaque joueur ne montre pas le joueur centré mais se décale afin d’avoir plus de visibilité devant le joueur en fonctino de la directino dans laquelle il court. On utilisera un tween d’1/4 de seconde pour déplacer la caméra. Au démarrage de la course, dès la première frame de course, la caméra rejoindra sa place avec le tween décrit précédemment.
- Lorsqu’un concurrent traverse une case (donc en traçant son mur) et que la cellule bouge, alors le concurrent se décale AVEC la cellule. Et le mur qu’il trace également. Il faudra donc « tronçonner » les murs à chaque fois qu’un concurrent sort d’une case afin que le morceau de mur puisse éventuellement se déplacer avec la case si celle-ci est amenée à se déplacer de nouveau.
- Cas particuliers de mort : il existe un AnimationPlayer avec une animation « toute bête » pour ces cas-là (Animation_Disappearing_Death). Si par exemple se présent un cas avec deux colonnes baissées et que le concurrent veut passer dessous à vitesse normale, il ne pourra pas et mourra donc et on utilisera cette animation. Écrasé par une colonne, pareil ! Etc.
- Un concurrent ne peut pas courir sur un autre cadavre → Le jeu forcera le concurrent à tourner aléatoirement à droite ou à gauche. On jouera ici aussi l’Animation_Bonus_Malus et Alert (dans UI_Sounds.tscn). Si par vraiment super pas de bol, le concurrent se retrouve coincé entre des cadavres et/ou d’autres concurrents, alors on lui fera jouer son animation de mort à lui aussi et il sera donc mort ! Ça ne sera pas très joli mais c’est un cas vraiment très peu probable et il faut l’envisager (et faire une animation pour un tel cas…).
- À la mort d’un concurrent, ce qui reste de son mur ne disparaît pas ! Mais attention, l’animation de mort projette les concurrents en arrière, donc sur le mur : ça ne va pas aussi prendra-t-on soin de supprimer 1 ou 2 tronçons (suivant les animations, je pense qu’il ne sera pas nécessaire d’en effacer plus) de mur pour cela.

Options à proposer au joueur dans Settings:
- Taille de la map (de 9 à 21) ✔
- Volume sonore général (de 0 à 100) ✔
- Volume de la musique (de 0 à 100) ✔
- Difficulté (de 1 à 5) ✔ :
	• Temps avant l’apparition de la porte de sortie : (Taille de la map + (3 × Difficulté)) / 4 en minutes
	• Délai entre les déclenchements d’obstacles : 5.5’’ - (0.5 × Difficulté)  en secondes


Script de déroulement d’une partie :
Préambule :
	• À chaque chargement de scène (sauf contre-indication), on joue 1 fois Music/Bang (dans Music.tscn).
	• Les sons de validation (Validation) et d’annulation (Cancel) sont dans la scène UI_Sounds.tscn.
	• Par défaut, Intro et Music sont en boucle, pas besoin de le dire dans le code théoriquement !
	• Dans les scènes, des choses sont mises en place uniquement pour voir comment ça fait (je pense notamment à certains (bouts de) scripts, aux musiques ou sons d’UI qui devraient plus être dans des autoloads ou quoi, etc…).

Avant le jeu :
	1. Chargement de l’écran titre Title.tscn (l’overlay qui dit de presser un bouton, peu importe lequel) apparaît au bout de 15’’ si je joueur n’a rien fait jusque là). À partir du démarrage, Music/Intro joue en boucle.
	2. Transition brutale (pour une fois, sans effet de transition !) vers Settings.tscn. À l’ouverture de la scène suivante, on jouera juste Music/Bang (Music/Intro continue donc de jouer). Dans cette scène, presser B (Cancellare) remet les valeurs modifiées à leur valeur précédente et retourne à l’écran titre. Presser A lancera le jeu.

Le jeu :
	3. Transition brutale vers (pour le moment, la scène, c’est Test_Split_Screen.tscn mais il s’agit d’une scène de démo plus qu’autre chose). Les 4 caméras sont centrées sur les 4 coins de la zone de course. L’écran en haut à gauche affiche la sélection de joueur (Portraits.tscn) qui commence sur la fille et les 3 autres affichent aléatoirement les 3 autres personnages : pas de doublons ! À chaque fois que le joueur change de personnage, les autres sont retirés aléatoirement.
	4. On sélectionne le personnage avec droite et gauche, on valide avec A et on annule avec B (qui renvoie à l’écran titre avec transition brutale + Bang!). Lorsque le joueur change de personnage, à chaque fois, dans les autres quarts d’écran les personnages changent et on utilisera leurs animations de Glitch sur 5 frames pour faire une transition. Annuler renvoie à l’écran Settings.tscn avec toujours la même transition. Valider Fait disparaître l’overlay de sélection des personnages !
		◦ Ceci est pour la cas où il n’y aurait qu’1 joueur humain et 3 bots mais pour ajouter 1 autre (ou plusieurs autres) joueur humain, il suffira de presser un des boutons d’un autre contrôleur pour que le quart d’écran suivant lui soit attribué. Le reste se fait comme pour le premier joueur… Overlay des portraits, etc. Il ne peut pas avoir de doublons de personnage !
	5. Tous les Personnages passent alors en animation Start. Au bout d’1/2 seconde, on joue UI_Sounds/3_2_1 puis on coupe Music/Intro, on lance UI_Sounds/Go et Music/Music en boucle (sans Music/Bang cette fois-ci) et les coureurs (Bot) partent aléatoirement dans l’une des deux directions qu’il ont de possible dans, au plus tard, la 1/2 de seconde qui suit ! Au pire, 1 seconde après le « top départ », tous les concurrents restants partiront automatiquement avec un décalage de 1/4 de seconde les uns avec les autres pasque tous synchro, c’est pas joli.

Ici, la course elle-même prend place !

	6. Lorsque les 3 premiers concurrents meurent, on affiche l’Overlay Frames/Bug_0X/Death (X est le numéro de la zone d’écran concernée) dans la scène  Test_Split_Screen.tscn (scène pour le moment temporaire, comme je le disais).
		◦ Lorsque le dernier concurrent meurt, on affiche alors Frames/Info_Win_Lose_Overlay/Lose et on garde les précédents overlays de mort.
		◦ Si un concurrent gagne (soit parce qu’il est le dernier à courir, soit parce qu’il a franchis la porte de sortie), on affiche Frames/Info_Win_Lose/Win et on garde les éventuels overlays de mort ! Automatiquement, les concurrents restants meurent (animation Death) chacun avec un décalage 1/4 de seconde afin de ne pas les avoir tous exactement synchro, ce qui est moche !
		◦ Ensuite, n’importe quel bouton (sauf B) retourne brutalement (toujours) à l’écran de titre. On coupe alors Music/Music et on lance Music/Intro avec Music/Bang. Et on retourne au point 1 de cette liste. Presser B relance une partie « identique » à partir du point 5 de cette liste !
Les personnalités des « IA »/Bots :
- Par défaut, un Bot tendra bien évidemment à ne pas mourir en évitant les collisions et les chutes.
- On définira des valeurs « par défaut » pour un bot afin de faire varier ces valeurs en fonction du comportement sélectionné.
- Pour former un bot, on combine 1 comportement choisi aléatoirement dans chaque catégorie.

Comportements face aux obstacles :

	1. Anticipatif : Voit plus loin.
	2. Fuyant : S’éloigne des concurrents.
	3. Téméraire : Tente des passage plus étroits.
	4. Agressif : Essaye de bloquer les concurrents.

Comportements face aux Bonus/malus :

	1. Cupide : Fonce sur les bonus/malus.
	2. Sélectif : Ne ramasse que les bonus/malus à 1 case de lui.
	3. Méfiant : Évite les bonus/malus autant que possible.
	4. Opportuniste : Priorise le ramassage d’un bonus si un concurrent se dirige vers le bonus/malus.

Comportements face aux bugs du jeu (continuer tout droit, tourner et/ou utiliser un bonus – pas d’autre option pour le moment, il me semble) :

	1. Prudent : Réagit plus tôt (si possible) face aux obstacles.
	2. Inconscient : Collider de vision plus court.
	3. Panique : Réaction totalement aléatoire face à un obstacle.
	4. Maladroit : Confond les obstacles.
