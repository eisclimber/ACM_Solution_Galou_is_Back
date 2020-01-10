extends Node2D

signal board_done()
signal resolve_available()
signal board_clamped(_min_clamp, _max_clamp)

const GEAR_INITIAL = "I"
const GEAR_FREE = "F"
const GEAR_LEFT = ")"
const GEAR_RIGHT = "("
const GEAR_BLOCKED = "B"
const GEAR_NONE = "."

const DATA_PATH = "res://data.txt"
const NEIGHBORS = [Vector2(0, -1), Vector2(1, -1), Vector2(-1, 0), Vector2(1, 0), Vector2(-1, 1), Vector2(0, 1)]

onready var gear_grid = $GearGrid

var current_board : int = 0
var initial_boards : Array = []


var board_size : Vector2 = Vector2()
var board : Array = []

var steps : Array


func _ready():
	initial_boards = IO.load_initital_boards()
	change_board(current_board)


func solve_board():
	steps = []
	var temp_board = board.duplicate()
	for y in board.size():
		for x in board[0].size():
			if board[y][x] == GEAR_INITIAL:
				apply_force(temp_board, Vector2(x, y), GEAR_RIGHT)


func apply_force(_board, _pos, _force):
	var old_state = _board[_pos.y][_pos.x]
	var new_state = calc_force(old_state, _force)
	if new_state != old_state:
		_board[_pos.y][_pos.x] = new_state
		steps.append([_pos, new_state])
		apply_force_to_neighbors(_board, _pos, new_state)


func apply_force_to_neighbors(_board, _pos, _force):
	for neighbor_offset in NEIGHBORS:
		var neighbor_pos = _pos + neighbor_offset
		if is_on_board(neighbor_pos):
			apply_force(_board, neighbor_pos, _force)


func calc_force(_gear_state, _force):
	if _gear_state == GEAR_NONE:
		return GEAR_NONE
	elif (_gear_state == GEAR_FREE or _gear_state == GEAR_RIGHT) and _force == GEAR_LEFT or _gear_state == GEAR_INITIAL:
		return GEAR_RIGHT
	elif (_gear_state == GEAR_FREE or _gear_state == GEAR_LEFT) and _force == GEAR_RIGHT:
		return GEAR_LEFT
	else:
		return GEAR_BLOCKED


func print_board():
	var res = ""
	for y in range(board.size()):
		for x in range(board[0].size()):
			res += board[y][x] + " "
		res += "\n"
	print(res)


func is_on_board(_pos):
	return _pos.x in range(board_size.x) and _pos.y in range(board_size.y)


func set_current_board(_current_board):
	current_board = int(clamp(_current_board, 0, initial_boards.size() - 1))
	var min_clamp = (current_board == 0)
	var max_clamp = (current_board == initial_boards.size() - 1)
	emit_signal("board_clamped", min_clamp, max_clamp)
	change_board(_current_board)


func change_board(_board_idx):
	if _board_idx in range(initial_boards.size()):
		board = initial_boards[_board_idx].duplicate()
		board_size = Vector2(board[0].size(), board.size())
		gear_grid.change_displayed_board(board)
		solve_board()

#----------------------------------------------------

func _unhandled_input(event):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		gear_grid.center_on_board()
	elif Input.is_action_just_pressed("ui_cancel"):
		OS.window_fullscreen = false
		gear_grid.center_on_board()




#----------------------------------------------------


func _on_UI_next_board():
	set_current_board(current_board + 1)


func _on_UI_prev_board():
	set_current_board(current_board - 1)


func _on_UI_solve(_step_enabled):
	if _step_enabled:
		process_one_step()
	else:
		process_all_steps()


func process_one_step():
	if !steps.empty():
		var step = steps.pop_front()
		gear_grid.set_gear(step[0], step[1])
	if steps.empty():
		emit_signal("board_done")


func process_all_steps():
	for step in steps:
		gear_grid.set_gear(step[0], step[1])
	emit_signal("board_done")


func _on_UI_change_gear(_position, _add):
	var grid_pos = gear_grid.world_to_map(_position - gear_grid.position)
	var board_pos = gear_grid.as_board_pos(grid_pos)
	if is_on_board(board_pos):
		if _add:
			board[board_pos.y][board_pos.x] = GEAR_FREE
			emit_signal("resolve_available")
		else:
			if initial_boards[current_board][board_pos.y][board_pos.x] != GEAR_INITIAL:
				board[board_pos.y][board_pos.x] = GEAR_NONE
				emit_signal("resolve_available")
		gear_grid.change_displayed_board(board)
		solve_board()
