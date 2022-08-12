extends Node

const FILE_PATH = "user://settings.cfg"

var config := ConfigFile.new()

signal value_updated(section, key, value, old_value)

func _ready():
	call_deferred("load_from_disk")

func save_to_disk():
	config.save(FILE_PATH)

func load_from_disk():
	var config_disk := ConfigFile.new()
	var err = config_disk.load(FILE_PATH)
	for section in config_disk.get_sections():
		for key in config_disk.get_section_keys(section):
			config.set_value(section, key, config_disk.get_value(section, key))
	
	for section in config.get_sections():
		for key in config.get_section_keys(section):
			emit_signal("value_updated", section, key, config.get_value(section, key), null)
	
	if err != OK:
		print("No settings file found, using defaults.")
		save_to_disk()

func set_default_value(section:String, key:String, value):
	if !config.has_section_key(section, key):
		config.set_value(section, key, value)
	else:
		push_error("Already have a default value for " + section + "/" + key)

func set_value(section:String, key:String, value):
	if config.has_section_key(section, key):
		var old_value = config.get_value(section, key)
		config.set_value(section, key, value)
		emit_signal("value_updated", section, key, value, old_value)
		save_to_disk()
	else:
		push_error("Unknown setting " + section + "/" + key)

func get_value(section:String, key:String): # Returns Varient
	return config.get_value(section, key) if config.has_section_key(section, key) else null
