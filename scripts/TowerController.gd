extends Node2D
class_name TowerController

@export var initial_height: int = 1
@export var block_size: float = 90.0
@export var tower_block_scene: PackedScene

var height: int = 1
var _blocks: Array[Node2D] = []
var _colorblind_mode: bool = false

func reset_tower() -> void:
  for block in _blocks:
    block.queue_free()
  _blocks.clear()
  height = initial_height
  for i in range(initial_height):
    _spawn_block(0)

func get_next_block_y() -> float:
  return global_position.y + _base_center_y() - (height * block_size)

func attach_block(color_id: int) -> void:
  _spawn_block(color_id)
  height += 1

func apply_mismatch(shrink_amount: int) -> void:
  var remove_count = min(shrink_amount, _blocks.size())
  for i in range(remove_count):
    var block = _blocks.pop_back()
    if block:
      block.queue_free()
  height = max(0, height - shrink_amount)

func set_colorblind_mode(enabled: bool) -> void:
  _colorblind_mode = enabled
  for block in _blocks:
    if block.has_method("set_colorblind_mode"):
      block.set_colorblind_mode(enabled)

func _spawn_block(color_id: int) -> void:
  if tower_block_scene == null:
    return
  var block = tower_block_scene.instantiate()
  add_child(block)
  var y = _base_center_y() - ((_blocks.size()) * block_size)
  block.position = Vector2(0, y)
  if block.has_method("set_color_id"):
    block.set_color_id(color_id)
  if block.has_method("set_colorblind_mode"):
    block.set_colorblind_mode(_colorblind_mode)
  _blocks.append(block)

func _base_center_y() -> float:
  return -block_size * 0.5
