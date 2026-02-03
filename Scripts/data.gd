extends Node

signal chakanas_updated(new_amount) 
signal door_unlocked(door_id)

var chakana_parts : int = 0
var rocas_coleccionadas : int = 0
var required_parts_to_open : int = 1
var piedras_recolectadas : int = 0

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
