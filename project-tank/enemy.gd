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
var destination

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#add_child(raycast_line)
	screen_size = get_viewport().size
	destination = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
		# random movement: choose a destination and if no obstacles in way then move there
		#if $Destination.overlaps_body(self):
			#destination = Vector2(global_position.x + randf_range(-200, 200), 
								  #global_position.y + randf_range(-200, 200))
			#var query = PhysicsRayQueryParameters2D.create(global_position, destination, 1)
			#var space_state = get_world_2d().direct_space_state
			#var result = space_state.intersect_ray(query)
			#if result:
				#destination = global_position
				#velocity = Vector2.ZERO
			#else:
				#$Destination.global_position = destination
				#velocity = (destination - global_position).normalized() * 100
		
		# Pathfinding to player
		destination = $"../Player".global_position
		var query = PhysicsRayQueryParameters2D.create(global_position, destination, 1)
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(query)
		var queue = [[Vector2((int(global_position.x) / 32) * 32 + 16, (int(global_position.y) / 32) * 32 + 16)]]
		var neighbors = [Vector2(0, 32), Vector2(32, 32), Vector2(32, 0), Vector2(32, -32),
						 Vector2(0, -32), Vector2(-32, -32), Vector2(-32, 0), Vector2(-32, 32)]
		if result:
			var path
			while true:
				path = queue.pop_back()
				query = PhysicsRayQueryParameters2D.create(path[-1], destination, 1)
				result = space_state.intersect_ray(query)
				if not result:
					break
				for neighbor in neighbors:
					var point_query = PhysicsPointQueryParameters2D.new()
					point_query.set_position(path[-1] + neighbor)
					if not space_state.intersect_point(point_query, 1):
						var new_path = path.duplicate(true)
						new_path.append(path[-1] + neighbor)
						queue.append(new_path)
				queue.sort_custom(func(a, b): return (destination - a[-1]).length() > (destination - b[-1]).length())
			path.reverse()
			for point in path:
				query = PhysicsRayQueryParameters2D.create(global_position, point, 1)
				result = space_state.intersect_ray(query)
				if not result:
					destination = point
					break
		
		#movement code once destination is finalized
		$Destination.global_position = destination
		velocity = (destination - global_position).normalized() * 100
		move_and_slide()


func raycast(angle, ricochets=1):  # returns true if player is found
	var space_state = get_world_2d().direct_space_state
	var from = global_position
	var direction = Vector2.from_angle(angle)
	var to = from + direction * (screen_size.x ** 2 + screen_size.y ** 2) ** 0.5
	#raycast_line.clear_points()
	#raycast_line.add_point(from - global_position)
	for ricochet in range(ricochets+1):  # one for the initial shot, then the ricochets
		var query
		if ricochet == 0:
			query = PhysicsRayQueryParameters2D.create(from, to, raycast_mask, [self])
		else:
			query = PhysicsRayQueryParameters2D.create(from, to, raycast_mask)
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
