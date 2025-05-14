extends Node2D
class_name Gold

@export var quantity: int :
	set(value):
		quantity = value
		if quantity < 0:
			quantity = 0
		_update_text()
	
var _disabled := true
var _mouse_captured := false
var _active_house: House

func _ready() -> void:
	quantity = App.GOLD_INIT_VALUE
	
	App.active_changed.connect(_on_active_house_changed)
	App.action_selected.connect(_on_action_selected)
	App.action_executed.connect(_on_action_executed)
	$Area.mouse_entered.connect(_on_area_mouse_entered)
	$Area.mouse_exited.connect(_on_area_mouse_exited)

func _selectable(play=true):
	if play:
		$AnimationPlayer.play("blinking")
		_disabled = false
	else:
		$AnimationPlayer.stop()
		_disabled = true

func _update_text():
	$Label.text = str(quantity)

func _on_active_house_changed(house: House):
	_active_house = null
	_selectable(false)
	
	if house.is_reachable($Area):
		_active_house = house
	
func _on_action_selected(action: Actions.Actions):
	if _active_house == null:
		return
		
	_selectable(false)
	
	if action == Actions.Actions.MINE \
	and _active_house.is_reachable($Area) \
	and quantity > 0:
		_selectable(true)

func _on_action_executed():
	_selectable(false)

func _on_area_mouse_entered() -> void:
	if not _disabled:
		_mouse_captured = true
	
func _on_area_mouse_exited() -> void:
	_mouse_captured = false

func _input(event: InputEvent) -> void:
	if not _disabled and _mouse_captured and event.is_action_pressed("action"):
		App.target_selected.emit(self)
