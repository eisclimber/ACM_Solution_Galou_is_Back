extends Control

signal next_board()
signal prev_board()
signal solve(_step_enabled)
signal change_gear(_position, _add)

onready var solve_button = $ControlsPanel/VBox/SolveButton
onready var next_board_button = $ControlsPanel/VBox/BoardControl/NextBoardButton
onready var prev_board_button = $ControlsPanel/VBox/BoardControl/PrevBoardButton

var step_enabled : bool = false setget set_step_enabled


func set_step_enabled(_step_enabled):
	step_enabled = _step_enabled
	if _step_enabled:
		solve_button.text = "Next Step"
	else:
		solve_button.text = "Solve"


func _on_StepButton_toggled(_button_pressed):
	set_step_enabled(_button_pressed)


func _on_SolveButton_pressed():
	emit_signal("solve", step_enabled)


func _on_NextBoardButton_pressed():
	solve_button.disabled = false
	emit_signal("next_board")


func _on_PrevBoardButton_pressed():
	solve_button.disabled = false
	emit_signal("prev_board")


#------------------------------------------------------------------


func _on_Galou_board_clamped(_min_clamp, _max_clamp):
	next_board_button.disabled = _max_clamp
	prev_board_button.disabled = _min_clamp


func _on_Galou_resolve_available():
	solve_button.disabled = false


func _on_Galou_board_done():
	solve_button.disabled = true


#-----------------------------------------------------------------


func can_drop_data(position, data):
	return true


func drop_data(position, data):
	emit_signal("change_gear", position, (data == "Add"))