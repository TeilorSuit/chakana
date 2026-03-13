extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Data.guardar_partida("res://Scenes/level1.tscn")
# Revisamos si es la primera vez que abrimos el juego
	if not Data.intro_vista:
		Data.intro_vista = true # Marcamos que ya la vio
		mostrar_mensaje_pachamama()

# Pegar esta función al final de tu script level_1.gd
func mostrar_mensaje_pachamama():
	var canvas_intro = CanvasLayer.new()
	canvas_intro.layer = 150
	canvas_intro.process_mode = Node.PROCESS_MODE_ALWAYS 
	add_child(canvas_intro)
	
	get_tree().paused = true 
	
	var fondo_negro = ColorRect.new()
	fondo_negro.color = Color.BLACK
	fondo_negro.size = get_viewport_rect().size 
	canvas_intro.add_child(fondo_negro)
	
	var texto_misterioso = Label.new()
	texto_misterioso.text = "Despierta, pequeña semilla...\n\nEl equilibrio se ha quebrado.\n\nPor favor... sálvalos a todos."
	texto_misterioso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto_misterioso.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto_misterioso.size = get_viewport_rect().size
	texto_misterioso.position = Vector2.ZERO
	
	# Empezamos con 0 caracteres visibles
	texto_misterioso.visible_characters = 0 
	
	var fuente_pixel = preload("res://Assets/m5x7.ttf")
	var ajustes = LabelSettings.new()
	ajustes.font = fuente_pixel
	ajustes.font_size = 16 
	ajustes.font_color = Color.WHITE
	texto_misterioso.label_settings = ajustes
	fondo_negro.add_child(texto_misterioso)
	
	# --- SISTEMA DE AUDIO UNDERTALE ---
	var sfx_voz = AudioStreamPlayer.new()
	# ¡OJO AQUÍ PARA MAÑANA! Cuando consigas tu ruidito (un .wav o .ogg corto), quítale el '#' a la línea de abajo y pon tu ruta:
	# sfx_voz.stream = load("res://Assets/Sounds/blip.ogg") 
	canvas_intro.add_child(sfx_voz)
	
	# 1. Espera inicial en negro (1 segundo). Los 'true' son para que ignore la pausa del juego.
	await get_tree().create_timer(1.0, true, false, true).timeout
	
	# 2. BUCLE TIPO MÁQUINA DE ESCRIBIR
	var texto_completo = texto_misterioso.text
	for i in range(texto_completo.length()):
		texto_misterioso.visible_characters += 1
		var letra_actual = texto_completo[i]
		
		# Reproducimos el "blip" solo si NO es un espacio o salto de línea, y si ya cargaste un sonido
		if letra_actual not in [" ", "\n"] and sfx_voz.stream != null:
			# Truco pro: variar un poquito el pitch hace que suene más orgánico y menos robótico
			sfx_voz.pitch_scale = randf_range(0.9, 1.1) 
			sfx_voz.play()
		
		# Tiempos de espera dinámicos
		if letra_actual == ".":
			await get_tree().create_timer(0.4, true, false, true).timeout # Pausa corta en los puntos suspensivos
		elif letra_actual == "\n":
			await get_tree().create_timer(1.0, true, false, true).timeout # Pausa de 1 segundo entre párrafos
		else:
			await get_tree().create_timer(0.06, true, false, true).timeout # Velocidad normal de las letras
			
	# 3. Pausa dramática cuando el texto ya está completo
	await get_tree().create_timer(3.0, true, false, true).timeout
	
	# 4. FADE OUT FINAL
	var tween = canvas_intro.create_tween()
	tween.tween_property(fondo_negro, "modulate:a", 0.0, 2.0)
	
	tween.tween_callback(func():
		get_tree().paused = false 
		canvas_intro.queue_free() 
	)
