extends Control

onready var section := get_parent().get_parent().name
onready var key := get_parent().name

var orignal_step:float

onready var label:Label = get_parent().get_child(0) if get_parent().get_child(0) is Label else null

onready var InputManager = $"%InputManager"

const FOCUS_COLOR = Color(0xefd15aFF)
const NORMAL_COLOR = Color.white

func _ready():
	if label != null:
		connect("focus_entered", self, "on_focus_entered")
		connect("focus_exited", self, "on_focus_exited")
	if get("disabled") && label != null:
		label.text += " (Disabled)"
	
	match get_class():
		"CheckBox":
			Settings.set_default_value(section, key, get("pressed"))
			Settings.connect("value_updated", self, "on_checkbox_settings_value_changed")
			connect("toggled", self, "on_checkbox_toggled")
			connect("focus_entered", self, "on_checkbox_entered_focus")
			connect("focus_exited", self, "on_checkbox_exited_focus")
		"OptionButton":
			Settings.set_default_value(section, key, call("get_item_id", get("selected")))
			Settings.connect("value_updated", self, "on_option_settings_value_changed")
			connect("item_selected", self, "on_option_item_selected")
			connect("pressed", self, "on_option_pressed")
			call("get_popup").connect("hide", self, "on_option_popup_hide")
		"HSlider":
			Settings.set_default_value(section, key, get("value"))
			Settings.connect("value_updated", self, "on_slider_settings_value_changed")
			connect("value_changed", self, "on_slider_value_changed")
			InputManager.connect("input_mode_changed", self, "on_slider_input_mode_changed")
			orignal_step = get("step")
			set("step", 0.001)
		_:
			push_error("This script should not go on a " + get_class())

# Generic

func on_focus_entered():
	label.set("custom_colors/font_color", FOCUS_COLOR)

func on_focus_exited():
	if get_class() == "OptionButton" && call("get_popup").visible: return
	label.set("custom_colors/font_color", NORMAL_COLOR)

# Checkbox

func on_checkbox_toggled(button_pressed:bool):
	Settings.set_value(section, key, button_pressed)

func on_checkbox_settings_value_changed(changed_section:String, changed_key:String, value, old_value):
	if section == changed_section && key == changed_key:
		set_block_signals(true)
		set("pressed", value)
		set_block_signals(false)

func on_checkbox_entered_focus():
	set("custom_icons/checked", preload("res://addons/SettingsMenu/buttons/checkbox_focus_checked.svg"))
	set("custom_icons/unchecked", preload("res://addons/SettingsMenu/buttons/checkbox_focus_unchecked.svg"))
	set("custom_icons/checked_disabled", preload("res://addons/SettingsMenu/buttons/checkbox_disabled_focus_checked.svg"))
	set("custom_icons/unchecked_disabled", preload("res://addons/SettingsMenu/buttons/checkbox_disabled_focus_unchecked.svg"))

func on_checkbox_exited_focus():
	set("custom_icons/checked", preload("res://addons/SettingsMenu/buttons/checkbox_checked.svg"))
	set("custom_icons/unchecked", preload("res://addons/SettingsMenu/buttons/checkbox_unchecked.svg"))
	set("custom_icons/checked_disabled", preload("res://addons/SettingsMenu/buttons/checkbox_disabled_checked.svg"))
	set("custom_icons/unchecked_disabled", preload("res://addons/SettingsMenu/buttons/checkbox_disabled_unchecked.svg"))

# OptionButton

func on_option_item_selected(_index:int):
	Settings.set_value(section, key, call("get_selected_id"))

func on_option_settings_value_changed(changed_section:String, changed_key:String, value, old_value):
		if section == changed_section && key == changed_key:
			set_block_signals(true)
			for i in range(0, call("get_item_count")):
				if call("get_item_id", i) == value:
					set("selected", i)
					break
			set_block_signals(false)

func on_option_pressed(): # Select Current Item in PopupMenu
	var index:int = get("selected")
	var menu:PopupMenu = call("get_popup")
	menu.set_current_index(index)

func on_option_popup_hide():
	if InputManager.current_input_mode == InputManager.InputMode.MOUSE_KEYBOARD:
		release_focus()

# Slider

func on_slider_value_changed(value:float):
	Settings.set_value(section, key, value)

func on_slider_settings_value_changed(changed_section:String, changed_key:String, value, old_value):
		if section == changed_section && key == changed_key:
			set_block_signals(true)
			set("value", value)
			set_block_signals(false)

func on_slider_input_mode_changed(mode:int):
	if mode == InputManager.InputMode.CONTROLLER:
		set("step", orignal_step)
	else:
		set("step", 0.001)
