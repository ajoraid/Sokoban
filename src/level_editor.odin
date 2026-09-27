package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

Editor_Tool :: enum {
	Grass,
	Water,
	Goal,
	Box,
	Player,
	Wall,
}

process_level_editor_input :: proc(gs: ^Game_State) {
	if rl.IsKeyPressed(.ONE) do gs.editor_tool = .Grass
	if rl.IsKeyPressed(.TWO) do gs.editor_tool = .Water
	if rl.IsKeyPressed(.THREE) do gs.editor_tool = .Goal
	if rl.IsKeyPressed(.FOUR) do gs.editor_tool = .Box
	if rl.IsKeyPressed(.FIVE) do gs.editor_tool = .Player
	if rl.IsKeyPressed(.SIX) do gs.editor_tool = .Wall
	mouse_pos := rl.GetMousePosition()
	grid_pos := screen_to_grid(mouse_pos)
	if rl.IsMouseButtonDown(.LEFT) {
		gs.level_not_saved = true
		if within_bounds(gs, grid_pos) {
			switch gs.editor_tool {
			case .Wall:
				gs.level.board[grid_pos.y][grid_pos.x] = Tile {
					kind   = .Solid,
					visual = .Wall,
				}
			case .Water:
				gs.level.board[grid_pos.y][grid_pos.x] = Tile {
					kind   = .Solid,
					visual = .Water,
				}
			case .Grass:
				gs.level.board[grid_pos.y][grid_pos.x] = Tile {
					kind   = .Floor,
					visual = .Grass,
				}
			case .Goal:
				gs.level.board[grid_pos.y][grid_pos.x] = Tile {
					kind   = .Goal,
					visual = .Goal,
				}
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
		gs.level_not_saved = true
		if within_bounds(gs, grid_pos) {
			box_exists, index := box_at(gs, grid_pos)
			if box_exists {
				ordered_remove(&gs.level.boxes, index)
			} else {
				gs.level.board[grid_pos.y][grid_pos.x] = Tile {
					kind   = .Floor,
					visual = .Grass,
				}
			}
		}
	}
}

render_editor :: proc(gs: ^Game_State) {
	handle_text_display(gs)
	set_editor_tool_text(gs.editor_tool)
	mouse_pos := rl.GetMousePosition()
	grid_pos := screen_to_grid(mouse_pos)
	if within_bounds(gs, grid_pos) {
		pos := grid_to_screen(grid_pos)
		rl.DrawRectangle(i32(pos.x), i32(pos.y), TILE_SIZE, TILE_SIZE, rl.Color{255, 255, 255, 60})
	}
}

handle_text_display :: proc(gs: ^Game_State) {
	unsaved_mark: cstring = ""
	if gs.level_not_saved do unsaved_mark = " *"
	level_text := fmt.aprintf("Level: %03d%s", gs.current_level, unsaved_mark)
	defer delete(level_text)
	to_cstring := strings.clone_to_cstring(level_text)
	defer delete(to_cstring)
	rl.DrawText(to_cstring, 10, 40, 20, rl.WHITE)
	if gs.save_message_timer > 0 do rl.DrawText("Saved!", 10, 70, 20, rl.GREEN)

}

set_editor_tool_text :: proc(tool: Editor_Tool) {
	tool_text: cstring = "Wall"

	switch tool {
	case .Water:
		tool_text = "Water"
	case .Wall:
		tool_text = "Wall"
	case .Grass:
		tool_text = "Grass"
	case .Goal:
		tool_text = "Goal"
	case .Box:
		tool_text = "Box"
	case .Player:
		tool_text = "Player"
	}

	rl.DrawText(tool_text, 10, 10, 20, rl.WHITE)
}

handle_level_editor_file_operations :: proc(gs: ^Game_State) {
	if rl.IsKeyPressed(.S) {
		path := level_path(gs.current_level)
		defer delete(path)
		save_level(gs, path)
	}

	if rl.IsKeyPressed(.N) {
		unload_level(&gs.level)
		gs.current_level += 1
		gs.level = new_level()
	}

	if rl.IsKeyPressed(.RIGHT) {
		fmt.println("RIGHT PRESSED")
		fmt.println("current before:", gs.current_level)
		try_load_level_index(gs, gs.current_level + 1)
		fmt.println("current after:", gs.current_level)
	}

	if rl.IsKeyPressed(.LEFT) && gs.current_level > 0 {
		try_load_level_index(gs, gs.current_level - 1)
	}
}
