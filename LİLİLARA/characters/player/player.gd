extends CharacterBody3D

@onready var camera_3d = $Camera3D 
@onready var character_mover = $CharacterMover
@onready var health_manager = $HealthManager
@onready var weapon_manager = $Camera3D/WeaponManager
@onready var music = $AudioStreamPlayer3D
@onready var hud = $death_message
@onready var hp_hud = $hp_hud
@onready var death_sound = $death_message/death_sound



@export var mouse_sensitivity_h = 0.15
@export var mouse_sensitivity_v = 0.15

var jump_count = 0
var max_jumps = 2

const HOTKEYS = {
	KEY_1: 0,
	KEY_2: 1,
	KEY_3: 2,
	KEY_4: 3,
	KEY_5: 4,
	KEY_6: 5,
	KEY_7: 6,
	KEY_8: 7,
	KEY_9: 8,
	KEY_0: 9,
}

var dead = false



func _ready():
	if dead == false:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		music.play()
		health_manager.died.connect(kill)

func _input(event):
	if dead:
		music.volume_db = 0 #sesi kısıyor
		death_sound.play()
		hud.text = "you died \n press  'r'  to restart"
		return
	else:
		#hud.text = " "
		music.volume_db = 100
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity_h
		camera_3d.rotation_degrees.x -= event.relative.y * mouse_sensitivity_v
		camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -90, 90)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			weapon_manager.switch_to_previous_weapon()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			weapon_manager.switch_to_next_weapon()
	if event is InputEventKey and event.pressed and event.keycode in HOTKEYS:
		weapon_manager.switch_to_weapon_slot(HOTKEYS[event.keycode])

func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		pass
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("fullscreen"):
		var fs = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		if fs:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	if dead:
		return
	
	if Input.is_action_just_pressed("dash"):
		var forward = -camera_3d.global_transform.basis.z
		character_mover.dash(forward)
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if character_mover.is_on_floor():
		jump_count = 0
	
	character_mover.set_move_dir(move_dir)
	
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		character_mover.jump()
		jump_count += 1
	
	weapon_manager.attack(Input.is_action_just_pressed("attack"), Input.is_action_pressed("attack"))
	#hp_hud.text = "HP: "+str(health_manager.cur_health)
func kill():
	dead = true
	character_mover.set_move_dir(Vector3.ZERO)

func hurt(damage_data: DamageData):
	health_manager.hurt(damage_data)
