extends Control

@onready var texto = $Label
@onready var sfx = $AudioStreamPlayer
@onready var flash = $ColorRect2  

func _ready():
	texto.visible_characters = 0
	flash.modulate.a = 0.0  
	reproducir_cinematica()

func reproducir_cinematica():
	await get_tree().create_timer(1.0).timeout
	
	var total_letras = texto.text.length()
	for i in range(total_letras):
		texto.visible_characters += 1
		var letra = texto.text[i]
		
		if letra not in [" ", "\n"] and sfx.stream != null:
			sfx.stop()
			sfx.pitch_scale = randf_range(0.9, 1.1)
			sfx.play()
		
		if letra == ".":
			sfx.stop()
			await get_tree().create_timer(0.4).timeout
		elif letra == "\n":
			sfx.stop()
			await get_tree().create_timer(1.0).timeout
		else:
			await get_tree().create_timer(0.06).timeout
			sfx.stop()
	
	sfx.stop()
	await get_tree().create_timer(3.0).timeout
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 1.0, 1.5) 
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://Scenes/level1.tscn")
	)
