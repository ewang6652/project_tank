extends CharacterBody2D

signal moved

@export var speed = 200
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player_hit.connect(_on_player_hit)
	screen_size = get_viewport_rect().size


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
		moved.emit()
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if "bullet" in collision.get_collider():  # checks for the bullet property
			Global.player_hit.emit()
			

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_player_hit():
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
