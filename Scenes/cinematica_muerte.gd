extends CanvasLayer

@onready var fondo = $ColorRect
@onready var label_muerte = $ColorRect/VBoxContainer/Muerte
@onready var label_frase = $ColorRect/VBoxContainer/Frase
@onready var label_continuar = $ColorRect/VBoxContainer/Continuar

var es_jefe = false
var player_ref = null
var puede_continuar = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS 
	
	fondo.modulate.a = 0.0
	label_muerte.modulate.a = 0.0
	label_frase.modulate.a = 0.0
	label_continuar.modulate.a = 0.0
	
	label_frase.text = obtener_frase_aleatoria()
	animar_pantalla()

func obtener_frase_aleatoria() -> String:
	var frases = []
	var ruta_archivo = "res://dialogos/frases_motivadoras.json"
	
	if FileAccess.file_exists(ruta_archivo):
		var archivo = FileAccess.open(ruta_archivo, FileAccess.READ)
		var json = JSON.new()
		if json.parse(archivo.get_as_text()) == OK:
			var datos = json.data
			if datos is Dictionary and datos.has("frases"):
				frases = datos["frases"]
				
	if frases.is_empty():
		frases.append("La luz de la Chakana te guiará.") 
		
	return frases[randi() % frases.size()]

func animar_pantalla():
	get_tree().paused = true 
	
	var tween = create_tween().set_ignore_time_scale(true)
	tween.tween_property(fondo, "modulate:a", 1.0, 1.0)
	tween.tween_property(label_muerte, "modulate:a", 1.0, 0.5)
	tween.tween_interval(0.5)
	tween.tween_property(label_frase, "modulate:a", 1.0, 1.0)
	tween.tween_interval(1.5)
	tween.tween_property(label_continuar, "modulate:a", 1.0, 0.5)
	
	tween.tween_callback(func():
		puede_continuar = true
	)

func _input(event):
	if puede_continuar and event.is_action_pressed("ui_accept"):
		puede_continuar = false
		terminar_cinematica()

func terminar_cinematica():
	get_tree().paused = false
	
	if es_jefe and player_ref != null:
		player_ref.morir() 
		
		var tween = create_tween().set_ignore_time_scale(true)
		
		tween.tween_property(label_muerte, "modulate:a", 0.0, 0.2)
		tween.tween_property(label_frase, "modulate:a", 0.0, 0.2)
		tween.tween_property(label_continuar, "modulate:a", 0.0, 0.2)
		
		tween.tween_property(fondo, "modulate:a", 0.0, 0.5)
		
		await tween.finished
		queue_free() 
		
	else:
		get_tree().reload_current_scene()
