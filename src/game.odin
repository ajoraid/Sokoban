package main

import rl "vendor:raylib"

Game_State :: struct {
	level:  Level,
	assets: Assets,
	audio:  Audio,
	won:    bool,
}

game_init :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_NAME)
	rl.InitAudioDevice()

	gs := Game_State {
		level  = load_level(),
		assets = load_assets(),
		audio  = load_audio(),
		won    = false,
	}

	rl.PlayMusicStream(gs.audio.background)
	rl.SetMusicVolume(gs.audio.background, 0.2)

	defer rl.CloseWindow()
	defer unload_level(&gs.level)
	defer unload_assets(&gs.assets)
	defer unload_audio(&gs.audio)

	for !rl.WindowShouldClose() {
		rl.UpdateMusicStream(gs.audio.background)
		dt := rl.GetFrameTime()
		process_input(&gs)
		update_player_animation(&gs, dt)

		was_won := gs.won
		gs.won = did_win(&gs)

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		render_game(&gs)

		if !was_won && gs.won {
			rl.PlaySound(gs.audio.win)
		}

		if gs.won {
			draw_win_text()
		}

		rl.EndDrawing()
	}
}
