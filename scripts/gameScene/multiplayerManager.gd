extends Node

var port = 8080
var serverIP = "35.161.170.19"

var unique_id = 0

var world = null
var players = null
var player = null


#functions

func _ready():
	multiplayer.connected_to_server.connect(connected)

#sets up a client
func becomeJoin():
	var clientPeer = ENetMultiplayerPeer.new()
	
	clientPeer.create_client(serverIP, port)
	
	multiplayer.multiplayer_peer = clientPeer
	unique_id = clientPeer.get_unique_id()
	
	print("joining")

func connected():
	get_tree().change_scene_to_file("res://scenes/main/world.tscn")

@rpc("any_peer", "call_remote", "reliable")
func sendServerPosition(data, rot):
	var id = multiplayer.get_remote_sender_id()
	sendClientsPosition.rpc(data, id, rot)

@rpc("any_peer", "call_remote", "reliable")
func sendClientsPosition(data, id, rot):
	world.updatePosition(id, data, rot)

@rpc("any_peer", "call_remote", "reliable")
func addPlayer(id, data):
	players.addPlayer(id, data)

@rpc("any_peer", "call_remote", "reliable")
func rmPlayer(id):
	players.rmPlayer(id)

@rpc("any_peer", "call_local", "reliable")
func scream():
	get_tree().root.get_node("world/AudioStreamPlayer").play()

@rpc("any_peer", "call_remote", "reliable")
func playerPickup(id):
	pickedUp.rpc_id(id, multiplayer.get_remote_sender_id())

@rpc("any_peer", "call_remote", "reliable")
func playerDrop(_id, _rot):
	pass

@rpc("any_peer", "call_remote", "reliable")
func pickedUp(id):
	player.grabbed = true
	player.grabbedId = id

@rpc("any_peer", "call_remote", "reliable")
func dropped(_id, rot):
	player.grabbed = false
	player.grabbedId = 0
	player.throw(rot)

@rpc("any_peer", "call_remote", "reliable")
func moveWithMaster(data):
	get_tree().root.get_node("world/Player").position = data

@rpc("any_peer", "call_remote", "reliable")
func stolen(id):
	if unique_id != id:
		player.playerPicked = null
		player.pickedOneUp = false
