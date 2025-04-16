extends Node2D


var board : Board

func get_pos_in_board(pos : Vector2):
	return board.get_pos_in_grid(pos)

func get_tile_size():
	return board.get_tile_size()

func get_grid_pos(pos : Vector2):
	return board.get_grid_pos(pos)
