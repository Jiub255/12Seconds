class_name Camera
extends Camera2D


@export var _scroll_speed : float = 20.0
## Thickness of the edge scroll zone in percentage of screen height (px).
@export_range(0, 0.4) var _percent_thickness : float = 0.20

@onready var _top_area : Area2D = $TopScrollArea
@onready var _bottom_area : Area2D = $BottomScrollArea

@onready var _top_shape : CollisionShape2D = $TopScrollArea/CollisionShape2D
var _area_height : float
var started : bool = false

func _physics_process(delta: float) -> void:
	# TODO: Use mouse position and screen size instead of areas so it will work when mouse leaves the viewport?
	var mouse_y : float = get_viewport().get_mouse_position().y
	var viewport_y : float = get_viewport_rect().size.y
	var dist_from_center : float = -mouse_y + roundi(viewport_y / 2)
	var border_dist : float = roundi(viewport_y * (0.5 - _percent_thickness))
	var max_dist : float = roundi(viewport_y / 2)
	# Dist from center ranges from border_dist to max_dist (or more, but clamp it).
	# Map that to 0 through 1 as a scroll speed strength modifier.
	var modifier : float = clamp((abs(dist_from_center) - border_dist) / (max_dist - border_dist), 0, 1)
	#print("Mouse y-position: " + str(mouse_y) + ", Viewport rect y-size: " + str(viewport_y) +
		#", Distance from center: " + str(dist_from_center) + ", Border distance: " + str(border_dist) +
		#", Max distance: " + str(max_dist) + ", Modifier: " + str(modifier))
	if abs(dist_from_center) > border_dist and started:
		if dist_from_center > 0:
			# Scroll up at a speed scaled by distance from top, and don't go above ceiling.
			global_position.y -= _scroll_speed * modifier
			var ceiling_y : float = -roundi(viewport_y / 2) * 1.42
			if global_position.y < ceiling_y:
				global_position.y = ceiling_y
		elif dist_from_center < 0:
			# Scroll down at a speed scaled by distance from bottom, and don't go below ground.
			global_position.y += _scroll_speed * modifier
			var floor_y : float = viewport_y / 2
			if global_position.y > floor_y:
				global_position.y = floor_y
