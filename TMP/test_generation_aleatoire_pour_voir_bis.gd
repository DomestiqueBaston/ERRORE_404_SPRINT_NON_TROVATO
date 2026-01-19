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

# BORDS (3 variantes par côté) — CORRIGÉ
var edge_variants := {
	"bord_haut_gauche": ["Cellule_De_Terrain_Bord_Haut_Gauche_1", "Cellule_De_Terrain_Bord_Haut_Gauche_2", "Cellule_De_Terrain_Bord_Haut_Gauche_3"],
	"bord_bas_gauche":  ["Cellule_De_Terrain_Bord_Bas_Gauche_1",  "Cellule_De_Terrain_Bord_Bas_Gauche_2",  "Cellule_De_Terrain_Bord_Bas_Gauche_3"],
	"bord_haut_droit":  ["Cellule_De_Terrain_Bord_Haut_Droit_1",  "Cellule_De_Terrain_Bord_Haut_Droit_2",  "Cellule_De_Terrain_Bord_Haut_Droit_3"],
	"bord_bas_droit":   ["Cellule_De_Terrain_Bord_Bas_Droit_1",   "Cellule_De_Terrain_Bord_Bas_Droit_2",   "Cellule_De_Terrain_Bord_Bas_Droit_3"]
}

# Grille de suivi
var chosen_sprites: Array = []

# ------------------------------------------------------------------
# Vérifie si un sprite est valide (pas de doublon orthogonal)
func is_sprite_valid(row: int, col: int, sprite_name: String) -> bool:
	if row > 0 and chosen_sprites[row - 1][col] == sprite_name:
		return false
	if row < grid_size - 1 and chosen_sprites[row + 1][col] != "" and chosen_sprites[row + 1][col] == sprite_name:
		return false
	if col > 0 and chosen_sprites[row][col - 1] == sprite_name:
		return false
	if col < grid_size - 1 and chosen_sprites[row][col + 1] != "" and chosen_sprites[row][col + 1] == sprite_name:
		return false
	return true

# ------------------------------------------------------------------
# Choisit un sprite valide parmi les candidats
func choose_valid_sprite(row: int, col: int, candidates: Array) -> String:
	var shuffled := candidates.duplicate()
	shuffled.shuffle()
	for sprite_name in shuffled:
		if is_sprite_valid(row, col, sprite_name):
			return sprite_name
	for sprite_name in candidates:
		if is_sprite_valid(row, col, sprite_name):
			return sprite_name
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
	
	# === PRÉ-CALCUL ÉQUILIBRÉ DES SPRITES INTÉRIEURS ===
	var interior_positions := []
	var interior_sprite_pool := []
	
	for row in range(grid_size):
		for col in range(grid_size):
			if not (row == center and col == center) \
			   and not (row == 0 or row == grid_size - 1 or col == 0 or col == grid_size - 1):
				interior_positions.append(Vector2i(row, col))
	
	var num_interior = interior_positions.size()
	var base_count = int(num_interior / float(interior_sprites.size()))
	var extra = num_interior % interior_sprites.size()
	
	for i in range(interior_sprites.size()):
		var sprite_name = interior_sprites[i]
		var count = base_count + (1 if i < extra else 0)
		for _j in range(count):
			interior_sprite_pool.append(sprite_name)
	
	interior_sprite_pool.shuffle()
	
	var interior_assignment := {}
	var pool_idx := 0
	for pos in interior_positions:
		interior_assignment[pos] = interior_sprite_pool[pool_idx]
		pool_idx += 1
	# ==================================================================
	
	# === GÉNÉRATION DE LA GRILLE ===
	for row in range(grid_size):
		for col in range(grid_size):
			var cell_instance = cell_scene.instantiate()
			var images_node = cell_instance.get_node("Column/Cell_Tops/Images")
			
			# Cacher tous les sprites
			for child in images_node.get_children():
				if child is Sprite2D:
					child.visible = false
			
			var sprite_name: String = ""
			
			# === 1. CENTRE ===
			if row == center and col == center:
				sprite_name = "Cellule_De_Terrain_Centre"
			
			# === 2. COINS ===
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
				sprite_name = choose_valid_sprite(row, col, edge_variants.bord_haut_droit.duplicate())
			elif row == grid_size - 1:  # Bas
				sprite_name = choose_valid_sprite(row, col, edge_variants.bord_bas_gauche.duplicate())
			elif col == 0:  # Gauche
				sprite_name = choose_valid_sprite(row, col, edge_variants.bord_haut_gauche.duplicate())
			elif col == grid_size - 1:  # Droit
				sprite_name = choose_valid_sprite(row, col, edge_variants.bord_bas_droit.duplicate())
			
			# === 4. INTÉRIEUR : pré-attribué + fallback si conflit ===
			else:
				var pos = Vector2i(row, col)
				var preassigned = interior_assignment.get(pos, "")
				if preassigned and is_sprite_valid(row, col, preassigned):
					sprite_name = preassigned
				else:
					sprite_name = choose_valid_sprite(row, col, interior_sprites.duplicate())
			
			# Sauvegarde
			chosen_sprites[row][col] = sprite_name
			
			# Affichage
			var sprite = images_node.get_node_or_null(sprite_name)
			if sprite and sprite is Sprite2D:
				sprite.visible = true
			else:
				push_error("SPRITE MANQUANT dans Cell.tscn : '%s' (row=%d, col=%d)" % [sprite_name, row, col])
			
			# Position isométrique
			var x_pos = (col - row) * iso_offset.x
			var y_pos = (col + row) * iso_offset.y
			cell_instance.position = Vector2(x_pos, y_pos) + center_offset
			
			add_child(cell_instance)
	
	# === DEBUG : Répartition finale de TOUS les sprites utilisés ===
	var global_counts := {}

	for row in range(grid_size):
		for col in range(grid_size):
			var sprite = chosen_sprites[row][col]
			if sprite != "":  # sécurité
				global_counts[sprite] = global_counts.get(sprite, 0) + 1

	print("=== RÉPARTITION COMPLÈTE DE TOUS LES SPRITES UTILISÉS (grid_size = %d) ===" % grid_size)
	print("Total cellules : %d\n" % (grid_size * grid_size))

	# Trie par ordre alphabétique pour plus de lisibilité
	var sorted_keys = global_counts.keys()
	sorted_keys.sort()

	for sprite_name in sorted_keys:
		var count = global_counts[sprite_name]
		print("%s : %d" % [sprite_name, count])
