extends Resource
class_name MovesGenerator

const types = ["King","Queen","Bishop","Knight","Rook","Pawn"]


func legalmoves(piece : Piece):
	var type = types[piece.pieceType]
	
	if(type == "King"):
		return king_moves(piece)
	if(type == "Pawn"):
		return pawn_moves(piece)
	if(type == "Rook"):
		return rook_moves(piece)
	if(type == "Queen"):
		return queen_moves(piece)
	if(type == "Bishop"):
		return bishop_moves(piece)
	if(type == "Knight"):
		return knight_moves(piece)
	
	return [[],[]]

func pawn_moves(piece : Piece):
	var legalmoves = []
	var legalcaptures = []
	
	var dir = -1 if piece.is_white else 1
	
	if(Global.get_piece_at(piece.boardpos + Vector2(0,dir)) == null):
		legalmoves.append(piece.boardpos + Vector2(0,dir))
	if(Global.get_piece_at(piece.boardpos + Vector2(1,dir)) != null and Global.get_piece_at(piece.boardpos + Vector2(1,dir)).is_white != piece.is_white):
		legalcaptures.append(piece.boardpos + Vector2(1,dir))
	if(Global.get_piece_at(piece.boardpos + Vector2(-1,dir)) != null and Global.get_piece_at(piece.boardpos + Vector2(-1,dir)).is_white != piece.is_white):
		legalcaptures.append(piece.boardpos + Vector2(-1,dir))
	
	if(!piece.moved):
		if(legalmoves.size() == 1):
			if(Global.get_piece_at(piece.boardpos + Vector2(0,dir * 2)) == null):
				legalmoves.append(piece.boardpos + Vector2(0,dir * 2))
	
	return [legalmoves,legalcaptures]
	

func rook_moves(piece : Piece):
	var dirs = [Vector2(-1,0),Vector2(0,1),Vector2(1,0),Vector2(0,-1)]
	
	return _line_moves(piece, dirs)

func bishop_moves(piece : Piece):
	var dirs = [Vector2(-1,-1),Vector2(-1,1),Vector2(1,1),Vector2(1,-1)]
	
	return _line_moves(piece, dirs)

func queen_moves(piece : Piece):
	var dirs = [Vector2(-1,0),Vector2(0,1),Vector2(1,0),Vector2(0,-1)]
	dirs += [Vector2(-1,-1),Vector2(-1,1),Vector2(1,1),Vector2(1,-1)]
	
	
	return _line_moves(piece,dirs)

func king_moves(piece):
	var moves = []
	var captures = []
	
	for i in range(-1,2):
		for j in range(-1,2):
			var pos :Vector2= piece.boardpos + Vector2(i,j)
			if(not is_inside_bounds(pos)):
				continue
			if(can_move_to(pos)):
				moves.append(pos)
			elif(can_capture(piece,pos)):
				captures.append(pos)
	
	return [moves, captures]

func knight_moves(piece):
	var dirs = [
		Vector2(2, 1),   
		Vector2(2, -1),  
		Vector2(-2, 1),  
		Vector2(-2, -1), 
		Vector2(1, 2),   
		Vector2(1, -2),  
		Vector2(-1, 2),  
		Vector2(-1, -2)  
	]
	
	var moves = []
	var captures = []
	
	for i in dirs:
		var pos :Vector2= piece.boardpos + i
		if(!is_inside_bounds(pos)):
			continue
		if(can_move_to(pos)):
			moves.append(pos)
		if(can_capture(piece,pos)):
			captures.append(pos)
	
	return [moves,captures]
	
	


func can_move_to(pos: Vector2) -> bool:
	return is_inside_bounds(pos) and Global.get_piece_at(pos) == null

func can_capture(piece : Piece, pos: Vector2) -> bool:
	var p :Piece= Global.get_piece_at(pos)
	return p and p.is_white != piece.is_white


func is_inside_bounds(pos : Vector2):
	if(pos.x < 0 or pos.x > 7):
		return false
	if(pos.y < 0 or pos.y > 7):
		return false
		
	return true

func _line_moves(piece : Piece, directions: Array) -> Array:
	var board = Global.board
	var moves := []
	var captures := []

	for dir in directions:
		var pos : Vector2= piece.boardpos + dir
		while is_inside_bounds(pos):
			var target = Global.get_piece_at(pos)
			if target == null:
				moves.append(pos)
			else:
				if target.is_white != piece.is_white:
					captures.append(pos)
				break
			pos += dir

	return [moves, captures]
