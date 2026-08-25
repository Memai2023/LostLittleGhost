extends CanvasLayer

@onready var time_label: Label = $TimeLabel
@onready var lives_label: Label = $LivesLabel

func _ready() -> void:
	var day_night := get_tree().get_first_node_in_group("day_night_cycle")
	var player := get_tree().get_first_node_in_group("player")
	if day_night:
		day_night.time_updated.connect(_on_time_updated)
	if player:
		player.lives_changed.connect(_on_lives_changed)
		_on_lives_changed(player.lives)

func _on_time_updated(remaining: float, _progress: float) -> void:
	var m := int(remaining) / 60
	var s := int(remaining) % 60
	time_label.text = "%d:%02d" % [m, s]

func _on_lives_changed(lives: int) -> void:
	lives_label.text = "♥".repeat(max(lives, 0))
