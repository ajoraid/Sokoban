package main

import "core:fmt"
import "core:mem"

Memory_Tracker :: struct {
	tracking: mem.Tracking_Allocator,
	original: mem.Allocator,
}

tracker_init :: proc(mt: ^Memory_Tracker, base_allocator := context.allocator) {
	mt.original = base_allocator
	mem.tracking_allocator_init(&mt.tracking, base_allocator)
	context.allocator = mem.tracking_allocator(&mt.tracking)
}

tracker_destroy :: proc(mt: ^Memory_Tracker) {
	if len(mt.tracking.allocation_map) > 0 {
		fmt.printfln("--- Memory Leaks Detected (%v) ---", len(mt.tracking.allocation_map))
		for _, entry in mt.tracking.allocation_map {
			fmt.printfln("- Leaked %v bytes at %v", entry.size, entry.location)
		}
	}

	if len(mt.tracking.bad_free_array) > 0 {
		fmt.printfln("--- Bad Frees Detected (%v) ---", len(mt.tracking.bad_free_array))
		for entry in mt.tracking.bad_free_array {
			fmt.printfln("- Bad free at %v", entry.location)
		}
	}

	mem.tracking_allocator_destroy(&mt.tracking)
}
