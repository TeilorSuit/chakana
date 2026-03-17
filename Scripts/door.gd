extends StaticBody2D

@export var my_door_id : int = 0

@onready var anim_player = $AnimationPlayer
@onready var collision = $CollisionShape2D
@onready var audio_puerta = $AudioPuerta

func _ready():
	if Data.has_signal("door_unlocked"):
		Data.door_unlocked.connect(open_door)
	else:
		print("Error: No se encuentra la señal door_unlocked en Data")

func open_door(id_received):
	if id_received != my_door_id:
		return

	print("¡Puerta ", my_door_id, " activada!")
	
	if anim_player.has_animation("abrir"):
		audio_puerta.play()
		anim_player.play("abrir")
	else:
		print("ERROR: No existe la animación 'abrir'. Revisa el nombre en el AnimationPlayer.")

func desactivar_fisica():
	collision.set_deferred("disabled", true)
