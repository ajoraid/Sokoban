package main

import rl "vendor:raylib"

process_input :: proc(level: ^Level) {
	direction: Vec2i

	if rl.IsKeyPressed(.A) do direction = Vec2i{-1, 0}
	if rl.IsKeyPressed(.D) do direction = Vec2i{1, 0}
	if rl.IsKeyPressed(.S) do direction = Vec2i{0, 1}
	if rl.IsKeyPressed(.W) do direction = Vec2i{0, -1}

	next_pos := Vec2i{level.player.pos.x + direction.x, level.player.pos.y + direction.y}
	if is_valid_move(level, next_pos) {
		level.player.pos.x += direction.x
		level.player.pos.y += direction.y
	} else {
		box_exists, box_index := box_at(level, next_pos)
		if box_exists {
			if try_push_box(level, box_index, direction) {
				level.player.pos = next_pos
			}
		}
	}
}

is_valid_move :: proc(level: ^Level, pos: Vec2i) -> bool {
	if !within_bounds(level, pos) do return false
	if level.board[pos.y][pos.x] == .Wall do return false
	is_blocked_by_box, _ := box_at(level, pos)
	return !is_blocked_by_box
}

box_at :: proc(level: ^Level, pos: Vec2i) -> (bool, int) {
	if !within_bounds(level, pos) do return false, -1
	for box, index in level.boxes {
		if box.pos.x == pos.x && box.pos.y == pos.y do return true, index
	}
	return false, -1
}

within_bounds :: proc(level: ^Level, pos: Vec2i) -> bool {
	if pos.x < 0 || pos.x >= level.width do return false
	if pos.y < 0 || pos.y >= level.height do return false
	return true
}

try_push_box :: proc(level: ^Level, box_index: int, direction: Vec2i) -> bool {
	box_pos := level.boxes[box_index]
	push_pos: Vec2i = {box_pos.pos.x + direction.x, box_pos.pos.y + direction.y}
	if within_bounds(level, push_pos) {
		box_exists, _ := box_at(level, push_pos)
		if box_exists do return false
		switch level.board[push_pos.y][push_pos.x] {
		case .Floor, .Goal:
			level.boxes[box_index].pos = push_pos
			return true
		case .Wall:
			return false
		}
	}
	return false
}

did_win :: proc(level: ^Level) -> bool {
	for row, y in level.board {
		for tile, x in row {
			if tile == .Goal {
				box_exist, _ := box_at(level, {x, y})
				if !box_exist do return false
			}
		}
	}
	return true
}

draw_win_text :: proc() {
	text_width := rl.MeasureText(WON_TEXT, FONT_SIZE)
	x := (WINDOW_WIDTH - text_width) / 2
	y := (WINDOW_HEIGHT - FONT_SIZE) / 2
	rl.DrawText(WON_TEXT, i32(x), i32(y), FONT_SIZE, rl.WHITE)
}
