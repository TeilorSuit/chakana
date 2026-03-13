extends CharacterBody2D

@onready var jump_sound: AudioStreamPlayer2D = $jumpSound
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var daño_flash = $Camera2D/DañoFlash
@export var bala_scene : PackedScene
@onready var disparo_sound: AudioStreamPlayer2D = $DisparoSound
@onready var hit_sound: AudioStreamPlayer2D = $HitSound
@onready var pasos_sound: AudioStreamPlayer2D = $PasosSound

const SPEED = 125.0
var jump_velocity = -400.0 
var en_game_over = false

var vidas_jefe = 3
var is_invulnerable = false 
var facing_right = true 

var can_shoot = true
var fire_rate = 0.25 

func _ready():
	add_to_group("Player")
	# Verificamos en qué nivel estamos para cargar el paso correcto
	var nombre_escena = get_tree().current_scene.name.to_lower()
	
	if "level1" in nombre_escena:
		pasos_sound.stream = load("res://Assets/sounds/pasos lvl1.wav") # Cambia a .mp3 si los convertiste
	elif "level2" in nombre_escena:
		pasos_sound.stream = load("res://Assets/sounds/pasos lvl2.wav")
	elif "level3" in nombre_escena:
		pasos_sound.stream = load("res://Assets/sounds/pasos lvl3.wav")

func _physics_process(delta: float) -> void:
	# VALIDACIÓN MAESTRA: Si hay diálogo o pregunta, Sami se congela
	if Data.en_dialogo or Data.en_pregunta:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		sprite_2d.animation = "idle"
		if pasos_sound.playing:      
			pasos_sound.stop()       
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# --- AQUÍ ESTÁ LA CORRECCIÓN: Quitamos el 'not Data.cerca_de_npc' ---
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity 
		jump_sound.play()
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5
	
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		facing_right = (direction == 1.0)
		sprite_2d.flip_h = not facing_right 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("ataque") and Data.chakana_parts >= 3: 
		disparar()

	if not is_on_floor():
		sprite_2d.animation = "jump"
		pasos_sound.stop() # Si está en el aire, no hay sonido de pasos
	elif direction:
		sprite_2d.animation = "walk"
		if not pasos_sound.playing:
			pasos_sound.play() # Reproduce los pasos si está caminando
	else:
		sprite_2d.animation = "idle"
		pasos_sound.stop() # Si se queda quieto, apaga los pasos
	
	move_and_slide()
	
	# Empujar cajas
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var box = collision.get_collider()
		if box is RigidBody2D:
			if "CajaEmpujable" in box.name and not Data.hablado_anciano_m3: continue
			if abs(direction) == 0: continue
			var normal = collision.get_normal()
			if abs(normal.y) > 0.6: continue
			var push_speed = 100.0
			var push_velocity = Vector2(direction * push_speed, box.linear_velocity.y)
			if abs(box.linear_velocity.x) < push_speed:
				box.linear_velocity = push_velocity

func disparar():
	if Data.en_dialogo or Data.en_pregunta: return
	
	if not can_shoot or not bala_scene: return
	
	can_shoot = false 
	disparo_sound.play()
	
	sprite_2d.modulate = Color(2, 2, 0) 
	get_tree().create_timer(0.05).timeout.connect(func(): sprite_2d.modulate = Color(1, 1, 1))

	var nueva_bala = bala_scene.instantiate()
	if facing_right:
		nueva_bala.direction = 1
		nueva_bala.position = global_position + Vector2(15, 0) 
	else:
		nueva_bala.direction = -1
		nueva_bala.position = global_position + Vector2(-15, 0) 
		if nueva_bala.has_node("AnimatedSprite2D"):
			nueva_bala.get_node("AnimatedSprite2D").flip_h = true 
			
	get_parent().add_child(nueva_bala) 
	
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func recibir_dano_jefe():
	if is_invulnerable:
		return
		
	vidas_jefe -= 1 
	hit_sound.play()
	print("Sami recibió daño. Vidas restantes: ", vidas_jefe)
	
	var ui = get_tree().current_scene.get_node_or_null("%UIJefe")
	if ui:
		ui.actualizar_corazones(vidas_jefe)
	
	if vidas_jefe <= 0:
		morir_animacion(true)
	else:
		is_invulnerable = true
		if daño_flash:
			daño_flash.color.a = 0.4
			await get_tree().create_timer(0.1).timeout
			daño_flash.color.a = 0.0
			await get_tree().create_timer(0.1).timeout
			daño_flash.color.a = 0.4
			await get_tree().create_timer(0.1).timeout
			daño_flash.color.a = 0.0
			
		await get_tree().create_timer(1.2).timeout
		is_invulnerable = false

