class_name Pylon extends Node2D

func lower():
	Sounds.play_pylon_down()
	await get_tree().create_timer(0.5).timeout
	$Pylon_Animation.play("Going_Down")
	await $Pylon_Animation.animation_finished
	Sounds.stop_pylon_down()

func raise():
	$Pylon_Animation.play("Going_Up")
	await $Pylon_Animation.animation_finished

func drop():
	Sounds.play_pylon_crunch()
	await get_tree().create_timer(0.25).timeout
	$Pylon_Animation.play("Going_Down_Falling")
	await $Pylon_Animation.animation_finished

func undrop():
	$Pylon_Animation.play("Going_Up_Falling")
	await $Pylon_Animation.animation_finished

func start_sliding():
	$Pylon_Animation.play("Sliding_Beginning")

func stop_sliding():
	$Pylon_Animation.play("Sliding_End")
