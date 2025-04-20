extends Node2D

func _ready() -> void:
	pass
	#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func creat_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(8080)
	multiplayer.multiplayer_peer = peer
	

func creat_client(ip : String):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip,8080)
	multiplayer.multiplayer_peer = peer
	

func _process(delta: float) -> void:
	pass
	#if(get_window().has_focus()):
		#move_cursor.rpc(get_global_mouse_position())


@rpc("any_peer","call_local","unreliable")
func move_cursor(pos):
	if(multiplayer.get_remote_sender_id() == multiplayer.get_unique_id()):
		$player1.global_position = pos
	else:
		$player2.global_position = pos
