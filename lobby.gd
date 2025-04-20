extends Node2D


func _on_join_pressed() -> void:
	ServerManager.creat_client("")
	ServerManager.multiplayer.connected_to_server.connect(go_to_game)


func _on_host_pressed() -> void:
	ServerManager.creat_server()
	ServerManager.multiplayer.peer_connected.connect(go_to_game)


func go_to_game(id = 1):
	get_tree().change_scene_to_file("res://node_2d.tscn")
