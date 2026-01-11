extends Node
class_name ColorPalette

const COLORS := [
  Color(0.95, 0.25, 0.25),
  Color(0.25, 0.55, 0.95),
  Color(0.30, 0.80, 0.40),
  Color(0.98, 0.85, 0.20),
  Color(0.85, 0.45, 0.90),
]

const NAMES := ["Red", "Blue", "Green", "Yellow", "Purple"]
const PATTERNS := ["R", "B", "G", "Y", "P"]

static func get_color(color_id: int) -> Color:
  var idx = clamp(color_id, 0, COLORS.size() - 1)
  return COLORS[idx]

static func get_name(color_id: int) -> String:
  var idx = clamp(color_id, 0, NAMES.size() - 1)
  return NAMES[idx]

static func get_pattern(color_id: int) -> String:
  var idx = clamp(color_id, 0, PATTERNS.size() - 1)
  return PATTERNS[idx]
