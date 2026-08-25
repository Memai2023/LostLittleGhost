extends CharacterBody2D
# Ghost movement: floaty accel/friction, coyote time, jump buffering, double jump, squish/stretch.
# Also owns health (hurt by hazards, fall = damage + respawn) and the possess/stealth power-up.
# Controls: A/D or Left/Right to move, Space/W/Up to jump.

signal lives_changed(lives: int)
signal died

@export var max_speed: float = 220.0
@export var acceleration: float = 900.0
@export var air_acceleration: float = 500.0
@export var friction: float = 700.0
@export var gravity: float = 900.0
@export var fall_gravity_multiplier: float = 1.4
@export var jump_velocity: float = -420.0
@export var double_jump_velocity: float = -380.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12

@export var max_lives: int = 3
@export var hurt_invulnerability_time: float = 1.0
@export var stealth_duration: float = 4.0
@export var respawn_position: Vector2 = Vector2(60, 100)
@export var fall_death_y: float = 900.0

@onready var visual: Node2D = $Visual
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var sfx_player: AudioStreamPlayer = $SfxPlayer

var can_double_jump: bool = true
var lives: int = 0
var _jump_was_pressed: bool = false
var _invulnerable: bool = false
var _stealthed: bool = false

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	lives = max_lives
	died.connect(_on_died)

func _physics_process(delta: float) -> void:
	var direction := 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction += 1.0

	if direction != 0.0:
		var accel := acceleration if is_on_floor() else air_acceleration
		velocity.x = move_toward(velocity.x, direction * max_speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	if not is_on_floor():
		var g := gravity * fall_gravity_multiplier if velocity.y > 0.0 else gravity
		velocity.y += g * delta

	if is_on_floor():
		coyote_timer.start(coyote_time)
		can_double_jump = true

	var jump_pressed := Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W)
	var jump_just_pressed := jump_pressed and not _jump_was_pressed
	_jump_was_pressed = jump_pressed

	if jump_just_pressed:
		jump_buffer_timer.start(jump_buffer_time)

	var buffered_jump := jump_buffer_timer.time_left > 0.0

	if buffered_jump and (is_on_floor() or coyote_timer.time_left > 0.0):
		_do_jump(jump_velocity)
		jump_buffer_timer.stop()
		coyote_timer.stop()
	elif buffered_jump and can_double_jump:
		_do_jump(double_jump_velocity)
		can_double_jump = false
		jump_buffer_timer.stop()

	var was_on_floor := is_on_floor()
	move_and_slide()
	if not was_on_floor and is_on_floor():
		_land_squish()

	if global_position.y > fall_death_y:
		take_damage(Vector2.ZERO)
		global_position = respawn_position
		velocity = Vector2.ZERO

func _do_jump(v: float) -> void:
	velocity.y = v
	_jump_stretch()
	if sfx_player:
		sfx_player.stream = SoundGen.woosh()
		sfx_player.play()

func _jump_stretch() -> void:
	visual.scale = Vector2(0.7, 1.3)
	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2.ONE, 0.25) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _land_squish() -> void:
	visual.scale = Vector2(1.3, 0.7)
	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2.ONE, 0.2) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func take_damage(knockback: Vector2) -> void:
	if _invulnerable or _stealthed:
		return
	lives -= 1
	lives_changed.emit(lives)
	velocity += knockback
	_invulnerable = true
	_hurt_flash()
	if sfx_player:
		sfx_player.stream = SoundGen.buzz()
		sfx_player.play()
	await get_tree().create_timer(hurt_invulnerability_time).timeout
	_invulnerable = false
	if lives <= 0:
		died.emit()

func _hurt_flash() -> void:
	visual.modulate = Color(0.85, 0.3, 0.75)
	var tween := create_tween()
	tween.tween_property(visual, "modulate", Color.WHITE, hurt_invulnerability_time)

func activate_stealth() -> void:
	if _stealthed:
		return
	_stealthed = true
	var previous_layer := collision_layer
	collision_layer = 0
	modulate.a = 0.3
	await get_tree().create_timer(stealth_duration).timeout
	await _blink_and_restore(previous_layer)

func _blink_and_restore(previous_layer: int) -> void:
	for i in 4:
		modulate.a = 0.8 if i % 2 == 0 else 0.3
		await get_tree().create_timer(0.1).timeout
	modulate.a = 1.0
	collision_layer = previous_layer
	_stealthed = false

func _on_died() -> void:
	lives = max_lives
	lives_changed.emit(lives)
	global_position = respawn_position
	velocity = Vector2.ZERO
