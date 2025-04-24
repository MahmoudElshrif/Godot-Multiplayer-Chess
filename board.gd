extends Node2D
class_name Board

const PIECEOBJ := preload("res://piece.tscn")
signal _flip
signal _host_finished_board

var selected : Piece = null
var whiteturn := true
var is_white := false
var pieces = {}
var isgameover := false
var board = []
var legalmoves = []
var legalcapture = []
var selectind = 0

func _ready() -> void:
	for i in range(8):
		var l = []
		for x in range(8):
			l.append(null)
		board.append(l)
	
	Global.board = self
	if(ServerManager.multiplayer.is_server()):
		is_white = true
		_init_from_map("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
	else:
		await _host_finished_board
	
	if(!is_white):
		flip()

func switch_turn():
	whiteturn = not whiteturn

func flip():
	_flip.emit()
	for i in $pieces.get_children():
		i = i as Piece
		i.flip()

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
	board[piece.boardpos.x][piece.boardpos.y] = piece.id

@rpc("reliable")
func finished_init_board():
	_host_finished_board.emit()

func win(white : bool):
	$wins.show()
	if(white):
		$wins.text = "wHITE"
	else:
		$wins.text = "BalcK"
	
	$wins.text += " Winss!!1!"
	isgameover = true
	

func get_pos_in_grid(pos : Vector2):
	pos -= $ColorRect.global_position
	
	pos /= $ColorRect.get_global_rect().size
	pos *= 8
	pos = pos.floor()
	pos.x = clamp(pos.x,0,7)
	pos.y = clamp(pos.y,0,7)
	
	return pos

func get_grid_pos(pos: Vector2):
	pos *= get_tile_size()
	pos += $ColorRect.global_position
	
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
				"is_white" : i != i.to_lower(),
				"type": pieces[i.to_lower()],
				"pos": Vector2(x,y),
				"id": id
			}
			
			add_piece.rpc(data)
			
			id += 1
			x += 1
	
	finished_init_board.rpc()

func _input(event: InputEvent) -> void:
	if(get_window().has_focus() and event.is_action_pressed("click")):
		_check_select()


func _check_select():
	if(isgameover):
		return
	var pos = get_pos_in_grid(get_global_mouse_position())
	if(pos in legalmoves):
		move.rpc(selected.id,pos,is_white)
		return
	var pieceid = board[pos.x][pos.y]
	if(pieceid != null):
		var i : Piece = pieces[board[pos.x][pos.y]]
		if(pos in legalcapture):
			proccess_move(selected,i)
			return
		if(selected == i):
			unselect()
		elif(i.is_white == is_white):
			select(i)

	

func capture(i : Piece):
	i.capture()
	if(i.pieceType == 0):
		win(not i.is_white)

@rpc("any_peer","call_local","reliable")
func move(i : int,pos : Vector2,team : bool, to_capture : int = -1):
	#if(multiplayer.get_unique_id() == multiplayer.get_remote_sender_id()):
		#print(str(multiplayer.get_unique_id()) + " " + str(team) + " " + str(is_white) + " " + str(whiteturn))
	if(whiteturn != team):
		return
	var piece :Piece= pieces[i]
	#print(piece.is_white)
	if(piece.is_white != team):
		return
	if(to_capture != -1):
		var cap = pieces[to_capture]
		capture(cap)
	unselect()
	board[piece.boardpos.x][piece.boardpos.y] = null
	piece.move_to(pos)
	board[piece.boardpos.x][piece.boardpos.y] = piece.id
	switch_turn()


func get_legal_moves(piece : Piece):
	var moves = piece.legalmoves()
	
	legalmoves = moves[0]
	legalcapture = moves[1]

	

func proccess_move(to_move : Piece, other_piece : Piece):
	if(to_move.is_white != other_piece.is_white):
		move.rpc(to_move.id,other_piece.boardpos,is_white,other_piece.id)
		unselect()
	else:
		select(other_piece)

func select(piece):
	if(piece.is_white != is_white):
		return
	unselect()
	selected = piece
	selected.select()
	$ColorRect.material.set_shader_parameter("selected",selected.boardpos)
	get_legal_moves(piece)
	

func unselect():
	$ColorRect.material.set_shader_parameter("selected",Vector2(-1,-1))
	if(selected):
		selected.unselect()
	selected = null
	legalmoves = []
	legalcapture = []

func get_tile_size():
	return $ColorRect.get_global_rect().size.x / 8

func _physics_process(delta: float) -> void:
	var moveslist = legalmoves + legalcapture
	
	if(moveslist.size() > 0):
		selectind += 1
		selectind %= moveslist.size()
		$ColorRect.material.set_shader_parameter("selected",moveslist[selectind])
		
