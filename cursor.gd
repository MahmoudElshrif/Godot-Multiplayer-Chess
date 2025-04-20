extends Node2D



var prevpos := Vector2.ZERO
var init_rot := 0
var invert := 1

func _ready() -> void:
	prevpos = global_position
	init_rot = rotation_degrees
	if(init_rot != 0):
		invert *= -1

func _process(delta: float) -> void:
	var vel = global_position - prevpos
	
	rotation_degrees = lerp(rotation_degrees,init_rot + vel.x * 4 * invert,0.03)
	
	prevpos = global_position
