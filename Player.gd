extends KinematicBody2D

var Box = preload("res://Box.tscn")
var PlayerDeathEffect = preload("res://PlayerDeathEffect.tscn")

export(int) var ACCELERATION = 1000
export(int) var MAX_SPEED = 90
export(int) var FRICTION = 400
export(int) var JUMP_FORCE = 105
export(int) var JUMP_HORIZONTAL_BOOST = 40
export(int) var GRAVITY = 900
export(int) var HALF_GRAVITY_THRESHOLD = 40
export(int) var FAST_MAX_ACCEL = 300
export(int) var MAX_FALL = 160

enum {
	LEFT = -1,
	NEUTRAL = 0,
	RIGHT = 1
}

var motion = Vector2.ZERO
var just_jumped = false
var max_fall = 0
var variable_jump_speed = 0
var facing = NEUTRAL
var is_holding = false

var is_crabbed = true

onready var sprite = $Sprite
onready var animator = $AnimationPlayer
onready var coyote_jump_timer = $CoyoteJumpTimer
onready var variable_jump_timer = $VariableJumpTimer
onready var grab_left = $GrabLeft
onready var grab_right = $GrabRight
onready var collider = $Collider
onready var camera = $Camera

signal hit_goal(goal)
signal player_death

func _ready():
	Events.connect("box_destroyed", self, "_on_Box_destroyed")
	Global.Player = self

func _on_Box_destroyed(box):
	if is_a_parent_of(box):
		# the box we were holding got destroyed so reset our extents
		reset_player()


func _process(delta):
	if Input.is_action_just_pressed("reset"):
		Utils.reset_scene()
		reset_player()
	
func reset_player():
	collider.shape.extents.y = 7
	collider.position.y = -7
	is_holding = false

func _physics_process(delta):
	just_jumped = false

	var input_vector = get_input_vector()
	var direction = sign(input_vector.x)
	
	if direction != 0:
		facing = direction
	
	apply_horizontal_force(input_vector, delta)
	jump_check(input_vector)
	apply_gravity(delta)
	update_animations(input_vector)
	move()
	pickup_item()
	
func pickup_item():
	if not is_holding and facing == LEFT and grab_left.is_colliding():
		grab_box(grab_left.get_collider())
		
	if not is_holding and facing == RIGHT and grab_right.is_colliding():
		grab_box(grab_right.get_collider())

func grab_box(box):
	if not box.is_in_group("pickable"):
		return
	
	var box_sprite = box.get_node("BoxSprite").duplicate()
	box_sprite.name = "HoldingHurtbox"
	box_sprite.position = Vector2(-8, -16)
	add_child(box_sprite)
	box.queue_free()
#
	collider.shape.extents.y = 15
	collider.position.y = -15
	
	is_holding = true


func animate(animation):
	if is_crabbed:
		animator.play(animation + "Crab")
	else:
		animator.play(animation)
	
func update_animations(input_vector):
	if input_vector.x != 0:
		sprite.scale.x = sign(input_vector.x)
		animate("Run")
	else:
		animate("Idle")
		
	# air
	if not is_on_floor():
		var orientation = sign(motion.y)
		if orientation == -1:
			animate("Jump")
		else:
			animate("Fall")


func get_input_vector():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	return input_vector	

func apply_horizontal_force(input_vector, delta):
	if abs(motion.x) > MAX_SPEED and sign(motion.x) == input_vector.x:
		motion.x = move_toward(motion.x, input_vector.x * MAX_SPEED, FRICTION * delta)
	else:
		motion.x = move_toward(motion.x, input_vector.x * MAX_SPEED, ACCELERATION * delta)
		
func move():
	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	
	# by supplying the normal of the surface we can automatically
	# detect when the character is on floor using
	# is_on_floor()
	motion = move_and_slide(motion, Vector2.UP)
	
	# landing
	if was_in_air and is_on_floor():
		pass
	
	# just left ground
	if was_on_floor and not is_on_floor() and not just_jumped:
		motion.y = 0
		coyote_jump_timer.start()
		
func jump_check(input_vector):
	if is_on_floor() or coyote_jump_timer.time_left > 0:
		if Input.is_action_just_pressed("jump"):
			jump(input_vector, JUMP_FORCE)
			just_jumped = true
	else:
		# variable jump height if we release early
		if Input.is_action_just_released("jump") and motion.y < -JUMP_FORCE / 2.0:
			motion.y = -JUMP_FORCE / 2.0

func jump(input_vector, force):
	variable_jump_timer.start()
	motion.x += input_vector.x * JUMP_HORIZONTAL_BOOST
	motion.y = -force
	variable_jump_speed = motion.y
	
func apply_gravity(delta):
	max_fall = move_toward(max_fall, MAX_FALL, FAST_MAX_ACCEL * delta)
	var mult = 0.5 if abs(motion.y) < HALF_GRAVITY_THRESHOLD and Input.is_action_pressed("jump") else 1.0
	
	motion.y = move_toward(motion.y, max_fall, GRAVITY * mult * delta)
	
	if (variable_jump_timer.time_left > 0):
		if Input.is_action_pressed("jump"):
			motion.y = min(motion.y, variable_jump_speed)
		else:
			variable_jump_timer.stop()

func update_camera(room: Area2D):
	var collider = room.get_node("Collider")
	var size = collider.shape.extents * 2
	
	camera.limit_left = collider.global_position.x - size.x / 2
	camera.limit_top = collider.global_position.y - size.y / 2
	camera.limit_right = camera.limit_left + size.x
	camera.limit_bottom = camera.limit_top + size.y

func _on_RoomDetectorLeft_area_entered(room: Area2D):
	update_camera(room)


func _on_RoomDetectorRight_area_entered(room: Area2D):
	update_camera(room)


func _on_Hurtbox_hit(damage):
	var death_effect = Utils.instance_scene_on_main(PlayerDeathEffect, global_position)
	Events.emit_signal("player_death")
	queue_free()
