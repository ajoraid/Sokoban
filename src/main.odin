package main

import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_NAME)
	defer rl.CloseWindow()

	level := load_level()
	assets := load_assets()
	defer unload_assets(assets)

	for !rl.WindowShouldClose() {
		process_input(&level)
		won := did_win(&level)

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		render_game(&level, assets)

		if won do draw_win_text()

		rl.EndDrawing()
	}
}
