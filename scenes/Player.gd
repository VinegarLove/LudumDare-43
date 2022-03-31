# mostly taken by the tutorial 2d with some modification
extends KinematicBody2D

const GRAVITY = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const MIN_ONAIR_TIME = 0.1
const ATTACK_TIME = 0.5
const WALK_SPEED = 300 # pixels/sec
const JUMP_SPEED = 650
const SIDING_CHANGE_SPEED = 15

# movement
var linear_vel = Vector2()
var onair_time = 0.0
var on_floor = false
var health = 1.0

# audio
onready var sound_jump = $soundjump
onready var sound_attack1 = $soundattack1

# animation
const ANIM_ATTACK = "attack1"
const ANIM_RUN = "run1"
const ANIM_IDLE = "idle1"
const ANIM_JUMP = "jump1"
const ANIM_FALL = "fall1"
var anim="" #current
export var is_attacking = false
export var is_damaging = false
export(NodePath) var start_position

onready var sprite = $sprite
onready var playeranim = $playeranim
onready var attackchecks = $attack1shape
onready var healthbar = $CanvasLayer/filler


func _physics_process(delta):
	### FORCES ###

	if health < 0.0:
		_player_death()

	onair_time += delta

	# gravity
	linear_vel += delta * GRAVITY
	# apply force movement
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	# set flags
	if is_on_floor():
		onair_time = 0
	on_floor = onair_time < MIN_ONAIR_TIME

	### CONTROL ###

	# Horizontal Movement
	var target_speed = 0
	if Input.is_action_pressed("move_left"):
		target_speed += -1
	if Input.is_action_pressed("move_right"):
		target_speed +=  1

	target_speed *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)

	# Jumping
	if on_floor and Input.is_action_just_pressed("jump"):
		linear_vel.y = -JUMP_SPEED
		sound_jump.play()
	# Atacking
	if Input.is_action_just_pressed("attack") and not playeranim.is_playing():
		playeranim.play("attack_sequence")
		anim = "attack1"
		is_attacking = true

	### ANIMATION ###

	var new_anim = ANIM_IDLE

	# don't do nothing if it's attacking
	if is_attacking:
		if attackchecks.is_colliding():
			var obj = attackchecks.get_collider()
			if obj.has_method("hit_by_player"):
				obj.hit_by_player()
				health += 0.1
				attackchecks.enabled = false
	elif on_floor:
		if linear_vel.x < -SIDING_CHANGE_SPEED:
			_turn_face_left()
			new_anim = ANIM_RUN

		if linear_vel.x > SIDING_CHANGE_SPEED:
			_turn_face_right()
			new_anim = ANIM_RUN
	else:
		# We want the character to immediately change facing side when the player
		# tries to change direction, during air control.
		# This allows for example the player to shoot quickly left then right.
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			_turn_face_left()
		if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			_turn_face_right()

		if linear_vel.y < 0:
			new_anim = ANIM_JUMP
		else:
			new_anim = ANIM_FALL

	if new_anim != anim and not is_attacking:
		anim = new_anim
		sprite.play(anim)

	#healthbar
	health = min(health, 1.0)
	health = max(health, 0.0)
	healthbar.region_rect.size.x = 210 * health
	_check_fall()

func _turn_face_left():
	sprite.flip_h = true
	attackchecks.position.x = -abs(attackchecks.position.x)
	attackchecks.rotation_degrees = 90.0

func _turn_face_right():
	sprite.flip_h = false
	attackchecks.position.x = abs(attackchecks.position.x)
	attackchecks.rotation_degrees = -90.0

func hit_by_enemy():
	if not is_damaging:
		playeranim.play("damaged")
		_lose_health()

func _check_fall():
	if self.position.y < -500.0:
		_player_death()

func _player_death():
	pass

func _lose_health():
	health -= 0.1
