extends Button

onready var InputManager = $"%InputManager"

func _ready():
	connect("pressed", self, "_on_pressed")

func _on_pressed():
	InputManager = InputManager.InputMode.MOUSE_KEYBOARD
	OS.shell_open(OS.get_user_data_dir())
