class_name Present
extends RigidBody2D


var _lmb_held : bool = false
var _input_enabled : bool = true

@export var _min_velocity : float = 100

var _pickup_sound = preload("res://assets/audio/sfx/pickup.wav")
var _drop_sound = preload("res://assets/audio/sfx/pickup.wav")
var _drop_volume : float = -10
var started : bool = false
@onready var _pickup_audio_player : AudioStreamPlayer = $PickupAudioPlayer
@onready var _drop_audio_player : AudioStreamPlayer = $DropAudioPlayer

var _last_frames_speed : float
var _sound_timer : float = 0
const SOUND_DELAY : float = 0.25


func _ready() -> void:
	_pickup_audio_player.stream = _pickup_sound
	_pickup_audio_player.volume_db = -7
	_drop_audio_player.stream = _drop_sound
	_drop_audio_player.volume_db = _drop_volume


func _process(delta: float) -> void:
	_sound_timer -= delta
	#print(str(_sound_timer))


func _physics_process(delta: float) -> void:
	_last_frames_speed = linear_velocity.length()

	if _lmb_held:
		global_transform.origin = get_global_mouse_position()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and _input_enabled:
		if event.pressed:
			#print("Left button was clicked at ", event.position)
			_toggle_present_held(true)
		else:
			#print("Left button was released at ", event.position)
			_toggle_present_held(false)


func disable_input() -> void:
	_input_enabled = false
	# Reset everything in case player was holding present when timer ran out.
	if _lmb_held:
		_toggle_present_held(false)


func _toggle_present_held(held : bool) -> void:
	# TODO: Play sfx.
	if held:
		_pickup_audio_player.play()
	#print("Toggle present held: " + str(held))
	_lmb_held = held
	# Turn physics off while lmb held.
	freeze = held
	# Change layer so present doesn't bump other presents while being dragged.
	set_collision_layer_value(1, !held)
	set_collision_layer_value(2, !held)
	set_collision_layer_value(3, held)
	# Change ordering z index so held present draws over others.
	z_index = 1 if held else 0


func _on_body_entered(body: Node) -> void:
	_play_sfx_scaled(body)


func _play_sfx_scaled(body: Node) -> void:
	#print(name + " last frame's velocity: " + str(_last_frames_speed))
	var can_play : bool = (_last_frames_speed > _min_velocity and !_lmb_held and started and _sound_timer <= 0)
	if can_play:
		_drop_audio_player.volume_db = _speed_to_db(_last_frames_speed)
		_drop_audio_player.play()
		_sound_timer = SOUND_DELAY


func _speed_to_db(linear_speed : float) -> float:
	# Linear velocity is roughly 0 -> 1000+
	# Maps that range to -20 -> 0.
	var db : float = (linear_speed * 0.02) - 20
	print("Volume (db): " + str(min(0, db)))
	return min(0, db)
