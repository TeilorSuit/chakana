extends Control

@onready var btn_tts = $VBoxContainer/CheckButton
@onready var btn_volver = $VBoxContainer/BtnHome

func _ready():
	btn_volver.focus_mode = Control.FOCUS_ALL
	
	btn_tts.button_pressed = Data.tts_activado
	
	btn_tts.toggled.connect(_on_tts_toggled)
	btn_volver.pressed.connect(_on_volver_pressed)
	
	# --- ENRUTAMIENTO MANUAL DE TECLADO ---
	btn_tts.focus_neighbor_bottom = btn_volver.get_path()
	btn_volver.focus_neighbor_top = btn_tts.get_path()
	
	btn_tts.grab_focus()

func _on_tts_toggled(toggled_on: bool):
	Data.tts_activado = toggled_on

func _on_volver_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu_principal.tscn")
