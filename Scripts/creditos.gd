extends Control

@onready var btn_volver = $BtnHome 

func _ready():
	btn_volver.pressed.connect(_on_btn_volver_pressed)
	
	btn_volver.grab_focus()

func _on_btn_volver_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu_principal.tscn")
