extends Node2D

func show_door():
	$Animation_Door_On.play("Appearing")
	$Animation_Door.play("Alive")
	$Door_Sound/Door_Hum.play()
