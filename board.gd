extends Node2D
class_name Board

const PIECEOBJ := preload("res://piece.tscn")

var selected : Piece = null

var pieces = {}

func _ready() -> void:
	Global.board = self
	if(ServerManager.multiplayer.is_server()):
		_init_from_map("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")

@rpc("call_local","reliable")
func add_piece(data):
	var piece = PIECEOBJ.instantiate()
	$pieces.add_child(piece)
	piece.is_white = data["is_white"] #i == i.to_lower()
	piece.pieceType = data["type"] #pieces[i.to_lower()]
	piece.set_pos(data["pos"]) #(Vector2(x,y))
	piece.global_position = get_grid_pos(data["pos"])
	piece.id = data["id"]
	pieces[data["id"]] = piece
	

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
	var id = 0
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
			
			var data = {
				"is_white" : i == i.to_lower(),
				"type": pieces[i.to_lower()],
				"pos": Vector2(x,y),
				"id": id
			}
			
			add_piece.rpc(data)
			
			id += 1
			x += 1

func _input(event: InputEvent) -> void:
	if(get_window().has_focus() and event.is_action_pressed("click")):
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
		move.rpc(selected.id,pos)
	
	unselect() 

func capture(i : Piece):
	i.capture()

@rpc("any_peer","call_local","reliable")
func move(i : int,pos : Vector2, to_capture : int = -1):
	var piece = pieces[i]
	if(to_capture != -1):
		var cap = pieces[to_capture]
		capture(cap)
	piece.move_to(pos)

func proccess_move(to_move : Piece, other_piece : Piece):
	if(to_move.is_white != other_piece.is_white):
		move.rpc(to_move.id,other_piece.boardpos,other_piece.id)
		unselect()
	else:
		select(other_piece)

func select(piece):
	unselect()
	selected = piece
	selected.select()
	$ColorRect.material.set_shader_parameter("selected",selected.boardpos)
	

func unselect():
	$ColorRect.material.set_shader_parameter("selected",Vector2(-1,-1))
	if(selected):
		selected.unselect()
	selected = null

func get_tile_size():
	return $ColorRect.get_global_rect().size.x / 8

func _physics_process(delta: float) -> void:
	pass
