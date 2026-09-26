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
			#partial switch tile.visual {
			case .Water:
				dest := tile_destination(pos)
				rl.DrawTexturePro(
					gs.assets.tileset,
					get_source_for_tile(.Water),
					dest,
					Vec2{0, 0},
					0,
					rl.WHITE,
				)

			case .Grass:
				dest := tile_destination(pos)
				rl.DrawTexturePro(
					gs.assets.tileset,
					get_source_for_tile(.Grass),
					dest,
					Vec2{0, 0},
					0,
					rl.WHITE,
				)

			case .Goal:
				dest := tile_destination(pos)
				rl.DrawTexturePro(
					gs.assets.tileset,
					get_source_for_tile(.Goal),
					dest,
					Vec2{0, 0},
					0,
					rl.WHITE,
				)
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
		source := get_source_for_tile(.Box)
		dest := tile_destination(pos)
		rl.DrawTexturePro(gs.assets.tileset, source, dest, Vec2{0, 0}, 0, rl.WHITE)
	}
}

render_background :: proc(gs: ^Game_State) {
	for y := 0; y < WINDOW_HEIGHT; y += TILE_SIZE {
		for x := 0; x < WINDOW_WIDTH; x += TILE_SIZE {
			dest := tile_destination({f32(x), f32(y)})
			source := get_source_for_tile(.Grass)
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
	return {f32(pos.x) * TILE_SIZE, f32(pos.y) * TILE_SIZE}
}

screen_to_grid :: proc(pos: Vec2) -> Vec2i {
	return {int(pos.x / TILE_SIZE), int(pos.y / TILE_SIZE)}
}

get_source_for_tile :: proc(tile: Tile_Visual) -> rl.Rectangle {
	switch tile {
	case .Water:
		return tile_source(0, 48)
	case .Grass:
		return tile_source(0, 16)
	case .Goal:
		return tile_source(48, 1)
	case .Box:
		return tile_source(0, 64)
	}
	return {}
}

tile_source :: proc(col, row: f32) -> rl.Rectangle {
	return {
		x = col * TEXTURE_FRAME,
		y = row * TEXTURE_FRAME,
		width = TEXTURE_FRAME,
		height = TEXTURE_FRAME,
	}
}

tile_destination :: proc(pos: Vec2) -> rl.Rectangle {
	return {x = pos.x, y = pos.y, width = TILE_SIZE, height = TILE_SIZE}
}
