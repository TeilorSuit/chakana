extends CanvasLayer

@export var numero_nivel: String = "NIVEL 1"
@export var nombre_nivel: String = "Uku Pacha"

@onready var fondo = $ColorRect
@onready var lbl_numero =  $VBoxContainer/LabelNumero
@onready var lbl_nombre = $VBoxContainer/LabelNombre

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	
	lbl_numero.text = numero_nivel
	lbl_nombre.text = nombre_nivel
	
	fondo.modulate.a = 1.0
	lbl_numero.modulate.a = 0.0
	lbl_nombre.modulate.a = 0.0
	
	animar_transicion()

func animar_transicion():
	var tween = create_tween().set_ignore_time_scale(true)
	
	tween.tween_property(lbl_numero, "modulate:a", 1.0, 0.5)
	tween.tween_interval(0.2)
	tween.tween_property(lbl_nombre, "modulate:a", 1.0, 0.5)
	
	tween.tween_interval(2.0)
	
	tween.tween_property(lbl_numero, "modulate:a", 0.0, 0.5)
	tween.tween_property(lbl_nombre, "modulate:a", 0.0, 0.5)
	
	tween.tween_property(fondo, "modulate:a", 0.0, 1.0)
	
	tween.tween_callback(func():
		get_tree().paused = false
		queue_free()
	)
