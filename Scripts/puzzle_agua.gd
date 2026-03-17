extends Node2D 

@onready var agua1 = $waterLeft
@onready var agua2 = $waterMid
@onready var agua3 = $waterRight
@onready var palanca_izq: Area2D = $palancaVertical
@onready var palanca_centro: Area2D = $palancaVertical2
@onready var palanca_der: Area2D = $palancaVertical3

@export var puerta_id : int = 51

var paso_actual = 0

func _ready():
	resetear_puzzle()
	
	
func _on_palanca_2_activada():
	if paso_actual == 0: 
		agua2.visible = true
		paso_actual = 1
	else:
		resetear_puzzle()

func _on_palanca_3_activada():
	if paso_actual == 1: 
		agua3.visible = true
		paso_actual = 2
	else:
		resetear_puzzle()
		
func _on_palanca_1_activada():
	if paso_actual == 2: 
		agua1.visible = true
		Data.door_unlocked.emit(puerta_id)
	else:
		resetear_puzzle()
		
# --- LA FUNCIÓN DE CASTIGO ---
func resetear_puzzle():
	# 1. Volver contador a 0
	paso_actual = 0
	
	# 2. Esconder toda el agua
	agua1.visible = false
	agua2.visible = false
	agua3.visible = false
	
	# 3. Decirle a las palancas que se levanten (Llamamos a la función nueva del Paso 1)
	palanca_izq.resetear()
	palanca_centro.resetear()
	palanca_der.resetear()
