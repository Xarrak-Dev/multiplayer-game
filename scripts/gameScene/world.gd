extends Node3D

var rng = RandomNumberGenerator.new()
@onready var pauseMenu = $Menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MultiplayerManager.world = self
	var pos = Vector3(rng.randi_range(-15, 15), rng.randi_range(2, 15), rng.randi_range(-15, 15))
	$Player.position = pos
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func updatePosition(id, data, rot):
	for child in $players.get_children():
		if child.name == str(id):
			child.global_position = data
			child.global_rotation.y = rot


func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body)
	if body == $Player:
		$Player.position = Vector3(0, 10, 0)


func _on_menu_button_pressed() -> void:
	multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_file("res://scenes/main/menu.tscn")


func _on_resume_button_pressed() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pauseMenu.visible = false
