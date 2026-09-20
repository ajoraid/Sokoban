package main

import "core:fmt"
import "core:os"
import rl "vendor:raylib"

Vec2i :: struct {
	x, y: int,
}

Entity :: struct {
	pos: Vec2i,
}

Tile :: enum {
	Wall,
	Floor,
	Goal,
}

Box :: struct {
	pos: Vec2i,
}

Level :: struct {
	width:  int,
	height: int,
	board:  [dynamic][dynamic]Tile,
	player: Entity,
	boxes:  [dynamic]Box,
}


main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_NAME)
	defer rl.CloseWindow()

	level := Level{}
	load_level(&level)
	level.width = len(level.board[0])
	level.height = len(level.board)

	for !rl.WindowShouldClose() {
		process_input(&level)
		won := did_win(&level)

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		render_game(&level)
		if won do draw_win_text()

		rl.EndDrawing()
	}
}


draw_win_text :: proc() {
	text_width := rl.MeasureText(WON_TEXT, FONT_SIZE)
	x := (WINDOW_WIDTH - text_width) / 2
	y := (WINDOW_HEIGHT - FONT_SIZE) / 2
	rl.DrawText(WON_TEXT, i32(x), i32(y), FONT_SIZE, rl.WHITE)
}

load_level :: proc(level: ^Level) {
	level_data, ok := os.read_entire_file_from_path("src/levels/level_000.dat", context.allocator)
	assert(ok == nil, "Failed to lead level data.")

	current_row: [dynamic]Tile
	x, y: int

	for tile in level_data {
		switch tile {
		case '\n':
			append(&level.board, current_row)
			current_row = make([dynamic]Tile)
			y += 1
			x = 0
		case '#':
			append(&current_row, Tile.Wall)
			x += 1
		case '.':
			append(&current_row, Tile.Goal)
			x += 1
		case ' ':
			append(&current_row, Tile.Floor)
			x += 1
		case '@':
			append(&current_row, Tile.Floor)
			level.player.pos = Vec2i{x, y}
			x += 1
		case '$':
			append(&current_row, Tile.Floor)
			append(&level.boxes, Box{pos = Vec2i{x, y}})
			x += 1
		}
	}

	if len(current_row) > 0 {
		append(&level.board, current_row)
	}
}


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

render_game :: proc(level: ^Level) {
	render_level(level)
	render_player(level)
	render_boxes(level)
}

render_level :: proc(level: ^Level) {
	for row, y in level.board {
		for tile, x in row {
			switch tile {
			case .Wall:
				rl.DrawRectangle(
					i32(x) * TILE_SIZE,
					i32(y) * TILE_SIZE,
					TILE_SIZE,
					TILE_SIZE,
					rl.GRAY,
				)

			case .Floor:
				rl.DrawRectangle(
					i32(x) * TILE_SIZE,
					i32(y) * TILE_SIZE,
					TILE_SIZE,
					TILE_SIZE,
					rl.DARKGRAY,
				)

			case .Goal:
				rl.DrawRectangle(
					i32(x) * TILE_SIZE,
					i32(y) * TILE_SIZE,
					TILE_SIZE,
					TILE_SIZE,
					rl.GREEN,
				)
			}
		}
	}
}

render_player :: proc(level: ^Level) {
	player_x := level.player.pos.x * TILE_SIZE
	player_y := level.player.pos.y * TILE_SIZE
	rl.DrawRectangle(i32(player_x), i32(player_y), TILE_SIZE, TILE_SIZE, rl.BLUE)
}

render_boxes :: proc(level: ^Level) {
	for box in level.boxes {
		rl.DrawRectangle(
			i32(box.pos.x) * TILE_SIZE,
			i32(box.pos.y) * TILE_SIZE,
			TILE_SIZE,
			TILE_SIZE,
			rl.PINK,
		)
	}
}
