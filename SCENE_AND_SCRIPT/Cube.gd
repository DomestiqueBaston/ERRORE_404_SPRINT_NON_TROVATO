extends Node2D


func _ready():
	$Animation_Cube_On_Off.play("Appearing")
	$Animation_Cube.play("Alive")
	$Cube_Hum.play()
