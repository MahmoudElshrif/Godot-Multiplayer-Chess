extends Node2D
class_name Piece

signal _select(piece)

@export var move_generator : MovesGenerator

@export var is_white : bool:
	set(value): 
		is_white = value
		set_iswhite()
	get: return is_white

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
	return move_generator.legalmoves(self)
