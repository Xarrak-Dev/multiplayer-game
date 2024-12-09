extends Node3D

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MultiplayerManager.world = self
	MultiplayerManager.becomeJoin()
	var pos = Vector3(rng.randi_range(-15, 15), rng.randi_range(2, 15), rng.randi_range(-15, 15))
	$Player.position = pos


# Called every frame. 'delta' is the elapsed time since the previous frame.
func updatePosition(id, data, rot):
	for child in $players.get_children():
		if child.name == str(id):
			child.global_position = data
			child.global_rotation.y = rot
