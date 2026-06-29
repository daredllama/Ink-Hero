extends CharacterBody2D

@onready var tilemap = get_parent().get_node("TileMapLayer")
const SPEED = 900.0
var is_moving = false
var last_tile_pos = Vector2i()
var just_teleported = false
var current_swap = Vector2i(2, 0)
var current_color = "red"
var wrong_tiles = {}
var force_check = false
var teleport_cooldown = false
var stop_movement = false



var win_tiles = {
	Vector2i(8,9): Vector2i(3,0),
	Vector2i(8,8): Vector2i(3,0),
	Vector2i(9,8): Vector2i(3,0),
	Vector2i(8,7): Vector2i(5,0),
	Vector2i(7,7): Vector2i(5,0),
	Vector2i(6,7): Vector2i(5,0),
	Vector2i(5,7): Vector2i(5,0),
	Vector2i(4,7): Vector2i(5,0),
	Vector2i(4,6): Vector2i(5,0),
	Vector2i(5,6): Vector2i(5,0),
	Vector2i(6,6): Vector2i(5,0),
	Vector2i(7,6): Vector2i(5,0),
	Vector2i(7,5): Vector2i(5,0),
	Vector2i(6,5): Vector2i(5,0),
	Vector2i(5,5): Vector2i(5,0),
	Vector2i(5,4): Vector2i(5,0),
	Vector2i(6,4): Vector2i(5,0),
	Vector2i(6,3): Vector2i(5,0),
	Vector2i(7,3): Vector2i(5,0),
	Vector2i(7,2): Vector2i(5,0),
	Vector2i(6,2): Vector2i(5,0),
	Vector2i(7,1): Vector2i(5,0),
	Vector2i(8,1): Vector2i(5,0),
	Vector2i(8,0): Vector2i(5,0),
	Vector2i(9,0): Vector2i(5,0),
	Vector2i(9,1): Vector2i(5,0),
	Vector2i(9,2): Vector2i(5,0),
	Vector2i(9,4): Vector2i(5,0),
	Vector2i(8,4): Vector2i(5,0),
	Vector2i(10,1): Vector2i(5,0),
	Vector2i(10,2): Vector2i(5,0),
	Vector2i(10,3): Vector2i(5,0),
	Vector2i(9,3): Vector2i(5,0),
	Vector2i(11,2): Vector2i(5,0),
	Vector2i(11,3): Vector2i(5,0),
	Vector2i(11,4): Vector2i(5,0),
	Vector2i(11,5): Vector2i(5,0),
	Vector2i(12,4): Vector2i(5,0),
	Vector2i(12,5): Vector2i(5,0),
	Vector2i(12,6): Vector2i(5,0),
	Vector2i(13,6): Vector2i(5,0),
	Vector2i(13,7): Vector2i(5,0),
	Vector2i(12,7): Vector2i(5,0),
	Vector2i(11,7): Vector2i(5,0),
	Vector2i(10,7): Vector2i(5,0),
	Vector2i(10,6): Vector2i(5,0),
	Vector2i(10,5): Vector2i(5,0),
}	

var swapped_tiles = {}

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	process_movement()
	if stop_movement:
		velocity = Vector2.ZERO
		is_moving = false
		stop_movement = false
	move_and_slide()
	check_tile()
	
	if velocity == Vector2.ZERO:
		$AnimatedSprite2D.play(current_color + "_idle")
	elif velocity.y != 0:
		if velocity.y < 0:
			$AnimatedSprite2D.play(current_color + "_up")
		else:
			$AnimatedSprite2D.play(current_color + "_down")
	else:
		$AnimatedSprite2D.play(current_color + "_side")
		$AnimatedSprite2D.flip_h = velocity.x < 0
	

	
func process_movement() -> void:
	if teleport_cooldown:
		return
	
	var direction := Input.get_vector("left", "right","up", "down")
	
	if direction != Vector2.ZERO and not is_moving:
		if direction.x != 0:
			direction.y = 0
		velocity  = direction * SPEED	
		is_moving = true
		if not $Slime.playing:
			$Slime.play()	
		
	if velocity.length() < 1.0:
		velocity = Vector2.ZERO
		is_moving = false
		
func check_tile() -> void:
	var tile_pos = tilemap.local_to_map(tilemap.to_local(global_position))
	
	if tile_pos != last_tile_pos or force_check:
		last_tile_pos = tile_pos
		
		if just_teleported:
			just_teleported = false
			force_check = false
			return
			
		if force_check:
			force_check = false
			var atlas_coords = tilemap.get_cell_atlas_coords(tile_pos)

			if atlas_coords != Vector2i(-1, -1) and atlas_coords != Vector2i(8, 0) and atlas_coords != Vector2i(9, 0):
				tilemap.set_cell(tile_pos, 1, current_swap)
				check_win(tile_pos)
			return
		var atlas_coords = tilemap.get_cell_atlas_coords(tile_pos)	
		
		if atlas_coords != Vector2i(-1, -1):
			if atlas_coords == Vector2i(8, 0):
				teleport_to_tile(tile_pos,Vector2i(8, 0))
				return
			if atlas_coords == Vector2i(9, 0):
				teleport_to_tile(tile_pos,Vector2i(9, 0))
				return
			
				
			tilemap.set_cell(tile_pos, 1, current_swap)
			check_win(tile_pos)
			

			
func teleport_to_tile(current_pos: Vector2i, portal_atlas: Vector2i) -> void:
	var all_cells = tilemap.get_used_cells()
	for cell in all_cells:
		if tilemap.get_cell_atlas_coords(cell) == portal_atlas and cell != current_pos:
			var target = tilemap.to_global(tilemap.map_to_local(cell))
			global_position = target #tilemap.to_global(tilemap.map_to_local(cell))
			velocity = Vector2.ZERO
			is_moving = false
			last_tile_pos =  Vector2i(-999, -999)
			just_teleported = true	
			stop_movement = true
			force_check = false
			teleport_cooldown = true
			await get_tree().create_timer(0.2).timeout
			teleport_cooldown = false
			break
			
func check_win(tile_pos: Vector2i) -> void:
	if tile_pos in win_tiles:
		if current_swap == win_tiles[tile_pos]:
			swapped_tiles[tile_pos] = current_swap
		else:
			if tile_pos in swapped_tiles:
				swapped_tiles.erase(tile_pos)
	else:
		wrong_tiles[tile_pos] = current_swap
		
		
	var missing = []
	for tile in win_tiles:
		if tile not in swapped_tiles:
			missing.append(tile)
	
		
	if swapped_tiles.size() == win_tiles.size() and wrong_tiles.size() == 0:
		get_parent().show_win_popup()
	
func show_win_popup() -> void:	
	get_parent().get_node("CanvasLayer/Panel").visible = true

func _on_next_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level2.tscn")

func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/control.tscn")
