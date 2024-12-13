extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !DisplayServer.is_touchscreen_available():
		self.hide()
