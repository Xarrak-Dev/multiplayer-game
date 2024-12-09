extends Node

const port = 8080
var serverIP = "127.0.0.1"

var unique_id = 0

var world = null
var players = null


#functions

#sets up a client
func becomeJoin():
	var clientPeer = ENetMultiplayerPeer.new()
	
	clientPeer.create_client(serverIP, port)
	
	multiplayer.multiplayer_peer = clientPeer
	unique_id = clientPeer.get_unique_id()
	
	print("joining")

@rpc("any_peer", "call_remote", "reliable")
func sendServerPosition(data):
	var id = multiplayer.get_remote_sender_id()
	sendClientsPosition.rpc(data, id)

@rpc("any_peer", "call_remote", "reliable")
func sendClientsPosition(data, id):
	world.updatePosition(id, data)

@rpc("any_peer", "call_remote", "reliable")
func addPlayer(id, data):
	players.addPlayer(id, data)

@rpc("any_peer", "call_remote", "reliable")
func rmPlayer(id):
	players.rmPlayer(id)
