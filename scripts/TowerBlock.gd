extends Node2D
class_name TowerBlock

@export var color_rect_path: NodePath = NodePath("BlockRect")
@export var pattern_label_path: NodePath = NodePath("PatternLabel")

var _color_rect: ColorRect
var _pattern_label: Label
var _color_id: int = 0
var _colorblind_mode: bool = false

func _ready() -> void:
  _color_rect = get_node(color_rect_path)
  _pattern_label = get_node(pattern_label_path)
  _update_visuals()

func set_color_id(color_id: int) -> void:
  _color_id = color_id
  _update_visuals()

func set_colorblind_mode(enabled: bool) -> void:
  _colorblind_mode = enabled
  _update_pattern()

func _update_visuals() -> void:
  if _color_rect:
    _color_rect.color = ColorPalette.get_color(_color_id)
  _update_pattern()

func _update_pattern() -> void:
  if _pattern_label:
    _pattern_label.visible = _colorblind_mode
    _pattern_label.text = ColorPalette.get_pattern(_color_id)
