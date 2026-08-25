extends Area2D
# The open window at the end of the level. Reaching it wins the run.

@export var win_message: String = "You made it home before sunrise! 👻"

var _triggered: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _triggered or not body.is_in_group("player"):
		return
	_triggered = true
	get_tree().call_group("fade_overlay", "trigger_win", win_message)
