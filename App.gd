extends Node

const DISABLED_COLOR = Color(0.5, 0.5, 0.5, 1)

const TURNS_FORECAST = 5

const HOUSE_INIT_POPULATION = 50
const HOUSE_INIT_MONEY = 150
const GOLD_INIT_VALUE = 175
const BUILD_POPULATION_REQUIREMENT = 30 # must be smaller then init
const BUILD_MONEY_REQUIREMENT = 100 # must be smaller then init
const COIN_PER_POPULATION = 10

var winner: Color

# signalize active house
signal active_changed(house: House)

# player picks an action
signal action_selected(action: Actions.Actions)

# signalize action was executed
signal action_executed()

# player targeted given house or stone
signal target_selected(node: Node2D)

# house was defeated by current player
signal defeated(house: House)

# house was acquired by current player
signal acquired(house: House)

# stone was depleted and mining is no more possible
signal depleted(stone: Gold)
