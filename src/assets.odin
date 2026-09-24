package main

import rl "vendor:raylib"

// todo: i should prob consider a better way to load assets. my brain tells me to
// just read the src/assets path and load the filename and use them instead.
// also some sort of array. later problem

// map assets from -> https://dani-maccari.itch.io/sokoban-tileset
// player assets from -> https://gibbongl.itch.io/8-directional-gameboy-character-template

GOAL_ASSET_PATH :: "src/assets/goal.png"
TILE_SET_ASSET_PATH :: "src/assets/tileset.png"

// animation
UP :: "src/assets/up1.png"
UP_2 :: "src/assets/up2.png"
UP_3 :: "src/assets/up3.png"
UP_4 :: "src/assets/up4.png"

DOWN :: "src/assets/down1.png"
DOWN_2 :: "src/assets/down2.png"
DOWN_3 :: "src/assets/down3.png"
DOWN_4 :: "src/assets/down4.png"

LEFT :: "src/assets/left1.png"
LEFT_2 :: "src/assets/left2.png"
LEFT_3 :: "src/assets/left3.png"
LEFT_4 :: "src/assets/left4.png"

RIGHT :: "src/assets/right1.png"
RIGHT_2 :: "src/assets/right2.png"
RIGHT_3 :: "src/assets/right3.png"
RIGHT_4 :: "src/assets/right4.png"

Assets :: struct {
	player_up:    [4]rl.Texture2D,
	player_down:  [4]rl.Texture2D,
	player_left:  [4]rl.Texture2D,
	player_right: [4]rl.Texture2D,
	goal:         rl.Texture2D,
	tileset:      rl.Texture2D,
}

Player_Direction :: enum {
	Up,
	Down,
	Left,
	Right,
}

load_assets :: proc() -> Assets {
	return Assets {
		player_up = load_player_assets(.Up),
		player_down = load_player_assets(.Down),
		player_left = load_player_assets(.Left),
		player_right = load_player_assets(.Right),
		goal = rl.LoadTexture(GOAL_ASSET_PATH),
		tileset = rl.LoadTexture(TILE_SET_ASSET_PATH),
	}
}

unload_assets :: proc(assets: ^Assets) {
	for texture in assets.player_up {
		rl.UnloadTexture(texture)
	}

	for texture in assets.player_down {
		rl.UnloadTexture(texture)
	}

	for texture in assets.player_left {
		rl.UnloadTexture(texture)
	}

	for texture in assets.player_right {
		rl.UnloadTexture(texture)
	}
	rl.UnloadTexture(assets.goal)
	rl.UnloadTexture(assets.tileset)
}

load_player_assets :: proc(direction: Player_Direction) -> [4]rl.Texture2D {
	switch direction {
	case .Up:
		return {
			rl.LoadTexture(UP),
			rl.LoadTexture(UP_2),
			rl.LoadTexture(UP_3),
			rl.LoadTexture(UP_4),
		}
	case .Down:
		return {
			rl.LoadTexture(DOWN),
			rl.LoadTexture(DOWN_2),
			rl.LoadTexture(DOWN_3),
			rl.LoadTexture(DOWN_4),
		}
	case .Left:
		return {
			rl.LoadTexture(LEFT),
			rl.LoadTexture(LEFT_2),
			rl.LoadTexture(LEFT_3),
			rl.LoadTexture(LEFT_4),
		}
	case .Right:
		return {
			rl.LoadTexture(RIGHT),
			rl.LoadTexture(RIGHT_2),
			rl.LoadTexture(RIGHT_3),
			rl.LoadTexture(RIGHT_4),
		}
	}
	return {}
}
