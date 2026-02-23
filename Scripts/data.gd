extends Node

signal chakanas_updated(new_amount) 
signal door_unlocked(door_id)
var cerca_de_npc : bool = false

var chakana_parts : int = 0
var rocas_coleccionadas : int = 0
var required_parts_to_open : int = 1
var piedras_recolectadas : int = 0

# --- VARIABLES MUNDO 1 ---
var en_dialogo : bool = false
var hablado_anciano_m1 : bool = false
var leyo_cartel_balanza : bool = false
var puzzle_resuelto : bool = false

# --- VARIABLES MUNDO 2 ---
var hablado_anciano_m2 : bool = false
var tiene_fruto_yaku : bool = false
var entrego_fruto_m2 : bool = false

# Señal o función para spawnear la Chakana del mundo 2
signal aparecer_chakana_m2

func dar_chakana_recompensa():
	aparecer_chakana_m2.emit()
	
	# --- VARIABLES MUNDO 3 ---
var hablado_anciano_m3 : bool = false
var puzzle_cajas_resuelto : bool = false


func add_chakana():
	chakana_parts += 1
	chakanas_updated.emit(chakana_parts)
	if chakana_parts >= required_parts_to_open:
		door_unlocked.emit(99)
		required_parts_to_open += 1
		
func agregar_roca():
	rocas_coleccionadas += 1
	
func add_piedras():
	piedras_recolectadas += 1
