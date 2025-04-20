extends Node2D


func creat_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(8080)
	multiplayer.multiplayer_peer = peer
	

func creat_client(ip : String):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip,8080)
	multiplayer.multiplayer_peer = peer
	
