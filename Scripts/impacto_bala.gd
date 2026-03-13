# impacto_bala.gd
extends AnimatedSprite2D

func _ready():
	top_level = true 
	play("default")
	get_tree().create_timer(0.5).timeout.connect(queue_free)

func _on_animation_finished():
	queue_free()
