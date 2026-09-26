package main

import "core:os"

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
	pos:         Vec2i,
	frame:       int,
	animating:   bool,
	frame_timer: f32,
	facing:      Direction,
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
}

Tile :: struct {
	kind:   Tile_Kind,
	visual: Tile_Visual,
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


// how im gonna map it
/*
 ' ' -> kind = floor | visual = grass
 '#' -> kind = solid | visual = water
 '.' -> kind = goal  | visual = goal
*/

load_level :: proc() -> Level {
	level_data, ok := os.read_entire_file_from_path("src/levels/level_000.dat", context.allocator)
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
		case '#':
			append(&current_row, Tile{kind = .Solid, visual = .Water})
			x += 1
		case '.':
			append(&current_row, Tile{kind = .Goal, visual = .Goal})
			x += 1
		case ' ':
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
