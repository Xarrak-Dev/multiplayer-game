extends CharacterBody3D

const otherplayerscene = preload("res://otherplayer.tscn")
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed = 5
var jump_speed = 7
var mouse_sensitivity = 0.002
var pickable = false
var playerPicked = null
var pickedOneUp = false
var grabbed = false
var grabbedId

func _ready() -> void:
	MultiplayerManager.player = self

func _physics_process(delta: float) -> void:
	if grabbed != true:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_speed
		if Input.is_action_pressed("sprint"):
			speed = 8
		else:
			speed = 5
		if Input.is_action_just_pressed("scream"):
			MultiplayerManager.scream.rpc()
		if Input.is_action_just_pressed("click"):
			if playerPicked != null && pickable && !pickedOneUp:
				pickable = false
				pickedOneUp = true
				MultiplayerManager.playerPickup.rpc_id(1, int(str(playerPicked.name)))
			elif pickedOneUp && playerPicked != null:
				pickedOneUp = false
				MultiplayerManager.playerDrop.rpc_id(1, int(str(playerPicked.name)))
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		MultiplayerManager.sendServerPosition.rpc_id(1, self.position, rotation.y)
		move_and_slide()
	else:
		var dude
		for child in $"../players".get_children():
			if grabbedId == int(str(child.name)):
				dude = child
		position = Vector3(dude.global_position.x, (dude.global_position.y + 3), dude.global_position.z)
		MultiplayerManager.sendServerPosition.rpc_id(1, self.position, rotation.y)

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
	var arrowCam = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	rotate_y(-arrowCam.x * 300 * mouse_sensitivity)
	$Camera3D.rotate_x(-arrowCam.y * 150 * mouse_sensitivity)
	$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.get_parent() == $"../players":
		pickable = true
		playerPicked = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	pickable = false
