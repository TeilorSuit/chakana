extends Control

@onready var btn_start = $VBoxContainer/HBoxContainer/BtnStart
@onready var btn_reset = $VBoxContainer/HBoxContainer/BtnReset
@onready var btn_exit = $VBoxContainer/HBoxContainer/BtnExit
@onready var confirmacion = $ConfirmationDialog

func _ready():
	# Conectamos los botones
	btn_start.pressed.connect(_on_btn_start_pressed)
	btn_reset.pressed.connect(_on_btn_reset_pressed)
	btn_exit.pressed.connect(_on_btn_exit_pressed)
	
	confirmacion.confirmed.connect(_on_confirmacion_aceptada)
	
	# Le damos el foco al botón Start para que el teclado funcione de una
	btn_start.grab_focus()

func _on_btn_start_pressed():
	# Cargamos la partida y limpiamos si es necesario
	var nivel_a_cargar = Data.cargar_partida()
	Data.resetear_variables_del_nivel(nivel_a_cargar)
	get_tree().change_scene_to_file(nivel_a_cargar)

func _on_btn_reset_pressed():
	# Mostramos el diálogo de confirmación
	confirmacion.popup_centered()

func _on_confirmacion_aceptada():
	# Borramos todo y empezamos desde cero en el nivel 1
	Data.borrar_partida()
	get_tree().change_scene_to_file("res://Scenes/level1.tscn")

func _on_btn_exit_pressed():
	get_tree().quit()
