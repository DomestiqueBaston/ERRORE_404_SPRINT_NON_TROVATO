PIXEL ART V

Errore 404: Sprint Non Trovato!

Un jeu basé sur les bugs (se souvenir du site e13.com)
Pour le moment, on part pour de la 2D !

Un runner à pied (étonnant !)

Ce « Runner » va se « rapprocher » de la (fameuse) séquence de course de moto dans Tron (1982) qu’on va mélanger avec un peu du film Cube.

Un espace de course qui sera carré au départ et deviendra « plus du tout carré » avec les transformations ultérieures.
Le champs de course se structurera sous forme de grille dont les lignes et colonnes vont être poussées ou tirées par le jeu transformant ainsi le terrain en permanence.
Des cases s’élèveront ou se baisseront également.
L’aire de course sera composée de base de 9x9 à 15x15 (uniquement impaires) cellules de terrain (ou plus ?).
Au départ, les joueurs auront la possibilité de choisir la taille de l’aire dans laquelle il veut courir.
Plus le temps passe et plus les modifications de l’environnement se font fréquemment.
À chaque fois que le jeu va bouger une ligne/colonne, une alarme se fera entendre.
Sur le terrain, au centre, une case est levée (colonne) avec dessus, la porte de sortie de la zone.
Un jeu pour 1 à 4. Il y aura toujours 4 concurrents en piste mais quel que soit le nombres de joueurs humains, les concurrents manquants seront pris en charge par l’IA (Bots).
Pour les coureurs, 4 directions de mouvement (les diagonales).
Les joueurs ne peuvent pas faire directement demi-tour (à cause du mur qu’ils tracent).
Les joueurs ne peuvent tourner qu’à 90°.
Les joueurs ne peuvent pas arrêter de courir ! → Sinon on meurt.
Les joueurs peuvent stocker jusqu’à 2 bonus.
Ils tracent un mur temporaire derrière eux (s’efface au fur et à mesure après 10 secondes – à préciser plus tard).


Le but du jeu est ici de tenir le plus longtemps possible et être le dernier survivant ou éventuellement être le premier à atteindre la sortie qui se manifestera aléatoirement au bout d’un certain temps.





Un runner bugué :
	1. Freeze (les 5 à 10 dernières images du jeu (en fonction du fps 5 à 30fps et 10 à 60fps) et le son qui va avec qui bouclent pendant 1 seconde)
	2. Téléportation
	3. Joueur « hors phase » (shader) ✔ 
	4. Décors ou cellules de décor « hors phase » (shader) ✔ (bonus/malus?)
	5. Plus aucune musique/bug de la musique
	6. Plus aucun bruitages/bug des bruitages
	7. Son chiant permanent
	8. Le jeu prend le contrôle du joueur et donne le sien au joueur
	9. Des éléments de décor disparaissent/apparaissent
	10. Inversion des commandes

Des bugs (graphiques) qui font vraiment bug et pas « le jeu essaye de géner le joueur » :
	11. Les sprites se mélangent (?) (changer des frames d’animation à la volée dans les cycles de course)
	12. Les textures de sol clignotent/changent
	13. La palette de couleurs change ✔ 
	14. Des artefacts graphiques (oui, et ?)
	15. Des glitches sonores (oui, et ?)
	16. L’image globale se décale dans la vue du joueur (la caméra se décentre du joueur)
	17. La caméra vibre ✔
	18. Des éléments de décors changent de position /?\ 
	19. Des messages d’erreur ou des barres de chargement (ou autres) apparaissent masquant une partie de l'écran
    20. L’écran clignote /?\ 
    21. « BSOD » d’1/2 seconde ✔ 
    22. Couleurs inversées ✔ 
    23. Surpixelisation ✔ 

Les bonus en jeu (passif par défaut) :
	- Il n’y a qu’1 à 3 exemplaires de chaque Bonus/Malus (en fonction de la puissance du bonus/malus – à préciser plus tard) que l’on peut ramasser. Si un joueur en possède un ou est en jeu mais n’a pas été ramassé, il ne peut pas apparaître ailleurs (uniquement au delà de la limite du nombre max de ce bonus/malus).
	- Peut-être y a-t-il un moyen de créer des synergies en accumulant certains bonus (ça va être compliqué) ?

    1. Échange de personnage
    2. Récupère de la vie
    3. Invulnérabilité (à quoi?)
    4. Super saut - Actif
    5. Freeze adversaire
    6. Bouclier (contre quoi ?)
    7. Sabotage (renvoie un malus/bug à un adversaire) - Actif
    8. Super slide - Actif
    9. Dash (accélération qui permet de traverser 2 case le temps d’1) - Actif
    10. Passe-muraille (permet de traverser uniquement les murs) - Actif
    11. Réflexe (fait tourner le joueur au lieu de tomber dans le vide)
    12. Virus (envoie un malus récolté à un adversaire aléatoire) - Actif
    13. Téléportation - Actif
    14. Débogueur (vire un bug actif) - Actif



Les obstacles :
    1. Vrais murs → Cellules qui montent ✔
    2. Murs des coureurs → ✔ (?)
    3. Cellule à sens unique → ✔
    4. Colonnes tombantes → ✔
    5. La porte finale (par les côtés) → ✔
    6. Blocs (mouvants ou non)
    7. Dalles disparaissant → Cellules qui disparaissent ✔

Liste des animations du joueur :
    1. Courir
    2. Sauter
    3. Glissade
    4. Pose de départ
    5. Intro
    6. Tomber dans le vide → Mort !
    7. Bim ! Dans un mur → Mort !








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


Notes de fabrication :

- Lorsqu’un coureur traverse une case (donc en traçant son mur) et que la case bouge, alors le coureur se décale AVEC la case. Et le mur qu’il trace également. Il faudra donc « tronçonner » les murs à chaque fois qu’un coureur sort d’une case afin que le morceau de mur puisse éventuellement se déplacer avec la case ultérieurement.
