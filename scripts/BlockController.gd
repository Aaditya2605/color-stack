extends Node2D
class_name BlockController

signal drop_requested
signal reached_tower(color_id: int)
signal effect_finished

@export var fall_speed: float = 1600.0
@export var color_rect_path: NodePath = NodePath("BlockRect")
@export var pattern_label_path: NodePath = NodePath("PatternLabel")

var _color_ids: Array[int] = []
var _color_cycle_speed: float = 0.6
var _auto_drop_time: float = 3.0
var _color_index: int = 0
var _locked_color_id: int = 0
var _dropping: bool = false
var _auto_drop_timer: float = 0.0
var _cycle_timer: float = 0.0
var _tower_target_y: float = 0.0
var _color_rect: ColorRect
var _pattern_label: Label
var _colorblind_mode: bool = false
var _auto_drop_fired: bool = false
var _landed: bool = false

func _ready() -> void:
  _color_rect = get_node(color_rect_path)
  _pattern_label = get_node(pattern_label_path)

func setup(color_count: int, cycle_speed: float, auto_drop_time: float) -> void:
  _color_ids.clear()
  for i in range(color_count):
    _color_ids.append(i)
  _color_cycle_speed = cycle_speed
  _auto_drop_time = auto_drop_time
  _color_index = 0
  _auto_drop_timer = 0.0
  _cycle_timer = 0.0
  _dropping = false
  _auto_drop_fired = false
  _landed = false
  _set_color_id(_color_ids[_color_index])

func set_tower_target_y(target_y: float) -> void:
  _tower_target_y = target_y

func set_colorblind_mode(enabled: bool) -> void:
  _colorblind_mode = enabled
  _update_pattern_label(_locked_color_id)

func _process(delta: float) -> void:
  if _dropping:
    global_position.y += fall_speed * delta
    if global_position.y >= _tower_target_y and not _landed:
      global_position.y = _tower_target_y
      _landed = true
      emit_signal("reached_tower", _locked_color_id)
  else:
    _cycle_timer += delta
    _auto_drop_timer += delta
    if _cycle_timer >= _color_cycle_speed:
      _cycle_timer = 0.0
      _color_index = (_color_index + 1) % _color_ids.size()
      _set_color_id(_color_ids[_color_index])
    if _auto_drop_timer >= _auto_drop_time and not _auto_drop_fired:
      _auto_drop_fired = true
      emit_signal("drop_requested")

func drop() -> void:
  if _dropping:
    return
  _locked_color_id = _color_ids[_color_index]
  _auto_drop_fired = true
  _dropping = true

func play_snap() -> void:
  var tween = create_tween()
  tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.08)
  tween.tween_property(self, "scale", Vector2.ONE, 0.08)
  tween.finished.connect(_on_effect_finished)

func play_mismatch() -> void:
  var tween = create_tween()
  tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
  tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.15)
  tween.finished.connect(_on_effect_finished)

func _set_color_id(color_id: int) -> void:
  _locked_color_id = color_id
  var color_value = ColorPalette.get_color(color_id)
  _color_rect.color = color_value
  _update_pattern_label(color_id)

func _update_pattern_label(color_id: int) -> void:
  if _colorblind_mode:
    _pattern_label.visible = true
    _pattern_label.text = ColorPalette.get_pattern(color_id)
  else:
    _pattern_label.visible = false

func _on_effect_finished() -> void:
  emit_signal("effect_finished")
