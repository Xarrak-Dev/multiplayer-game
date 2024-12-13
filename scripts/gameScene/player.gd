extends CharacterBody3D

const otherplayerscene = preload("res://scenes/objects/otherplayer.tscn")
@onready var pauseMenu = $"../Menu"
@onready var staminaBar = $"../bars/ProgressBar"
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed = 5
var jump_speed = 7
var mouse_sensitivity = 0.002
var pickable = false
var playerPicked = null
var pickedOneUp = false
var grabbed = false
var grabbedId
var lastPos
var lastRot
var inAir = false
var stamina = 100

func _ready() -> void:
	MultiplayerManager.player = self
	pauseMenu.visible = false

func _physics_process(delta: float) -> void:
	if lastPos != position || lastRot != rotation.y:
		MultiplayerManager.sendServerPosition.rpc_id(1, self.position, rotation.y)
	lastPos = position
	lastRot = rotation.y
	if grabbed != true:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		# Handle jump.
		if is_on_floor():
			if Input.is_action_just_pressed("jump") && stamina > 10: 
				velocity.y = jump_speed
				if pickedOneUp:
					stamina -= 10
				else:
					stamina -= 5
			if inAir:
				inAir = false
		if Input.is_action_pressed("sprint"):
			if stamina >= 5:
				speed = 20
				stamina -= 5
			else:
				speed = 8
		else:
			speed = 8
			if stamina <= 100:
				stamina += 0.1
		if Input.is_action_just_pressed("scream"):
			MultiplayerManager.scream.rpc()
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction && !inAir && !pauseMenu.visible:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		elif !inAir:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		if pickedOneUp:
			stamina -= 0.2
			if stamina <= 3:
				pickedOneUp = false
				MultiplayerManager.playerDrop.rpc_id(1, int(str(playerPicked.name)), rotation.y)
		move_and_slide()
		staminaBar.value = stamina

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
	var arrowCam = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	rotate_y(-arrowCam.x * 150 * mouse_sensitivity)
	$Camera3D.rotate_x(-arrowCam.y * 75 * mouse_sensitivity)
	$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		pauseMenu.visible = true
	if event.is_action_pressed("click"):
		if playerPicked != null && pickable && !pickedOneUp && stamina >= 10:
				print(pickable)
				pickable = false
				pickedOneUp = true
				MultiplayerManager.playerPickup.rpc_id(1, int(str(playerPicked.name)))
				MultiplayerManager.sendServerPosition.rpc_id(1, self.position, rotation.y)
		elif pickedOneUp && playerPicked != null && !pickable:
			print(pickable)
			print("dropping?")
			pickedOneUp = false
			MultiplayerManager.playerDrop.rpc_id(1, int(str(playerPicked.name)), rotation.y)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.get_parent() == $"../players" && !pickedOneUp:
		pickable = true
		playerPicked = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.get_parent() == $"../players":
		pickable = false

func throw(rot):
	if !inAir:
		velocity = Vector3(0, 0, 1).rotated(Vector3(0,1,0), rot) * -100
		inAir = true
