extends Area2D

@export var puerta_a_abrir_id : int = 50

@export var textura_balanza_llena : Texture2D

@onready var sprite_balanza = $Sprite2D


func _on_body_entered(body):
	if Data.puzzle_resuelto:
		return

	if body.name == "Player" and Data.rocas_coleccionadas >= 3:
		print("Puzzle resuelto")
		
		if textura_balanza_llena and sprite_balanza:
			sprite_balanza.texture = textura_balanza_llena
		
		Data.door_unlocked.emit(puerta_a_abrir_id)
		
		Data.puzzle_resuelto = true
		print("balanza resuelta")
		# Opcional: desactivar la colisión para que no vuelva a detectar
		# $CollisionShape2D.set_deferred("disabled", true) 
	
	elif body.name == "Player" and Data.rocas_coleccionadas < 3:
		print("Faltan rocas. Tienes: ", Data.rocas_coleccionadas)
