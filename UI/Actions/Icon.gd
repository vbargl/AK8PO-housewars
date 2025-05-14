extends TextureButton
class_name Icon

@export var action: Actions.Actions

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	App.action_selected.emit(action)
