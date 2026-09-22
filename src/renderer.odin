package main

import rl "vendor:raylib"

render_game :: proc(gs: ^Game_State) {
	render_level(gs)
	render_player(gs)
	render_boxes(gs)
}

render_level :: proc(gs: ^Game_State) {
	for row, y in gs.level.board {
		for tile, x in row {
			switch tile {
			case .Wall:
				rl.DrawTexture(gs.assets.wall, i32(x) * TILE_SIZE, i32(y) * TILE_SIZE, rl.WHITE)

			case .Floor:
				rl.DrawTexture(gs.assets.floor, i32(x) * TILE_SIZE, i32(y) * TILE_SIZE, rl.WHITE)

			case .Goal:
				rl.DrawTexture(gs.assets.goal, i32(x) * TILE_SIZE, i32(y) * TILE_SIZE, rl.WHITE)
			}
		}
	}
}

render_player :: proc(gs: ^Game_State) {
	player_x := gs.level.player.pos.x * TILE_SIZE
	player_y := gs.level.player.pos.y * TILE_SIZE
	rl.DrawTexture(gs.assets.player, i32(player_x), i32(player_y), rl.WHITE)
}

render_boxes :: proc(gs: ^Game_State) {
	for box in gs.level.boxes {
		rl.DrawTexture(
			gs.assets.box,
			i32(box.pos.x) * TILE_SIZE,
			i32(box.pos.y) * TILE_SIZE,
			rl.WHITE,
		)
	}
}
draw_win_text :: proc() {
	text_width := rl.MeasureText(WON_TEXT, FONT_SIZE)
	x := (WINDOW_WIDTH - text_width) / 2
	y := (WINDOW_HEIGHT - FONT_SIZE) / 2
	rl.DrawText(WON_TEXT, i32(x), i32(y), FONT_SIZE, rl.WHITE)
}
