extends Area2D
# "Possess / Stealth" power-up: bobs like a Spirit Orb, but on pickup it makes
# the ghost briefly pass through hazards instead of just giving points.

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
	var t := (Time.get_ticks_msec() / 1000.0) * 1.6 + _time_offset
	position.y = _start_y + sin(t) * 8.0
	visual.rotation -= delta * 1.2

func _on_body_entered(body: Node2D) -> void:
	if _collected or not body.is_in_group("player"):
		return
	_collect(body)

func _collect(body: Node2D) -> void:
	_collected = true
	visual.visible = false
	collision_shape.set_deferred("disabled", true)
	particles.restart()
	particles.emitting = true
	if sfx_player:
		sfx_player.stream = SoundGen.chime()
		sfx_player.pitch_scale = 0.8
		sfx_player.play()
	if body.has_method("activate_stealth"):
		body.activate_stealth()
	await get_tree().create_timer(particles.lifetime).timeout
	queue_free()
