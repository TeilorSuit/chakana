extends Control

@onready var btn_start = $VBoxContainer/HBoxContainer/BtnStart
@onready var btn_reset = $VBoxContainer/HBoxContainer/BtnReset
@onready var btn_exit = $VBoxContainer/HBoxContainer/BtnExit
@onready var btn_config = $VBoxContainer/HBoxContainer/BtnConfig
@onready var btn_info = $VBoxContainer/HBoxContainer/BtnInfo    
@onready var confirmacion = $ConfirmationDialog

func _ready():
	btn_start.pressed.connect(_on_btn_start_pressed)
	btn_reset.pressed.connect(_on_btn_reset_pressed)
	btn_exit.pressed.connect(_on_btn_exit_pressed)
	btn_config.pressed.connect(_on_btn_config_pressed) 
	btn_info.pressed.connect(_on_btn_info_pressed)
	
	confirmacion.confirmed.connect(_on_confirmacion_aceptada)
	
	btn_start.grab_focus()

func _on_btn_start_pressed():
	var nivel_a_cargar = Data.cargar_partida()
	Data.resetear_variables_del_nivel(nivel_a_cargar)
	
	if not Data.intro_vista:
		get_tree().change_scene_to_file("res://Scenes/intro.tscn")
	else:
		get_tree().change_scene_to_file(nivel_a_cargar)

func _on_btn_reset_pressed():
	confirmacion.popup_centered()

func _on_confirmacion_aceptada():
	Data.borrar_partida()
	Data.intro_vista = false 
	get_tree().change_scene_to_file("res://Scenes/intro.tscn")

func _on_btn_config_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu_opciones.tscn")

func _on_btn_info_pressed():
	get_tree().change_scene_to_file("res://Scenes/creditos.tscn")

func _on_btn_exit_pressed():
	get_tree().quit()
