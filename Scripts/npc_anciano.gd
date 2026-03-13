extends Node2D

@export var numero_mundo : int = 1 # Para saber en qué nivel estamos
@export var archivo_dialogo : DialogueResource # Arrastraremos el archivo .dialogue aquí
@export var nodo_chakana : Area2D # Aquí asignaremos la Chakana que ya está en tu nivel

var jugador_cerca : bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("idle") 
	
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	Data.aparecer_chakana_m2.connect(_on_aparecer_chakana)
	
	if numero_mundo == 2 and nodo_chakana:
		nodo_chakana.visible = false
		nodo_chakana.set_deferred("monitoring", false)

func _process(_delta: float) -> void:
	if jugador_cerca and Input.is_action_just_pressed("ui_accept") and not Data.en_dialogo:
		iniciar_dialogo()

func iniciar_dialogo():
	if numero_mundo == 1:
		DialogueManager.show_example_dialogue_balloon(archivo_dialogo, "inicio_nivel_1")
	elif numero_mundo == 2:
		DialogueManager.show_example_dialogue_balloon(archivo_dialogo, "inicio_nivel_2")
	elif numero_mundo == 3:
		DialogueManager.show_example_dialogue_balloon(archivo_dialogo, "inicio_nivel_3")
		
# --- SEÑALES DEL AREA2D ---
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player": 
		jugador_cerca = true
		Data.cerca_de_npc = true 
		if not Data.en_dialogo:
			$Indicador.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		jugador_cerca = false
		Data.cerca_de_npc = false 
		$Indicador.visible = false
		
# --- SEÑALES DEL DIALOGUE MANAGER ---
func _on_dialogue_started(_resource: DialogueResource):
	Data.en_dialogo = true
	if $Indicador:
		$Indicador.visible = false
		
func _on_dialogue_ended(_resource: DialogueResource):
	# margen de activación
	await get_tree().create_timer(0.1).timeout
	Data.en_dialogo = false
	if jugador_cerca and $Indicador:
		$Indicador.visible = true
		
# --- FUNCIÓN PARA SPAWNEAR LA CHAKANA ---
func _on_aparecer_chakana():
	if numero_mundo == 2 and nodo_chakana:
		nodo_chakana.visible = true
		nodo_chakana.set_deferred("monitoring", true) # Activa la colisión para agarrarla
		print("¡El anciano ha revelado la Chakana!")
