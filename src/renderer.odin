package main

import rl "vendor:raylib"

render_game :: proc(gs: ^Game_State) {
	render_background(gs)
	render_level(gs)
	render_player(gs)
	render_boxes(gs)
}

render_level :: proc(gs: ^Game_State) {
	for row, y in gs.level.board {
		for tile, x in row {
			pos := grid_to_screen({x, y})
			switch tile {
			case .Wall:
				source := rl.Rectangle {
					x      = 0,
					y      = 48,
					width  = TEXTURE_FRAME,
					height = TEXTURE_FRAME,
				}

				dest := rl.Rectangle {
					x      = pos.x,
					y      = pos.y,
					width  = TILE_SIZE,
					height = TILE_SIZE,
				}

				rl.DrawTexturePro(gs.assets.tileset, source, dest, Vec2{0, 0}, 0, rl.WHITE)

			case .Floor:
				source := rl.Rectangle {
					x      = 0,
					y      = 16,
					width  = TEXTURE_FRAME,
					height = TEXTURE_FRAME,
				}

				dest := rl.Rectangle {
					x      = pos.x,
					y      = pos.y,
					width  = TILE_SIZE,
					height = TILE_SIZE,
				}

				rl.DrawTexturePro(gs.assets.tileset, source, dest, Vec2{0, 0}, 0, rl.WHITE)

			case .Goal:
				rl.DrawTextureEx(gs.assets.goal, pos, 0, SCALE, rl.GREEN)
			}
		}
	}
}

render_player :: proc(gs: ^Game_State) {
	pos := grid_to_screen(gs.level.player.pos)
	texture: rl.Texture2D

	switch gs.level.player.facing {
	case .Up:
		texture = gs.assets.player_up[gs.level.player.frame]
	case .Down:
		texture = gs.assets.player_down[gs.level.player.frame]
	case .Left:
		texture = gs.assets.player_left[gs.level.player.frame]
	case .Right:
		texture = gs.assets.player_right[gs.level.player.frame]
	}

	rl.DrawTextureEx(texture, pos, 0, 2, rl.WHITE)
}

render_boxes :: proc(gs: ^Game_State) {
	for box in gs.level.boxes {
		pos := grid_to_screen(box.pos)
		source := rl.Rectangle {
			x      = 0,
			y      = 64,
			width  = TEXTURE_FRAME,
			height = TEXTURE_FRAME,
		}

		dest := rl.Rectangle {
			x      = pos.x,
			y      = pos.y,
			width  = TILE_SIZE,
			height = TILE_SIZE,
		}
		rl.DrawTexturePro(gs.assets.tileset, source, dest, Vec2{0, 0}, 0, rl.WHITE)
	}
}

render_background :: proc(gs: ^Game_State) {
	source := rl.Rectangle {
		x      = 0,
		y      = 16,
		width  = TEXTURE_FRAME,
		height = TEXTURE_FRAME,
	}

	for y := 0; y < WINDOW_HEIGHT; y += TILE_SIZE {
		for x := 0; x < WINDOW_WIDTH; x += TILE_SIZE {
			dest := rl.Rectangle {
				x      = f32(x),
				y      = f32(y),
				width  = TILE_SIZE,
				height = TILE_SIZE,
			}

			rl.DrawTexturePro(gs.assets.tileset, source, dest, Vec2{0, 0}, 0, rl.WHITE)
		}
	}
}

draw_win_text :: proc() {
	text_width := rl.MeasureText(WON_TEXT, FONT_SIZE)
	x := (WINDOW_WIDTH - text_width) / 2
	y := (WINDOW_HEIGHT - FONT_SIZE) / 2
	rl.DrawText(WON_TEXT, i32(x), i32(y), FONT_SIZE, rl.WHITE)
}

grid_to_screen :: proc(pos: Vec2i) -> Vec2 {
	return Vec2{PADDING + f32(pos.x) * TILE_SIZE, PADDING + f32(pos.y) * TILE_SIZE}
}
