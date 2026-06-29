extends Node2D

@onready var button_a = $CanvasLayer/ColorPanel/Red
@onready var button_b = $CanvasLayer/ColorPanel/Blue
@onready var button_c = $CanvasLayer/ColorPanel/Yellow
@onready var sfx = $AudioStreamPlayer2D

var selected_colors = []

var color_map = {
	"A": Vector2i(2, 0),
	"B": Vector2i(6, 0),
	"C": Vector2i(4, 0)
}

var combo_map = {
	"AB": Vector2i(7, 0),
	"AC": Vector2i(3, 0),
	"BC": Vector2i(5, 0)
}


func _on_next_pressed() -> void:
	sfx.play()
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://scenes/levels/level2.tscn")

func _on_return_pressed() -> void:
	sfx.play()
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://scenes/control.tscn")
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		$CanvasLayer/PausePanel.visible = not $CanvasLayer/PausePanel.visible
	if event.is_action_pressed("interact"):
		var panel = $CanvasLayer/ColorPanel
		panel.visible = not panel.visible
		if panel.visible:
			reset_buttons()

func _on_resume_pressed() -> void:
	sfx.play()
	
	$CanvasLayer/PausePanel.visible = false

func _on_reset_pressed() -> void:
	sfx.play()
	await get_tree().create_timer(0.4).timeout
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	sfx.play()
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://scenes/control.tscn")

func reset_buttons() -> void:
	button_a.button_pressed = false
	button_b.button_pressed = false
	button_c.button_pressed = false
	selected_colors = []
	
func toggle_color(color: String) -> void:
	if color in selected_colors:
		selected_colors.erase(color)
	else:
		if selected_colors.size() >= 2:			
			var first = selected_colors[0]
			selected_colors.erase(first)
			
			match first:
				"A": button_a.button_pressed = false
				"B": button_b.button_pressed = false
				"C": button_c.button_pressed = false
		selected_colors.append(color)
	
func _on_red() -> void:  
	sfx.play()
	toggle_color("A")
	
func _on_blue() -> void:
	sfx.play()
	toggle_color("B")
	
func _on_yellow() -> void:
	sfx.play()
	toggle_color("C")

func _on_mix() -> void:
	sfx.play()
	var result = get_result()
	if result != Vector2i(-1, -1):
		$Player.current_swap = result
		$Player.last_tile_pos = $Player.last_tile_pos
		$Player.force_check = true
		$Player.just_teleported = false
		var color_name_map = {
			Vector2i(2, 0): "red",
			Vector2i(6, 0): "blue",
			Vector2i(4, 0): "yellow",
			Vector2i(7, 0): "purple",  # AB
			Vector2i(5, 0): "green",   # AC
			Vector2i(3, 0): "orange",  # BC
		}
		if result in color_name_map:
			$Player.current_color = color_name_map[result]
	# update player's swap target
	$CanvasLayer/ColorPanel.visible = false
	selected_colors = []
	
func get_result() -> Vector2i:
	if selected_colors.size() == 1:
		return color_map[selected_colors[0]]
	elif selected_colors.size() == 2:
		var key = "".join(selected_colors)
		if key in combo_map:
			return combo_map[key]
		else:
			return combo_map[selected_colors[1] + selected_colors[0]]  # try reverse
	return Vector2i(-1, -1)

func show_win_popup() -> void:
	$CanvasLayer/Panel.visible = true

func _ready() -> void:
	$CanvasLayer/Map.visible = true
	
func _on_continue_pressed() -> void:
	sfx.play()
	$CanvasLayer/Map.visible = false


func _on_continue2_pressed() -> void:
	sfx.play()
	$CanvasLayer/Map2.visible = false # Replace with function body.


func _on_continue3_pressed() -> void:
	sfx.play()
	$CanvasLayer/Map3.visible = false # Replace with function body.
