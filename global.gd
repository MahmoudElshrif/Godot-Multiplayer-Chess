extends Node2D


var board : Board

func get_pos_in_board(pos : Vector2):
	return board.get_pos_in_grid(pos)

func get_tile_size():
	return board.get_tile_size()

func get_grid_pos(pos : Vector2):
	return board.get_grid_pos(pos)

func get_piece(pos : Vector2):
	return board.board[pos.x][pos.y]

func get_piece_from_id(id : int):
	return board.pieces[id]

func get_piece_at(pos : Vector2) -> Piece:
	return board.get_piece_at(pos)
