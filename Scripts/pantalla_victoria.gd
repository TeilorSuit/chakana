extends Control

@onready var linea_1 = $VBoxContainer/Linea1
@onready var linea_2 = $VBoxContainer/Linea2
@onready var linea_3 = $VBoxContainer/Linea3
@onready var linea_4 = $VBoxContainer/Linea4
@onready var caja_botones = $VBoxContainer/HBoxContainer
@onready var btn_home = $VBoxContainer/HBoxContainer/BtnHome
@onready var btn_salir = $VBoxContainer/HBoxContainer/BtnSalir

func _ready():
	linea_1.modulate.a = 0.0
	linea_2.modulate.a = 0.0
	linea_3.modulate.a = 0.0
	linea_4.modulate.a = 0.0
	caja_botones.modulate.a = 0.0
	
	Engine.time_scale = 1.0
	
	btn_home.pressed.connect(_on_btn_home_pressed)
	btn_salir.pressed.connect(func(): get_tree().quit())
	
	iniciar_secuencia_victoria()

func iniciar_secuencia_victoria():
	var tween = create_tween()
	tween.tween_interval(1.0) 
	
	tween.tween_property(linea_1, "modulate:a", 1.0, 1.5)
	tween.tween_interval(1.5) 
	
	tween.tween_property(linea_2, "modulate:a", 1.0, 1.5)
	tween.tween_interval(1.5) 
	
	tween.tween_property(linea_3, "modulate:a", 1.0, 1.5)
	tween.tween_interval(1.5)
	
	tween.tween_property(linea_4, "modulate:a", 1.0, 1.5)
	tween.tween_interval(2.0) 
	
	tween.tween_property(caja_botones, "modulate:a", 1.0, 1.0)
	
	await tween.finished
	btn_home.grab_focus()

func _on_btn_home_pressed():
	Data.borrar_partida()
	get_tree().change_scene_to_file("res://Scenes/menu_principal.tscn")
