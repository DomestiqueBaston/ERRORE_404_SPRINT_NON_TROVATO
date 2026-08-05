class_name Pylon extends Node2D

func lower():
	Sounds.play_pylon_down()
	await get_tree().create_timer(1).timeout
	$Pylon_Animation.play("Going_Down")
	await $Pylon_Animation.animation_finished

func raise():
	await get_tree().create_timer(1).timeout
	$Pylon_Animation.play("Going_Up")
	await $Pylon_Animation.animation_finished
	Sounds.stop_pylon_down()

func drop():
	Sounds.play_pylon_crunch()
	await get_tree().create_timer(1).timeout
	$Pylon_Animation.play("Going_Down_Falling")
	await $Pylon_Animation.animation_finished

func undrop():
	Sounds.play_pylon_crunch()
	await get_tree().create_timer(1).timeout
	$Pylon_Animation.play("Going_Up_Falling")
	await $Pylon_Animation.animation_finished
