package main

import rl "vendor:raylib"

process_input :: proc(gs: ^Game_State) {
	level := &gs.level
	direction: Vec2i
	facing: Direction
	did_move := false

	if rl.IsKeyPressed(.A) {
		did_move = true
		direction = Vec2i{-1, 0}
		facing = .Left
	}
	if rl.IsKeyPressed(.D) {
		did_move = true
		direction = Vec2i{1, 0}
		facing = .Right
	}
	if rl.IsKeyPressed(.S) {
		did_move = true
		direction = Vec2i{0, 1}
		facing = .Down
	}
	if rl.IsKeyPressed(.W) {
		did_move = true
		direction = Vec2i{0, -1}
		facing = .Up
	}

	if !did_move do return

	next_pos := Vec2i{level.player.pos.x + direction.x, level.player.pos.y + direction.y}
	if is_valid_move(gs, next_pos) {
		rl.PlaySound(gs.audio.walk)
		level.player.pos.x += direction.x
		level.player.pos.y += direction.y
		level.player.frame = 0
		level.player.animating = true
		level.player.facing = facing
	} else {
		box_exists, box_index := box_at(gs, next_pos)
		if box_exists {
			if try_push_box(gs, box_index, direction) {
				rl.PlaySound(gs.audio.push)
				level.player.pos = next_pos
				level.player.frame = 0
				level.player.animating = true
				level.player.facing = facing

			}
		}
	}
}

is_valid_move :: proc(gs: ^Game_State, pos: Vec2i) -> bool {
	level := &gs.level
	if !within_bounds(gs, pos) do return false
	if level.board[pos.y][pos.x].kind == .Solid do return false
	is_blocked_by_box, _ := box_at(gs, pos)
	return !is_blocked_by_box
}

box_at :: proc(gs: ^Game_State, pos: Vec2i) -> (bool, int) {
	level := &gs.level
	if !within_bounds(gs, pos) do return false, -1
	for box, index in level.boxes {
		if box.pos.x == pos.x && box.pos.y == pos.y do return true, index
	}
	return false, -1
}

within_bounds :: proc(gs: ^Game_State, pos: Vec2i) -> bool {
	level := &gs.level
	if pos.x < 0 || pos.x >= level.width do return false
	if pos.y < 0 || pos.y >= level.height do return false
	return true
}

try_push_box :: proc(gs: ^Game_State, box_index: int, direction: Vec2i) -> bool {
	level := &gs.level
	box_pos := level.boxes[box_index]
	push_pos: Vec2i = {box_pos.pos.x + direction.x, box_pos.pos.y + direction.y}
	if within_bounds(gs, push_pos) {
		box_exists, _ := box_at(gs, push_pos)
		if box_exists do return false
		switch level.board[push_pos.y][push_pos.x].kind {
		case .Floor:
			level.boxes[box_index].pos = push_pos
			return true
		case .Goal:
			level.boxes[box_index].pos = push_pos
			rl.PlaySound(gs.audio.goal)
			return true
		case .Solid:
			return false
		}
	}
	return false
}

did_win :: proc(gs: ^Game_State) -> bool {
	level := &gs.level
	for row, y in level.board {
		for tile, x in row {
			if tile.kind == .Goal {
				box_exist, _ := box_at(gs, {x, y})
				if !box_exist do return false
			}
		}
	}
	return true
}
