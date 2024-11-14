extends Control

@onready var world: PackedScene = preload("res://scenes/world.tscn")

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(world)
