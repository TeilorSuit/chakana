extends Node2D

@export var archivo_dialogo : DialogueResource 
var jugador_cerca : bool = false

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _process(_delta: float) -> void:
	if jugador_cerca and Input.is_action_just_pressed("ui_accept") and not Data.en_dialogo:
		if Data.hablado_anciano_m1:
			# Si ya habló con el anciano, lee el cartel normal
			DialogueManager.show_example_dialogue_balloon(archivo_dialogo, "cartel_balanza")
		else:
			# Si NO ha hablado con el anciano, Sami dice que no entiende
			DialogueManager.show_example_dialogue_balloon(archivo_dialogo, "cartel_bloqueado")
			
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		jugador_cerca = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		jugador_cerca = false

func _on_dialogue_started(_resource: DialogueResource):
	Data.en_dialogo = true

func _on_dialogue_ended(_resource: DialogueResource):
	await get_tree().create_timer(0.1).timeout
	Data.en_dialogo = false
