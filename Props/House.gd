extends Node2D
class_name House

var _active_house: House
var _disabled := true
var _mouse_captured := false

@export var player := Color.WHITE :
	set(value):
		var original = player
		player = value
		_update_color()

@export var population: int :
	set(value):
		population = value
		if population < 0:
			population = 0
		_update_text()

@export var money: int :
	set(value):
		money = value
		if money < 0:
			money = 0
		_update_text()

func _ready() -> void:
	_update_text()
	$Reach/Collision.polygon = $ReachShape.polygon

	App.active_changed.connect(_on_active_house)
	App.action_selected.connect(_on_action_picked)
	App.action_executed.connect(_on_action_executed)
	$Interactive.mouse_entered.connect(_on_interactive_mouse_entered)
	$Interactive.mouse_exited.connect(_on_interactive_mouse_exited)
	
func is_reachable(area: Area2D) -> bool:
	return $Reach.overlaps_area(area)
	
func is_reachable_pos(pos: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(to_local(pos), $ReachShape.polygon)
	
func acquire(player: Color, population: int = App.HOUSE_INIT_POPULATION, money: int = App.HOUSE_INIT_MONEY):
	self.player = player
	self.population = population
	self.money = money
	App.acquired.emit(self)

func defeated():
	App.defeated.emit(self)
	self.player = Color.WHITE
	self.population = 0
	self.money = 0

func _selectable(play=true):
	if play:
		$AnimationPlayer.play("blinking")
		_disabled = false
	else:
		$AnimationPlayer.stop()
		_disabled = true
	
func _update_color():
	$Indicator.color = player
	
func _update_text():
	
	$Label.text = "P%d / M%d" % [population, money]

func _on_active_house(house: House):
	_active_house = null
	_selectable(false)
	
	var is_self = self == house
	$ReachShape.visible = is_self
	if is_self or house.is_reachable($Interactive):
		_active_house = house

func _on_action_picked(action: Actions.Actions):
	_selectable(false)
	if _active_house == null:
		return
	
	if action == Actions.Actions.ATTACK and _active_house.player != player:
		_selectable(true)
	elif action == Actions.Actions.REINFORCE and _active_house.player == player and _active_house != self:
		_selectable(true)
	elif action == Actions.Actions.HIRE and _active_house == self:
		_selectable(true)

func _on_action_executed():
	_selectable(false)

func _on_interactive_mouse_entered() -> void:
	if not _disabled:
		_mouse_captured = true
		
func _on_interactive_mouse_exited() -> void:
	_mouse_captured = false

func _input(event: InputEvent):
	if not _disabled and _mouse_captured and event.is_action_pressed("action"):
		App.target_selected.emit(self)
