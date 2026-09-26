package main

import "core:fmt"
import rl "vendor:raylib"

Editor_Tool :: enum {
	Wall,
	Floor,
	Goal,
	Box,
	Player,
}

process_level_editor_input :: proc(gs: ^Game_State) {
	if rl.IsKeyPressed(.ONE) do gs.editor_tool = .Wall
	if rl.IsKeyPressed(.TWO) do gs.editor_tool = .Floor
	if rl.IsKeyPressed(.THREE) do gs.editor_tool = .Goal
	if rl.IsKeyPressed(.FOUR) do gs.editor_tool = .Box
	if rl.IsKeyPressed(.FIVE) do gs.editor_tool = .Player
	mouse_pos := rl.GetMousePosition()
	grid_pos := screen_to_grid(mouse_pos)
	if rl.IsMouseButtonDown(.LEFT) {
		if within_bounds(gs, grid_pos) {
			switch gs.editor_tool {
			case .Wall:
				gs.level.board[grid_pos.y][grid_pos.x] = .Wall
			case .Floor:
				gs.level.board[grid_pos.y][grid_pos.x] = .Floor
			case .Goal:
				gs.level.board[grid_pos.y][grid_pos.x] = .Goal
			case .Box:
				box_exists, _ := box_at(gs, grid_pos)
				if !box_exists {
					append(&gs.level.boxes, Box{pos = grid_pos})
				}
			case .Player:
				gs.level.player = Entity {
					pos = grid_pos,
				}
			}
		}
	}

	if rl.IsMouseButtonDown(.RIGHT) {
		if within_bounds(gs, grid_pos) {
			box_exists, index := box_at(gs, grid_pos)
			if box_exists {
				ordered_remove(&gs.level.boxes, index)
			} else {
				gs.level.board[grid_pos.y][grid_pos.x] = .Floor
			}
		}
	}
}

process_level_editor_rendering :: proc(gs: ^Game_State) {
	set_editor_tool_text(gs.editor_tool)
	mouse_pos := rl.GetMousePosition()
	grid_pos := screen_to_grid(mouse_pos)
	if within_bounds(gs, grid_pos) {
		pos := grid_to_screen(grid_pos)
		rl.DrawRectangle(i32(pos.x), i32(pos.y), TILE_SIZE, TILE_SIZE, rl.Color{255, 255, 255, 60})
	}
}

set_editor_tool_text :: proc(tool: Editor_Tool) {
	tool_text: cstring = "Wall"

	switch tool {
	case .Wall:
		tool_text = "Wall"
	case .Floor:
		tool_text = "Floor"
	case .Goal:
		tool_text = "Goal"
	case .Box:
		tool_text = "Box"
	case .Player:
		tool_text = "Player"
	}

	rl.DrawText(tool_text, 10, 10, 20, rl.WHITE)
}
