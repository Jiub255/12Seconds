extends Node2D


var _game_resource : PackedScene = preload("res://scenes/game/game.tscn")
# What is the type?
var _game_instance : Node


func _ready() -> void:
	_game_instance = _game_resource.instantiate()
	add_child(_game_instance)
	_game_instance.restart.connect(_restart)


func _restart() -> void:
	_game_instance.queue_free()
	_ready()
