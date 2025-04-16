extends Node2D
class_name Board

func _ready() -> void:
	Global.board = self

func get_pos_in_grid(pos : Vector2):
	pos -= global_position
	
	pos /= $ColorRect.get_global_rect().size
	pos *= 8
	pos = pos.floor()
	pos.x = clamp(pos.x,0,7)
	pos.y = clamp(pos.y,0,7)
	pos /= 8
	pos *= $ColorRect.get_global_rect().size
	
	
	pos += global_position
	
	return pos

func get_grid_pos(pos: Vector2):
	pos *= get_tile_size()
	pos += global_position
	
	return pos

func get_pos_in_grid_center(pos : Vector2):
	pos = get_pos_in_grid(pos)
	pos += $ColorRect.size / 16
	
	return

func get_tile_size():
	return $ColorRect.get_global_rect().size.x / 8

func _physics_process(delta: float) -> void:
	pass
