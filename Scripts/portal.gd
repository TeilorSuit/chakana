extends Area2D

@export var portal_objetivo : Node2D 

var esta_bloqueado = false 

func _on_body_entered(body):
	if portal_objetivo == null or esta_bloqueado:
		return
	
	if body.name == "Player":
		if portal_objetivo.has_method("recibir_jugador"):
			portal_objetivo.recibir_jugador()
		
		call_deferred("teletransportar", body)

func teletransportar(body):
	body.global_position = portal_objetivo.global_position


func recibir_jugador():
	esta_bloqueado = true
	print("Portal bloqueado temporalmente para recibir al jugador")

func _on_body_exited(body):
	if body.name == "Player":
		esta_bloqueado = false
		print("Jugador salió. Portal reactivado.")
