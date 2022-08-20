extends KinematicBody2D


export var gravity := 5
export var jump_height := 1000
export var acceleration_speed := 100
export var max_speed = 500
export var friction = 35
export var jump_cancel_velocity := 100

onready var jump_buffer_timer := $JumpBufferTimer
onready var coyote_timer := $CoyoteTimer

var acceleration := Vector2.ZERO
var velocity := Vector2.ZERO

var jump_buffering := false
var coyote_timing := false

func _physics_process(delta: float) -> void:
	# Jumping
	if Input.is_action_pressed("jump"):
		jump_buffering = true
		jump_buffer_timer.start()
		
	if is_on_floor():
		coyote_timing = true
		coyote_timer.start()
	
	if (
		!is_on_floor() && velocity.y < 0 &&
		Input.is_action_just_released("jump")
	):
		acceleration.y = jump_cancel_velocity
	
	if jump_buffering && coyote_timing:
		velocity.y = -jump_height
		acceleration.y = 0
		jump_buffering = false
		jump_buffer_timer.stop()
		coyote_timing = false
		coyote_timer.stop()
	
	# Walking
	acceleration.x = Input.get_axis("left", "right") * acceleration_speed
	
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	
	if velocity.x < -friction:
		velocity.x += friction
	elif velocity.x > friction:
		velocity.x -= friction
	else:
		velocity.x = 0
	
	# Actually moving
	
	acceleration.y += gravity
	
	if is_on_floor():
		acceleration.y = 0
	
	velocity += acceleration
	
	velocity = move_and_slide(velocity, Vector2.UP)


func _on_coyote_time_end() -> void:
	coyote_timing = false


func _on_jump_buffer_end() -> void:
	jump_buffering = false
