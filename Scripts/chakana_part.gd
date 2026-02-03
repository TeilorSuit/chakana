extends Area2D

@export var part_texture : Texture2D 
@onready var sprite : Sprite2D = $Sprite2D 

func _ready():
	if part_texture:
		sprite.texture = part_texture

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Data.add_chakana()
		queue_free()
