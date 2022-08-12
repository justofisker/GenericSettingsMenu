extends Button

func _ready():
	connect("pressed", get_tree(), "quit")
