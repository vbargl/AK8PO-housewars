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
	if active.population > App.BUILD_POPULATION_REQUIREMENT \
	and active.money > App.BUILD_MONEY_REQUIREMENT:
		disabled = false
		modulate = Color.WHITE
	else:
		disabled = true
		modulate = App.DISABLED_COLOR
