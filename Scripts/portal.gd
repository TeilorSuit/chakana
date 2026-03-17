extends Area2D

@export var portal_objetivo : Node2D 
var archivo_dialogo = preload("uid://c8jkwta1yxxtu")
var esta_bloqueado = false 
const GLOBO_CHAKANA = preload("res://Scenes/globo_chakana/globo_chakana.tscn")

func _on_body_entered(body):
	if Data.hablado_anciano_m2:
		if portal_objetivo == null or esta_bloqueado:
			return
		
		if body.name == "Player":
			if portal_objetivo.has_method("recibir_jugador"):
				portal_objetivo.recibir_jugador()
			
			call_deferred("teletransportar", body)
	else:
		if not Data.en_dialogo:
			Data.en_dialogo = true
			var globo = GLOBO_CHAKANA.instantiate()
			get_tree().current_scene.add_child(globo)
			globo.start(archivo_dialogo, "portal_bloqueado")
				
func teletransportar(body):
	body.global_position = portal_objetivo.global_position


func recibir_jugador():
	esta_bloqueado = true
	print("Portal bloqueado temporalmente para recibir al jugador")

func _on_body_exited(body):
	if body.name == "Player":
		esta_bloqueado = false
		print("Jugador salió. Portal reactivado.")
