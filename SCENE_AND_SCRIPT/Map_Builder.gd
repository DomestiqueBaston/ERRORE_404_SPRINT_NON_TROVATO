class_name MapBuilder extends RefCounted

## MapBuilder builds Map instances in separate threads as needed. Maps are built
## in the background when the Globals.map_size variable changes, or when a map
## is taken for use in the game.

static var _map_scene = preload("res://SCENE_AND_SCRIPT/Map.tscn")

static var _map: Map = null
static var _mutex: Mutex = Mutex.new()
static var _task_id: int = -1

##
## Call this when the map_size global variable becomes known or has changed. A
## map of the appropriate size is built in a separate thread if necessary.
##
static func update_map_size():
	_mutex.lock()
	_wait_for_task_unsafe()
	if _map == null or _map.map_size != Globals.map_size:
		_task_id = WorkerThreadPool.add_task(_build_map)
	_mutex.unlock()

##
## Builds a map of the appropriate size, if it has not been built already, and
## returns it. The caller takes ownership of the map. A new, replacement map
## will be built in a separate thread.
##
static func take_map() -> Map:
	_mutex.lock()
	_wait_for_task_unsafe()
	var map = _map
	_map = null
	_task_id = WorkerThreadPool.add_task(_build_map)
	_mutex.unlock()
	return map

static func _wait_for_task_unsafe():
	if _task_id == -1:
		return
	var err = WorkerThreadPool.wait_for_task_completion(_task_id)
	match err:
		OK:
			pass
		ERR_INVALID_PARAMETER:
			push_error("MapBuilder: invalid task ID")
		ERR_BUSY:
			push_error("MapBuilder: task busy?")
		_:
			push_error("MapBuilder: unexpected error ", err)
	_task_id = -1

static func _build_map():
	#print("building map of size ", Globals.map_size)
	if _map:
		_map.queue_free()
	_map = _map_scene.instantiate()
	_map.map_size = Globals.map_size
	_map.build_map()
