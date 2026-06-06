extends Sprite2D

# Références déjà définies dans le code
@onready var screen_glitch: ColorRect = $Screen_Glitch
@onready var glitch_only: ColorRect = $Glitch_Only
@onready var glitch_for_screen_glitch: AudioStreamPlayer = $"../../../Sound/Glitch_For_Screen_Glitch"
@onready var glitch_for_glitch_only: AudioStreamPlayer = $"../../../Sound/Glitch_For_Glitch_Only"

# Optionnel : un son pour le Sprite2D lui-même
@export var sprite_audio: AudioStreamPlayer

func _ready() -> void:
	# Connexion des signaux visibility_changed pour les trois nœuds
	screen_glitch.visibility_changed.connect(_on_screen_glitch_visibility_changed)
	glitch_only.visibility_changed.connect(_on_glitch_only_visibility_changed)
	visibility_changed.connect(_on_sprite_visibility_changed)
	
	# État initial cohérent au démarrage
	_sync_audio_with_visibility()

func _sync_audio_with_visibility() -> void:
	# Screen_Glitch
	if screen_glitch.visible and glitch_for_screen_glitch and not glitch_for_screen_glitch.playing:
		glitch_for_screen_glitch.play()
	elif not screen_glitch.visible and glitch_for_screen_glitch:
		glitch_for_screen_glitch.stop()
	
	# Glitch_Only
	if glitch_only.visible and glitch_for_glitch_only and not glitch_for_glitch_only.playing:
		glitch_for_glitch_only.play()
	elif not glitch_only.visible and glitch_for_glitch_only:
		glitch_for_glitch_only.stop()
	
	# Sprite2D lui-même
	if visible and sprite_audio and not sprite_audio.playing == false:
		sprite_audio.play()
	elif not visible and sprite_audio:
		sprite_audio.stop()

func _on_screen_glitch_visibility_changed() -> void:
	if screen_glitch.visible:
		if glitch_for_screen_glitch and not glitch_for_screen_glitch.playing:
			glitch_for_screen_glitch.play()
	else:
		if glitch_for_screen_glitch:
			glitch_for_screen_glitch.stop()

func _on_glitch_only_visibility_changed() -> void:
	if glitch_only.visible:
		if glitch_for_glitch_only and not glitch_for_glitch_only.playing:
			glitch_for_glitch_only.play()
	else:
		if glitch_for_glitch_only:
			glitch_for_glitch_only.stop()

func _on_sprite_visibility_changed() -> void:
	if visible and sprite_audio and not sprite_audio.playing:
		sprite_audio.play()
	elif not visible and sprite_audio:
		sprite_audio.stop()
