extends Marker2D

var screen_size
var cursor = load("res://cursor.png")
var mouse_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	Input.set_custom_mouse_cursor(cursor, 0, Vector2(16, 16))

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.position
		var angle = global_position.angle_to_point(mouse_position)
		rotation = angle - PI/2
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position = Vector2.ZERO


func _on_player_moved() -> void:
	var angle = global_position.angle_to_point(mouse_position)
	rotation = angle - PI/2
