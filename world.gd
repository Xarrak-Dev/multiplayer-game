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


func _on_button_pressed() -> void:
	Input.action_press("jump")


func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body)
	if body == $Player:
		$Player.position = Vector3(0, 10, 0)
