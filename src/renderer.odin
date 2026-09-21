package main

import rl "vendor:raylib"

render_game :: proc(level: ^Level) {
	render_level(level)
	render_player(level)
	render_boxes(level)
}

render_level :: proc(level: ^Level) {
	for row, y in level.board {
		for tile, x in row {
			switch tile {
			case .Wall:
				rl.DrawRectangle(
					i32(x) * TILE_SIZE,
					i32(y) * TILE_SIZE,
					TILE_SIZE,
					TILE_SIZE,
					rl.GRAY,
				)

			case .Floor:
				rl.DrawRectangle(
					i32(x) * TILE_SIZE,
					i32(y) * TILE_SIZE,
					TILE_SIZE,
					TILE_SIZE,
					rl.DARKGRAY,
				)

			case .Goal:
				rl.DrawRectangle(
					i32(x) * TILE_SIZE,
					i32(y) * TILE_SIZE,
					TILE_SIZE,
					TILE_SIZE,
					rl.GREEN,
				)
			}
		}
	}
}

render_player :: proc(level: ^Level) {
	player_x := level.player.pos.x * TILE_SIZE
	player_y := level.player.pos.y * TILE_SIZE
	rl.DrawRectangle(i32(player_x), i32(player_y), TILE_SIZE, TILE_SIZE, rl.BLUE)
}

render_boxes :: proc(level: ^Level) {
	for box in level.boxes {
		rl.DrawRectangle(
			i32(box.pos.x) * TILE_SIZE,
			i32(box.pos.y) * TILE_SIZE,
			TILE_SIZE,
			TILE_SIZE,
			rl.PINK,
		)
	}
}

draw_win_text :: proc() {
	text_width := rl.MeasureText(WON_TEXT, FONT_SIZE)
	x := (WINDOW_WIDTH - text_width) / 2
	y := (WINDOW_HEIGHT - FONT_SIZE) / 2
	rl.DrawText(WON_TEXT, i32(x), i32(y), FONT_SIZE, rl.WHITE)
}
