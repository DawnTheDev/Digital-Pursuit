extends Button

@onready var maincscene = "res://PlayerCount.tscn"

func _on_pressed() -> void:
	#print("Clicked.")
	get_tree().change_scene_to_file(maincscene)


func _on_button_2_pressed() -> void:
	get_tree().quit()
