extends Node
class_name GameManager

signal game_over(final_score: int, best_score: int)
signal required_color_changed(color_id: int)

@export var base_score: int = 10
@export var initial_color_count: int = 3
@export var max_color_count: int = 5

@export var block_spawn_path: NodePath
@export var tower_path: NodePath
@export var ui_path: NodePath

var score: int = 0
var streak: int = 0
var best_score: int = 0
var required_color_id: int = 0
var color_count: int = 3
var colorblind_mode: bool = false

var _time_elapsed: float = 0.0
var _active_block: BlockController
var _tower: TowerController
var _ui: UIController
var _spawn: BlockSpawner

var _difficulty_table := [
  {"t": 0.0, "cycle": 0.60, "colors": 3, "auto": 3.0, "shrink": 1},
  {"t": 21.0, "cycle": 0.50, "colors": 3, "auto": 2.6, "shrink": 1},
  {"t": 46.0, "cycle": 0.42, "colors": 4, "auto": 2.2, "shrink": 1},
  {"t": 76.0, "cycle": 0.36, "colors": 4, "auto": 1.9, "shrink": 1},
  {"t": 111.0, "cycle": 0.32, "colors": 5, "auto": 1.6, "shrink": 2},
  {"t": 161.0, "cycle": 0.28, "colors": 5, "auto": 1.4, "shrink": 2},
]

var _current_cycle_speed: float = 0.6
var _current_auto_drop: float = 3.0
var _current_shrink: int = 1

func _ready() -> void:
  randomize()
  _tower = get_node(tower_path)
  _ui = get_node(ui_path)
  _spawn = get_node(block_spawn_path)
  _ui.connect("retry_requested", Callable(self, "_on_retry_requested"))
  _ui.connect("colorblind_toggled", Callable(self, "_on_colorblind_toggled"))
  _load_best_score()
  start_game()

func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventScreenTouch and event.pressed:
    _request_drop()
  elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
    _request_drop()

func start_game() -> void:
  score = 0
  streak = 0
  _time_elapsed = 0.0
  color_count = initial_color_count
  _apply_difficulty_for_time(0.0)
  _tower.reset_tower()
  _tower.set_colorblind_mode(colorblind_mode)
  _pick_required_color()
  _spawn_active_block()
  _ui.set_game_over_visible(false)
  _ui.update_score(score, streak)
  _ui.update_best_score(best_score)

func _process(delta: float) -> void:
  _time_elapsed += delta
  _update_difficulty()

func _spawn_active_block() -> void:
  _active_block = _spawn.spawn_block()
  _active_block.setup(color_count, _current_cycle_speed, _current_auto_drop)
  _active_block.set_colorblind_mode(colorblind_mode)
  _active_block.set_tower_target_y(_tower.get_next_block_y())
  _active_block.connect("drop_requested", Callable(self, "_on_block_drop_requested"))
  _active_block.connect("reached_tower", Callable(self, "_on_block_reached_tower"))
  _ui.set_required_color(required_color_id)

func _request_drop() -> void:
  if _active_block:
    _active_block.drop()

func _on_block_drop_requested() -> void:
  _request_drop()

func _on_block_reached_tower(color_id: int) -> void:
  var matched := (color_id == required_color_id)
  if matched:
    _tower.attach_block(color_id)
    streak += 1
    score += base_score * _streak_multiplier(streak)
    _pick_required_color()
    _active_block.play_snap()
  else:
    _tower.apply_mismatch(_current_shrink)
    streak = 0
    _active_block.play_mismatch()
  _ui.update_score(score, streak)
  await _active_block.effect_finished
  _active_block.queue_free()
  _active_block = null
  if _tower.height == 0:
    _handle_game_over()
  else:
    _spawn_active_block()

func _pick_required_color() -> void:
  required_color_id = randi_range(0, color_count - 1)
  emit_signal("required_color_changed", required_color_id)

func _streak_multiplier(value: int) -> int:
  if value >= 21:
    return 4
  if value >= 11:
    return 3
  if value >= 6:
    return 2
  return 1

func _update_difficulty() -> void:
  _apply_difficulty_for_time(_time_elapsed)

func _apply_difficulty_for_time(time_value: float) -> void:
  var selected = _difficulty_table[0]
  for row in _difficulty_table:
    if time_value >= row["t"]:
      selected = row
  color_count = min(max_color_count, selected["colors"])
  _current_cycle_speed = selected["cycle"]
  _current_auto_drop = selected["auto"]
  _current_shrink = selected["shrink"]

func _handle_game_over() -> void:
  best_score = max(best_score, score)
  _save_best_score()
  _ui.set_game_over_visible(true)
  _ui.set_game_over_scores(score, best_score)
  emit_signal("game_over", score, best_score)

func _on_retry_requested() -> void:
  if _active_block:
    _active_block.queue_free()
    _active_block = null
  start_game()

func _on_colorblind_toggled(enabled: bool) -> void:
  colorblind_mode = enabled
  _tower.set_colorblind_mode(colorblind_mode)
  if _active_block:
    _active_block.set_colorblind_mode(colorblind_mode)

func _load_best_score() -> void:
  var cfg := ConfigFile.new()
  var err = cfg.load("user://color_stack_save.cfg")
  if err == OK:
    best_score = int(cfg.get_value("score", "best", 0))

func _save_best_score() -> void:
  var cfg := ConfigFile.new()
  cfg.set_value("score", "best", best_score)
  cfg.save("user://color_stack_save.cfg")
