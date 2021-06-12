extends KinematicBody2D


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

onready var sprite = $Sprite
onready var coyote_jump_timer = $CoyoteJumpTimer
onready var variable_jump_timer = $VariableJumpTimer
onready var grab_left = $GrabLeft
onready var grab_right = $GrabRight
onready var collider = $Collider

func _physics_process(delta):
	just_jumped = false

	var input_vector = get_input_vector()
	facing = sign(input_vector.x)
	
	apply_horizontal_force(input_vector, delta)
	jump_check(input_vector)
	apply_gravity(delta)
	update_animations()
	move()
	pickup_item()
	
func pickup_item():
	if not is_holding and grab_left.is_colliding():
		grab_box(grab_left.get_collider())
		is_holding = true
		
	if not is_holding and grab_right.is_colliding():
		grab_box(grab_right.get_collider())
		is_holding = true

func grab_box(box):
	var box_sprite = box.get_node("Sprite").duplicate()
	box_sprite.name = "HoldingSprite"
	box_sprite.position = Vector2(0, -24)
	add_child(box_sprite)
	box.queue_free()
	
	collider.shape.extents.y = 16
	collider.position.y = -16

func update_animations():
	if facing != 0:
		sprite.scale.x = facing

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
