extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var objs = $Area2D.get_overlapping_bodies()
	for obj in objs:
		if obj == self:
			continue
		add_collision_exception_with(obj)


func _on_area_2d_body_exited(body: Node2D) -> void:
	remove_collision_exception_with(body)
