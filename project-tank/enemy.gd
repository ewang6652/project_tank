extends CharacterBody2D

var screen_size
var bullet_scene = preload("res://bullet.tscn")
#var raycast_line = Line2D.new()
@export_range(0, 360, 1, "radians_as_degrees", "suffix:°/s") var turret_angular_speed = PI/2  # per second
## How many times bullets shot by this enemy can bounce off walls
@export_range(0, 3) var max_ricochets = 1
## Speed of bullets shot by this enemy in pixels per second
@export var bullet_speed = 200
## What collision layers are checked when aiming a shot
@export_flags_2d_physics var raycast_mask

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#add_child(raycast_line)
	screen_size = get_viewport().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Called every physics frame.
func _physics_process(delta):
	var shooting = false
	for ricochets in range(max_ricochets+1):  # can we hit the player with 0 ricochets? 1? ...
		for theta in range(0, 360, 5):
			if raycast(deg_to_rad(theta), ricochets):
				rotate_turret(deg_to_rad(theta), delta)
				shooting = true
				break
		if shooting:
			break
	if not shooting:  # the player cannot be hit, so move
		var curr_pos = global_position
		

func raycast(angle, ricochets=1):  # returns true if player is found
	var space_state = get_world_2d().direct_space_state
	var from = global_position
	var direction = Vector2.from_angle(angle)
	var to = from + direction * (screen_size.x ** 2 + screen_size.y ** 2) ** 0.5
	#raycast_line.clear_points()
	#raycast_line.add_point(from - global_position)
	for ricochet in range(ricochets+1):  # one for the initial shot, then the ricochets
		var query = PhysicsRayQueryParameters2D.create(from, to, raycast_mask, [self])
		var result = space_state.intersect_ray(query)
		if not result:
			return false
		#raycast_line.add_point(result.position - global_position - Vector2.from_angle(angle) * 5)
		if result.collider.name == "Player":
			return true
		from = result.position - Vector2.from_angle(angle) * 5
		direction = direction.bounce(result.normal)
		to = from + direction * (screen_size.x ** 2 + screen_size.y ** 2) ** 0.5
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

func die():
	Global.enemy_killed.emit()
	queue_free()
