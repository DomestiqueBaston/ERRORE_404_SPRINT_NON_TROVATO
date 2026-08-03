extends Node

func play_validation():
	$UI_Sounds/Validation.play()
	
func play_cancel():
	$UI_Sounds/Cancel.play()
	
func play_menu_navigation():
	$UI_Sounds/Menu_Navigation.play()
	
func play_three_two_one():
	$UI_Sounds/Three_Two_One.play()
	
func play_go():
	$UI_Sounds/Go.play()

func play_full():
	$UI_Sounds/Full.play()

func play_woosh():
	$UI_Sounds/Woosh.play()

func play_bang():
	$Music/Bang.play()

func play_music():
	$Music/Music.play()

func stop_music():
	$Music/Music.stop()

func play_intro():
	$Music/Intro.play()

func stop_intro():
	$Music/Intro.stop()

func play_cell_up_down():
	$Cell_Pylon_Alarms/Cell_Up_Down.play()

func stop_cell_up_down():
	$Cell_Pylon_Alarms/Cell_Up_Down.stop()

func play_cell_slide():
	$Cell_Pylon_Alarms/Column_Row_Slide.play()

func stop_cell_slide():
	$Cell_Pylon_Alarms/Column_Row_Slide.stop()
