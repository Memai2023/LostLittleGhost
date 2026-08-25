extends CanvasLayer
# Full-screen fade + message, triggered by WindowTrigger (win) or DayNightCycle (lose).

@onready var fade_rect: ColorRect = $FadeRect
@onready var message_label: Label = $MessageLabel

var _triggered: bool = false

func _ready() -> void:
	fade_rect.color.a = 0.0
	message_label.visible = false

func trigger_win(message: String) -> void:
	_show_message(message, Color(0.0, 0.0, 0.0))

func trigger_lose(message: String) -> void:
	_show_message(message, Color(0.25, 0.02, 0.05))

func _show_message(message: String, target_color: Color) -> void:
	if _triggered:
		return
	_triggered = true
	message_label.text = message
	fade_rect.color = Color(target_color.r, target_color.g, target_color.b, 0.0)
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 1.2)
	await tween.finished
	message_label.visible = true
