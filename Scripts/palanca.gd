extends Area2D

signal palanca_activada

@onready var sprite = $Sprite2D
@export var textura_apagada : Texture2D
@export var textura_encendida : Texture2D

var esta_activa = false

func _on_body_entered(body):
	if body.name == "Player" and not esta_activa:
		activar()

func activar():
	esta_activa = true
	sprite.texture = textura_encendida
	emit_signal("palanca_activada")

func resetear():
	esta_activa = false
	sprite.texture = textura_apagada
