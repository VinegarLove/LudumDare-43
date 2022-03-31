extends KinematicBody2D


const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)

const WALK_SPEED = 50
const CHASE_SPEED = 0.0
const STATE_WALKING = 0
const STATE_CHASING = 1
const STATE_KILLED = 2
const BULLET_VELOCITY = 1000

var linear_velocity = Vector2()
var direction = -1
var anim=""

var state = STATE_WALKING

onready var detect_floor_left = $detect_floor_left
onready var detect_player_left = $detect_player_left
onready var detect_floor_right = $detect_floor_right
onready var detect_player_right = $detect_player_right
onready var shot_left = $shot_left
onready var shot_right = $shot_right
onready var sprite = $sprite

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

	if not detect_floor_right.is_colliding():
		direction = -1.0

func _start_chasing():
	if (direction > 0.0 and detect_player_right.is_colliding()) or (direction < 0.0 and detect_player_left.is_colliding()):
		state = STATE_CHASING

func _stop_chasing():
	if not ((direction > 0.0 and detect_player_right.is_colliding()) or (direction < 0.0 and detect_player_left.is_colliding())):
		state = STATE_WALKING

func shoot_player():
	var bullet = preload("res://scenes/Bullet1.tscn").instance()
	bullet.add_collision_exception_with(self)
	if direction > 0.0:
		bullet.position = shot_left.global_position
	else:
		bullet.position = shot_right.global_position

	bullet.linear_velocity = Vector2(BULLET_VELOCITY, 0) * direction
	self.get_parent().add_child(bullet)

func hit_by_player():
	state = STATE_KILLED
