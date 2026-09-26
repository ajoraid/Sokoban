package main

import "core:fmt"
import "core:sys/wasm/wasi"
import rl "vendor:raylib"

Game_Mode :: enum {
	Playing,
	Editing,
}

Game_State :: struct {
	mode:        Game_Mode,
	editor_tool: Editor_Tool,
	level:       Level,
	assets:      Assets,
	audio:       Audio,
	won:         bool,
}

game_init :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_NAME)
	rl.InitAudioDevice()

	gs := Game_State {
		mode        = .Playing,
		editor_tool = .Grass,
		level       = load_level(),
		assets      = load_assets(),
		audio       = load_audio(),
		won         = false,
	}

	rl.PlayMusicStream(gs.audio.background)
	rl.SetMusicVolume(gs.audio.background, 0.2)

	defer rl.CloseWindow()
	defer unload_level(&gs.level)
	defer unload_assets(&gs.assets)
	defer unload_audio(&gs.audio)

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		rl.UpdateMusicStream(gs.audio.background)

		process_game_mode(&gs, dt)

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		render_game(&gs)

		if gs.mode == .Editing do render_editor(&gs)
		if gs.mode == .Playing && gs.won do draw_win_text()

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
	switch gs.mode {
	case .Playing:
		process_input(gs)
		update_player_animation(gs, dt)
		was_won := gs.won
		gs.won = did_win(gs)
		if !was_won && gs.won {
			rl.PlaySound(gs.audio.win)
		}
	case .Editing:
		process_level_editor_input(gs)
	}
}
