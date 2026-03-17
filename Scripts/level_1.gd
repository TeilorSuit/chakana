extends Node2D

@onready var texto_moverse = $LabelMoverse 
@onready var texto_saltar = $LabelSaltar 

func _ready():
	# 1. Al arrancar, volvemos ambos textos del tutorial totalmente invisibles
	texto_moverse.modulate.a = 0.0
	texto_saltar.modulate.a = 0.0
	
	# Guardamos el progreso apenas el jugador pisa el Nivel 1
	Data.intro_vista = true 
	Data.guardar_partida("res://Scenes/level1.tscn")
	
	# 2. Hacemos que el texto de moverse aparezca suavemente (Fade in)
	var tween_moverse = create_tween()
	tween_moverse.tween_property(texto_moverse, "modulate:a", 1.0, 2.5)

# 3. Función conectada a la señal 'body_entered' de tu Area2D de los pinchos
func _on_zona_tutorial_salto_body_entered(body):
	if body.is_in_group("Player") and texto_saltar.modulate.a == 0.0:
		var tween_saltar = create_tween()
		tween_saltar.tween_property(texto_saltar, "modulate:a", 1.0, 1.0)
