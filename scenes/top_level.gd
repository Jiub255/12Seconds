extends Node2D


var _game_resource : PackedScene = preload("res://scenes/game/game.tscn")
# What is the type?
var _game_instance : Node

@onready var _music_player : AudioStreamPlayer = $MusicAudioStreamPlayer
@onready var _sfx_player : AudioStreamPlayer = $SfxAudioStreamPlayer
var _button_sound = preload("res://assets/audio/sfx/click.wav")


func _ready() -> void:
	_game_instance = _game_resource.instantiate()
	add_child(_game_instance)
	_game_instance.restart.connect(_restart)
	if _music_player.playing == false:
		_music_player.play()
	_sfx_player.stream = _button_sound
	_sfx_player.play()


func _restart() -> void:
	_game_instance.queue_free()
	_ready()
