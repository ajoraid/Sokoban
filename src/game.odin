package main

import rl "vendor:raylib"

Game_State :: struct {
	level:  Level,
	assets: Assets,
	audio:  Audio,
}

game_init :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_NAME)
	rl.InitAudioDevice()

	gs := Game_State {
		level  = load_level(),
		assets = load_assets(),
		audio  = load_audio(),
	}

	defer rl.CloseWindow()
	defer unload_level(&gs.level)
	defer unload_assets(&gs.assets)
	defer unload_audio(&gs.audio)

	for !rl.WindowShouldClose() {
		process_input(&gs)
		won := did_win(&gs)

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		render_game(&gs)

		if won do draw_win_text()

		rl.EndDrawing()
	}
}
