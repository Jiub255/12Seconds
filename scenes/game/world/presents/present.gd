class_name Present
extends RigidBody2D


var lmb_held : bool = false
var input_enabled : bool = true


func _physics_process(delta: float) -> void:
	if lmb_held:
		global_transform.origin = get_global_mouse_position()

# TODO: Can this be done without connecting to its own signal?
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and input_enabled:
		if event.pressed:
			#print("Left button was clicked at ", event.position)
			_toggle_present_held(true)
		else:
			#print("Left button was released at ", event.position)
			_toggle_present_held(false)


func disable_input() -> void:
	input_enabled = false
	# Reset everything in case player was holding present when timer ran out.
	if lmb_held:
		_toggle_present_held(false)


func _toggle_present_held(held : bool) -> void:
	print("Toggle present held: " + str(held))
	lmb_held = held
	# Turn physics off while lmb held.
	freeze = held
	# Change layer so present doesn't bump other presents while being dragged.
	set_collision_layer_value(1, !held)
	set_collision_layer_value(2, !held)
	set_collision_layer_value(3, held)
	# Change ordering z index so held present draws over others.
	z_index = 1 if held else 0
