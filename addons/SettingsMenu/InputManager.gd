extends Node

enum InputMode {
	MOUSE_KEYBOARD,
	CONTROLLER,
}

const CONTROLLER_DEAD_ZONE := 0.1
const MOUSE_MIN_MOVEMENT := 2

signal input_mode_changed(mode)

var current_input_mode:int = InputMode.MOUSE_KEYBOARD setget set_current_input_mode

var ignore_next_mouse_motion:bool = false

func set_current_input_mode(mode:int):
	if mode != current_input_mode:
		current_input_mode = mode
		match current_input_mode:
			InputMode.MOUSE_KEYBOARD:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			InputMode.CONTROLLER:
				Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		emit_signal("input_mode_changed", current_input_mode)
#		print(current_input_mode)

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _input(event):
	if event is InputEventMouseMotion && event.relative.abs().length_squared() >= MOUSE_MIN_MOVEMENT * MOUSE_MIN_MOVEMENT:
		if ignore_next_mouse_motion:
			ignore_next_mouse_motion = false
			return
		self.current_input_mode = InputMode.MOUSE_KEYBOARD
	elif event is InputEventMouseButton && event.is_pressed():
		self.current_input_mode = InputMode.MOUSE_KEYBOARD
	elif event is InputEventKey && event.is_pressed():
		self.current_input_mode = InputMode.CONTROLLER
	elif event is InputEventJoypadMotion && abs(event.axis_value) >= CONTROLLER_DEAD_ZONE:
		self.current_input_mode = InputMode.CONTROLLER
	elif event is InputEventJoypadButton && event.is_pressed():
		self.current_input_mode = InputMode.CONTROLLER
