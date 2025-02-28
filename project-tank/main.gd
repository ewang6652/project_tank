extends Node2D

@export var bullet_scene: PackedScene
var shooting = false
var initial_children
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_children = get_child_count()
	Global.player_hit.connect(_on_player_hit)

func _input(event):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed and get_child_count() - initial_children < 5:
		var bullet = bullet_scene.instantiate()
		bullet.position = $Player/Turret/Bullet_Spawner.global_position
		bullet.rotation = $Player/Turret.rotation
		bullet.velocity = Vector2(0.0, 200.0).rotated(bullet.rotation)
		add_child(bullet)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_hit() -> void:
	$SFX.play()
	await get_tree().create_timer(1).timeout 
	get_tree().quit()
