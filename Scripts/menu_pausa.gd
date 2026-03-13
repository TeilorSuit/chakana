extends CanvasLayer

@onready var contenedor = $Contenedor
@onready var btn_resumir = $Contenedor/VBoxContainer/HBoxContainer/BtnResumir

func _ready():
	contenedor.visible = false # Empieza oculto
	
	# Conectamos señales
	$Contenedor/VBoxContainer/HBoxContainer/BtnResumir.pressed.connect(despausar)
	$Contenedor/VBoxContainer/HBoxContainer/BtnHome.pressed.connect(_on_home_pressed)
	$Contenedor/VBoxContainer/HBoxContainer/BtnSalir.pressed.connect(func(): get_tree().quit())

func _input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		if not get_tree().paused:
			pausar()
		else:
			despausar()

func pausar():
	get_tree().paused = true
	contenedor.visible = true
	btn_resumir.grab_focus() # Para que el teclado funcione de una

func despausar():
	get_tree().paused = false
	contenedor.visible = false

func _on_home_pressed():
	get_tree().paused = false # ¡IMPORTANTE! Despausar antes de cambiar de escena
	get_tree().change_scene_to_file("res://Scenes/menu_principal.tscn")
