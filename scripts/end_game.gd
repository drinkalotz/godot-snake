extends Control
var label_text: String = "You died. Your score was %s"
var score: int = 0
@onready var label: Label = $Label

func _process(delta: float) -> void:
	label.text = label_text % score

func _on_button_pressed() -> void:
	var world_scene = load("res://scenes/world.tscn") as PackedScene
	if world_scene:
		get_tree().change_scene_to_packed(world_scene)
	else:
		print("Failed to load world scene")
	queue_free()
