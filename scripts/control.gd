extends Control


func _on_play_pressed() -> void:
	$Click.play()
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://scenes/levels/base_level.tscn")

func _on_help_pressed() -> void:
	$Click.play()
	$TextureRect/Panel5.visible = true  # we can fill this in later

func _on_exit_pressed() -> void:
	$Click.play()
	await get_tree().create_timer(0.4).timeout
	get_tree().quit()

func _on_next_pressed() -> void:
	$Click.play()
	$TextureRect/Panel5.visible = false
	$TextureRect/Panel4.visible = true

func _on_next1_pressed() -> void:
	$Click.play()
	$TextureRect/Panel4.visible = false
	$TextureRect/Panel3.visible = true

func _on_next2_pressed() -> void:
	$Click.play()
	$TextureRect/Panel3.visible = false
	$TextureRect/Panel2.visible = true

func _on_next3_pressed() -> void:
	$Click.play()
	$TextureRect/Panel2.visible = false
