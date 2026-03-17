extends Area2D

@export var next_scene_path: String = ""

func _on_body_entered(body):
	if body.name == "Player":
		call_deferred("change_scene")

func change_scene():
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
