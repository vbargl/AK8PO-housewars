extends Control
class_name Dialog

@export var value: int :
	set(val):
		value = val
		if value < min_value:
			value = min_value
		if value > max_value:
			value = max_value
		$VBoxContainer/SpinBox.set_value_no_signal(value)

@export var min_value: int :
	set(value):
		min_value = value
		$VBoxContainer/SpinBox.min_value = min_value
	 
@export var max_value: int :
	set(value):
		max_value = value
		$VBoxContainer/SpinBox.max_value = max_value

func _ready():
	min_value = 1
	max_value = 100
	value = 1
	
	$VBoxContainer/SpinBox.value_changed.connect(_set_value_from_spinbox)
	$"VBoxContainer/HBoxContainer3/-1".adding.connect(_increment_value_from_button)
	$"VBoxContainer/HBoxContainer3/+1".adding.connect(_increment_value_from_button)
	$"VBoxContainer/HBoxContainer3/+5".adding.connect(_increment_value_from_button)
	$"VBoxContainer/HBoxContainer3/+10".adding.connect(_increment_value_from_button)
	$"VBoxContainer/HBoxContainer3/+50".adding.connect(_increment_value_from_button)
	$Cancel.pressed.connect(_on_cancel)
	
func _update_value(val: int):
	value = val
	if value < min_value:
		value = min_value
	if value > max_value:
		value = max_value
	$VBoxContainer/SpinBox.set_value_no_signal(value)

func _increment_value_from_button(val: int) -> void:
	value += val
	
func _set_value_from_spinbox(val: float) -> void:
	value = int(val)
	
func _on_cancel() -> void:
	value = 0
	
