package main

import rl "vendor:raylib"

WALK_AUDIO_PATH :: "src/audio/walk.wav"
PUSH_AUDIO_PATH :: "src/audio/push.wav"
GOAL_AUDIO_PATH :: "src/audio/goal.wav"

Audio :: struct {
	walk: rl.Sound,
	push: rl.Sound,
	goal: rl.Sound,
}

load_audio :: proc() -> Audio {
	return Audio {
		walk = rl.LoadSound(WALK_AUDIO_PATH),
		push = rl.LoadSound(PUSH_AUDIO_PATH),
		goal = rl.LoadSound(GOAL_AUDIO_PATH),
	}
}

unload_audio :: proc(audio: ^Audio) {
	rl.UnloadSound(audio.walk)
	rl.UnloadSound(audio.push)
	rl.UnloadSound(audio.goal)
}
