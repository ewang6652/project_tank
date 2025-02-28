extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player_hit.connect(_on_player_hit)
	Global.enemy_killed.connect(_on_enemy_killed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_hit() -> void:
	$SFX.play()
	$SFX.finished.connect(get_tree().quit)

func _on_enemy_killed():
	$SFX.play()
