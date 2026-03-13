extends Node2D

func _ready():
	if Data.tiene_fruto_yaku or Data.entrego_fruto_m2:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Data.tiene_fruto_yaku = true 
		print("¡Fruto de Yaku recogido!")
		queue_free()
