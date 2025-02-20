extends CharacterBody2D

var bullet
var num_collisions
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player_hit.connect(_on_player_hit)
	num_collisions = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision and collision.get_collider().is_class("TileMapLayer"):
		num_collisions += 1
		if num_collisions == 2:
			queue_free()
		var angle_diff = velocity.angle_to(collision.get_normal())
		velocity = velocity.bounce(collision.get_normal())
		rotation += 2 * angle_diff


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_player_hit():
	velocity = Vector2.ZERO
