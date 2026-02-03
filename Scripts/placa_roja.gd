extends Area2D

# Señal que avisa al PuzzleManager si tenemos la caja correcta encima
signal estado_cambiado(esta_activa)

# En el Inspector escribes: "sol", "luna" o "normal"
@export var grupo_requerido : String = ""

func _on_body_entered(body):
	# Verificamos si es una caja Y si tiene el apellido correcto
	if body.is_in_group("caja") and body.is_in_group(grupo_requerido):
		emit_signal("estado_cambiado", true)

func _on_body_exited(body):
	# Si la caja se quita, avisamos que ya no está lista
	if body.is_in_group("caja") and body.is_in_group(grupo_requerido):
		emit_signal("estado_cambiado", false)
