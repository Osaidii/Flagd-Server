extends Node2D

const PORT := 7583

var tcp_server: TCPServer
var peers := {}
var next_id := 1

func start_server() -> void:
	tcp_server = TCPServer.new()
	var err = tcp_server.listen(PORT)
	if err != OK:
		push_error("listen failed: %d" % err)

func send_to_client(peer_id: int, type: String, ...args) -> void:
	var target = peers.get(peer_id)
	if target and target.get_ready_state() == WebSocketPeer.STATE_OPEN:
		target.send_text(JSON.stringify({"type": type, "args":args}))

func _ready() -> void:
	start_server()

func _process(_delta: float) -> void:
	while tcp_server.is_connection_available():
		var conn := tcp_server.take_connection()
		var ws := WebSocketPeer.new()
		ws.accept_stream(conn)
		peers[next_id] = ws
		next_id += 1
	for id in peers.keys():
		var ws: WebSocketPeer = peers[id]
		ws.poll()
		var state := ws.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN:
			while ws.get_available_packet_count() > 0:
				var text := ws.get_packet().get_string_from_utf8()
				print("peer %d says: %s" % [id, text]) # message recieved here, dont forget, inside text.
		elif state == WebSocketPeer.STATE_CLOSED:
			print("peer %d disconnected" % id)
			peers.erase(id)
