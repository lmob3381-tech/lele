class_name ObjectPool extends Node

## Generic object pool for reusing nodes

@export var scene_to_pool: PackedScene
@export var initial_pool_size: int = 20
@export var max_pool_size: int = 50

var _available: Array[Node] = []
var _in_use: Array[Node] = []

func _ready() -> void:
	if scene_to_pool == null:
		printerr("ObjectPool: scene_to_pool is null.")
		return
		
	for i in range(initial_pool_size):
		_create_new_instance()

func _create_new_instance() -> Node:
	var instance: Node = scene_to_pool.instantiate()
	add_child(instance)
	# Nonaktifkan processing
	instance.process_mode = Node.PROCESS_MODE_DISABLED
	if instance is Node3D:
		instance.hide()
	elif instance is CanvasItem:
		instance.hide()
	
	_available.append(instance)
	return instance

## Acquires an instance from the pool. Sets spawn transform if it's a Node3D.
func acquire(spawn_transform: Transform3D = Transform3D()) -> Node:
	var instance: Node
	
	if _available.size() > 0:
		instance = _available.pop_back()
	else:
		if _in_use.size() + _available.size() < max_pool_size:
			instance = _create_new_instance()
			_available.pop_back()
		else:
			# Pool is maxed out, steal the oldest one
			instance = _in_use.pop_front()
			
	if instance is Node3D:
		instance.global_transform = spawn_transform
		instance.show()
	elif instance is CanvasItem:
		instance.show()
		
	instance.process_mode = Node.PROCESS_MODE_INHERIT
	_in_use.append(instance)
	
	if instance.has_method("on_pool_spawn"):
		instance.call("on_pool_spawn")
		
	return instance

## Releases an instance back to the pool
func release(instance: Node) -> void:
	if not _in_use.has(instance):
		return
		
	_in_use.erase(instance)
	
	if instance.has_method("on_pool_recycle"):
		instance.call("on_pool_recycle")
		
	instance.process_mode = Node.PROCESS_MODE_DISABLED
	if instance is Node3D:
		instance.hide()
	elif instance is CanvasItem:
		instance.hide()
		
	_available.append(instance)
