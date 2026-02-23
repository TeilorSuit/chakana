extends CharacterBody2D

@onready var jump_sound: AudioStreamPlayer2D = $jumpSound
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

const SPEED = 125.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
	if Data.en_dialogo:
		velocity.x = move_toward(velocity.x, 0, SPEED) # Frena si venía corriendo
		sprite_2d.animation = "idle"
		if not is_on_floor():
			velocity += get_gravity() * delta # Que caiga si estaba en el aire
		move_and_slide()
		return # Corta la función aquí para que no lea los inputs de salto/moverse
		
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor() and not Data.cerca_de_npc:
		velocity.y = JUMP_VELOCITY
		jump_sound.play()
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5
	
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		sprite_2d.flip_h = (direction == -1.0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if not is_on_floor():
		sprite_2d.animation = "jump"
	elif direction:
		sprite_2d.animation = "walk"
	else:
		sprite_2d.animation = "idle"
	
	move_and_slide()
	
	# EMPUJAR CAJAS
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var box = collision.get_collider()
	
		if box is RigidBody2D:
			# --- BLOQUEO DEL MUNDO 3 ---
			if "CajaEmpujable" in box.name and not Data.hablado_anciano_m3:
				continue
			# ----------------------------------
			
		# Solo empujar si el jugador se mueve
			if abs(direction) == 0:
				continue
		
			var normal = collision.get_normal()
		
		# Ignorar choques verticales (caer encima)
			if abs(normal.y) > 0.6:
				continue
		
			var push_speed = 100.0
		
		# Empuje horizontal controlado
			var push_velocity = Vector2(direction * push_speed, box.linear_velocity.y)
		
		# Límite de velocidad
			if abs(box.linear_velocity.x) < push_speed:
				box.linear_velocity = push_velocity
