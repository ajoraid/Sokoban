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

Level :: struct {
	width:  int,
	height: int,
	board:  [dynamic][dynamic]Tile,
	player: Entity,
}


main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_NAME)
	defer rl.CloseWindow()

	level := Level{}
	load_level(&level)
	level.width = len(level.board[0])
	level.height = len(level.board)

	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()
		process_input(&level)
		rl.BeginDrawing()

		rl.ClearBackground(rl.BLACK)
		render_level(&level)

		rl.EndDrawing()
	}
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
		}
	}

	if len(current_row) > 0 {
		append(&level.board, current_row)
	}

	fmt.println(level.player.pos)
}

process_input :: proc(level: ^Level) {
	if rl.IsKeyPressed(.A) && is_valid_move(level, {level.player.pos.x - 1, level.player.pos.y}) do level.player.pos.x -= 1
	if rl.IsKeyPressed(.D) && is_valid_move(level, {level.player.pos.x + 1, level.player.pos.y}) do level.player.pos.x += 1
	if rl.IsKeyPressed(.S) && is_valid_move(level, {level.player.pos.x, level.player.pos.y + 1}) do level.player.pos.y += 1
	if rl.IsKeyPressed(.W) && is_valid_move(level, {level.player.pos.x, level.player.pos.y - 1}) do level.player.pos.y -= 1
}

is_valid_move :: proc(level: ^Level, pos: Vec2i) -> bool {
	if pos.x < 0 || pos.x >= level.width do return false
	if pos.y < 0 || pos.y >= level.height do return false
	return level.board[pos.x][pos.y] != .Wall
}

render_level :: proc(level: ^Level) {

}
