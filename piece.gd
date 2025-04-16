extends Node2D

signal select(piece)

@export var is_white : bool = true

const pieces = {
	"P" : 0,
	"K" : 1,
	"Q" : 2,
	"N" : 3,
	"B" : 4,
	"R" : 5
}

@export_enum("Pawn","King","Queen","Knight","Bishop","Rook") var pieceType : int

var t = 0
var t2 = 0

func _ready() -> void:
	var sc = Global.get_tile_size() / $LightPawn.get_rect().size.x 
	scale = Vector2(sc,sc)

func _physics_process(delta: float) -> void:
	t += 1
	if(t > 7):
		t = 0
		t2 = (t2 + 1) % 8
	global_position = Global.get_grid_pos(Vector2(t,t2))
	#global_position = Global.get_pos_in_board(get_global_mouse_position())
	
	if(Input.is_action_just_pressed("click")):
		select.emit(self)
