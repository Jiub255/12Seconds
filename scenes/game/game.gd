class_name Game
extends Node2D


signal restart()

@onready var world : World = $World
@onready var ui : UI = $UI
@onready var measurement_button : CheckButton = $UI/MeasurementControl/HBoxContainer/CheckButton
var ui_resource : PackedScene = preload("res://scenes/game/ui/ui.tscn")
var world_resource : PackedScene = preload("res://scenes/game/world/world.tscn")

func _ready() -> void:
	print(str(world.tick.is_connected(ui.on_tick)))
	if !world.tick.is_connected(ui.on_tick):
		world.tick.connect(ui.on_tick)
	print(str(world.tick.is_connected(ui.on_tick)))
	if !world.gameover.is_connected(ui.on_gameover):
		world.gameover.connect(ui.on_gameover)
	if !world.height_counter.is_connected(ui.on_height_counter):
		world.height_counter.connect(ui.on_height_counter)
	if !world.start_measuring.is_connected(ui.on_start_measuring):
		world.start_measuring.connect(ui.on_start_measuring)
	if !world.done_measuring.is_connected(ui.on_done_measuring):
		world.done_measuring.connect(ui.on_done_measuring)
	if !measurement_button.toggled.is_connected(world.on_toggle_measurement):
		measurement_button.toggled.connect(world.on_toggle_measurement)
	if !ui.start_game.is_connected(world._on_start_game):
		ui.start_game.connect(world._on_start_game)


# TODO: Fix. I think the references to ui and world aren't getting set here to _ready doesn't connect signals. Maybe.
# Maybe just make another higher level node and just destroy then reinstantiate game.tscn?
func _reset() -> void:
	restart.emit()

	# TODO: Destroy and then reinstantiate game and ui scenes? Then reconnect signals?
	# Probably gonna add a main menu too, with play and high scores options. Maybe an actual options too.

	#print("_reset called from game.gd")
#
	#for child in get_children():
		#child.queue_free()
#
	#var ui_instance = ui_resource.instantiate()
	#add_child(ui_instance)
	#ui = ui_instance as UI
#
	#var world_instance = world_resource.instantiate()
	#add_child(world_instance)
	#world = world_instance as World
	#_ready()


func _on_ui_restart() -> void:
	_reset()
