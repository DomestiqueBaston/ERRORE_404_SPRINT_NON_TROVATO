extends TextureRect


func _process(_delta: float) -> void:
	visible = $"../Top_Cell_FX_Mask/Screen_Glitch".is_visible_in_tree() or $"../Top_Cell_FX_Mask/Glitch_Only".is_visible_in_tree()
