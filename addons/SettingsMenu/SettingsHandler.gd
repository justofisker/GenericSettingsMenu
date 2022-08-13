extends Node

onready var InputManager = $"%InputManager"

func _ready():
	Settings.connect("value_updated", self, "on_settings_value_changed")

func on_settings_value_changed(section:String, key:String, value, old_value):
	if old_value != null && typeof(old_value) != typeof(value):
		push_error("Type of " + section + "/" + key + " differs from default value")
		return
	if old_value == value: return
	match section:
		"Video":
			match key:
				"fullscreen":
					match old_value:
						0:
							pass
						1:
							InputManager.ignore_next_mouse_motion = true
							OS.window_fullscreen = false
						2:
							OS.window_borderless = false
							OS.window_maximized = old_maximized
							if !old_maximized:
								OS.window_position = old_position
								OS.window_size = old_size
					match value:
						0:
							pass
						1:
							InputManager.ignore_next_mouse_motion = true
							OS.window_fullscreen = true
						2:
							old_position = OS.window_position
							old_size = OS.window_size
							old_maximized = OS.window_maximized
							OS.window_borderless = true
							OS.window_position = OS.get_screen_position()
							OS.window_size = OS.get_screen_size() + Vector2(0, 1)
				"vsync":
					OS.vsync_enabled = value
		"Graphics":
			match key:
				"msaa":
					get_viewport().msaa = value
				"fxaa":
					get_viewport().fxaa = value
				"bloom":
					var environment := get_viewport().world.environment
					environment.glow_enabled = value > 0
					environment.glow_bicubic_upscale = value > 1
					environment.glow_high_quality = value > 2
				"shadow_quality":
					if value == 0:
						toggle_lights(false)
						ProjectSettings.set("rendering/quality/directional_shadow/size", 1024)
						ProjectSettings.set("rendering/quality/shadows/filter_mode", 0)
					else:
						if old_value == null || old_value == 0:
							toggle_lights(true)
						var size:int
						var filter_mode:int
						match value:
							1: # Low
								size = 2048
								filter_mode = 1
							2: # Medium
								size = 4096
								filter_mode = 1
							3: # High
								size = 4096
								filter_mode = 2
							4: # Ultra
								size = 8192
								filter_mode = 2
						ProjectSettings.set("rendering/quality/directional_shadow/size", size)
						ProjectSettings.set("rendering/quality/shadows/filter_mode", filter_mode)
				"ssao":
					var environment := get_viewport().world.environment
					environment.ssao_enabled = value > 0
					match value:
						1: # Low
							environment.ssao_quality = environment.SSAO_QUALITY_LOW
						2: # Medium
							environment.ssao_quality = environment.SSAO_QUALITY_MEDIUM
						3: # High
							environment.ssao_quality = environment.SSAO_QUALITY_HIGH
		"Miscellaneous":
			match key:
				"text_speed":
					pass # Just store the value
				"fps_counter":
					pass
		"Audio":
			match key:
				"volume_mute":
					AudioServer.set_bus_mute(0, value)
				"volume_main":
					AudioServer.set_bus_volume_db(0, log(value) * 20)
				"volume_sfx":
					AudioServer.set_bus_volume_db(1, log(value) * 20)

# Setting Speficic Code

# Video/fullscreen

var old_size:Vector2
var old_position:Vector2
var old_maximized:bool

# Graphics/shadow_quality

func toggle_lights(enabled:bool):
	for light in get_tree().get_nodes_in_group("Light"):
		if light is DirectionalLight:
			light.shadow_enabled = enabled
		elif light is OmniLight:
			light.shadow_enabled = enabled
