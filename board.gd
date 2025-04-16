extends Node2D
class_name Board

const PIECEOBJ := preload("res://piece.tscn")
func _ready() -> void:
	Global.board = self
	_init_from_map("pppppppp/rnbqknbr/8/3K4/8/8/RNBQKBNR/PPPPPPPP")

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
	return pos
	
func _init_from_map(map):
	const pieces = {
		"k" : 0,
		"q" : 1,
		"b" : 2,
		"n" : 3,
		"r" : 4,
		"p" : 5,
	}
	var x = 0
	var y = 0
	for i in map:
		i = i as String
		if(i.is_valid_int()):
			x += int(i)
		elif(i == "/"):
			pass
		else:
			while(x > 7):
				x -= 8
				y += 1
			var piece = PIECEOBJ.instantiate()
			$pieces.add_child(piece)
			piece.is_white = i == i.to_lower()
			piece.pieceType = pieces[i.to_lower()]
			piece.set_pos(Vector2(x,y))
			x += 1

func get_tile_size():
	return $ColorRect.get_global_rect().size.x / 8

func _physics_process(delta: float) -> void:
	pass
