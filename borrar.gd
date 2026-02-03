extends Node2D # Funciona si es CharacterBody2D, Area2D o Sprite

# Configura esto en el Inspector para ajustar sin tocar código
@export var distancia_patrulla : float = 200.0
@export var velocidad : float = 2.0

var x_inicial : float
var tiempo : float = 0.0

func _ready():
	# Guardamos dónde nació para que patrulle alrededor de ese punto
	x_inicial = global_position.x

func _process(delta):
	# --- MOVIMIENTO MATEMÁTICO (SENO) ---
	# Esto crea un movimiento suave de vaivén (ida y vuelta) infinito
	tiempo += delta * velocidad
	
	# Calculamos el desplazamiento: va de -200 a +200 px
	var desplazamiento = sin(tiempo) * distancia_patrulla
	
	# Aplicamos la posición
	global_position.x = x_inicial + desplazamiento
	
	# --- VOLTEAR EL SPRITE (Opcional) ---
	# Si cos(tiempo) es positivo, se mueve a la derecha -> Mirar derecha
	# Si es negativo, se mueve a la izquierda -> Mirar izquierda
	# (Si tu dibujo mira a la izquierda por defecto, invierte los signos abajo)
	if cos(tiempo) > 0:
		scale.x = abs(scale.x) # Mirar derecha
	else:
		scale.x = -abs(scale.x) # Mirar izquierda
