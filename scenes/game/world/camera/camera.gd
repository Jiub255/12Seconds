extends Camera2D


@export var _scroll_speed : float = 20.0

@onready var _top_area : Area2D = $TopScrollArea
@onready var _bottom_area : Area2D = $BottomScrollArea

@onready var _top_shape : CollisionShape2D = $TopScrollArea/CollisionShape2D
var _area_height : float

var _mouse_in_scroll_area : bool = false


func _ready() -> void:
	_top_area.mouse_entered.connect(_on_area_entered)
	_top_area.mouse_exited.connect(_on_area_exited)
	_bottom_area.mouse_entered.connect(_on_area_entered)
	_bottom_area.mouse_exited.connect(_on_area_exited)

	# Waits a frame before calling. Kinda like "Start" method from unity.
	call_deferred("_start")


func _start() -> void:
	_area_height = _top_shape.shape.get_rect().size.y


func _physics_process(delta: float) -> void:
	if _mouse_in_scroll_area:
		var screen_half_height = ProjectSettings.get_setting("display/window/size/viewport_height") / 2
		var mouse_y : float = get_local_mouse_position().y
		var top_y : float = -screen_half_height
		var bottom_y : float = -top_y
		var dist_from_top : float = mouse_y - top_y
		var dist_from_bottom : float = bottom_y - mouse_y

		if dist_from_top < dist_from_bottom:
			# Scroll up at a speed scaled by distance from top, and don't go above background.
			global_position.y -= _scroll_speed * (1 - (dist_from_top / _area_height))
			if global_position.y < -screen_half_height * 1.42:
				global_position.y = -screen_half_height * 1.42
		else:
			# Scroll down at a speed scaled by distance from bottom, and don't go below ground.
			global_position.y += _scroll_speed * (1 - (dist_from_bottom / _area_height))
			if global_position.y > screen_half_height:
				global_position.y = screen_half_height


func _on_area_entered() -> void:
	_mouse_in_scroll_area = true
	#print("area entered")


func _on_area_exited() -> void:
	_mouse_in_scroll_area = false
	#print("area exited")
