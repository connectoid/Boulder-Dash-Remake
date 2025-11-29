extends StaticBody2D


const TILE_SIZE = Vector2(16, 16)
var window_size = Vector2.ZERO
var falling_timer = Timer.new()
var rolling_timer = Timer.new()
var FALLING_INTERVAL = 0.25
var all_colliders_list = ['StaticBody2D', 'TileMapLayer', 'CharacterBody2D']
var denied_colliders_list = ['StaticBody2D', 'TileMapLayer']
var player_collider = ['CharacterBody2D']
var stone_is_falling = false



func _ready():
	update_window_size()
	add_child(falling_timer)
	falling_timer.wait_time = FALLING_INTERVAL
	falling_timer.connect("timeout", _on_timer_timeout)
	rolling_timer.wait_time = FALLING_INTERVAL
	rolling_timer.connect("timeout", _on_timer_timeout)

	

func update_window_size():
	window_size = DisplayServer.screen_get_size()
	window_size = Vector2(256, 128)


func _process(delta):
	var vertical_dir = Vector2.ZERO
	var horizontal_dir = Vector2.ZERO
	vertical_dir.y = 1
	horizontal_dir.x = -1
	var new_position = position + vertical_dir.normalized() * TILE_SIZE
	
	if is_no_colliders(new_position, denied_colliders_list) && is_no_walls(new_position):
		var previos_upper_position = Vector2(position.x, position.y - TILE_SIZE.y)
		if not is_no_colliders(new_position, player_collider) and stone_is_falling:
			kill_object($"../Player")
		
		if not falling_timer.is_stopped(): 
			return 
		vertical_dir.y += 1
		new_position = position + vertical_dir.normalized() * TILE_SIZE
		stone_is_falling = true
		position = new_position
		falling_timer.start()
	else:
		stone_is_falling = false

	if not is_no_colliders(position, all_colliders_list) && is_no_walls(position):
		if can_rolldown(position) == 'left':
			if not rolling_timer.is_stopped(): 
				return 
			new_position = position + horizontal_dir.normalized() * TILE_SIZE
			position = new_position
			rolling_timer.start()
		elif can_rolldown(position) == 'right':
			if not rolling_timer.is_stopped(): 
				return 
			new_position = position - horizontal_dir.normalized() * TILE_SIZE
			position = new_position
			rolling_timer.start()

func kill_object(object):
	print('Kill!!!')
	object.die_and_explode()

	
func move_stone(dir):
	print('moving stone to the ', dir)
	var horizontal_dir = Vector2.ZERO
	var new_position = position

	if dir == 'left':
		horizontal_dir.x = -1
		new_position = position + horizontal_dir.normalized() * TILE_SIZE
		print('New pushing position: ', new_position)
		print('Old pushing position: ', position)
	elif dir == 'right':
		horizontal_dir.x = 1
		new_position = position + horizontal_dir.normalized() * TILE_SIZE
		print('New pushing position: ', new_position)
		print('Old pushing position: ', position)
	var no_colliders = is_no_colliders(new_position, denied_colliders_list)
	var no_walls = is_no_walls(new_position)
	print('No colliders: ', no_colliders)
	print('No walls: ', no_walls)
	if no_colliders &&  no_walls:
		print('Changing position by pushing')
		position = new_position
	else:
		print('Some obstacle')


func get_objects_in_pos(pos):
	var direct_space_state = get_world_2d().direct_space_state
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.position = pos
	var objects = direct_space_state.intersect_point(point_query)
	var results = []
	for object in objects:
		results.append(object.collider.get_class())
	return results


func comape_lists(source_list, dest_list):
	# Проверяет есть ли вхождение любого элемента списка source_list
	# в список dest_list. Если есть, то возвращает true, иначе false
	for item in source_list:
		if dest_list.has(item):
			return true
	return false



func can_rolldown(pos):
	var pos_below_aside_left = Vector2(pos.x - TILE_SIZE.x, pos.y + TILE_SIZE.y)
	var pos_below_aside_right = Vector2(pos.x + TILE_SIZE.x, pos.y + TILE_SIZE.y)
	var pos_below = Vector2(pos.x, pos.y + TILE_SIZE.y)
	var pos_aside_left = Vector2(pos.x - TILE_SIZE.x, pos.y)
	var pos_aside_right = Vector2(pos.x + TILE_SIZE.x, pos.y)
	var collisions_below_aside_left = get_objects_in_pos(pos_below_aside_left)
	var collisions_below_aside_right = get_objects_in_pos(pos_below_aside_right)
	var collisions_below = get_objects_in_pos(pos_below)
	var collisions_aside_left = get_objects_in_pos(pos_aside_left)
	var collisions_aside_right = get_objects_in_pos(pos_aside_right)
	
	var is_empty_below_aside_left = not comape_lists(collisions_below_aside_left, all_colliders_list)
	var is_empty_below_aside_right = not comape_lists(collisions_below_aside_right, all_colliders_list)
	var is_stone_below = comape_lists(collisions_below, ['StaticBody2D'])
	var is_player_aside_left = comape_lists(collisions_aside_left, ['CharacterBody2D', 'TileMapLayer'])
	var is_player_aside_right = comape_lists(collisions_aside_right, ['CharacterBody2D', 'TileMapLayer'])
	if is_empty_below_aside_left && is_stone_below && not is_player_aside_left && is_no_walls(pos_below_aside_left):
		return 'left'
	elif is_empty_below_aside_right && is_stone_below && not is_player_aside_right && is_no_walls(pos_below_aside_right):
		return 'right'
	return 'no'

func is_no_colliders(pos, list):
	var colliders_list = get_objects_in_pos(pos)
	var is_colliders = comape_lists(colliders_list, list)
	if is_colliders:
		falling_timer.start()
		
	return not is_colliders


func is_no_walls(pos):
	var is_valid = pos.x >= 0 && pos.x <= window_size.x && pos.y >= 0 && pos.y <= window_size.y
	return is_valid
	

	
func _on_timer_timeout():
	falling_timer.stop()
	rolling_timer.stop()
