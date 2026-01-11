extends Node2D
class_name BlockSpawner

@export var block_scene: PackedScene

func spawn_block() -> BlockController:
  if block_scene == null:
    return null
  var block = block_scene.instantiate()
  add_child(block)
  block.position = Vector2.ZERO
  return block
