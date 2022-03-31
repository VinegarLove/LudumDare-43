extends KinematicBody2D


const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)

const WALK_SPEED = 50
const CHASE_SPEED = 150
const STATE_WALKING = 0
const STATE_CHASING = 1
const STATE_KILLED = 2

var linear_velocity = Vector2()
var direction = -1
var anim=""

var state = STATE_WALKING

onready var detect_floor_left = $detect_floor_left
onready var detect_player_left = $detect_player_left
onready var detect_floor_right = $detect_floor_right
onready var detect_player_right = $detect_player_right
onready var detect_attack_right = $detect_attack_right
onready var detect_attack_left = $detect_attack_left
onready var sprite = $sprite

func _ready():
	detect_attack_right.enabled = false
	detect_attack_left.enabled = true

func _physics_process(delta):
	var new_anim = ""

	if state==STATE_WALKING:
		_apply_speed_with_gravity(delta, WALK_SPEED)

		_change_direction()

		_start_chasing()

		sprite.scale = Vector2(direction, 1.0)
		new_anim = "walk"
	elif state==STATE_CHASING:
		_apply_speed_with_gravity(delta, CHASE_SPEED)

		_damage_player()

		_change_direction()

		_stop_chasing()

		new_anim = "attack"
	else:
		new_anim = "death"


	if anim != new_anim:
		anim = new_anim
		$anim.play(anim)

func _apply_speed_with_gravity(delta, speed):
	linear_velocity += GRAVITY_VEC * delta
	linear_velocity.x = direction * speed
	linear_velocity = move_and_slide(linear_velocity, FLOOR_NORMAL)

func _change_direction():
	if not detect_floor_left.is_colliding():
		direction = 1.0
		detect_attack_right.enabled = true
		detect_attack_left.enabled = false

	if not detect_floor_right.is_colliding():
		direction = -1.0
		detect_attack_right.enabled = false
		detect_attack_left.enabled = true

func _start_chasing():
	if (direction > 0.0 and detect_player_right.is_colliding()) or (direction < 0.0 and detect_player_left.is_colliding()):
		state = STATE_CHASING

func _stop_chasing():
	if not ((direction > 0.0 and detect_player_right.is_colliding()) or (direction < 0.0 and detect_player_left.is_colliding())):
		state = STATE_WALKING

func _damage_player():
	if direction > 0.0 and detect_attack_right.is_colliding():
		var obj = detect_attack_right.get_collider()
		if obj.has_method("hit_by_enemy"):
			obj.hit_by_enemy()

	if direction < 0.0 and detect_attack_left.is_colliding():
		var obj = detect_attack_left.get_collider()
		if obj.has_method("hit_by_enemy"):
			obj.hit_by_enemy()

func hit_by_player():
	state = STATE_KILLED
