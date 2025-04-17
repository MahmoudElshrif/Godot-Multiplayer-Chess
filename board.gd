extends Node2D
class_name Board

const PIECEOBJ := preload("res://piece.tscn")

var selected : Piece = null


func _ready() -> void:
	Global.board = self
	_init_from_map("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
	

func get_pos_in_grid(pos : Vector2):
	pos -= global_position
	
	pos /= $ColorRect.get_global_rect().size
	pos *= 8
	pos = pos.floor()
	pos.x = clamp(pos.x,0,7)
	pos.y = clamp(pos.y,0,7)
	
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
			piece.global_position = get_grid_pos(Vector2(x,y))
			x += 1

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("click")):
		_check_select()


func _check_select():
	var pos = get_pos_in_grid(get_global_mouse_position())
	
	if(selected and pos == selected.boardpos):
		unselect()
		return
	
	for i : Piece in $pieces.get_children():
		if(i.boardpos == pos):
			if(selected):
				proccess_move(selected,i)
			else:
				select(i)
			return
	
	if(selected):
		move(selected,pos)
	
	unselect() 

func capture(i : Piece):
	i.capture()

func move(i : Piece,pos : Vector2):
	i.move_to(pos)

func proccess_move(to_move : Piece, other_piece : Piece):
	if(to_move.is_white != other_piece.is_white):
		move(to_move,other_piece.boardpos)
		capture(other_piece)
		unselect()
	else:
		select(other_piece)

func select(piece):
	unselect()
	selected = piece
	selected.select()
	$selected.show()

func unselect():
	if(selected):
		selected.unselect()
	selected = null
	$selected.hide()

func get_tile_size():
	return $ColorRect.get_global_rect().size.x / 8

func _physics_process(delta: float) -> void:
	if(selected):
		$selected.global_position = get_grid_pos(selected.boardpos)
