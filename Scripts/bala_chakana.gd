extends Area2D

const SPEED = 800.0 
var direction := 1 

# 1. Exportamos la escena del impacto para poder arrastrarla en el editor
@export var impacto_scene : PackedScene

func _ready() -> void:
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)
	body_entered.connect(_on_body_entered)
	
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("default")

func _physics_process(delta: float) -> void:
	position.x += SPEED * direction * delta

func _on_screen_exited() -> void:
	queue_free() 

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jefe"):
		if body.has_method("recibir_dano"):
			body.recibir_dano(1) 
			
		# 2. Invocamos la explosión si la tenemos asignada
		if impacto_scene:
			var impacto = impacto_scene.instantiate()
			# El impacto nace exactamente donde estaba la bala al momento de chocar
			impacto.global_position = global_position 
			get_tree().current_scene.add_child(impacto)
			
		queue_free() 
		
	elif body is TileMap or body is StaticBody2D: 
		queue_free() # Contra la pared desaparece sin explosión
