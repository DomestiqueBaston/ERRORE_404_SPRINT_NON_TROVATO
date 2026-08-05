Description des comportements des cellules dans les modifications du terrain.

- Petit point important à probablement prévoir pour plus tard si nécessaire : dans la mesure où on va jouer pas mal de sons et avec beaucoup de réverbération (dans les Bus Audio), il serait probablement judicieux de faire en sorte que les sons qui sont au-delà de la détection de l’AudioListener2D du joueur (humain, les autres n’en ont pas besoin) ne soient pas joués.

Glissements de lignes/colonnes :
- Une cellule prend 358 frames (11.9333... secondes) pour se déplacer à la place de la suivante.
    • 1 seconde avant un glissement, on commence à jouer une alerte sonore dans Sounds.tscn : Sounds/Cell_Pylon_Alarms/Column_Row_Slide et le son continuera jusqu’à la fin du glissement.
    • Au démarrage du glissement, les cellules (Cell.tscn) qui sont au niveau du sol (par défaut) jouent (dans leur AnimationPlayer Cell/Global_Cell) leur animation High_Sliding_Beginning et les cellules qui sont sous le niveau du sol jouent leur animation Low_Sliding_Beginning. Tout autre cellule dans un autre état ne joue aucune animation à ce stade.
    • Pendant que la ligne/colonne glisse (rappel : 2 pixels à l’horizontale pour 1 pixel à la verticale) chaque cellule qui se déplace joue le son Cell/Sound/Cell_Slide_Sounds/Sliding_Cell.
    • À la fin du glissement dès qu’elles s’arrêtent, les cellules jouent leurs animations High_Sliding_End (pour celles qui étaient au sol) et Low_Sliding_End (pour celles qui était basses) dans  Cell/Global_Cell. Tout autre cellule dans un autre état ne joue aucune animation à ce stade non plus.
    • On stoppe le son  Sounds/Cell_Pylon_Alarms/Column_Row_Slide dans Sounds.tscn.


Concernant les animations suivantes, il est à noter que les cellules qui subissent ces comportements peuvent glisser mais on n’applique pas ces effets à une cellule qui glisse (ce qui ne devrait pas pouvoir se produire théoriquement d’après ce qui est prévu dans le jeu si je ne m’abuse).

Cellules disparaissantes (uniquement depuis la position.y = 0, donc par défaut) :
    • 1 seconde avant la disparition, on joue le son Sounds/Cell_Pylon_Alarms/Cell_Disappearing (ce son n’est pas une boucle).
    • Dans Cell.tscn, on joue l’animation Disappearing dans Cell/Global_Cell.

Cellules (ré)apparaissantes (uniquement après avoir précédemment disparu):
    • Dans Cell.tscn, on joue l’animation Appearing dans Cell/Global_Cell.

Cellules descendantes (uniquement depuis la position.y = 0, donc par défaut) :
    • 1 seconde avant la descente, on commence à jouer une alerte sonore dans Sounds.tscn : Sounds/Cell_Pylon_Alarms/Cell_Down et le son continuera jusqu’à la fin de la descente.
    • Dans Cell.tscn, on joue l’animation Going_Down dans Cell/Global_Cell.
    • On stoppe enfin le son  Sounds/Cell_Pylon_Alarms/Cell_Up_Down dans Sounds.tscn.

Cellules (re)montantes (uniquement en remontée après être précédemment descendue) :
    • Dans Cell.tscn, on joue l’animation Going_Down dans Cell/Global_Cell.
    • On stoppe enfin le son  Sounds/Cell_Pylon_Alarms/Cell_Up_Down dans Sounds.tscn.


Description des autres comportements des cellules.

Cellules à surface qui bugge (uniquement en position par défaut) :
    • Pas de son d’alerte.
    • Pour faire apparaître le bug de surface, dans Cell.tscn, on joue soit l’animation Glitch_Only_Appearing, soit l’animation Screen_Glitch_Appearing (suivant le bug choisi) dans Cell/Column/Cell_Top/Top_Cell_FX_Mask/Glitch et on jouera synchronisé, le son Cell/Sound/Sound_For_Glitch_Only ou le son Cell/Sound/Sound_For_Screen_Glitch (suivant le bug choisi).
    • Les sons durent jusqu’à l’animation suivante.
    • Pour faire disparaître le bug de surface, au même endroit, on jouera soit l’animation Glitch_Only_Disappearing, soit l’animation Screen_Glitch_Disappearing (suivant le bug choisi) et on coupera les sons Cell/Sound/Sound_For_Glitch_Only ou Cell/Sound/Sound_For_Screen_Glitch (suivant le bug choisi).

Cellules à sens unique (uniquement en position par défaut) :
    • Pas de son d’alerte.
    • Pour faire apparaître la flèche qui indique la direction de sens unique de la cellule, dans Cell.tscn, on jouera l’animation Appearing dans Cell/Column/Cell_Tops/One_Way_Direction et on jouera le son Cell/Sound/Sound_For_Screen_Glitch jusqu’à l’animation suivante.
    • Pour la faire disparaître, on jouera l’animation Disappearing.
    • On coupe le son  Cell/Sound/Sound_For_Screen_Glitch
À noter que l’animation de flottement de la flèche se joue automatiquement (il s’agit de l’animation Floating dans Cell/Column/Cell_Tops/One_Way_Direction/Direction_Floating).


Description des autres comportements des pylônes.

Pylônes-obstacles (descente) :
    • 1 seconde avant la descente (du « plafond ») d’un pylône-obstacle, on commence à jouer une alerte sonore dans Sounds.tscn : Sounds/Cell_Pylon_Alarms/Pylon_Down et le son continuera jusqu’à la fin de la descente.
    • Pour faire descendre le pylône-obstacle, dans la scène Pylon.tscn, on joue l’animation Going_Down dans Pylon/Pylon_Animation.
    • On coupe le son  Sounds/Cell_Pylon_Alarms/Pylon_Down dans Sounds.tscn.

Pylônes-obstacles (remontée) :
    • Pour faire remonter le pylône, dans la scène Pylon.tscn, on joue l’animation Going_Up dans Pylon/Pylon_Animation.
    • On coupe le son Sounds/Cell_Pylon_Alarms/Pylon_Down dans Sounds.tscn.

Pylônes-écraseur (chute):
    • 1 seconde avant la chute (du « plafond ») d’un pylône-écraseur, on joue une alerte sonore dans Sounds.tscn : Sounds/Cell_Pylon_Alarms/Pylon_Crunch (ce son n’est pas une boucle).
    • Pour faire descendre le pylône, dans la scène Pylon.tscn, on joue l’animation Going_Down_Falling dans Pylon/Pylon_Animation.

Pylônes-écraseur (remontée):
    • Pour faire remonter le pylône, dans la scène Pylon.tscn, on joue l’animation Going_Up_Falling dans Pylon/Pylon_Animation.