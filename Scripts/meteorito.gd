extends Area2D

var velocidad = 300.0

func _ready():
	# Conectamos para dañar al jugador
	body_entered.connect(_on_body_entered)
	# Se destruye solo a los 4 segundos para no laggear el juego
	get_tree().create_timer(4.0).timeout.connect(queue_free)

func _physics_process(delta):
	position.y += velocidad * delta # Cae hacia abajo

func _on_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		if body.has_method("recibir_dano_meteorito"):
			body.recibir_dano_meteorito()
		queue_free()
	elif body is TileMap or body is StaticBody2D:
		queue_free()
