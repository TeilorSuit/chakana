extends Node

signal chakanas_updated(new_amount) 
signal door_unlocked(door_id)
var cerca_de_npc : bool = false

# --- NUEVO: Memoria de coleccionables ---
var chakanas_recogidas : Array = []

var chakana_parts : int = 0
var rocas_coleccionadas : int = 0
var required_parts_to_open : int = 1
var piedras_recolectadas : int = 0

# --- VARIABLES MUNDO 1 ---
var en_dialogo : bool = false
var hablado_anciano_m1 : bool = false
var leyo_cartel_balanza : bool = false
var puzzle_resuelto : bool = false
var intro_vista : bool = false

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
var jefe_visto : bool = false
var en_pregunta : bool = false

func add_chakana(id_chakana: String = ""):
	# Si la chakana tiene un ID y no está en la lista, la guardamos
	if id_chakana != "" and not id_chakana in chakanas_recogidas:
		chakanas_recogidas.append(id_chakana)
		
	chakana_parts += 1
	chakanas_updated.emit(chakana_parts)
	if chakana_parts >= required_parts_to_open:
		door_unlocked.emit(99)
		required_parts_to_open += 1
		
func agregar_roca():
	rocas_coleccionadas += 1
	
func add_piedras():
	piedras_recolectadas += 1


# --- SISTEMA DE GUARDADO ---
var save_path = "user://partida_sami.save"

func guardar_partida(ruta_nivel: String):
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	# Guardamos un diccionario con el nivel y las chakanas
	var data_guardada = {
		"nivel": ruta_nivel,
		"chakanas": chakanas_recogidas
	}
	file.store_var(data_guardada)
	print("Partida guardada en: ", ruta_nivel)

func cargar_partida() -> String:
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data_guardada = file.get_var()
		
		# Restauramos las chakanas recolectadas
		if data_guardada.has("chakanas"):
			chakanas_recogidas = data_guardada["chakanas"]
			chakana_parts = chakanas_recogidas.size()
			
		return data_guardada["nivel"]
	else:
		return "res://Scenes/level1.tscn" # Si no hay partida, va al nivel 1

func borrar_partida():
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
	
	# Reseteamos todo a cero
	chakanas_recogidas.clear()
	chakana_parts = 0
	hablado_anciano_m1 = false
	hablado_anciano_m2 = false
	tiene_fruto_yaku = false
	entrego_fruto_m2 = false
	hablado_anciano_m3 = false
	puzzle_cajas_resuelto = false

func resetear_variables_del_nivel(ruta_nivel: String):
	# Limpia solo el mundo actual por si te saliste a la mitad
	if ruta_nivel == "res://Scenes/level2.tscn":
		hablado_anciano_m2 = false
		tiene_fruto_yaku = false
		entrego_fruto_m2 = false
		chakanas_recogidas.erase("chakana_nv2") # Te quita la chakana del nivel 2 para que la vuelvas a agarrar
	elif ruta_nivel == "res://Scenes/level3.tscn":
		hablado_anciano_m3 = false
		puzzle_cajas_resuelto = false
		en_pregunta = false
		chakanas_recogidas.erase("chakana_nv3")
		
	chakana_parts = chakanas_recogidas.size()
