extends Area2D
@onready var background_entero: TextureRect = $"../../backgroundEntero"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var cam = get_parent() 
		cam.enabled = true 
		cam.make_current() 
		background_entero.visible = true;

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_node("Camera2D"):
			body.get_node("Camera2D").make_current()
		background_entero.visible = false;
