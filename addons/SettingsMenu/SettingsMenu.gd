extends Control

onready var blurred_background := $BlurredBackground
onready var h_tab_container = $HTabContainer
onready var tab_button_container = $HTabContainer/TabButtons
onready var InputManager = $"%InputManager"

enum State {
	OPEN,
	CLOSED,
	CLOSING,
	OPENING,
}

export(float) var tween_time := 0.15
onready var blur_amount:float = blurred_background.material.get_shader_param("blur_amount")
const COLOR_VISIBLE := Color(1.0, 1.0, 1.0, 1.0)
const COLOR_HIDDEN := Color(1.0, 1.0, 1.0, 0.0)

var current_tween : SceneTreeTween = null

var state : int = State.CLOSED

var last_focused : Control = null

func _ready():
	visible = false
	modulate = COLOR_HIDDEN

func _input(event):
	if event.is_action_pressed("game_settings") || event.is_action_pressed("ui_cancel"):
		if event.is_action_pressed("ui_cancel") && !event.is_action_pressed("game_settings"):
			if state == State.CLOSING || !is_visible_in_tree(): return
			var focus_owner = get_focus_owner()
			if focus_owner != null && (focus_owner.get_script() != null || focus_owner is PopupMenu): return
		
		if current_tween != null:
			current_tween.custom_step(tween_time)
		
		match state:
			State.OPEN:
				state = State.CLOSING
				get_tree().paused = false
				var tween := create_tween().set_parallel()
				var tweener := tween.tween_property(self, "modulate", COLOR_HIDDEN, tween_time).set_trans(Tween.TRANS_CUBIC)
				tween.tween_method(self, "set_blur_amount", blur_amount, 0.0, tween_time).set_trans(Tween.TRANS_CUBIC)
				tweener.connect("finished", self, "set_visible", [false])
				tweener.connect("finished", self, "set", ["state" ,State.CLOSED])
#				tweener.connect("finished", self, "set", ["current_tween", null])
				last_focused = get_focus_owner()
				current_tween = tween
			State.CLOSED:
				state = State.OPENING
				visible = true
				get_tree().paused = true
				var tween := create_tween().set_parallel()
				var tweener = tween.tween_property(self, "modulate", COLOR_VISIBLE, tween_time).set_trans(Tween.TRANS_CUBIC)
				tweener.connect("finished", self, "set", ["state", State.OPEN])
#				tweener.connect("finished", self, "set", ["current_tween", null])
				tween.tween_method(self, "set_blur_amount", 0.0, blur_amount, tween_time).set_trans(Tween.TRANS_CUBIC)
				current_tween = tween
				
				if InputManager.current_input_mode == InputManager.InputMode.CONTROLLER:
					if last_focused != null && last_focused.visible:
						last_focused.grab_focus()
					else:
						tab_button_container.get_child(h_tab_container.tab_index).grab_focus()

func set_blur_amount(amount:float) -> void:
	blurred_background.material.set_shader_param("blur_amount", amount)
