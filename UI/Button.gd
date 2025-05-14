extends Button
class_name MyButton

@export var value := 0
signal adding(value: int)

func _init():
	pressed.connect(_on__pressed)
	
func _ready():
	custom_minimum_size = Vector2(40, 0)
	if value > 0:
		text = "+" + str(value)
	else:
		text = str(value)

func _on__pressed() -> void:
	adding.emit(value)
