extends Node3D

@export var jump_force = 15.0
@export var gravity = 30.0

@export var max_speed = 15.0
@export var move_accel = 4.0
@export var stop_drag = 0.9
@export var dash_speed = 40.0
@export var dash_duration = 0.2

var character_body : CharacterBody3D
var move_drag = 0.0
var move_dir : Vector3
var dash_time_left = 0.0
var dash_velocity = Vector3.ZERO



func dash(direction: Vector3):
	if direction.length() == 0:
		return
	dash_velocity = direction.normalized() * dash_speed
	dash_time_left = dash_duration


func _ready():
	character_body = get_parent()
	move_drag = float(move_accel) / max_speed

func set_move_dir(new_move_dir: Vector3):
	move_dir = new_move_dir

func jump():
		character_body.velocity.y = jump_force

func _physics_process(delta):
	if dash_time_left > 0.0:
		character_body.velocity = dash_velocity
		dash_time_left -= delta
	else:
		if character_body.velocity.y > 0.0 and character_body.is_on_ceiling():
			character_body.velocity.y = 0.0
		if not character_body.is_on_floor():
			character_body.velocity.y -= gravity * delta
		
		var drag = move_drag
		if move_dir.is_zero_approx():
			drag = stop_drag
		
		var flat_velo = character_body.velocity
		flat_velo.y = 0.0
		character_body.velocity += move_accel * move_dir - flat_velo * drag
	character_body.move_and_slide()

func is_on_floor() -> bool:
	return character_body.is_on_floor()
	
func is_on_ceiling() -> bool:
	return character_body.is_on_ceiling()

func is_on_wall() -> bool:
	return character_body.is_on_wall()
