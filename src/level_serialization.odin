package main

import "core:fmt"
import "core:os"
import rl "vendor:raylib"

Vec2i :: struct {
	x, y: int,
}

Direction :: enum {
	Down,
	Up,
	Left,
	Right,
}

Entity :: struct {
	pos:             Vec2i,
	last_move:       Vec2i,
	did_player_move: bool,
	frame:           int,
	animating:       bool,
	frame_timer:     f32,
	facing:          Direction,
}

Tile_Kind :: enum {
	Solid,
	Floor,
	Goal,
}

Tile_Visual :: enum {
	Grass,
	Water,
	Goal,
	Box,
	Wall,
}

Tile :: struct {
	kind:   Tile_Kind,
	visual: Tile_Visual,
}

Box :: struct {
	pos:                  Vec2i,
	last_box_location:    Vec2i,
	last_moved_box_index: int,
	did_box_move:         bool,
}

Level :: struct {
	width:       int,
	height:      int,
	board:       [dynamic][dynamic]Tile,
	player:      Entity,
	boxes:       [dynamic]Box,
	goals_count: int,
}

load_level :: proc(path: string = "src/levels/level_000.dat") -> Level {
	level_data, ok := os.read_entire_file_from_path(path, context.allocator)
	defer delete(level_data)
	assert(ok == nil, "Failed to lead level data.")

	level := Level{}
	current_row: [dynamic]Tile
	x, y: int

	for tile in level_data {
		switch tile {
		case '\n':
			append(&level.board, current_row)
			current_row = make([dynamic]Tile)
			y += 1
			x = 0
		case 'W':
			append(&current_row, Tile{kind = .Solid, visual = .Wall})
		case '#':
			append(&current_row, Tile{kind = .Solid, visual = .Water})
			x += 1
		case '.':
			append(&current_row, Tile{kind = .Goal, visual = .Goal})
			level.goals_count += 1
			x += 1
		case 'g':
			append(&current_row, Tile{kind = .Floor, visual = .Grass})
			x += 1
		case '@':
			append(&current_row, Tile{kind = .Floor, visual = .Grass})
			level.player.pos = Vec2i{x, y}
			x += 1
		case '$':
			append(&current_row, Tile{kind = .Floor, visual = .Grass})
			append(&level.boxes, Box{pos = Vec2i{x, y}})
			x += 1
		}
	}

	if len(current_row) > 0 {
		append(&level.board, current_row)
	}

	level.width = len(level.board[0])
	level.height = len(level.board)

	return level
}

unload_level :: proc(level: ^Level) {
	for row in level.board {
		delete(row)
	}
	delete(level.board)
	delete(level.boxes)
}

tile_to_char :: proc(tile: Tile) -> u8 {
	switch tile.kind {
	case .Floor:
		#partial switch tile.visual {
		case .Grass:
			return 'g'
		}

	case .Solid:
		#partial switch tile.visual {
		case .Water:
			return '#'
		case .Wall:
			return 'W'
		}

	case .Goal:
		return '.'
	}
	return 'a'
}

save_level :: proc(gs: ^Game_State, path: string) {
	data := make([dynamic]u8)
	defer delete(data)

	for row, y in gs.level.board {
		for tile, x in row {
			pos := Vec2i{x, y}
			ch := tile_to_char(tile)

			if gs.level.player.pos == pos {
				ch = '@'
			} else {
				box_exists, _ := box_at(gs, pos)
				if box_exists do ch = '$'
			}
			append(&data, ch)
		}

		append(&data, '\n')

	}

	ok := os.write_entire_file(path, data[:])
	if ok != nil do rl.DrawText("Failed to Saved!", 10, 40, 20, rl.RED)
	gs.save_message_timer = 1.0
	gs.level_not_saved = false
}

new_level :: proc() -> Level {
	level := Level {
		width  = LEVEL_WIDTH,
		height = LEVEL_HEIGHT,
	}

	for y in 0 ..< LEVEL_HEIGHT {
		row := make([dynamic]Tile)
		for x in 0 ..< LEVEL_WIDTH {
			append(&row, Tile{kind = .Floor, visual = .Grass})
		}
		append(&level.board, row)
	}
	return level
}

level_path :: proc(index: int) -> string {
	path := fmt.aprintf("src/levels/level_%03d.dat", index)
	return path
}

try_load_level_index :: proc(gs: ^Game_State, index: int) {
	if index < 0 do return
	path := level_path(index)
	defer delete(path)

	if !os.exists(path) do return

	unload_level(&gs.level)

	gs.current_level = index

	gs.level = load_level(path)
	gs.current_level = index
}
