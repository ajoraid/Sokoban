package main

import rl "vendor:raylib"

render_game :: proc(level: ^Level, assets: Assets) {
	render_level(level, assets)
	render_player(level, assets)
	render_boxes(level, assets)
}

render_level :: proc(level: ^Level, assets: Assets) {
	for row, y in level.board {
		for tile, x in row {
			switch tile {
			case .Wall:
				rl.DrawTexture(assets.wall, i32(x) * TILE_SIZE, i32(y) * TILE_SIZE, rl.WHITE)

			case .Floor:
				rl.DrawTexture(assets.floor, i32(x) * TILE_SIZE, i32(y) * TILE_SIZE, rl.WHITE)

			case .Goal:
				rl.DrawTexture(assets.goal, i32(x) * TILE_SIZE, i32(y) * TILE_SIZE, rl.WHITE)
			}
		}
	}
}

render_player :: proc(level: ^Level, assets: Assets) {
	player_x := level.player.pos.x * TILE_SIZE
	player_y := level.player.pos.y * TILE_SIZE
	rl.DrawTexture(assets.player, i32(player_x), i32(player_y), rl.WHITE)
}

render_boxes :: proc(level: ^Level, assets: Assets) {
	for box in level.boxes {
		rl.DrawTexture(
			assets.box,
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
