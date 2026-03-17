extends CanvasLayer

@onready var fondo = $ColorRect
@onready var contenedor_textos = $ColorRect/VBoxContainer
@onready var label_titulo = $ColorRect/VBoxContainer/Titulo
@onready var label_instruccion = $ColorRect/VBoxContainer/Instruccion
@onready var label_continuar = $ColorRect/VBoxContainer/Continuar

@onready var sfx_zumbido = $AudioStreamPlayer

var puede_continuar = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS 
	
	contenedor_textos.modulate.a = 1.0 
	label_titulo.modulate.a = 0.0
	label_instruccion.modulate.a = 0.0
	label_continuar.modulate.a = 0.0
	
	sfx_zumbido.play()
	

	var tween = create_tween().set_ignore_time_scale(true) 
	
	tween.tween_property(fondo, "color:a", 0.8, 0.2)
	tween.tween_property(fondo, "color:a", 0.2, 0.1)
	tween.tween_property(fondo, "color:a", 0.8, 0.5)
	tween.tween_property(fondo, "color:a", 0.2, 0.1)
	tween.tween_property(fondo, "color:a", 0.9, 0.1)
	tween.tween_property(fondo, "color:a", 1.0, 1)
	
	tween.tween_callback(func():
		get_tree().paused = true
	)
	
	tween.tween_interval(3.0)
	
	tween.tween_property(label_titulo, "modulate:a", 1.0, 1.0)
	tween.tween_interval(1.0) 
	
	tween.tween_property(label_instruccion, "modulate:a", 1.0, 1.0)
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
	var tween = create_tween().set_ignore_time_scale(true)
	tween.tween_property(fondo, "modulate:a", 0.0, 1.0)
	
	await tween.finished
	
	Engine.time_scale = 1.0
	get_tree().paused = false
	queue_free()
