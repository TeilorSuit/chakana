extends CanvasLayer

@onready var filtro_sepia = $FiltroSepia
@onready var caja_pregunta = $CajaPregunta
@onready var corazones_box = $CorazonesBox
@onready var barra_vida_jefe = $BarraVidaJefe
@onready var nombre_jefe = $NombreJefe

@onready var texto_pregunta = $CajaPregunta/TextoPregunta
@onready var tiempo_label = $CajaPregunta/TiempoLabel
@onready var opciones_labels = [
	$CajaPregunta/VBoxContainer/Op0, 
	$CajaPregunta/VBoxContainer/Op1, 
	$CajaPregunta/VBoxContainer/Op2, 
	$CajaPregunta/VBoxContainer/Op3
]

@onready var corazon_1 = $CorazonesBox/Heart1
@onready var corazon_2 = $CorazonesBox/Heart2
@onready var corazon_3 = $CorazonesBox/Heart3

@export var tex_full_heart : Texture2D
@export var tex_void_heart : Texture2D

var banco_preguntas = [
	{"pregunta": "¿Qué símbolo sagrado debiste completar para poder restaurar el orden?", "opciones": ["El Fruto de Yaku", "La balanza de piedra", "La Chakana", "El Quipu de oro"], "correcta": 2},
	{"pregunta": "¿Quién es la madre tierra que te dio forma como su último aliento de esperanza?", "opciones": ["El Anciano sabio", "La Pachamama", "La Entidad", "El Dios Inti"], "correcta": 1},
	{"pregunta": "¿Cuál es el mundo de abajo, el subsuelo oscuro?", "opciones": ["Hanan Pacha", "Kay Pacha", "Supay Pacha", "Uku Pacha"], "correcta": 3},
	{"pregunta": "¿Cómo se llama el mundo terrenal de los vivos?", "opciones": ["Kay Pacha", "Uku Pacha", "Hanan Pacha", "Llacta Pacha"], "correcta": 0},
	{"pregunta": "¿Qué mundo representa el cielo superior?", "opciones": ["Uku Pacha", "Kay Pacha", "Hanan Pacha", "Hurin Pacha"], "correcta": 2},
	{"pregunta": "¿Qué animal sagrado representa el Uku Pacha (subsuelo)?", "opciones": ["El Cóndor", "El Puma", "La Serpiente", "El Sapo"], "correcta": 2},
	{"pregunta": "¿Qué animal vigila el mundo terrenal (Kay Pacha)?", "opciones": ["El Puma", "El Zorro", "La Llama", "El Cuy"], "correcta": 0},
	{"pregunta": "¿Cuál es el guardián de los cielos (Hanan Pacha)?", "opciones": ["El Cóndor", "El Búho", "El Águila", "El Halcón"], "correcta": 0},
	{"pregunta": "¿Qué astros debían volver a su lugar en el Hanan Pacha para traer la luz?", "opciones": ["Las Estrellas", "El Sol y la Luna", "Los Cometas", "Los Planetas"], "correcta": 1},
	{"pregunta": "¿Cómo se llama la sombra antigua que quebró el equilibrio de los tres mundos?", "opciones": ["La Entidad", "El Amaru", "El Pishtaco", "El Supay"], "correcta": 0}
]
var preguntas_mezcladas = []
var pregunta_actual = {}
var seleccion_actual = 0
var tiempo_restante = 20.0

func _ready():
	visible = true 
	caja_pregunta.visible = false
	filtro_sepia.visible = false
	corazones_box.visible = false 
	barra_vida_jefe.visible = false
	nombre_jefe.visible = false
	mezclar_preguntas()
	
	for op in opciones_labels:
		op.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto_pregunta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func iniciar_batalla_ui(vida_maxima: int):
	corazones_box.visible = true
	nombre_jefe.visible = true
	barra_vida_jefe.visible = true
	barra_vida_jefe.max_value = vida_maxima
	barra_vida_jefe.value = vida_maxima
	actualizar_corazones(3)
	
