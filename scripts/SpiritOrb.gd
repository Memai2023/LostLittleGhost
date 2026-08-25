extends Area2D
# Collectible: bobs on a sine wave, bursts particles and disappears when the ghost touches it.

@export var bob_height: float = 8.0
@export var bob_speed: float = 2.0

@onready var visual: Node2D = $Visual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var particles: GPUParticles2D = $CollectParticles
@onready var sfx_player: AudioStreamPlayer = $SfxPlayer

var _start_y: float = 0.0
var _time_offset: float = 0.0
var _collected: bool = false

func _ready() -> void:
	_start_y = position.y
	_time_offset = randf() * TAU
	collision_layer = 8
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if _collected:
		return
	var t := (Time.get_ticks_msec() / 1000.0) * bob_speed + _time_offset
	position.y = _start_y + sin(t) * bob_height
	visual.rotation += delta * 0.6

func _on_body_entered(body: Node2D) -> void:
	if _collected or not body.is_in_group("player"):
		return
	_collect()

func _collect() -> void:
	_collected = true
	visual.visible = false
	collision_shape.set_deferred("disabled", true)
	particles.restart()
	particles.emitting = true
	if sfx_player:
		sfx_player.stream = SoundGen.chime()
		sfx_player.play()
	await get_tree().create_timer(particles.lifetime).timeout
	queue_free()
