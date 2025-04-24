extends Node2D
class_name Piece

signal _select(piece)

@export var move_generator : Resource

@export var is_white : bool:
	set(value): 
		is_white = value
		set_iswhite()
	get: return is_white

const types = ["King","Queen","Bishop","Knight","Rook","Pawn"]

@export_enum("King","Queen","Bishop","Knight","Rook","Pawn") var pieceType : int:
	set(value):
		pieceType = value
		set_type()
	get: return pieceType

var selected := false
var boardpos = Vector2.ZERO
var id := 0
var moved = false

func set_iswhite():
	if(is_white):
		$sprite.region_rect.position.y = 0
	else:
		$sprite.region_rect.position.y = 135

func set_type():
	$sprite.region_rect.position.x = $sprite.get_rect().size.x * pieceType

func flip():
	$sprite.rotation_degrees = 180

func set_pos(pos : Vector2):
	boardpos = pos

func _ready() -> void:
	var sc = Global.get_tile_size() / ($sprite.get_rect().size.y) 
	global_scale = Vector2(sc,sc)

func _physics_process(delta: float) -> void:
	#global_position = Global.get_grid_pos(boardpos)
	
	
	if(Input.is_action_just_pressed("click")):
		if(mouse_hover()):
			_select.emit(self)
		else:
			if(selected):
				unselect()


func capture():
	queue_free()

func move_to(pos : Vector2):
	boardpos = pos
	moved = true
	var t = create_tween()
	t.tween_property(self,"global_position",Global.get_grid_pos(pos),0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func mouse_hover():
	return $mousearea.get_global_rect().has_point(get_global_mouse_position())

func select():
	selected = true
	#hide()

func unselect():
	selected = false
	#show()


func legalmoves():
	var type = types[pieceType]
	
	if(type == "Pawn"):
		return pawn_moves()
	if(type == "Rook"):
		return rook_moves()
	if(type == "Queen"):
		return queen_moves()
	if(type == "Bishop"):
		return bishop_moves()
	
	return [[],[]]

func pawn_moves():
	var legalmoves = []
	var legalcaptures = []
	
	var dir = -1 if is_white else 1
	
	if(Global.get_piece_at(boardpos + Vector2(0,dir)) == null):
		legalmoves.append(boardpos + Vector2(0,dir))
	if(Global.get_piece_at(boardpos + Vector2(1,dir)) != null and Global.get_piece_at(boardpos + Vector2(1,dir)).is_white != is_white):
		legalcaptures.append(boardpos + Vector2(1,dir))
	if(Global.get_piece_at(boardpos + Vector2(-1,dir)) != null and Global.get_piece_at(boardpos + Vector2(-1,dir)).is_white != is_white):
		legalcaptures.append(boardpos + Vector2(-1,dir))
	
	if(!moved):
		if(legalmoves.size() == 1):
			if(Global.get_piece_at(boardpos + Vector2(0,dir * 2)) == null):
				legalmoves.append(boardpos + Vector2(0,dir * 2))
	
	return [legalmoves,legalcaptures]
	

func rook_moves():
	var dirs = [Vector2(-1,0),Vector2(0,1),Vector2(1,0),Vector2(0,-1)]
	
	return _line_moves(dirs)

func bishop_moves():
	var dirs = [Vector2(-1,-1),Vector2(-1,1),Vector2(1,1),Vector2(1,-1)]
	
	return _line_moves(dirs)

func queen_moves():
	var dirs = [Vector2(-1,0),Vector2(0,1),Vector2(1,0),Vector2(0,-1)]
	dirs += [Vector2(-1,-1),Vector2(-1,1),Vector2(1,1),Vector2(1,-1)]
	
	
	return _line_moves(dirs)


func is_inside_bounds(pos : Vector2):
	if(pos.x < 0 or pos.x > 7):
		return false
	if(pos.y < 0 or pos.y > 7):
		return false
		
	return true

func _line_moves(directions: Array) -> Array:
	var board = Global.board
	var moves := []
	var captures := []

	for dir in directions:
		var pos :Vector2= boardpos + dir
		while is_inside_bounds(pos):
			var target = Global.get_piece_at(pos)
			if target == null:
				moves.append(pos)
			else:
				if target.is_white != is_white:
					captures.append(pos)
				break
			pos += dir

	return [moves, captures]
