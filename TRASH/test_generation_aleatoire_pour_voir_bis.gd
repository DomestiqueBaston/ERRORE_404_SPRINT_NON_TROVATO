extends Node2D

@export var cell_scene: PackedScene

# grid_size toujours impair et >= 3
@export var grid_size: int = 3 :
	set(value):
		value = max(3, value)
		if value % 2 == 0:
			grid_size = value + 1
			push_warning("grid_size ajusté à l'impair supérieur (>= 3) : %d" % grid_size)
		else:
			grid_size = value

# Taille cellule
var cell_size := Vector2(236, 118)
var iso_offset := Vector2(cell_size.x / 2, cell_size.y / 2)
var center_offset := Vector2.ZERO

# Sprites intérieurs
var interior_sprites := [
	"Cellule_De_Terrain_01", "Cellule_De_Terrain_02", "Cellule_De_Terrain_03",
	"Cellule_De_Terrain_04", "Cellule_De_Terrain_05", "Cellule_De_Terrain_06",
	"Cellule_De_Terrain_07", "Cellule_De_Terrain_08"
]

# COINS (fixes)
var corner_sprites := {
	"gauche": "Cellule_De_Terrain_Bord_Gauche",
	"droit":  "Cellule_De_Terrain_Bord_Droit",
	"haut":   "Cellule_De_Terrain_Bord_Haut",
	"bas":    "Cellule_De_Terrain_Bord_Bas"
}

# BORDS (2+ variantes aléatoires par côté)
var edge_variants := {
	"bord_haut_gauche":    ["Cellule_De_Terrain_Bord_Haut_Gauche_1", "Cellule_De_Terrain_Bord_Haut_Gauche_2", "Cellule_De_Terrain_Bord_Haut_Gauche_3"],
	"bord_bas_gauche":     ["Cellule_De_Terrain_Bord_Bas_Gauche_1", "Cellule_De_Terrain_Bord_Bas_Gauche_2", "Cellule_De_Terrain_Bord_Bas_Gauche_3"],
	"bord_haut_droit":     ["Cellule_De_Terrain_Bord_Haut_Droit_1", "Cellule_De_Terrain_Bord_Haut_Droit_2", "Cellule_De_Terrain_Bord_Haut_Droit_3"],
	"bord_bas_droit":      ["Cellule_De_Terrain_Bord_Bas_Droit_1", "Cellule_De_Terrain_Bord_Bas_Droit_2", "Cellule_De_Terrain_Bord_Bas_Droit_3"]
}

# ------------------------------------------------------------------
# Grille de suivi des sprites choisis (pour éviter doublons orthogonaux)
var chosen_sprites: Array = []

# ------------------------------------------------------------------
# Fonction pour choisir un sprite valide parmi les candidats
func choose_valid_sprite(row: int, col: int, candidates: Array) -> String:
	var shuffled := candidates.duplicate()
	shuffled.shuffle()
	
	for sprite_name in shuffled:
		var valid := true
		
		# Voisin HAUT
		if row > 0 and chosen_sprites[row - 1][col] == sprite_name:
			valid = false
		# Voisin BAS (si déjà placé)
		if row < grid_size - 1 and chosen_sprites[row + 1][col] != "" and chosen_sprites[row + 1][col] == sprite_name:
			valid = false
		# Voisin GAUCHE
		if col > 0 and chosen_sprites[row][col - 1] == sprite_name:
			valid = false
		# Voisin DROIT (si déjà placé)
		if col < grid_size - 1 and chosen_sprites[row][col + 1] != "" and chosen_sprites[row][col + 1] == sprite_name:
			valid = false
		
		if valid:
			return sprite_name
	
	# Fallback : si bloqué, on force un sprite différent des voisins
	for sprite_name in candidates:
		var forced_valid := true
		if row > 0 and chosen_sprites[row - 1][col] == sprite_name:
			forced_valid = false
		if row < grid_size - 1 and chosen_sprites[row + 1][col] != "" and chosen_sprites[row + 1][col] == sprite_name:
			forced_valid = false
		if col > 0 and chosen_sprites[row][col - 1] == sprite_name:
			forced_valid = false
		if col < grid_size - 1 and chosen_sprites[row][col + 1] != "" and chosen_sprites[row][col + 1] == sprite_name:
			forced_valid = false
		
		if forced_valid:
			return sprite_name
	
	# Ultime fallback (impossible normalement)
	return candidates[0]

# ------------------------------------------------------------------
func _ready() -> void:
	center_offset = Vector2(
		(grid_size - 1) * iso_offset.x / 2.0,
		-(grid_size - 1) * iso_offset.y / 2.0
	)
	
	var center := int(grid_size * 0.5)
	
	# Initialiser la grille de suivi
	chosen_sprites.resize(grid_size)
	for r in range(grid_size):
		chosen_sprites[r] = []
		chosen_sprites[r].resize(grid_size)
		for c in range(grid_size):
			chosen_sprites[r].append("")
	
	# Parcours de la grille
	for row in range(grid_size):
		for col in range(grid_size):
			var cell_instance = cell_scene.instantiate()
			var images_node = cell_instance.get_node("Column/Images")
			
			# Cacher tous les sprites
			for child in images_node.get_children():
				if child is Sprite2D:
					child.visible = false
			
			var sprite_name: String = ""
			var candidates: Array = []
			
			# === 1. CENTRE ===
			if row == center and col == center:
				sprite_name = "Cellule_De_Terrain_Centre"
			
			# === 2. COINS (fixes) ===
			elif row == 0 and col == 0:
				sprite_name = corner_sprites.haut
			elif row == 0 and col == grid_size - 1:
				sprite_name = corner_sprites.droit
			elif row == grid_size - 1 and col == 0:
				sprite_name = corner_sprites.gauche
			elif row == grid_size - 1 and col == grid_size - 1:
				sprite_name = corner_sprites.bas
			
			# === 3. BORDS (aléatoire + contrainte) ===
			elif row == 0:  # Haut
				candidates = edge_variants.bord_haut_droit.duplicate()
				sprite_name = choose_valid_sprite(row, col, candidates)
			elif row == grid_size - 1:  # Bas
				candidates = edge_variants.bord_bas_gauche.duplicate()
				sprite_name = choose_valid_sprite(row, col, candidates)
			elif col == 0:  # Gauche
				candidates = edge_variants.bord_haut_gauche.duplicate()
				sprite_name = choose_valid_sprite(row, col, candidates)
			elif col == grid_size - 1:  # Droit
				candidates = edge_variants.bord_bas_droit.duplicate()
				sprite_name = choose_valid_sprite(row, col, candidates)
			
			# === 4. INTÉRIEUR (aléatoire + contrainte) ===
			else:
				candidates = interior_sprites.duplicate()
				sprite_name = choose_valid_sprite(row, col, candidates)
			
			# Sauvegarde du choix
			chosen_sprites[row][col] = sprite_name
			
			# Affichage
			var sprite = images_node.get_node_or_null(sprite_name)
			if sprite and sprite is Sprite2D:
				sprite.visible = true
			else:
				push_error("SPRITE MANQUANT dans Cell.tscn : '%s' (row=%d, col=%d)" % [sprite_name, row, col])
			
			# === CORRECTION ICI : "row" au lieu de "scpp row" ===
			var x_pos = (col - row) * iso_offset.x
			var y_pos = (col + row) * iso_offset.y
			cell_instance.position = Vector2(x_pos, y_pos) + center_offset
			
			add_child(cell_instance)
