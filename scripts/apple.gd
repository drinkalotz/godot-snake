extends Node2D
signal _on_apple_eaten

func _on_apple_area_area_entered(_area: Area2D) -> void:
	_on_apple_eaten.emit(self)
