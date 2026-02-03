extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		Data.agregar_roca()
		# sonido 
		print("roca agarrada, total:",Data.rocas_coleccionadas)
		queue_free()
