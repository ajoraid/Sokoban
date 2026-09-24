package main

update_player_animation :: proc(gs: ^Game_State, dt: f32) {
	player := &gs.level.player

	if !player.animating do return

	player.frame_timer += dt

	if player.frame_timer >= PLAYER_FRAME_DURATION {
		player.frame_timer = 0
		player.frame += 1

		if player.frame >= 4 {
			player.frame = 0
			player.animating = false
		}
	}
}