func recibir_dano_meteorito():
	if is_invulnerable:
		return
		
	vidas_jefe -= 1 
	hit_sound.play()
	print("Sami recibió daño por meteorito. Vidas restantes: ", vidas_jefe)
	
	var ui = get_tree().current_scene.get_node_or_null("%UIJefe")
	if ui:
		ui.actualizar_corazones(vidas_jefe)
	
	if vidas_jefe <= 0:
		morir_animacion(true)
	else:
		is_invulnerable = true
		
		if daño_flash:
			for i in range(4): 
				daño_flash.color.a = 0.4
				await get_tree().create_timer(0.125).timeout
				daño_flash.color.a = 0.0
				await get_tree().create_timer(0.125).timeout
		else:
			await get_tree().create_timer(1.0).timeout 
			
		is_invulnerable = false
		
func morir():
	print("Game Over en el Jefe. Reapareciendo y reseteando arena...")
	vidas_jefe = 3 
	
	Data.en_pregunta = false 
	Data.en_dialogo = false
	
	var ui = get_tree().current_scene.get_node_or_null("%UIJefe")
	if ui:
		ui.actualizar_corazones(vidas_jefe)
	
	activar_super_salto(false)
	
	var punto_respawn = get_tree().current_scene.get_node_or_null("%PuntoRespawnJefe")
	if punto_respawn:
		global_position = punto_respawn.global_position
		
	var muro_izq = get_tree().current_scene.get_node_or_null("%MuroIzq/CollisionShape2D")
	if muro_izq:
		muro_izq.set_deferred("disabled", true)
		
	var trigger = get_tree().current_scene.get_node_or_null("%TriggerJefe")
	if trigger:
		trigger.dialogo_iniciado = false
		get_tree().create_timer(0.5).timeout.connect(func(): trigger.set_deferred("monitoring", true))
		
	Engine.time_scale = 1.0 
	
	var jefe = get_tree().get_first_node_in_group("Jefe")
	if jefe and jefe.has_method("resetear_batalla"):
		jefe.resetear_batalla()
		
	if has_node("Camera2D"):
		get_node("Camera2D").make_current()

func activar_super_salto(activado: bool):
	if activado:
		jump_velocity = -550.0
	else:
		jump_velocity = -400.0 

func sacudir_camara(fuerza: float, duracion: float):
	if not has_node("Camera2D"): return
	var camara = $Camera2D
	
	var tween = create_tween()
	var pasos = int(duracion / 0.05)
	
	for i in range(pasos):
		var y_random = randf_range(-fuerza, fuerza)
		tween.tween_property(camara, "offset", Vector2(0, y_random), 0.05)
		
	tween.tween_property(camara, "offset", Vector2.ZERO, 0.05)

func morir_animacion(es_jefe: bool = false):
	if en_game_over: return 
	en_game_over = true
	
	velocity = Vector2.ZERO
	set_physics_process(false) 
	
	var canvas_muerte = CanvasLayer.new()
	canvas_muerte.layer = 200 
	get_tree().current_scene.add_child(canvas_muerte)
	
	var fondo_negro = ColorRect.new()
	fondo_negro.color = Color(0, 0, 0, 0)
	fondo_negro.size = get_viewport_rect().size
	canvas_muerte.add_child(fondo_negro)
	
	var mensajes = [
		"Levántate, pequeña semilla...",
		"La Pachamama aún confía en ti.",
		"El equilibrio requiere paciencia.",
		"No temas a la oscuridad, Sami.",
		"Cada caída te hace más fuerte."
	]
	var mensaje_elegido = mensajes[randi() % mensajes.size()]
	
	var texto_muerte = Label.new()
	texto_muerte.text = mensaje_elegido
	texto_muerte.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto_muerte.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto_muerte.size = get_viewport_rect().size
	texto_muerte.position = Vector2.ZERO
	texto_muerte.modulate.a = 0.0
	
	var fuente_pixel = preload("res://Assets/m5x7.ttf")
	var ajustes = LabelSettings.new()
	ajustes.font = fuente_pixel
	ajustes.font_size = 16 
	ajustes.font_color = Color.WHITE
	texto_muerte.label_settings = ajustes
	fondo_negro.add_child(texto_muerte)
	
	var tween = create_tween()
	tween.tween_property(fondo_negro, "color:a", 1.0, 0.5)
	tween.tween_property(texto_muerte, "modulate:a", 1.0, 1.0)
	tween.tween_interval(2.0)
	
	if es_jefe:
		tween.tween_callback(func():
			morir() 
		)
		tween.tween_property(fondo_negro, "modulate:a", 0.0, 0.5)
		tween.tween_property(texto_muerte, "modulate:a", 0.0, 0.5)
		tween.tween_callback(func():
			set_physics_process(true) 
			en_game_over = false
			canvas_muerte.queue_free()
		)
	else:
		tween.tween_callback(func():
			get_tree().reload_current_scene()
		)
