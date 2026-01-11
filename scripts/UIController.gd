extends CanvasLayer
class_name UIController

signal retry_requested
signal colorblind_toggled(enabled: bool)

@export var required_color_label_path: NodePath
@export var required_color_swatch_path: NodePath
@export var score_label_path: NodePath
@export var streak_label_path: NodePath
@export var best_label_path: NodePath
@export var game_over_panel_path: NodePath
@export var game_over_score_label_path: NodePath
@export var game_over_best_label_path: NodePath
@export var retry_button_path: NodePath
@export var colorblind_toggle_path: NodePath

var _required_label: Label
var _required_swatch: ColorRect
var _score_label: Label
var _streak_label: Label
var _best_label: Label
var _game_over_panel: Control
var _game_over_score_label: Label
var _game_over_best_label: Label
var _retry_button: Button
var _colorblind_toggle: CheckButton
var _colorblind_mode: bool = false
var _current_required_color: int = 0

func _ready() -> void:
  _required_label = get_node(required_color_label_path)
  _required_swatch = get_node(required_color_swatch_path)
  _score_label = get_node(score_label_path)
  _streak_label = get_node(streak_label_path)
  _best_label = get_node(best_label_path)
  _game_over_panel = get_node(game_over_panel_path)
  _game_over_score_label = get_node(game_over_score_label_path)
  _game_over_best_label = get_node(game_over_best_label_path)
  _retry_button = get_node(retry_button_path)
  _colorblind_toggle = get_node(colorblind_toggle_path)
  _retry_button.pressed.connect(_on_retry_pressed)
  _colorblind_toggle.toggled.connect(_on_colorblind_toggled)

func set_required_color(color_id: int) -> void:
  _current_required_color = color_id
  var color_value = ColorPalette.get_color(color_id)
  _required_swatch.color = color_value
  var label_text = "Required: %s" % ColorPalette.get_name(color_id)
  if _colorblind_mode:
    label_text += " (%s)" % ColorPalette.get_pattern(color_id)
  _required_label.text = label_text

func update_score(score: int, streak: int) -> void:
  _score_label.text = "Score: %d" % score
  _streak_label.text = "Streak: %d" % streak

func update_best_score(best_score: int) -> void:
  _best_label.text = "Best: %d" % best_score

func set_game_over_visible(visible: bool) -> void:
  _game_over_panel.visible = visible

func set_game_over_scores(score: int, best_score: int) -> void:
  _game_over_score_label.text = "Score: %d" % score
  _game_over_best_label.text = "Best: %d" % best_score

func _on_retry_pressed() -> void:
  emit_signal("retry_requested")

func _on_colorblind_toggled(enabled: bool) -> void:
  _colorblind_mode = enabled
  set_required_color(_current_required_color)
  emit_signal("colorblind_toggled", enabled)
