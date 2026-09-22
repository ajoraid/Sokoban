package main

import rl "vendor:raylib"


// todo: i should prob consider a better way to load assets. my brain tells me to
// just read the src/assets path and load the filename and use them instead.
// also some sort of array. later problem

PLAYER_ASSET_PATH :: "src/assets/player.png"
BOX_ASSET_PATH :: "src/assets/box.png"
FLOOR_ASSET_PATH :: "src/assets/floor.png"
WALL_ASSET_PATH :: "src/assets/wall.png"
GOAL_ASSET_PATH :: "src/assets/goal.png"

Assets :: struct {
	player: rl.Texture2D,
	box:    rl.Texture2D,
	floor:  rl.Texture2D,
	wall:   rl.Texture2D,
	goal:   rl.Texture2D,
}

load_assets :: proc() -> Assets {
	return Assets {
		player = rl.LoadTexture(PLAYER_ASSET_PATH),
		box = rl.LoadTexture(BOX_ASSET_PATH),
		floor = rl.LoadTexture(FLOOR_ASSET_PATH),
		wall = rl.LoadTexture(WALL_ASSET_PATH),
		goal = rl.LoadTexture(GOAL_ASSET_PATH),
	}
}

unload_assets :: proc(assets: ^Assets) {
	rl.UnloadTexture(assets.player)
	rl.UnloadTexture(assets.box)
	rl.UnloadTexture(assets.floor)
	rl.UnloadTexture(assets.wall)
	rl.UnloadTexture(assets.goal)
}
