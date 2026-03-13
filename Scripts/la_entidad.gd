extends CharacterBody2D

enum State {IDLE, DROP, PRE_SPIN, SPIN, RISE, BURST, QUESTION, SLEEP_DROP, SLEEP, DEAD, METEOR_HELL}
var current_state = State.IDLE
var activado = false

var max_health = 30
var health = 30
var speed = 100.0
var move_dir = 1
var wall_hits = 0 

@onready var anim = $AnimatedSprite2D
@onready var sfx_caida = get_node_or_null("SfxCaida")
@onready var sfx_muerte = get_node_or_null("SfxMuerte")
@onready var sfx_spin = get_node_or_null("SfxSpin")
@onready var sfx_dano = get_node_or_null("SfxDano")
@onready var sfx_meteorito = get_node_or_null("SfxMeteorito")

@export var musica_jefe : AudioStreamPlayer 
@export var meteorito_scene : PackedScene 

var question_timer = 0.0
var time_to_question = 10.0 
var original_y = 0.0 
var castigo_timer = 0.0 
var shake_tween : Tween # Seguro para la cámara

func _ready():
	add_to_group("Jefe") 
	anim.play("iddle") 
	original_y = global_position.y 
	time_to_question = randf_range(8.0, 12.0)

	var sami = get_tree().get_first_node_in_group("Player")
	if sami: add_collision_exception_with(sami)

func _physics_process(delta):
	if not activado or current_state in [State.DEAD, State.QUESTION, State.SLEEP, State.BURST, State.PRE_SPIN]:
		return
		
	if current_state == State.METEOR_HELL:
		velocity = Vector2.ZERO 
		
		castigo_timer -= delta
		if castigo_timer <= 0:
			castigo_timer = 0.15 
			spawn_meteorito()
			spawn_meteorito()
			sacudir_camara_activa(3.0, 0.15)
							
		question_timer += delta
		if question_timer >= 5.0: 
			question_timer = 0.0
			anim.modulate = Color(1, 1, 1) 
			time_to_question = randf_range(8.0, 12.0) 
			cambiar_estado(State.IDLE)
		return
		
	elif current_state == State.SLEEP_DROP:
		velocity.x = 0
		velocity.y += 800.0 * delta 
		move_and_slide()
		if is_on_floor():
			if sfx_caida: sfx_caida.play()
			cambiar_estado(State.SLEEP)
		return
		
	if current_state == State.IDLE:
		velocity.x = speed * move_dir
		velocity.y = 0
		move_and_slide()
		
		question_timer += delta
		if question_timer >= time_to_question:
			question_timer = 0.0
			time_to_question = randf_range(8.0, 12.0)
			preparar_pregunta()
			return 
		
		if is_on_wall():
			move_dir *= -1
			wall_hits += 1
			anim.flip_h = (move_dir == -1)
			
			if wall_hits >= 4:
				cambiar_estado(State.DROP)
			elif randf() < 0.25: 
				cambiar_estado(State.DROP)
				
	elif current_state == State.DROP:
		velocity.x = 0
		velocity.y += 800.0 * delta 
		move_and_slide()
		if is_on_floor(): 
			sacudir_camara_activa(10.0, 0.3)
			cambiar_estado(State.PRE_SPIN)
			
	elif current_state == State.SPIN:
		velocity.x = (speed * 2.0) * move_dir 
		velocity.y = 0
		move_and_slide()
		
		if is_on_wall():
			move_dir *= -1
			wall_hits = 0 
			anim.flip_h = (move_dir == -1)
			cambiar_estado(State.RISE)
			
	elif current_state == State.RISE:
		velocity.x = 0
		velocity.y = -150
		move_and_slide()
		
		if global_position.y <= original_y:
			global_position.y = original_y 
			cambiar_estado(State.IDLE)

func cambiar_estado(nuevo_estado):
	current_state = nuevo_estado
	if current_state == State.IDLE: 
		anim.play("iddle")
	elif current_state == State.DROP: 
		anim.play("iddle") 
	elif current_state == State.PRE_SPIN:
		anim.play("iddle") 
		velocity = Vector2.ZERO 
		await get_tree().create_timer(0.5).timeout 
		cambiar_estado(State.SPIN)
	elif current_state == State.SPIN: 
		anim.play("spin")
		if sfx_spin: sfx_spin.play(1.0) 
	elif current_state == State.RISE: 
		anim.play("iddle")
		if sfx_spin: sfx_spin.stop() 
	elif current_state == State.METEOR_HELL:
		anim.play("burst")
		anim.modulate = Color(0, 2, 0) 
	elif current_state == State.SLEEP_DROP:
		anim.play("down")
	elif current_state == State.SLEEP:
		anim.play("sleep")
		iniciar_temporizador_sueño()

func iniciar_temporizador_sueño():
	await get_tree().create_timer(3.0).timeout
	if current_state == State.SLEEP: 
		cambiar_estado(State.RISE)

func preparar_pregunta():
	current_state = State.BURST
	velocity = Vector2.ZERO 
	anim.play("burst")
	
	await get_tree().create_timer(1.5).timeout
	
	current_state = State.QUESTION
	Engine.time_scale = 0.05
	if musica_jefe: musica_jefe.pitch_scale = 0.5 
	
	var ui = get_tree().current_scene.get_node_or_null("%UIJefe")
	if ui: ui.mostrar_pregunta()

