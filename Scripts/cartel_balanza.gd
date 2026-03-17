extends Node2D

@export var archivo_dialogo : DialogueResource 
var jugador_cerca : bool = false
const GLOBO_CHAKANA = preload("res://Scenes/globo_chakana/globo_chakana.tscn")

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _process(_delta: float) -> void:
	if jugador_cerca and Input.is_action_just_pressed("ui_accept") and not Data.en_dialogo:
		Data.en_dialogo = true
		var globo = GLOBO_CHAKANA.instantiate()
		get_tree().current_scene.add_child(globo)
		
		if Data.hablado_anciano_m1:
			globo.start(archivo_dialogo, "cartel_balanza")
		else:
			globo.start(archivo_dialogo, "cartel_bloqueado")
			
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		jugador_cerca = true
		if not Data.en_dialogo:
			$Indicador.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		jugador_cerca = false
		$Indicador.visible = false

func _on_dialogue_started(_resource: DialogueResource):
	Data.en_dialogo = true
	if $Indicador:
		$Indicador.visible = false 

func _on_dialogue_ended(_resource: DialogueResource):
	await get_tree().create_timer(0.1).timeout
	Data.en_dialogo = false
	if jugador_cerca and $Indicador:
		$Indicador.visible = true
