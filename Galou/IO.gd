extends Node2D

const DATA_PATH = "res://data.txt"

var input_lines = []


func load_initital_boards():
	var initial_boards = []
	input_lines = read_input_file(DATA_PATH)
	while input_lines.size() != 0:
		var board = load_new_board()
		if board != []:
			initial_boards.append(board)
	return initial_boards


func load_new_board():
	var board_size = parse_board_size()
	return parse_board(board_size)


func parse_board_size():
	var line = input_lines[0]
	input_lines.remove(0)
	var new_size = line.split(" ")
	return Vector2(int(new_size[0]), int(new_size[1]))


func parse_board(_board_size):
	var new_board = []
	for i in range(_board_size.y):
		var line = input_lines[0]
		input_lines.remove(0)
		var line_content = line.split(" ")
		new_board.append(line_content)
	return new_board


func read_input_file(_path):
	var file = File.new()
	file.open(_path, File.READ)
	var content = file.get_as_text()
	file.close()
	var input_lines = content.split("\n")
	return input_lines