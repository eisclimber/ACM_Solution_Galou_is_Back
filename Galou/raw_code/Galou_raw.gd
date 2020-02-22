extends Node2D

const GEAR_INITIAL = "I"
const GEAR_FREE = "F"
const GEAR_LEFT = ")"
const GEAR_RIGHT = "("
const GEAR_BLOCKED = "B"
const GEAR_NONE = "."

const DATA_PATH = "res://data.txt"
const NEIGHBORS = [Vector2(0, -1), Vector2(1, -1), Vector2(-1, 0), Vector2(1, 0), Vector2(-1, 1), Vector2(0, 1)]

var initial_gears : Array = []
var input_lines : PoolStringArray = []
var board_size : Vector2 = Vector2()
var board : Array = []


func _ready():
	main()


func main():
	input_lines = read_input_file(DATA_PATH)
	load_new_board()
	while board_size != Vector2():
		solve_board()
		load_new_board()


func solve_board():
	for gear_pos in initial_gears:
		apply_force(gear_pos, GEAR_RIGHT)
	print_board()


func apply_force(_pos, _force):
	var old_state = board[_pos.y][_pos.x]
	var new_state = calc_force(old_state, _force)
	if new_state != old_state:
		board[_pos.y][_pos.x] = new_state
		apply_force_to_neighbors(_pos, new_state)


func apply_force_to_neighbors(_pos, _force):
	for neighbor_offset in NEIGHBORS:
		var neighbor_pos = _pos + neighbor_offset
		if is_valid_gear(neighbor_pos):
			apply_force(neighbor_pos, _force)


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
	var res = "\n"
	for y in range(board.size()):
		for x in range(board[0].size()):
			res += board[y][x] + " "
		if y < board.size() - 1:
			res += "\n"
	print(res)


func is_valid_gear(_pos):
	return is_on_board(_pos) and board[_pos.y][_pos.x] != GEAR_NONE


func is_on_board(_pos):
	return _pos.x >= 0 and _pos.x < board_size.x and _pos.y >= 0 and _pos.y < board_size.y


# -----------------------------------
#   Loading and parsing input files
# -----------------------------------


func read_input_file(_path):
	var file = File.new()
	file.open(_path, File.READ)
	var content = file.get_as_text()
	file.close()
	var input_lines = content.split("\n")
	return input_lines


func load_new_board():
	board_size = parse_board_size()
	board = parse_board()
	initial_gears = parse_initial_gears()


func parse_board_size():
	var line = input_lines[0]
	input_lines.remove(0)
	var new_size = line.split(" ")
	return Vector2(int(new_size[0]), int(new_size[1]))


func parse_board():
	var new_board = []
	for i in range(board_size.y):
		var line = input_lines[0]
		input_lines.remove(0)
		var line_content = line.split(" ")
		new_board.append(line_content)
	return new_board


func parse_initial_gears():
	var new_initial = []
	for y in board.size():
		for x in board[0].size():
			if board[y][x] == GEAR_INITIAL:
				new_initial.append(Vector2(x, y))
	return new_initial
