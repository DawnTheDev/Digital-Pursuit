extends Node2D

@onready var tile_map = $"../TileMapLayer"
@onready var nextscene = "res://node_2d.tscn"

@onready var pb = [$"../Control/player1b", $"../Control/player2b", $"../Control/player3b", $"../Control/player4b"]
@onready var buffnoti = $"../Control"

@onready var faces = [load("res://dice_1.png.png"), load("res://dice_2.png.png"), load("res://dice_3.png.png")]
@onready var diceSprite = $"../diceFrame/dicesprite"

var astar: AStarGrid2D
var cur_id_path: Array
var random = RandomNumberGenerator.new()

var plrpreset2 = [Vector2i(-204.0, 27.0), Vector2i(73.0, 27.0)]
var plrpreset3 = [Vector2i(-235.0, 51.0), Vector2i(-61.0, 51.0), Vector2i(112.0, 51.0)]

var AllPlayers = [player1, player2, player3, player4]

#CONFIGS

var curbattlegenerated: int
var curbuffgenerated: int

var buffchance = 3
var battlechance = 3
var curbuff: String

var deb: bool
var cleanup: bool

var rolled: bool
var moved: bool
var moves = 0
var inArea: bool

func _ready() -> void:
	curbattlegenerated = 0
	curbuffgenerated = 0
	astar = AStarGrid2D.new()
	astar.region = tile_map.get_used_rect()
	astar.cell_size = Vector2(16, 16)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	
	if Singleton.maxplrcount == 2:
		for i in range(2):
			pb[i].position = plrpreset2[i]
			pb[i].visible = true
		
	elif Singleton.maxplrcount == 3:
		for i in range(3):
			pb[i].position = plrpreset3[i]
			pb[i].visible = true
		
	var tiles = tile_map.get_used_cells()
	var tileset = tile_map.tile_set
	
	while curbattlegenerated == 0 or curbuffgenerated == 0:
		#if deb: return
		#deb = true
		genrandomtiles(tiles)
		#await get_tree().create_timer(.1).timeout
		#deb = false
	#print(player2.character)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and moves > 0:
		if moved: return
		if buffnoti.visible: return
		var id_path = astar.get_id_path(
			tile_map.local_to_map(global_position),
			tile_map.local_to_map(get_global_mouse_position())
		).slice(1, moves + 1)
		#print(id_path)
		if not id_path.is_empty():
			cur_id_path = id_path
		
		moved = true
	
	elif event.is_action_pressed("debug"):
		print("PLAYER 1 HP: " + str(player1.character))
		print("PLAYER 2 HP: " + str(player2.character))
		print("PLAYER 3 HP: " + str(player3.character))
		print("PLAYER 4 HP: " + str(player4.character))
		
		print("MOVES: " + str(moves))
		print(cur_id_path)
	
	elif event.is_action_pressed("click") and not rolled and inArea:
		#print("received")
		for i in range(9):
			diceSprite.texture = faces[random.randi_range(1, 3) - 1]
			await get_tree().create_timer(.05).timeout
		
		var rng = randi_range(1, 3)
		diceSprite.texture = faces[rng - 1]
		moves = rng
		rolled = true
		print(moves)
		
func _physics_process(delta: float) -> void:
	if curbattlegenerated > 0 and curbuffgenerated > 0:
		if not cleanup:
			var tiles = tile_map.get_used_cells()
			genrandomtiles(tiles)
			cleanup = true
		else:
			pass
	
	for i in range(Singleton.maxplrcount):
		if AllPlayers[i].character["stats"]["hp"] > AllPlayers[i].character["stats"]["maxhp"]:
			print("OVERHEAL: " + str(AllPlayers[i]))
			AllPlayers[i].character["stats"]["hp"] = AllPlayers[i].character["stats"]["maxhp"]
	
	if cur_id_path.is_empty():
		if moved:
			rolled = false
			moved = false
			moves = 0
			print("Resetted")
			return
			
		else:
			return
	
	var targetpos = tile_map.map_to_local(cur_id_path.front())
	var tiledata = tile_map.get_cell_tile_data(tile_map.local_to_map(global_position))
	
	if tiledata != null and tiledata.get_custom_data("battle"):
		var curenemy = random.randi_range(1, 1)
		
		if curenemy == 1:
			Singleton.CurrentEnemy = enemies.gpt
			
		else:
			Singleton.CurrentEnemy = enemies.hacker
		
		get_tree().change_scene_to_file(nextscene)
		cur_id_path = [tile_map.local_to_map(global_position)]
	
	if  tiledata != null and tiledata.get_custom_data("buff"):
		if Singleton.maxplrcount == 1:
			player1.character["stats"]["hp"] += Singleton.healbuff
			tile_map.set_cell(tile_map.local_to_map(global_position), 6, Vector2i(2, 0), 0)
			return
		elif Singleton.maxplrcount == 4:
			for i in range(4):
				pb[i].visible = true
		
		buffnoti.visible = true
		cur_id_path = [tile_map.local_to_map(global_position)]
	
	global_position = global_position.move_toward(targetpos, 10)
	
	if global_position == targetpos:
		#await get_tree().create_timer(.25).timeout
		cur_id_path.pop_front()

func _on_player_1b_pressed() -> void:
	player1.character["stats"]["hp"] += Singleton.healbuff
	
	tile_map.set_cell(tile_map.local_to_map(global_position), 6, Vector2i(2, 0), 0)
	buffnoti.visible = false


func _on_player_2b_pressed() -> void:
	player2.character["stats"]["hp"] += Singleton.healbuff
	
	tile_map.set_cell(tile_map.local_to_map(global_position), 6, Vector2i(2, 0), 0)
	buffnoti.visible = false


func _on_player_3b_pressed() -> void:
	player3.character["stats"]["hp"] += Singleton.healbuff
	
	tile_map.set_cell(tile_map.local_to_map(global_position), 6, Vector2i(2, 0), 0)
	buffnoti.visible = false


func _on_player_4b_pressed() -> void:
	player4.character["stats"]["hp"] += Singleton.healbuff
	
	tile_map.set_cell(tile_map.local_to_map(global_position), 6, Vector2i(2, 0), 0)
	buffnoti.visible = false

func genrandomtiles(tiles):
	for i in tiles:
		var tiledata = tile_map.get_cell_tile_data(i)
		
		if tiledata != null and tiledata.get_custom_data("rbattle"):
			print("Generating battle: " + str(i))
			var rngbattle = random.randi_range(1, 10)
			#print(rngbattle)
			if random.randi_range(1, battlechance) == 1:
				tile_map.set_cell(i, 6, Vector2i(1, 0), 0)
				curbattlegenerated += 1
				#print("Generated battle")
			else:
				if curbattlegenerated == 0:
					pass
				else:
					tile_map.set_cell(i, 6, Vector2i(2, 0), 0)
			
		if tiledata != null and tiledata.get_custom_data("rbuff"):
			var rngbuff = random.randi_range(1, 10)
			print("Generating buff: " + str(i))
			#print(rngbuff)
			if random.randi_range(1, buffchance) == 1:
				tile_map.set_cell(i, 6, Vector2i(0, 0), 0)
				curbuffgenerated += 1
				#print("Generated buff")
			else:
				if curbuffgenerated == 0:
					pass
				else:
					tile_map.set_cell(i, 6, Vector2i(2, 0), 0)
		
		if tiledata == null or not tiledata.get_custom_data("walkable"):
			astar.set_point_solid(i)

func _on_area_2d_mouse_entered() -> void:
	inArea = true
	#print("Entered")


func _on_area_2d_mouse_exited() -> void:
	inArea = false
	#print("Exited")
