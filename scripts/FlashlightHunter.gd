extends Area2D
# Patrols back and forth; hurts the ghost on contact ("rör en lampa/spökjägare").

@export var patrol_distance: float = 140.0
@export var speed: float = 60.0
@export var knockback_strength: float = 260.0

@onready var visual: Node2D = $Visual

var _start_x: float = 0.0
var _direction: float = 1.0

func _ready() -> void:
	_start_x = global_position.x
	collision_layer = 4
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position.x += _direction * speed * delta
	if abs(position.x - _start_x) >= patrol_distance:
		_direction *= -1.0
	visual.scale.x = 1.0 if _direction > 0.0 else -1.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		var dir := (body.global_position - global_position).normalized()
		body.take_damage(dir * knockback_strength)
