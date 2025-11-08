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
	"Cellule_De_Terrain_04", "Cellule_De_Terrain_05", "Cellule_De_Terrain_06"
]

# COINS (fixes)
var corner_sprites := {
	"gauche": "Cellule_De_Terrain_Bord_Gauche",
	"droit":  "Cellule_De_Terrain_Bord_Droit",
	"haut":  "Cellule_De_Terrain_Bord_Haut",
	"bas":   "Cellule_De_Terrain_Bord_Bas"
}

# BORDS (2 variantes aléatoires par côté)
var edge_variants := {
	"bord_haut_gauche":    ["Cellule_De_Terrain_Bord_Haut_Gauche_1", "Cellule_De_Terrain_Bord_Haut_Gauche_2", "Cellule_De_Terrain_Bord_Haut_Gauche_3"],
	"bord_bas_gauche":     ["Cellule_De_Terrain_Bord_Bas_Gauche_1", "Cellule_De_Terrain_Bord_Bas_Gauche_2", "Cellule_De_Terrain_Bord_Bas_Gauche_3"],
	"bord_haut_droit":  ["Cellule_De_Terrain_Bord_Haut_Droit_1", "Cellule_De_Terrain_Bord_Haut_Droit_2"],
	"bord_bas_droit":   ["Cellule_De_Terrain_Bord_Bas_Droit_1",  "Cellule_De_Terrain_Bord_Bas_Droit_2"]
}

func _ready() -> void:
	center_offset = Vector2(
		(grid_size - 1) * iso_offset.x / 2.0,
		-(grid_size - 1) * iso_offset.y / 2.0
	)
	
	var center := int(grid_size * 0.5)
	
	for row in range(grid_size):
		for col in range(grid_size):
			var cell_instance = cell_scene.instantiate()
			var images_node = cell_instance.get_node("Column/Images")
			
			# Cacher tous les Sprite2D
			for child in images_node.get_children():
				if child is Sprite2D:
					child.visible = false
			
			var sprite_name: String = ""
			
			# 1. CENTRE
			if row == center and col == center:
				sprite_name = "Cellule_De_Terrain_Centre"
			
			# 2. COINS
			elif row == 0 and col == 0:
				sprite_name = corner_sprites.haut
			elif row == 0 and col == grid_size - 1:
				sprite_name = corner_sprites.droit
			elif row == grid_size - 1 and col == 0:
				sprite_name = corner_sprites.gauche
			elif row == grid_size - 1 and col == grid_size - 1:
				sprite_name = corner_sprites.bas
			
			# 3. BORDS
			elif row == 0:  # Haut
				sprite_name = _pick_random(edge_variants.bord_haut_droit)
			elif row == grid_size - 1:  # Bas
				sprite_name = _pick_random(edge_variants.bord_bas_gauche)
			elif col == 0:  # Gauche
				sprite_name = _pick_random(edge_variants.bord_haut_gauche)
			elif col == grid_size - 1:  # Droit
				sprite_name = _pick_random(edge_variants.bord_bas_droit)
			
			# 4. INTÉRIEUR
			else:
				sprite_name = _pick_random(interior_sprites)
			
			# Afficher + debug
			var sprite = images_node.get_node_or_null(sprite_name)
			if sprite and sprite is Sprite2D:
				sprite.visible = true
			else:
				push_error("SPRITE MANQUANT dans Cell.tscn : '%s' (row=%d, col=%d)" % [sprite_name, row, col])
			
			# Position
			var x_pos = (col - row) * iso_offset.x
			var y_pos = (col + row) * iso_offset.y
			cell_instance.position = Vector2(x_pos, y_pos) + center_offset
			
			add_child(cell_instance)

func _pick_random(array: Array) -> String:
	return array[randi() % array.size()]
