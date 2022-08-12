extends HBoxContainer

var tab_index := 0 setget set_tab_index
var tab_state:int = TabState.NORMAL

enum TabState {
	NORMAL,
	TRANSITION
}

onready var InputManager = $"%InputManager"

onready var tab_buttons: = $TabButtons.get_children()
onready var tabs := $Tabs.get_children()
const TABS_TWEEN_TIME = 0.15

var last_tween:SceneTreeTween = null

func _ready():
	setup_menu_navigation()
	for i in range(0, tab_buttons.size()):
		(tab_buttons[i] as Button).connect("pressed", self, "set_tab_index", [i])
		(tab_buttons[i] as Button).connect("focus_entered", self, "set_tab_index", [i])
	get_viewport().connect("gui_focus_changed", self, "focused_changed")
	InputManager.connect("input_mode_changed", self, "_on_input_mode_changed")

func set_tab_index(value:int):
	var animation_direction = sign(value - tab_index)
	if animation_direction == 0.0: return # Desired tab is the current tab. No change needed
	
	# If currently in transition to another tab finish it and then begin transition
	if tab_state == TabState.TRANSITION:
		last_tween.custom_step(TABS_TWEEN_TIME * 2.0)
	tab_state = TabState.TRANSITION

	var current_tab := tabs[tab_index] as Control
	var next_tab := tabs[value] as Control

	# Animate
	var tween := create_tween()
	var current_tab_rect_position := current_tab.rect_position
	var next_tab_rect_position := next_tab.rect_position
	var tweener := tween.tween_property(current_tab, "rect_position", current_tab_rect_position - animation_direction * Vector2(0, current_tab.rect_size.y), TABS_TWEEN_TIME).set_trans(Tween.TRANS_EXPO)
	tweener.connect("finished", current_tab, "set_position", [current_tab_rect_position])
	tweener.connect("finished", current_tab, "set_visible", [false])
	tweener.connect("finished", next_tab, "set_visible", [true])
	tweener = tween.tween_property(next_tab, "rect_position", next_tab_rect_position, TABS_TWEEN_TIME).from(next_tab_rect_position + animation_direction * Vector2(0, next_tab.rect_size.y)).set_trans(Tween.TRANS_EXPO)
	tweener.connect("finished", self, "set", ["tab_state", TabState.NORMAL])

	last_tween = tween
	tab_index = value

	
	for section in tab_buttons: # Todo remove
		section.focus_neighbour_right = tabs[tab_index].get_child(0).get_child(1).get_path()

var menu_buttons:Array = []

func _input(event):
	if !is_visible_in_tree(): return
	if event.is_action_pressed("ui_cancel") && !event.is_action("game_settings"):
		if get_focus_owner() == null || get_focus_owner().get_script() != null:
			tab_buttons[tab_index].call_deferred("grab_focus")
	if event.is_action("ui_accept"):
		if get_focus_owner() != null && get_focus_owner().get_parent() == $Section:
			get_node(get_focus_owner().focus_neighbour_right).call_deferred("grab_focus")

var last_focused:Control = null

func focused_changed(node:Control):
	if !is_visible_in_tree(): return
	last_focused = node
	if last_focused.get_script() != null: # Hackey should probably change
		for section in tab_buttons:
			section.focus_neighbour_right = last_focused.get_path()

func _on_input_mode_changed(mode:int):
	if mode == InputManager.InputMode.MOUSE_KEYBOARD:
		for button in menu_buttons:
			button.focus_mode = Control.FOCUS_CLICK
		var focus_owner := get_focus_owner()
		if focus_owner != null:
			focus_owner.release_focus()
	else:
		for button in menu_buttons:
			button.focus_mode = Control.FOCUS_ALL
		if is_visible_in_tree():
			if last_focused != null:
				last_focused.grab_focus()
			else:
				tab_buttons[tab_index].grab_focus()

func setup_menu_navigation():
	menu_buttons.append_array(tab_buttons)
	
	for i in range(0, tab_buttons.size()):
		var button:Control = tab_buttons[i]
		button.connect("mouse_exited", button, "release_focus")
		
		if i != 0:
			button.focus_previous = tab_buttons[i-1].get_path()
		else:
			button.focus_previous = button.get_path()
		button.focus_neighbour_top = button.focus_previous
		if i != tab_buttons.size() - 1:
			button.focus_next = tab_buttons[i+1].get_path()
		else:
			button.focus_next = button.get_path()
		button.focus_neighbour_bottom = button.focus_next
		
		# No left item
		button.focus_neighbour_left = button.get_path()
	
	for section_index in range(tabs.size()):
		var section:Control = tabs[section_index]
		
		var options:Array = []
		for option_container in section.get_children():
			for option in option_container.get_children():
				if option.get_script() != null:
					options.append(option)
					break
		
		menu_buttons.append_array(options)
		tab_buttons[section_index].focus_neighbour_right = options[0].get_path()
		
		for i in range(0, options.size()):
			var option:Control = options[i]
			option.connect("mouse_exited", option, "release_focus")
			option.connect("mouse_entered", option, "grab_focus")

			if i != 0:
				option.focus_previous = options[i-1].get_path()
			else:
				option.focus_previous = option.get_path()
			option.focus_neighbour_top = option.focus_previous
			if i != options.size() - 1:
				option.focus_next = options[i+1].get_path()
			else:
				option.focus_next = option.get_path()
			option.focus_neighbour_bottom = option.focus_next

			option.focus_neighbour_left = tab_buttons[section_index].get_path()
			option.focus_neighbour_right = option.get_path()
			option.focus_mode = Control.FOCUS_CLICK
