package main

import rl "vendor:raylib"

WALK_AUDIO_PATH :: "src/audio/walk.wav"
PUSH_AUDIO_PATH :: "src/audio/push.wav"
GOAL_AUDIO_PATH :: "src/audio/goal.wav"
WIN_AUDIO_PATH :: "src/audio/win.wav"
BACKGROUND_MUSIC_PATH :: "src/audio/background.wav"

Audio :: struct {
	background: rl.Music,
	walk:       rl.Sound,
	push:       rl.Sound,
	goal:       rl.Sound,
	win:        rl.Sound,
}

load_audio :: proc() -> Audio {
	return Audio {
		background = rl.LoadMusicStream(BACKGROUND_MUSIC_PATH),
		walk = rl.LoadSound(WALK_AUDIO_PATH),
		push = rl.LoadSound(PUSH_AUDIO_PATH),
		goal = rl.LoadSound(GOAL_AUDIO_PATH),
		win = rl.LoadSound(WIN_AUDIO_PATH),
	}
}

unload_audio :: proc(audio: ^Audio) {
	rl.UnloadMusicStream(audio.background)
	rl.UnloadSound(audio.walk)
	rl.UnloadSound(audio.push)
	rl.UnloadSound(audio.goal)
	rl.UnloadSound(audio.win)
}
