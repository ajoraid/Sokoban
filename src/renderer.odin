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
			pos := Vec2{f32(x) * TILE_SIZE, f32(y) * TILE_SIZE}
			switch tile {
			case .Wall:
				rl.DrawTextureEx(gs.assets.wall, pos, 0, SCALE, rl.WHITE)

			case .Floor:
				rl.DrawTextureEx(gs.assets.floor, pos, 0, SCALE, rl.WHITE)

			case .Goal:
				rl.DrawTextureEx(gs.assets.goal, pos, 0, SCALE, rl.GREEN)
			}
		}
	}
}

render_player :: proc(gs: ^Game_State) {
	player_x := f32(gs.level.player.pos.x) * TILE_SIZE
	player_y := f32(gs.level.player.pos.y) * TILE_SIZE
	pos := Vec2{player_x, player_y}
	rl.DrawTextureEx(gs.assets.player, pos, 0, SCALE, rl.WHITE)
}

render_boxes :: proc(gs: ^Game_State) {
	for box in gs.level.boxes {
		pos := Vec2{f32(box.pos.x) * TILE_SIZE, f32(box.pos.y) * TILE_SIZE}
		rl.DrawTextureEx(gs.assets.box, pos, 0, SCALE, rl.WHITE)
	}
}
draw_win_text :: proc() {
	text_width := rl.MeasureText(WON_TEXT, FONT_SIZE)
	x := (WINDOW_WIDTH - text_width) / 2
	y := (WINDOW_HEIGHT - FONT_SIZE) / 2
	rl.DrawText(WON_TEXT, i32(x), i32(y), FONT_SIZE, rl.WHITE)
}
