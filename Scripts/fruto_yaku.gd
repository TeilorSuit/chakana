extends Node2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Data.tiene_fruto_yaku = true 
		print("¡Fruto de Yaku recogido!")
		queue_free() 
