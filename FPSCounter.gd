extends Label

onready var original_text := text

func _ready():
	Settings.connect("value_updated", self, "on_value_updated")

func on_value_updated(section:String, key:String, value, old_value):
	if section == "Miscellaneous" && key == "fps_counter":
		visible = value

func _process(_delta:float):
	if visible:
		text = original_text + str(Engine.get_frames_per_second())