func spawn_meteorito():
	if meteorito_scene:
		var met = meteorito_scene.instantiate()
		var sami = get_tree().get_first_node_in_group("Player")
		var target_x = global_position.x
		
		if sami and randf() > 0.5: 
			target_x = sami.global_position.x
		else: 
			target_x += randf_range(-150, 150)
			
		met.global_position = Vector2(target_x, global_position.y - 100) 
		get_tree().current_scene.add_child(met)
		
		if sfx_meteorito and not sfx_meteorito.playing:
			sfx_meteorito.play(0.05)

func respuesta_correcta():
	Engine.time_scale = 1.0 
	if musica_jefe: musica_jefe.pitch_scale = 1.0
	cambiar_estado(State.SLEEP_DROP) 

func respuesta_incorrecta():
	Engine.time_scale = 1.0
	if musica_jefe: musica_jefe.pitch_scale = 1.0
	
	question_timer = 0.0
	castigo_timer = 0.0 
	cambiar_estado(State.METEOR_HELL)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if current_state not in [State.SLEEP, State.DEAD]:
			if body.has_method("recibir_dano_jefe"):
				body.recibir_dano_jefe()

func activar_jefe():
	activado = true
	original_y = global_position.y
	wall_hits = 0 
	question_timer = 0.0
	time_to_question = randf_range(8.0, 12.0)
	
	health = max_health 
	
	var ui = get_tree().current_scene.get_node_or_null("%UIJefe")
	if ui: ui.iniciar_batalla_ui(max_health)
	
	var musica_nivel = get_tree().current_scene.get_node_or_null("MusicaFondo")
	if musica_nivel:
		musica_nivel.stop()
		
	if musica_jefe:
		musica_jefe.play()

func recibir_dano(cantidad):
	if current_state != State.SLEEP: return 
		
	health -= cantidad
	if sfx_dano: sfx_dano.play() 
	
	var ui = get_tree().current_scene.get_node_or_null("%UIJefe")
	if ui: ui.actualizar_vida_jefe(health)
	
	anim.modulate = Color(10, 0, 0) # Destello rojo
	await get_tree().create_timer(0.05).timeout
	anim.modulate = Color(1, 1, 1) 
	
	if health <= 0: morir()

func morir():
	if sfx_muerte: sfx_muerte.play() 
	if sfx_spin: sfx_spin.stop()   
	current_state = State.DEAD
	velocity = Vector2.ZERO
	
	var ui = get_tree().current_scene.get_node_or_null("%UIJefe")
	if ui: ui.ocultar_ui_victoria()
	
	if musica_jefe:
		var tween_musica = create_tween()
		tween_musica.tween_property(musica_jefe, "volume_db", -80.0, 3.0)
		tween_musica.tween_callback(func(): musica_jefe.stop())
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(anim, "modulate", Color(50, 50, 50), 1.5) 
	tween.tween_property(anim, "scale", Vector2(2.0, 2.0), 2.0)
	tween.tween_property(anim, "modulate:a", 0.0, 2.0)
	
	for i in range(20):
		anim.position = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		await get_tree().create_timer(0.1, true, false, true).timeout
	
	print("¡LA ENTIDAD HA SIDO PURIFICADA!")
	
	var canvas_fade = CanvasLayer.new()
	canvas_fade.layer = 150 
	get_tree().current_scene.add_child(canvas_fade)
	
	var fondo_negro = ColorRect.new()
	fondo_negro.color = Color(0, 0, 0, 0) 
	fondo_negro.size = get_viewport_rect().size 
	canvas_fade.add_child(fondo_negro)
	
	var tween_fade = create_tween()
	tween_fade.tween_property(fondo_negro, "color:a", 1.0, 2.5) 
	
	await tween_fade.finished 
	get_tree().change_scene_to_file("res://Scenes/pantalla_victoria.tscn")
	
func resetear_batalla():
	if sfx_spin: sfx_spin.stop() 
	activado = false
	global_position.y = original_y
	
	health = max_health 
	wall_hits = 0 
	question_timer = 0.0 
	castigo_timer = 0.0 
	Engine.time_scale = 1.0 
	
	anim.modulate = Color(1, 1, 1) 
	
	if musica_jefe: 
		musica_jefe.stop()
		musica_jefe.pitch_scale = 1.0
		
	var musica_nivel = get_tree().current_scene.get_node_or_null("MusicaFondo")
	if musica_nivel and not musica_nivel.playing:
		musica_nivel.play()
	
	cambiar_estado(State.IDLE)
	
	var ui = get_tree().current_scene.get_node_or_null("%UIJefe")
	if ui: 
		ui.corazones_box.visible = false
		ui.barra_vida_jefe.visible = false
		ui.nombre_jefe.visible = false
		ui.caja_pregunta.visible = false 
		ui.filtro_sepia.visible = false

func sacudir_camara_activa(fuerza: float, duracion: float):
	var camara = get_viewport().get_camera_2d()
	if not camara: return
	
	# --- SEGURO ANTI-MAREO INFINITO ---
	if shake_tween and shake_tween.is_valid():
		shake_tween.kill() # Mata el temblor anterior antes de empezar uno nuevo
	
	shake_tween = create_tween()
	var pasos = int(duracion / 0.05)
	
	for i in range(pasos):
		var y_random = randf_range(-fuerza, fuerza)
		shake_tween.tween_property(camara, "offset", Vector2(0, y_random), 0.05)
		
	shake_tween.tween_property(camara, "offset", Vector2.ZERO, 0.05)
