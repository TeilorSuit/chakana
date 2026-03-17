extends Area2D

@export var part_texture : Texture2D 
@export var id_unico : String = "chakana_default" 

@onready var sprite : Sprite2D = $Sprite2D 

var escena_cinematica = preload("res://Scenes/cinematica_poder.tscn") 

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if id_unico in Data.chakanas_recogidas:
		queue_free()
		return
		
	if part_texture:
		sprite.texture = part_texture

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if not id_unico in Data.chakanas_recogidas:
			Data.add_chakana(id_unico)
			
			if Data.chakana_parts == 3:
				iniciar_cinematica_poder(body)
			else:
				queue_free()

func iniciar_cinematica_poder(sami_body):
	visible = false 
	
	if sami_body is CharacterBody2D:
		sami_body.velocity = Vector2.ZERO 
	
	Engine.time_scale = 0.2 
	
	var cinematica = escena_cinematica.instantiate()
	get_tree().current_scene.add_child(cinematica)
	
	await get_tree().create_timer(1.0).timeout
	queue_free()
