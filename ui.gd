extends CanvasLayer

@onready var label: Label = $Control/Label

func _ready():
	Data.chakanas_updated.connect(update_text)
	
	# Actualizar texto inicial (por si reinicias nivel y ya tienes piezas)
	label.text = str(Data.chakana_parts)

func update_text(amount):
	label.text = str(amount)
