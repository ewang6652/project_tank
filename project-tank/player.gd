extends CharacterBody2D

signal moved

@export var speed = 150
var bullet_scene = preload("res://bullet.tscn")
var shooting = false
var initial_children

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_children = get_child_count()
	Global.player_hit.connect(_on_player_hit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	
	if input_vector.length() > 0:
		velocity = input_vector.normalized() * speed
		move_and_slide()
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if "bullet" in collision.get_collider():  # checks for the bullet property
				Global.player_hit.emit()
		moved.emit()

func _input(event):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		var count = 0
		for node in get_children():
			if "bullet" in node:
				count += 1
		if count >= 5:
			return
		
		var bullet = bullet_scene.instantiate()
		bullet.position = $Turret/Bullet_Spawner.global_position
		bullet.rotation = $Turret.rotation
		bullet.velocity = Vector2(0.0, 200.0).rotated(bullet.rotation)
		add_child(bullet)

func _on_player_hit():
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