func actualizar_vida_jefe(vida_actual: int):
	var tween = create_tween()
	tween.tween_property(barra_vida_jefe, "value", vida_actual, 0.2)
	
func mezclar_preguntas():
	preguntas_mezcladas = banco_preguntas.duplicate()
	preguntas_mezcladas.shuffle() 

func actualizar_corazones(vidas: int):
	corazon_1.texture = tex_full_heart if vidas >= 1 else tex_void_heart
	corazon_2.texture = tex_full_heart if vidas >= 2 else tex_void_heart
	corazon_3.texture = tex_full_heart if vidas >= 3 else tex_void_heart

func mostrar_pregunta():
	if preguntas_mezcladas.is_empty(): mezclar_preguntas()
	pregunta_actual = preguntas_mezcladas.pop_back()
	
	texto_pregunta.text = pregunta_actual["pregunta"]
	seleccion_actual = 0
	tiempo_restante = 20.0
	actualizar_cursor()
	
	filtro_sepia.visible = true
	caja_pregunta.visible = true
	Data.en_pregunta = true

func actualizar_cursor():
	for i in range(4):
		if i == seleccion_actual:
			opciones_labels[i].text = "> " + pregunta_actual["opciones"][i] + " <"
			opciones_labels[i].modulate = Color(1, 1, 0)
		else:
			opciones_labels[i].text = pregunta_actual["opciones"][i]
			opciones_labels[i].modulate = Color(1, 1, 1)

func _process(delta):
	if not Data.en_pregunta: 
		return
		
	var delta_real = delta
	if Engine.time_scale > 0.0:
		delta_real = delta / Engine.time_scale
		
	tiempo_restante -= delta_real
	tiempo_label.text = "Tiempo: " + str(int(ceil(tiempo_restante)))
	
	if tiempo_restante <= 0:
		verificar_respuesta(true) 
		return
		
	if Input.is_action_just_pressed("jump"): 
		seleccion_actual -= 1
		if seleccion_actual < 0: seleccion_actual = 3
		actualizar_cursor()
	elif Input.is_action_just_pressed("abajo"): 
		seleccion_actual += 1
		if seleccion_actual > 3: seleccion_actual = 0
		actualizar_cursor()
	elif Input.is_action_just_pressed("ui_accept"): 
		verificar_respuesta(false)

func verificar_respuesta(tiempo_agotado: bool):
	Data.en_pregunta = false 
	
	if tiempo_agotado:
		for op in opciones_labels:
			op.modulate = Color(1, 0, 0) 
		await get_tree().create_timer(0.5, true, false, true).timeout
		
		# Revelamos la correcta
		opciones_labels[pregunta_actual["correcta"]].modulate = Color(0, 1, 0)
		await get_tree().create_timer(1.0, true, false, true).timeout
		
	elif seleccion_actual == pregunta_actual["correcta"]:
		opciones_labels[seleccion_actual].modulate = Color(0, 1, 0)
		await get_tree().create_timer(1.0, true, false, true).timeout 
		
	else:
		opciones_labels[seleccion_actual].modulate = Color(1, 0, 0) 
		
		await get_tree().create_timer(0.5, true, false, true).timeout 
		
		for i in range(3):
			opciones_labels[pregunta_actual["correcta"]].modulate = Color(0, 1, 0)
			await get_tree().create_timer(0.15, true, false, true).timeout 
			opciones_labels[pregunta_actual["correcta"]].modulate = Color(1, 1, 1)
			await get_tree().create_timer(0.15, true, false, true).timeout 
			
		opciones_labels[pregunta_actual["correcta"]].modulate = Color(0, 1, 0) 
		await get_tree().create_timer(0.5, true, false, true).timeout 

	filtro_sepia.visible = false
	caja_pregunta.visible = false
	
	var jefe = get_tree().get_first_node_in_group("Jefe")
	if not jefe: return
	
	if tiempo_agotado or seleccion_actual != pregunta_actual["correcta"]:
		jefe.respuesta_incorrecta()
	else:
		jefe.respuesta_correcta()

func ocultar_ui_victoria():
	nombre_jefe.visible = false
	barra_vida_jefe.visible = false
