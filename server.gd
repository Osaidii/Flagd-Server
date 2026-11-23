extends Node2D

const PORT := 7583

var peer: WebSocketMultiplayerPeer

func _ready() -> void:
	start_server()

func start_server() -> bool:
	peer = WebSocketMultiplayerPeer.new()
	var err = peer.create_server(PORT)
	if err != OK:
		return false
	multiplayer.multiplayer_peer = peer
	return true
