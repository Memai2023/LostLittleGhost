extends CanvasModulate
# Attach to a CanvasModulate node. Lerps the whole scene's tint from night to
# sunrise over run_duration seconds; emits time_up when the sun catches you.

signal time_updated(remaining: float, progress: float)
signal time_up

@export var run_duration: float = 150.0
@export var color_start: Color = Color(0.28, 0.26, 0.45, 1.0)
@export var color_end: Color = Color(1.05, 0.85, 0.68, 1.0)

var elapsed: float = 0.0
var _finished: bool = false

func _ready() -> void:
	color = color_start

func _process(delta: float) -> void:
	if _finished:
		return
	elapsed += delta
	var progress: float = clamp(elapsed / run_duration, 0.0, 1.0)
	color = color_start.lerp(color_end, progress)
	time_updated.emit(run_duration - elapsed, progress)
	if progress >= 1.0:
		_finished = true
		time_up.emit()
		get_tree().call_group("fade_overlay", "trigger_lose", "The sun rose without you... 🌅")
