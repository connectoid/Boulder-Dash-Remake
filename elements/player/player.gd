extends CharacterBody2D

const TILE_SIZE = Vector2(16, 16)
var move_timer = Timer.new()
var MOVE_INTERVAL = 0.2
var window_size = Vector2.ZERO
var WIN_GEMS_AMOUNT = 5
var gems_amount = 0


func _ready():
	update_window_size()
	add_child(move_timer)
	move_timer.wait_time = MOVE_INTERVAL
	move_timer.connect("timeout", _on_timer_timeout)


func update_window_size():
	window_size = DisplayServer.screen_get_size()
	window_size = Vector2(256, 128)
	print(window_size)


func dig_ground(player_position):
	var tilemap = get_parent().get_node("GroundTileLayer")
	var ground_tiles = $"../GroundTileLayer"
	var cell_coords = tilemap.local_to_map(player_position)
	ground_tiles.erase_cell(cell_coords)


func _process(delta):
	pass

func _physics_process(delta):
	var horizontal_dir = Vector2.ZERO
	var vertical_dir = Vector2.ZERO
	var player_position = $".".global_position
	dig_ground(player_position)
	
	if Input.is_action_pressed("ui_right"):  # Стрелка вправо
		horizontal_dir.x += 1
	elif Input.is_action_pressed("ui_left"):  # Стрелка влево
		horizontal_dir.x -= 1
	
	if Input.is_action_pressed("ui_down"):  # Стрелка вниз
		vertical_dir.y += 1
	elif Input.is_action_pressed("ui_up"):  # Стрелка вверх
		vertical_dir.y -= 1
	
	
	if horizontal_dir != Vector2.ZERO && vertical_dir != Vector2.ZERO:
		vertical_dir = Vector2.ZERO
	
	var final_direction = horizontal_dir + vertical_dir
	
	if final_direction.length_squared() > 0:
		if not move_timer.is_stopped(): 
			return  # Игнорируем повторные команды пока таймер запущен
		var new_position = position + final_direction.normalized() * TILE_SIZE
		if is_valid_position(new_position):
			if (Input.is_action_pressed("shift_left") or 
				Input.is_action_pressed("shift_right") or 
				Input.is_action_pressed("shift_up") or
				Input.is_action_pressed("shift_down")):
				dig_ground(new_position)
			else:
				try_move(final_direction)

			
		
		
		if final_direction == Vector2(-1.0, 0.0):
			if check_position(new_position, 'StoneStaticBody2D'):
				var object = get_objects_in_pos(new_position)
				push_stone('left', object[0].collider)
			elif check_position(new_position, 'GemStaticBody2D'):
				var object = get_objects_in_pos(new_position)
				eat_gem(object[0].collider)
		if final_direction == Vector2(1.0, 0.0):
			if check_position(new_position, 'StoneStaticBody2D'):
				var object = get_objects_in_pos(new_position)
				push_stone('right', object[0].collider)
			elif check_position(new_position, 'GemStaticBody2D'):
				var object = get_objects_in_pos(new_position)
				eat_gem(object[0].collider)
		if final_direction == Vector2(0.0, -1.0) or final_direction == Vector2(0.0, 1.0):
			if check_position(new_position, 'GemStaticBody2D'):
				var object = get_objects_in_pos(new_position)
				eat_gem(object[0].collider)


func check_position(pos, object_name):
	var collision_name = get_object_names_in_pos(pos)
	if collision_name.has(object_name):
		return true
	return false


func eat_gem(object):
	print(object)
	gems_amount += 1
	print('Gems amount: ', gems_amount)
	#var gem = object.get('collider')
	object.queue_free()
	if gems_amount >= WIN_GEMS_AMOUNT:
		print('YUO WIN !!!')


func explode(pos):
	for y in range(-1, 2):
		for x in range(-1, 2):
			var expolde_position = Vector2(pos.x + (x*TILE_SIZE.x), pos.y + (y*TILE_SIZE.y))
			var objects = get_objects_in_pos(expolde_position)
			for object in objects:
				var collider = object.get('collider')
				if collider.name == 'GroundTileLayer':
					dig_ground(expolde_position)
				elif collider.get_class() == 'StaticBody2D':
					print(collider)
					var tween = get_tree().create_tween()
					tween.tween_property(collider, "modulate:a", 0.0, 0.25)
					tween.tween_callback(collider.queue_free)
				else:
					collider.queue_free()



func die_and_explode(pos):
	print('BOOOOM!')
	explode(pos)
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred('disabled', true)
	queue_free()


func push_stone(dir, object):
	object.move(dir)


func get_object_classes_in_pos(pos):
	var direct_space_state = get_world_2d().direct_space_state
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.position = pos
	var objects = direct_space_state.intersect_point(point_query)
	var results = []
	for object in objects:
		results.append(object.collider.get_class())
	return results


func get_object_names_in_pos(pos):
	var direct_space_state = get_world_2d().direct_space_state
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.position = pos
	var objects = direct_space_state.intersect_point(point_query)
	var results = []
	for object in objects:
		results.append(object.collider.name.split('2D')[0] + '2D')
	return results


func get_objects_in_pos(pos):
	var direct_space_state = get_world_2d().direct_space_state
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.position = pos
	var objects = direct_space_state.intersect_point(point_query)
	return objects


func is_valid_position(pos):
	var colliders = get_object_classes_in_pos(pos)
	if 'StaticBody2D' in colliders:
		return false
	return pos.x >= 0 && pos.x <= window_size.x && pos.y >= 0 && pos.y <= window_size.y


func try_move(dir):
	dir = dir.normalized() * TILE_SIZE
	var collision_result = move_and_collide(dir)
	if collision_result == null:
		move_timer.start()


func _on_timer_timeout():
	move_timer.stop()





func _on_dig_area_2d_area_entered(area: Area2D) -> void:
	print('Player collision', area.name)
