extends Panel

func _ready() -> void:
	$CenterContainer/VBoxContainer/HBoxContainer/Player.color = App.winner

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		get_tree().change_scene_to_file("res://World.tscn")
