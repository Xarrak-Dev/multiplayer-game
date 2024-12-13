extends Node3D

var playerScene = preload("res://scenes/objects/otherplayer.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MultiplayerManager.players = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func addPlayer(id, data):
	MultiplayerManager.sendServerPosition.rpc_id(1, self.position, rotation.y)
	if id != MultiplayerManager.unique_id:
		var p = playerScene.instantiate()
		add_child(p)
		p.name = str(id)
		p.global_position = data

func rmPlayer(id):
	for child in self.get_children():
		if child.name == str(id):
			child.queue_free()
