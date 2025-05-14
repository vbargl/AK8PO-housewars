extends Node2D

var NextTurnIndicator = preload("res://UI/NextTurnIndicator.tscn")
var House = preload("res://Props/House.tscn")
var NormalCursor = preload("res://Assets/Cursors/Cursor.png")
var HammerCursor = preload("res://Assets/Cursors/Hammer.png")
var HammerBlockedCursor = preload("res://Assets/Cursors/Hammer_blocked.png")

var _queue: RotationalQueue = RotationalQueue.new()

var count = {
	Color.RED: 0,
	Color.BLUE: 0,
}

var _house: House
var _action: Actions.Actions
var _target: Node2D
var _reachable: bool # only for build

# post turn _actions
var _replenish_population := 0  # number of people to be put back
var _replenish_money := 0  # number of people to be put back

func _on_ready():
	# finalize node tree
	for i in range(App.TURNS_FORECAST):
		var indicator = NextTurnIndicator.instantiate() as ColorRect
		$Turns/Next.add_child(indicator)

	# connect signals
	App.action_selected.connect(_on_action_selected)
	App.target_selected.connect(_on_target_selected)
	App.acquired.connect(_on_house_acquired)
	App.defeated.connect(_on_house_defeated)

	# setup _queue
	($Houses/BLUE as House).acquire(Color.BLUE)
	($Houses/RED as House).acquire(Color.RED)
	
	# wait until queue is setup
	await get_tree().create_timer(0.05).timeout
	next_turn()
	
func next_turn():
	# post turn actions
	if _house != null:
		_house.population += _replenish_population
		_house.money += _replenish_money
	
	# next turn setup
	_house = _queue.next()
	_reset_action()
	_replenish_money = 0
	_replenish_population = 0
	
	# pre turn actions
	_house.money += _house.population/App.COIN_PER_POPULATION
	
	# turn notification
	_redraw_indicators()
	App.active_changed.emit(_house)

func _redraw_indicators():
	if _house != null:
		$Turns/Current.color = _house.player
	
	var ahead = _queue.peek(App.TURNS_FORECAST) as Array[Color]
	for i in range(App.TURNS_FORECAST):
		var indicator = $Turns/Next.get_child(i) as ColorRect
		indicator.color = ahead.get(i).player

func _reset_action(action = Actions.Actions.NONE):
	_action = action
	_target = null
	$Dialog.hide()
	_change_cursor()

func _on_house_acquired(house: House):
	count[house.player] += 1
	_queue.append(house)
	_redraw_indicators()

func _on_house_defeated(house: House):
	count[house.player] -= 1
	_queue.remove(house)
	_redraw_indicators()
	if count[house.player] == 0:
		_show_winner()

func _on_action_selected(action: Actions.Actions):
	_reset_action(action)
	
	match _action:
		Actions.Actions.ATTACK: _show_dialog(0, _house.population - 1)
		Actions.Actions.MINE: _show_dialog(0, _house.population - 1)
		Actions.Actions.REINFORCE: _show_dialog(0, _house.population - 1)
		Actions.Actions.BUILD: _change_cursor(HammerCursor)
		Actions.Actions.HIRE: _show_dialog(0, _house.money)
		Actions.Actions.END: next_turn()

func _show_dialog(min: int, max: int):
	$Dialog.min_value = min
	$Dialog.max_value = max
	$Dialog.value = min
	$Dialog.show()

func _change_cursor(cursor = NormalCursor):
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW)
	
func _show_winner():
	App.winner = _house.player
	get_tree().change_scene_to_file("res://UI/GameOver.tscn")

func _on_target_selected(target: Node2D):
	_target = target
	
	match _action:
		Actions.Actions.ATTACK: _do_attack()
		Actions.Actions.MINE: _do_mine()
		Actions.Actions.REINFORCE: _do_reinforce()
		Actions.Actions.HIRE: _do_hire()

func _do_attack():
	var target = _target as House
	var value = $Dialog.value
	if value < target.population:
		_house.population -= value
		target.population -= value
	elif value == target.population:
		_house.population -= value
		target.defeated()
	elif value > target.population:
		_house.population -= value
		var init_population = value - target.population
		var init_money = target.money
		target.defeated()
		target.acquire(_house.player, init_population, init_money)
	_executed()
	
func _do_mine():
	var target = _target as Gold
	var quantity = $Dialog.value
	if target.quantity < quantity:
		quantity = target.quantity
	
	_house.population -= quantity
	target.quantity -= quantity
	_replenish_population += quantity
	_replenish_money += quantity
	_executed()

func _do_reinforce():
	_house.population -= $Dialog.value
	(_target as House).population += $Dialog.value
	_executed()
	
func _do_build(pos: Vector2):
	var house = House.instantiate() as House
	$Houses.add_child(house)
	house.position = pos
	house.acquire(_house.player, App.BUILD_POPULATION_REQUIREMENT, App.BUILD_MONEY_REQUIREMENT)
	_house.population -= App.BUILD_POPULATION_REQUIREMENT
	_house.money -= App.BUILD_MONEY_REQUIREMENT
	_executed()

func _do_hire():
	_house.money -= $Dialog.value
	_house.population += $Dialog.value
	_executed()

func _executed():
	_reset_action()
	App.action_executed.emit()

func _input(event: InputEvent):
	if event.is_action_pressed("cancel"):
		App.action_selected.emit(Actions.Actions.NONE)
	
	if _action == Actions.Actions.BUILD:
		_reachable = _house.is_reachable_pos(get_global_mouse_position())
		if _reachable and event.is_action("action"):
			_do_build(get_local_mouse_position())
			return
		if _reachable:
			_change_cursor(HammerCursor)
		else:
			_change_cursor(HammerBlockedCursor)
