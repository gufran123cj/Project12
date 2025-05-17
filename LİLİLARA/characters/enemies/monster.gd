class_name Monster extends CharacterBody3D

@onready var health_manager = $HealthManager

func _ready():
	var hitboxes = find_children("*", "HitBox")
	for hitbox in hitboxes:
		hitbox.on_hurt.connect(health_manager.hurt)

func hurt(damage_data: DamageData):
	health_manager.hurt(damage_data)
