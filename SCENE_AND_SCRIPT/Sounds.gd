extends Node

@onready var _music: AudioStreamPlayer = $Music/Music
@onready var _victory_anim: AnimationPlayer = $Music/Music_Win_Animation

func stop_all(music_too: bool = true):
	for sound: AudioStreamPlayer in find_children("*", "AudioStreamPlayer"):
		if music_too or sound != _music:
			sound.stop()
	stop_victory_sound()

func play_validation():
	$UI_Sounds/Validation.play()
	
func play_cancel():
	$UI_Sounds/Cancel.play()
	
func play_menu_navigation():
	$UI_Sounds/Menu_Navigation.play()
	
func play_three_two_one():
	var sound = $UI_Sounds/Three_Two_One
	sound.play()
	await sound.finished
	
func play_go():
	$UI_Sounds/Go.play()

func play_full():
	$UI_Sounds/Full.play()

func play_woosh():
	$UI_Sounds/Woosh.play()

func play_bang():
	$Music/Bang.play()

func play_music():
	_music.play()

func stop_music():
	_music.stop()

func play_intro():
	$Music/Intro.play()

func stop_intro():
	$Music/Intro.stop()

func play_cell_up_down():
	$Cell_Pylon_Alarms/Cell_Down.play()

func stop_cell_up_down():
	$Cell_Pylon_Alarms/Cell_Down.stop()

func play_cell_slide():
	$Cell_Pylon_Alarms/Column_Row_Slide.play()

func stop_cell_slide():
	$Cell_Pylon_Alarms/Column_Row_Slide.stop()

func play_cell_disappearing():
	$Cell_Pylon_Alarms/Cell_Disappearing.play()

func play_pylon_down():
	$Cell_Pylon_Alarms/Pylon_Down.play()

func stop_pylon_down():
	$Cell_Pylon_Alarms/Pylon_Down.stop()

func play_pylon_crunch():
	$Cell_Pylon_Alarms/Pylon_Crunch.play()

func play_useless_alarm1():
	$Misc/Useless_Alarm_1.play()

func play_useless_alarm2():
	$Misc/Useless_Alarm_2.play()

func play_bug_sound():
	$Misc/Bug_Sound.play()

func stop_bug_sound():
	$Misc/Bug_Sound.stop()

func play_disappearing():
	$UI_Sounds/Disappearing.play()

func play_victory_sound():
	_victory_anim.play(&"Pitch_Down")

func stop_victory_sound():
	_victory_anim.play(&"RESET")
