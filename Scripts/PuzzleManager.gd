extends Node2D

@export var puerta_id : int = 53

# Referencias a las PLACAS
var placa_sol_lista = false
var placa_luna_lista = false
var placa_normal_lista = false

# Referencias a las CAJAS 
@onready var caja_sol = $CajaEmpujableSol
@onready var caja_luna = $CajaEmpujableLuna
@onready var caja_normal = $CajaEmpujable
@onready var palanca: Area2D = $palancaHorizontal


# Posiciones iniciales para el Reset
var pos_inicial_sol
var pos_inicial_luna
var pos_inicial_normal

func _ready():
	# Guardamos dónde empezaron las cajas
	pos_inicial_sol = caja_sol.global_position
	pos_inicial_luna = caja_luna.global_position
	pos_inicial_normal = caja_normal.global_position

func _on_placa_sol_estado_cambiado(activa):
	placa_sol_lista = activa
	verificar_victoria()

func _on_placa_luna_estado_cambiado(activa):
	placa_luna_lista = activa
	verificar_victoria()
	
func _on_placa_normal_estado_cambiado(activa):
	placa_normal_lista = activa
	verificar_victoria()
	
func verificar_victoria():
	if Data.puzzle_cajas_resuelto:
		return
		
	if placa_sol_lista and placa_luna_lista and placa_normal_lista:
		print("¡PUZZLE RESUELTO!")
		Data.door_unlocked.emit(puerta_id)
		Data.puzzle_cajas_resuelto = true

# --- FUNCIÓN DE RESET ROBUSTA ---
func _on_palanca_reset_activada():
	print("Reseteando posiciones de forma segura...")
	
	resetear_caja_segura(caja_sol, pos_inicial_sol)
	resetear_caja_segura(caja_luna, pos_inicial_luna)
	resetear_caja_segura(caja_normal, pos_inicial_normal)
	
	# 4. RESETEAR LA PALANCA VISUALMENTE
	if has_node("Palanca"): 
		$Palanca.resetear()
	elif has_node("palancaHorizontal"): 
		$palancaHorizontal.resetear()
	
	placa_sol_lista = false
	placa_luna_lista = false
	placa_normal_lista = false

func resetear_caja_segura(caja: RigidBody2D, destino: Vector2):
	if not caja:
		return
	
	# 1. Congelar el nodo para que deje de calcularse
	caja.freeze = true
	caja.linear_velocity = Vector2.ZERO
	caja.angular_velocity = 0
	
	# 2. Ordenar al Servidor de Físicas directamente
	PhysicsServer2D.body_set_state(
		caja.get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		Transform2D(0.0, destino) 
	)
	
	# resetear la velocidad en el servidor
	PhysicsServer2D.body_set_state(
		caja.get_rid(),
		PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY,
		Vector2.ZERO
	)
	
	# 3. Esperar DOS frames de física para asegurar que el servidor actualice
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# 4. Descongelar
	caja.freeze = false
	
	print("¡Caja forzada a: ", destino, "!")
