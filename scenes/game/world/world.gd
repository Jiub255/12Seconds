class_name World
extends Node2D


enum measurements {
	FEET,
	CM
}


var measurement : measurements = measurements.FEET


signal tick(time_left : float)
signal gameover()
signal height_counter(current_height : String)
signal start_measuring()
signal done_measuring(stack_height_px : int)


var game_over : bool = false
const TIMELIMIT : float = 12.0
var game_timer : float

@onready var presents : Node = $Presents

var stabilizing : bool = false
var stabilizer_timer : float = 0.0
const POLLTIME : float = 0.2

const MIN_VELOCITY : float = 1.0
const SPEED_MULTIPLIER : float = 5.0
const GROUND_VIEWPORT_BUFFER : float = 10.0
const MAX_PRESENT_RADIUS : float = 250.0
const RAYCAST_STEP_HEIGHT : float = 3.0

@onready var raycast : RayCast2D = $RayCast2D
var finding_height : bool = false

# I hate this.
var waited_one_physics_tick : bool = false

var _stack_height : int

var _started : bool = false


func _ready() -> void:
	game_timer = TIMELIMIT
	tick.emit(game_timer)


func _on_start_game() -> void:
	_started = true


func _process(delta: float) -> void:
	if !game_over and _started:
		game_timer -= delta
		tick.emit(game_timer)
		if game_timer <= 0:
			game_timer = TIMELIMIT
			_end_game()


func _physics_process(delta: float) -> void:
	if stabilizing:
		stabilizer_timer += delta
		if stabilizer_timer >= POLLTIME:
			stabilizer_timer = 0.0
			if _simulation_done():
				stabilizing = false
				Engine.time_scale = 1
				# Need to change ticks per second too so that physics doesn't break.
				Engine.physics_ticks_per_second = 60
				_find_stack_height()

	if finding_height:
		if !waited_one_physics_tick:
			waited_one_physics_tick = true
			return

		raycast.position.y -= RAYCAST_STEP_HEIGHT
		_stack_height = -raycast.position.y + ProjectSettings.get_setting("display/window/size/viewport_height")
		var height : String = format_height(_stack_height)
		height_counter.emit(height)
		if !raycast.is_colliding():
			done_measuring.emit(_stack_height)
			finding_height = false
			print("Stack Height: " + str(_stack_height))


func format_height(height : int) -> String:
	var height_inches : int = roundi(height * 0.13504)
	if measurement == measurements.FEET:
		var feet : int = floori(height_inches / 12)
		var inches : int = height_inches % 12
		if feet == 0:
			return str(inches) + " in"
		if inches == 0:
			return str(feet) + " ft"
		else:
			return str(feet) + " ft " + str(inches) + " in"
	else:
		#var cm : int = roundi(height * 0.34302)
		var cm : int = roundi(height_inches * 2.54)
		return str(cm) + " cm"


# Run the simulation super fast for a while to get to a stable state,
# then find the highest point of the stack.
func _end_game() -> void:
	game_over = true
	gameover.emit()
	_disable_input()
	_stabilize_stack_then_find_height()


func _disable_input() -> void:
	for present : Present in presents.get_children():
		present.disable_input()


func _stabilize_stack_then_find_height() -> void:
	# Run at super fast game speed until the presents stop moving.
	# Poll every POLLTIME seconds and check their velocities.
	stabilizing = true
	Engine.time_scale = SPEED_MULTIPLIER
	# Need to change ticks per second too so that physics doesn't break.
	Engine.physics_ticks_per_second = SPEED_MULTIPLIER * 60


func _simulation_done() -> bool:
	var done : bool = true
	for present : Present in presents.get_children():
		if present.get_linear_velocity().length() > MIN_VELOCITY:
			done = false
	return done


# Start the raycasts slightly above the ground.
# Run an upward series of sideways raycasts starting from there, then the first to NOT hit a present is the stack height.
func _find_stack_height() -> void:
	raycast.position.y = ProjectSettings.get_setting("display/window/size/viewport_height") - GROUND_VIEWPORT_BUFFER
	start_measuring.emit()
	finding_height = true


func on_toggle_measurement(cm : bool):
	if cm:
		measurement = measurements.CM
	else:
		measurement = measurements.FEET
	height_counter.emit(format_height(_stack_height))
