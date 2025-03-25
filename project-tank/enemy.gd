extends CharacterBody2D

var screen_size
var bullet_scene = preload("res://bullet.tscn")
@export_range(0, 360, 1, "radians_as_degrees", "suffix:°/s") var turret_angular_speed = PI/2  # per second
## How many times bullets shot by this enemy can bounce off walls
@export_range(0, 3) var max_ricochets = 1
## Speed of bullets shot by this enemy in pixels per second
@export var bullet_speed = 200
## What collision layers are checked when aiming a shot
@export_flags_2d_physics var raycast_mask

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func raycast(angle, ricochets=1):  # returns true if player is found
	var space_state = get_world_2d().direct_space_state
	var from = global_position
	var direction = Vector2.from_angle(angle)
	var to = from + direction * (screen_size.x ** 2 + screen_size.y ** 2) ** 0.5
	for ricochet in range(ricochets+1):  # one for the initial shot, then the ricochets
		var query = PhysicsRayQueryParameters2D.create(from, to, raycast_mask, [self])
		var result = space_state.intersect_ray(query)
		if not result:
			return false
		if result.collider.name == "Player":
			return true
		from = result.position
		to = to.bounce(result.normal)
	return false

func rotate_turret(target_angle, delta):
	var target_rotation = fposmod(target_angle-PI/2, 2*PI)
	$Turret.rotation = fposmod($Turret.rotation,2*PI)
	if abs(target_rotation - $Turret.rotation) <= turret_angular_speed * delta:
		$Turret.rotation = target_rotation
		shoot()
	elif 0 <= fposmod(target_rotation - $Turret.rotation, 2*PI) and fposmod(target_rotation - $Turret.rotation, 2*PI) < PI:  # target angle is greater than curr_angle
		$Turret.rotation += turret_angular_speed * delta
	else:
		$Turret.rotation -= turret_angular_speed * delta

func shoot():
	if $Timer.is_stopped():
		var bullet = bullet_scene.instantiate()
		bullet.position = $Turret/Bullet_Spawner.global_position
		bullet.rotation = $Turret.rotation
		bullet.velocity = Vector2(0.0, bullet_speed).rotated(bullet.rotation)
		add_sibling(bullet)
		$Timer.start()
	

func _physics_process(delta):
	var done = false
	for ricochets in range(max_ricochets+1):  # can we hit the player with 0 ricochets? 1? ...
		for theta in range(360):
			if raycast(deg_to_rad(theta), ricochets):
				rotate_turret(deg_to_rad(theta), delta)
				done = true
				break
		if done:
			break

func die():
	Global.enemy_killed.emit()
	queue_free()
