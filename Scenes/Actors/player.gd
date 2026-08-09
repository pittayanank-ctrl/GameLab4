class_name Player
extends CharacterBody2D

signal hit_enemy
signal hit_trap 


# --------- VARIABLES ---------- #

@export_category("Player Properties") # You can tweak these changes according to your likings
@export var move_speed : float = 300
@export var jump_force : float = 650
@export var gravity : float = 30
@export var max_jump_count : int = 2
@export var bullet_scene : PackedScene
@export var shoot_cooldown_time : float = 1
@export var bullet_lifetime = 2.0

var jump_count : int = 2
var knockback_active = false

@export_category("Toggle Functions") # Double jump feature is disable by default (Can be toggled from inspector)
@export var double_jump : = false

var is_grounded : bool = false
var movement_enabled : bool = true
var spawn_point = Vector2(0,0)
var is_attacking = false
var shoot_cooldown_timer = 0
var can_damage = true
var is_dead = false

@onready var player_sprite = $student/AnimatedSprite2D
@onready var player_node = $student
@onready var bullet_marker = $BulletMarker
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles



# --------- BUILT-IN FUNCTIONS ---------- #
func _ready() -> void:
	spawn_point = global_position

	if GameManager.save_player_position.x != 0:
		global_position = GameManager.save_player_position
		GameManager.save_player_position = Vector2.ZERO

	player_sprite.animation_finished.connect(_on_animation_finished)

	player_sprite.sprite_frames.set_animation_loop("Attack", false)
	player_sprite.sprite_frames.set_animation_loop("Running_Slash", false)
	player_sprite.sprite_frames.set_animation_loop("Air_Slash", false)
	
func _physics_process(_delta):
	is_grounded = is_on_floor()
	movement()

func _process(_delta):
	player_animations()
	flip_player()
	handle_shooting()
	if shoot_cooldown_timer > 0:
		shoot_cooldown_timer -= _delta
	
# --------- CUSTOM FUNCTIONS ---------- #

# <-- Player Movement Code -->
func movement():
	# Gravity
	if !is_on_floor():
		velocity.y += gravity
	elif is_on_floor():
		jump_count = max_jump_count

		if !knockback_active:
			velocity.x = 0

	handle_jumping()

	# Move Player
	if movement_enabled and !knockback_active:
		if Input.is_action_pressed("Left"):
			velocity.x = -move_speed
		if Input.is_action_pressed("Right"):
			velocity.x = move_speed

	if global_position.y > 650 and !is_dead:
		is_dead = true
		await GameManager.death()
		is_dead = false
		return

	move_and_slide()

# Handles jumping functionality (double jump or single jump, can be toggled from inspector)
func handle_jumping():
	if Input.is_action_just_pressed("Jump") and movement_enabled:
		if is_on_floor() and !double_jump:
			jump()
		elif double_jump and jump_count > 0:
			jump()
			jump_count -= 1

# Player jump
func jump():
	jump_tween()
	AudioManager.jump_sfx.play()
	velocity.y = -jump_force

# Handle Player Animations
func player_animations():
	particle_trails.emitting = false
	if is_attacking:
		return
	
	if is_on_floor():
		if abs(velocity.x) > 0:
			particle_trails.emitting = true
			player_sprite.play("Walk")

			if !AudioManager.WalkSfx.playing:
				AudioManager.WalkSfx.play()
		else:
			player_sprite.play("Idle")
			AudioManager.WalkSfx.stop()
	else:
		player_sprite.play("Jump")
		AudioManager.WalkSfx.stop()


# Flip player sprite based on X velocity
func flip_player():
	if velocity.x < 0: 
		player_node.scale.x = -1
	elif velocity.x > 0:
		player_node.scale.x = 1

# Tween Animations
func death_tween():
	AudioManager.death_sfx.play()
	death_particles.emitting = true
	movement_enabled = false
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	tween.parallel().tween_property(self, "position", Vector2(position.x,position.y-100), 0.15)
	await tween.finished
	global_position = spawn_point
	await get_tree().create_timer(0.3).timeout
	movement_enabled = true
	AudioManager.respawn_sfx.play()
	respawn_tween()

func respawn_tween():
	var tween = create_tween()
	tween.stop(); tween.play()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15) 
	tween.parallel().tween_property(self, "position", spawn_point, 0.15)

func jump_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.1)

func damage_tween():
	var tween = create_tween() 
	tween.stop(); tween.play()
	can_damage = false
	for i in range(1,3):
		tween.tween_property(player_node , "modulate", Color.RED, 0.1)
		tween.tween_property(player_node , "modulate", Color.WHITE, 0.1)
	await tween.finished
	can_damage = true
# --------- SIGNALS ---------- #

# Reset the player's position to the current level spawn point if collided with any trap
func _on_collision_body_entered(body):
	# ชนกับ Trap
	# ถ้าเพิ่งโดน Damage อยู่ ไม่รับซ้ำ
	if !can_damage:
		return
	if body.is_in_group("Traps"):
		var dx = body.global_position.x - global_position.x

		knockback_active = true
		movement_enabled = false

		# กระเด็นขึ้น
		velocity.y = -650
		AudioManager.HurtSfx.play()
		# กระเด็นออกจาก Enemy
		if dx > 0:
			velocity.x = -600
		else:
			velocity.x = 600

		damage_tween()
		hit_enemy.emit()

		await get_tree().create_timer(0.3).timeout

		knockback_active = false
		movement_enabled = true
		hit_trap.emit()
		return

	# ไม่ใช่ Enemy ก็ไม่ต้องทำอะไร
	if !body.is_in_group("Enemy"):
		return


	# =========================
	# Enemy Collision
	# =========================

	var dx = body.global_position.x - global_position.x

	knockback_active = true
	movement_enabled = false

	# กระเด็นขึ้น
	velocity.y = -650
	AudioManager.HurtSfx.play()
	# กระเด็นออกจาก Enemy
	if dx > 0:
		velocity.x = -600
	else:
		velocity.x = 600

	damage_tween()
	hit_enemy.emit()

	await get_tree().create_timer(0.3).timeout

	knockback_active = false
	movement_enabled = true

func handle_shooting():
	if Input.is_action_just_pressed("Shoot") and movement_enabled and shoot_cooldown_timer <= 0:
		shoot()

func shoot():
	if bullet_scene == null:
		return

	is_attacking = true

	AudioManager.AttackSfx.play()
	# เลือก Animation ตามสถานะของ Player
	if !is_on_floor():
		# อยู่กลางอากาศ
		player_sprite.play("Air_Slash")
	elif abs(velocity.x) > 0:
		# กำลังวิ่ง
		player_sprite.play("Running_Slash")
	else:
		# ยืนอยู่กับที่
		player_sprite.play("Attack")

	var bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_marker.global_position

	var sign_x = 1.0 if player_node.scale.x > 0 else -1.0
	var dir = Vector2(sign_x, 0)

	get_parent().add_child(bullet)
	bullet.shoot(dir, 1200, bullet_lifetime)

	shoot_cooldown_timer = shoot_cooldown_time

func _on_animation_finished() -> void:
	if player_sprite.animation in ["Attack", "Running_Slash", "Air_Slash"]:
		is_attacking = false
		player_animations()
	
