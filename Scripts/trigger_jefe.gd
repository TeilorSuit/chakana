extends Area2D

@export var archivo_dialogo : DialogueResource 
var dialogo_iniciado = false

func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not dialogo_iniciado:
		dialogo_iniciado = true
		Data.en_dialogo = true 
		var musica_nivel = get_tree().current_scene.get_node_or_null("MusicaFondo")
		if musica_nivel:
			musica_nivel.stop()
		# Cerramos la puerta trampa usando el Nombre Único
		var muro_izq = get_node_or_null("%MuroIzq/CollisionShape2D")
		if muro_izq:
			muro_izq.set_deferred("disabled", false)
			
		# Lanza el diálogo
		DialogueManager.show_example_dialogue_balloon(archivo_dialogo, "inicio_jefe_final")

func _on_dialogue_ended(_resource: DialogueResource):
	if dialogo_iniciado:
		Data.en_dialogo = false 
		var jefe = get_tree().get_first_node_in_group("Jefe")
		if jefe:
			jefe.activar_jefe() 
			
		var sami = get_tree().get_first_node_in_group("Player")
		if sami and sami.has_method("activar_super_salto"):
			sami.activar_super_salto(true)
			
		set_deferred("monitoring", false)
