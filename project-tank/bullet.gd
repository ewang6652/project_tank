extends CharacterBody2D

var bullet
var num_collisions
var collidable
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player_hit.connect(_on_player_hit)
	num_collisions = 0
	collidable = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision and collidable:
		num_collisions += 1
		if num_collisions == 2 or collision.get_collider() == bullet:
			queue_free()
		var angle_diff = velocity.angle_to(collision.get_normal())
		velocity = velocity.bounce(collision.get_normal())
		rotation += 2 * angle_diff
		collidable = false
	elif not collision:
		collidable = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_player_hit():
	velocity = Vector2.ZERO
