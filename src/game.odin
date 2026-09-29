package main

import "core:fmt"
import "core:os"
import rl "vendor:raylib"

Game_Mode :: enum {
	Playing,
	Editing,
	Level_Complete,
	Game_Complete,
	Restart_Level,
}

Undo_State :: struct {
	valid:          bool,
	player_pos:     Vec2i,
	box_pos:        Vec2i,
	box_moved:      bool,
	box_index:      int,
	mirror_pos:     Vec2i,
	mirror_b_pos:   Vec2i,
	mirror_moved:   bool,
	mirror_b_moved: bool,
	mirror_index:   int,
	mirror_b_index: int,
}

Game_State :: struct {
	mode:                  Game_Mode,
	editor_tool:           Editor_Tool,
	undo:                  Undo_State,
	level:                 Level,
	assets:                Assets,
	audio:                 Audio,
	won:                   bool,
	level_not_saved:       bool,
	save_message_timer:    f32,
	current_level:         int,
	did_teleport:          bool,
	last_moved_mirror_pos: Vec2i,
}

game_init :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_NAME)
	rl.InitAudioDevice()

	gs := Game_State {
		mode          = .Playing,
		editor_tool   = .Grass,
		level         = load_level(),
		assets        = load_assets(),
		audio         = load_audio(),
		won           = false,
		current_level = 0,
	}

	rl.PlayMusicStream(gs.audio.background)
	rl.PlayMusicStream(gs.audio.wave)
	rl.SetMusicVolume(gs.audio.wave, 0.4)
	rl.SetMusicVolume(gs.audio.background, 0.2)

	defer rl.CloseWindow()
	defer unload_level(&gs.level)
	defer unload_assets(&gs.assets)
	defer unload_audio(&gs.audio)

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		rl.UpdateMusicStream(gs.audio.background)
		rl.UpdateMusicStream(gs.audio.wave)

		process_game_mode(&gs, dt)

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		render_game(&gs)

		if gs.mode == .Editing do render_editor(&gs)
		if gs.mode == .Level_Complete do draw_message("Level Complete - Press ENTER to proceed")
		if gs.mode == .Game_Complete do draw_message("Game Complete - Press Enter to restart")
		if gs.current_level == 0 do show_game_instructions(&gs)

		rl.EndDrawing()
	}
}

process_game_mode :: proc(gs: ^Game_State, dt: f32) {
	if rl.IsKeyPressed(.F1) {
		if gs.mode == .Playing {
			gs.mode = .Editing
		} else {
			gs.mode = .Playing
		}
	}
	if rl.IsKeyPressed(.R) do gs.mode = .Restart_Level
	switch gs.mode {
	case .Playing:
		process_input(gs)
		update_player_animation(gs, dt)
		was_won := gs.won
		teleporter_active := did_activate_teleportation(gs)
		gs.won = did_win(gs)
		if teleporter_active && !gs.did_teleport {
			teleport_player_to_other_mirror_location(gs)
			rl.PlaySound(gs.audio.teleport)
		}
		gs.did_teleport = teleporter_active
		if !was_won && gs.won {
			rl.PlaySound(gs.audio.win)
			if level_exists(gs.current_level + 1) {
				gs.mode = .Level_Complete
			} else {
				gs.mode = .Game_Complete
			}
		}

	case .Editing:
		if gs.save_message_timer > 0 {
			gs.save_message_timer -= dt
			if gs.save_message_timer < 0 do gs.save_message_timer = 0
		}
		handle_level_editor_file_operations(gs)
		process_level_editor_input(gs)

	case .Level_Complete:
		draw_message("Level Complete - Press ENTER to proceed")
		if rl.IsKeyPressed(.ENTER) {
			next_index := gs.current_level + 1
			if level_exists(next_index) {
				try_load_level_index(gs, next_index)
				gs.won = false
				gs.undo.valid = false
				gs.did_teleport = false
				gs.mode = .Playing
			} else {
				gs.mode = .Game_Complete
			}
		}

	case .Game_Complete:
		if rl.IsKeyPressed(.ENTER) {
			try_load_level_index(gs, 0)
			gs.won = false
			gs.undo.valid = false
			gs.did_teleport = false
			gs.mode = .Playing
		}


	case .Restart_Level:
		try_load_level_index(gs, gs.current_level)
		gs.won = false
		gs.undo.valid = false
		gs.did_teleport = false
		gs.mode = .Playing
	}
}

show_game_instructions :: proc(gs: ^Game_State) {
	rl.DrawTexture(gs.assets.instructions, 0, 0, rl.WHITE)
}
