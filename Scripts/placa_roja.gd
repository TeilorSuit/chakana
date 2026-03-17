extends Area2D

signal estado_cambiado(esta_activa)

@export var grupo_requerido : String = ""

func _on_body_entered(body):
	if body.is_in_group("caja") and body.is_in_group(grupo_requerido):
		emit_signal("estado_cambiado", true)

func _on_body_exited(body):
	if body.is_in_group("caja") and body.is_in_group(grupo_requerido):
		emit_signal("estado_cambiado", false)
