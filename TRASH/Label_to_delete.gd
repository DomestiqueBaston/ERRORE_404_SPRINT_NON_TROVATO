extends Label

func _process(_delta):
	var fps := Engine.get_frames_per_second()
	var frame_time := 1000.0 / fps if fps > 0 else 0.0
	var process_time := Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var physics_time := Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
	var objects := Performance.get_monitor(Performance.OBJECT_COUNT)
	var nodes := Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var draw_calls := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var static_memory := Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0 / 1024.0

	text = "FPS: %d\nFrame: %.2f ms\nProcess: %.2f ms\nPhysics: %.2f ms\nObjects: %d\nNodes: %d\nDraw Calls: %d\nMemory: %.1f" % [
		fps,
		frame_time,
		process_time,
		physics_time,
		objects,
		nodes,
		draw_calls,
		static_memory
	]
