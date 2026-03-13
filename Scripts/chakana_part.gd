extends Area2D

@export var part_texture : Texture2D 
@export var id_unico : String = "chakana_default" 

@onready var sprite : Sprite2D = $Sprite2D 

var en_cinematica = false
var puede_continuar = false # ¡EL SEGURO CONTRA SALTOS!
var canvas_poder : CanvasLayer

var fuente_pixel = preload("res://Assets/m5x7.ttf")

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if id_unico in Data.chakanas_recogidas:
		queue_free()
		return
		
	if part_texture:
		sprite.texture = part_texture

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not en_cinematica:
		if not id_unico in Data.chakanas_recogidas:
			Data.add_chakana(id_unico)
			
			if Data.chakana_parts == 3:
				iniciar_cinematica_poder(body)
			else:
				queue_free()

func iniciar_cinematica_poder(sami_body):
	en_cinematica = true
	puede_continuar = false # Bloqueamos el "Enter/Espacio"
	visible = false 
	
	# --- 🎵 MAGIA DE AUDIO ÉPICO AQUÍ 🎵 ---
	var sfx_zumbido = AudioStreamPlayer.new()
	sfx_zumbido.process_mode = Node.PROCESS_MODE_ALWAYS # Para que suene aunque el juego se pause
	sfx_zumbido.stream = load("res://Assets/sounds/STAB THE EARTH - zumbidochakana.mp3") 
	add_child(sfx_zumbido)
	sfx_zumbido.play()
	# --------------------------------------
	
	if sami_body is CharacterBody2D:
		sami_body.velocity = Vector2.ZERO # Congelamos a Sami
	
	Engine.time_scale = 0.2 
	
	canvas_poder = CanvasLayer.new()
	canvas_poder.layer = 150 
	get_tree().current_scene.add_child(canvas_poder)
	
	var screen_size = get_viewport_rect().size # Tomamos la medida exacta
	
	var fondo_blanco = ColorRect.new()
	fondo_blanco.color = Color(1, 1, 1, 0) 
	fondo_blanco.size = screen_size # Fuerza bruta al fondo
	canvas_poder.add_child(fondo_blanco)
	
	var vbox_textos = VBoxContainer.new()
	# ¡FUERZA BRUTA AL CONTENEDOR! Nada de anchors automáticos
	vbox_textos.size = screen_size
	vbox_textos.position = Vector2(0, 40)
	vbox_textos.alignment = VBoxContainer.ALIGNMENT_CENTER 
	vbox_textos.modulate.a = 0.0 
	vbox_textos.add_theme_constant_override("separation", 2) 
	fondo_blanco.add_child(vbox_textos)
	
	var settings_main = LabelSettings.new()
	settings_main.font = fuente_pixel
	settings_main.font_size = 16 
	settings_main.font_color = Color.BLACK
	
	var settings_sub = LabelSettings.new()
	settings_sub.font = fuente_pixel
	settings_sub.font_size = 12 
	settings_sub.font_color = Color.BLACK
	
	var label_poder = Label.new()
	label_poder.text = "¡Has unificado la Chakana!\nEl poder de la Pachamama\nfluye en ti." 
	label_poder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_poder.label_settings = settings_main
	vbox_textos.add_child(label_poder)
	
	var label_spaciador = Label.new()
	label_spaciador.text = "\n" 
	vbox_textos.add_child(label_spaciador)
	
	var label_instruccion = Label.new()
	label_instruccion.text = "Presiona 'Z' o 'J' para disparar."
	label_instruccion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_instruccion.label_settings = settings_sub
	vbox_textos.add_child(label_instruccion)
	
	var label_spaciador2 = Label.new()
	label_spaciador2.text = "\n\n\n" 
	vbox_textos.add_child(label_spaciador2)
	
	var label_continuar = Label.new()
	label_continuar.text = "- Presiona ENTER para continuar -"
	label_continuar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var settings_cont = LabelSettings.new()
	settings_cont.font = fuente_pixel
	settings_cont.font_size = 10 
	settings_cont.font_color = Color(0.2, 0.2, 0.2) 
	label_continuar.label_settings = settings_cont
	vbox_textos.add_child(label_continuar)
	
	var tween = create_tween()
	
	tween.tween_property(fondo_blanco, "color:a", 0.8, 0.1)
	tween.tween_property(fondo_blanco, "color:a", 0.2, 0.1)
	tween.tween_property(fondo_blanco, "color:a", 0.9, 0.1)
	tween.tween_property(fondo_blanco, "color:a", 1.0, 0.2) 
	
	tween.tween_callback(func():
		get_tree().paused = true
		Engine.time_scale = 1.0
	)
	
	tween.tween_interval(1.5)
	
	tween.tween_property(vbox_textos, "modulate:a", 1.0, 1.5)
	
	# ¡MAGIA! Solo cuando el texto ya está 100% visible, permitimos continuar
	tween.tween_callback(func():
		puede_continuar = true
	)

func _input(event):
	# Ahora exige que 'puede_continuar' sea true
	if en_cinematica and puede_continuar and event.is_action_pressed("ui_accept"):
		puede_continuar = false 
		terminar_cinematica()

func terminar_cinematica():
	var tween = create_tween()
	tween.tween_property(canvas_poder.get_child(0), "modulate:a", 0.0, 1.0)
	
	await tween.finished
	
	canvas_poder.queue_free() 
	get_tree().paused = false 
	queue_free()
