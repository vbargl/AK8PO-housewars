extends Icon

var active: House

func _ready() -> void:
	super()
	App.active_changed.connect(_on_active)
	App.action_executed.connect(_on_action_executed)
	
func _on_active(house: House):
	active = house
	_on_action_executed()
	
func _on_action_executed():
	if active.money > 0:
		modulate = Color.WHITE
		disabled = false
	else:
		modulate = App.DISABLED_COLOR
		disabled = true
	
	
	
