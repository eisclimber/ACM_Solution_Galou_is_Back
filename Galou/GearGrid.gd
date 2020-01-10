extends TileMap


func set_gear(_pos, _gear_type):
	set_cellv(as_grid_pos(_pos), gear_to_tile(_gear_type))


func as_grid_pos(_pos):
	return Vector2(_pos.x + int(_pos.y / 2), _pos.y)


func as_board_pos(_pos):
	return Vector2(_pos.x - int(_pos.y / 2), _pos.y)


func gear_to_tile(_gear_type) -> int:
	match _gear_type:
		"I":
			return 0
		"F":
			return 1
		"(":
			return 2
		")":
			return 3
		"B":
			return 4
		_:
			return 5


func change_displayed_board(_board):
	clear_board()
	for y in range(_board.size()):
		for x in range(_board[0].size()):
			set_gear(Vector2(x, y), _board[y][x])
	center_on_board()


func clear_board():
	var board_start = get_used_rect().position
	var board_size = get_used_rect().size
	for y in range(board_start.y, board_size.y):
		for x in range(board_start.x, board_size.x):
			set_cell(x, y, INVALID_CELL)


func center_on_board():
	var board_size = get_used_rect().size + Vector2(2, 0)
	position = (OS.window_size - board_size * cell_size) / 2
	 