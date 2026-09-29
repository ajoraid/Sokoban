package main

import "core:sys/wasm/wasi"
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
	if rl.IsKeyPressed(.U) && gs.undo.valid {
		level.player.pos = gs.undo.player_pos

		if gs.undo.box_moved {
			level.boxes[gs.undo.box_index].pos = gs.undo.box_pos
		}

		if gs.undo.mirror_moved {
			level.mirrors[gs.undo.mirror_index].pos = gs.undo.mirror_pos
		}

		if gs.undo.mirror_b_moved {
			level.mirrors[gs.undo.mirror_b_index].pos = gs.undo.mirror_b_pos
		}

		gs.undo.valid = false
	}

	if !did_move do return

	next_pos := Vec2i{level.player.pos.x + direction.x, level.player.pos.y + direction.y}
	if is_valid_move(gs, next_pos) {
		gs.undo = Undo_State {
			valid      = true,
			player_pos = level.player.pos,
			box_moved  = false,
		}
		rl.PlaySound(gs.audio.walk)

		level.player.pos = next_pos
		level.player.frame = 0
		level.player.animating = true
		level.player.facing = facing
	} else {
		box_exists, box_index := box_at(gs, next_pos)
		if box_exists {
			if try_push_box(gs, box_index, direction) {
				gs.undo = Undo_State {
					valid      = true,
					player_pos = level.player.pos,
					box_moved  = true,
					box_index  = box_index,
					box_pos    = next_pos,
				}

				rl.PlaySound(gs.audio.push)
				level.player.pos = next_pos
				level.player.frame = 0
				level.player.animating = true
				level.player.facing = facing

			}
		} else {
			mirror_exists, mirror_index := mirror_at(gs, next_pos)
			mirror_b_pos, mirror_b_index := find_other_mirror_pos(gs)
			if mirror_exists {
				if try_push_mirror(gs, mirror_index, direction) {
					gs.undo = Undo_State {
						valid        = true,
						player_pos   = level.player.pos,
						mirror_moved = true,
						mirror_index = mirror_index,
						mirror_pos   = next_pos,
					}

					rl.PlaySound(gs.audio.push)
					level.player.pos = next_pos
					level.player.frame = 0
					level.player.animating = true
					level.player.facing = facing
				}
			}
		}
	}
}

is_valid_move :: proc(gs: ^Game_State, pos: Vec2i) -> bool {
	level := &gs.level
	if !within_bounds(gs, pos) do return false
	if level.board[pos.y][pos.x].kind == .Solid do return false
	is_blocked_by_box, _ := box_at(gs, pos)
	is_blocked_by_mirror, _ := mirror_at(gs, pos)
	return !is_blocked_by_box && !is_blocked_by_mirror
}

box_at :: proc(gs: ^Game_State, pos: Vec2i) -> (bool, int) {
	level := &gs.level
	if !within_bounds(gs, pos) do return false, -1
	for box, index in level.boxes {
		if box.pos.x == pos.x && box.pos.y == pos.y do return true, index
	}
	return false, -1
}

mirror_at :: proc(gs: ^Game_State, pos: Vec2i) -> (bool, int) {
	level := &gs.level
	if !within_bounds(gs, pos) do return false, -1
	for mirror, index in level.mirrors {
		if mirror.pos == pos do return true, index
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
		mirror_exists, _ := mirror_at(gs, push_pos)
		if mirror_exists do return false
		switch level.board[push_pos.y][push_pos.x].kind {
		case .Floor:
			level.boxes[box_index].pos = push_pos
			return true
		case .Goal:
			if level.board[push_pos.y][push_pos.x].visual == .Goal {
				level.boxes[box_index].pos = push_pos
				rl.PlaySound(gs.audio.goal)
				return true
			}
		case .Solid:
			return false
		}
	}
	return false
}

try_push_mirror :: proc(gs: ^Game_State, mirror_index: int, direction: Vec2i) -> bool {
	level := &gs.level
	mirror_pos := level.mirrors[mirror_index]
	push_pos := Vec2i{mirror_pos.pos.x + direction.x, mirror_pos.pos.y + direction.y}
	if within_bounds(gs, push_pos) {
		box_exists, _ := box_at(gs, push_pos)
		if box_exists do return false
		mirror_exists, _ := mirror_at(gs, push_pos)
		if mirror_exists do return false
		switch level.board[push_pos.y][push_pos.x].kind {
		case .Floor:
			level.mirrors[mirror_index].pos = push_pos
			return true
		case .Goal:
			if level.board[push_pos.y][push_pos.x].visual == .Grass {
				level.mirrors[mirror_index].pos = push_pos
				gs.last_moved_mirror_pos = push_pos
				rl.PlaySound(gs.audio.goal)
				return true
			}
		case .Solid:
			return false
		}
	}

	return false
}

did_activate_teleportation :: proc(gs: ^Game_State) -> bool {
	if len(gs.level.mirrors) == 0 do return false
	found_spot := false
	level := &gs.level
	for row, y in level.board {
		for tile, x in row {
			if tile.kind == .Goal && tile.visual == .Grass {
				found_spot = true
				mirror_exists, _ := mirror_at(gs, {x, y})
				if !mirror_exists do return false
			}
		}
	}
	return found_spot
}

find_other_mirror_pos :: proc(gs: ^Game_State) -> (Vec2i, int) {
	for mirror, index in gs.level.mirrors {
		if mirror.pos != gs.last_moved_mirror_pos do return mirror.pos, index
	}
	return {}, -1
}

teleport_player_to_other_mirror_location :: proc(gs: ^Game_State) {
	other_pos, other_index := find_other_mirror_pos(gs)
	gs.undo.mirror_b_pos = other_pos
	gs.undo.mirror_b_index = other_index
	gs.undo.mirror_b_moved = true
	gs.level.player.pos = find_next_x_pos(gs, other_pos, other_index, 2)
	gs.level.mirrors[other_index].pos = find_next_x_pos(gs, other_pos, other_index, 1)
}

// finding player and teleporter next x based on the passed x value
// for the two methods below, it's better to check all corners to see the first
// valid empty spot for player to teleport to; but in this game i don't care tbh
// i know when designing a map, i want to leave an empty space next to the
// mirror so that the player can teleport to. Another thing i could also do is
// when editing a level, requiring the editor to provide a space by highlighting
// in red.
find_next_x_pos :: proc(gs: ^Game_State, other_pos: Vec2i, other_index, val: int) -> Vec2i {
	x: int
	#partial switch gs.level.mirrors[other_index].facing {
	case .Left:
		x = val
	case .Right:
		x = -val
	}
	position := Vec2i{x, 0}
	new_pos := Vec2i{other_pos.x + position.x, other_pos.y + position.y}
	if within_bounds(gs, new_pos) {
		if gs.level.board[new_pos.y][new_pos.x].kind == .Floor {
			return new_pos
		}
	}
	return {}
}

did_win :: proc(gs: ^Game_State) -> bool {
	if len(gs.level.boxes) == 0 do return false
	found_goal := false
	level := &gs.level
	for row, y in level.board {
		for tile, x in row {
			if tile.kind == .Goal && tile.visual == .Goal {
				found_goal = true
				box_exist, _ := box_at(gs, {x, y})
				if !box_exist do return false
			}
		}
	}
	return found_goal
}
