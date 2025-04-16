extends Node2D
class_name Piece

signal _select(piece)

@export var is_white : bool:
	set(value): 
		is_white = value
		set_iswhite()
	get: return is_white

#const pieces = {
	#"k" : 0,
	#"q" : 1,
	#"b" : 2,
	#"n" : 3,
	#"r" : 4,
	#"p" : 5,
#}

@export_enum("King","Queen","Bishop","Knight","Rook","Pawn") var pieceType : int:
	set(value):
		pieceType = value
		set_type()
	get: return pieceType

var boardpos = Vector2.ZERO

func set_iswhite():
	if(is_white):
		$sprite.region_rect.position.y = 135

func set_type():
	$sprite.region_rect.position.x = $sprite.get_rect().size.x * pieceType

func set_pos(pos : Vector2):
	boardpos = pos
	print(pos)

func _ready() -> void:
	var sc = Global.get_tile_size() / ($sprite.get_rect().size.y) 
	global_scale = Vector2(sc,sc)

func _physics_process(delta: float) -> void:
	global_position = Global.get_grid_pos(boardpos)
	
	
	if(Input.is_action_just_pressed("click") and mouse_hover):
		_select.emit(self)

func mouse_hover():
	return $mousearea.get_global_rect().has_point(get_global_mouse_position())

func select():
	pass

func unselect():
	pass
