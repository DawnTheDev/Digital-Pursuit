extends Node

class_name PlayerMovement

var astar = AStarGrid2D.new()
var tilemap: TileMapLayer
var path: Array[Vector2i] = []
var pNodes

var scanActive: bool
var firewallActive: int

var IsMyTurn: bool
var spawned = false
var PLabel

var IsVirus = false
var VTarget: Array
var CVTarget: Node2D
var Alive = true
var TurnVisible = randi_range(2, 4)
var counted: bool
var VSprite: Sprite2D

var End: bool

var target: Node2D

var debounce: bool

func _init(_tilemap: TileMapLayer, _target):
	tilemap = _tilemap
	target = _target
	
	astar.region = tilemap.get_used_rect()
	astar.cell_size = tilemap.tile_set.tile_size
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	
	while not spawned:
		await randomSpawn()
		#print("EXECUTED")
	

func setVirus(active: Array, Sprite: Sprite2D):
	IsVirus = true
	VTarget = active
	
	CVTarget = active.pick_random()
	VSprite = Sprite

func setpathid(start, goal, amount: int):
	#print(str(start) + " " + str(goal))
	if not IsVirus:
		return astar.get_id_path(start, goal).slice(1,amount + 1)
		
	else:
		return astar.get_id_path(start, goal).slice(1,amount + 1)

func setplayers(array):
	pNodes = array

func setturn(active: bool):
	IsMyTurn = active

func calpath(id):
	if firewallActive > 0:
		#print(str(id[0]), tilemap.local_to_map(Vector2i(CVTarget.global_position)))
		if id[0] == tilemap.local_to_map(Vector2i(CVTarget.global_position)):
			#print("DETECTED")
			path = []
		else:
			path = id
		
		firewallActive -= 1
		print(firewallActive)
	else:
		path = id
	print("CALCULAED PATH: " + str(path))
	#print(IsMyTurn)
	counted = false

func setdeb(active: bool):
	End = active

func _physics_process(delta):
	if End: return
	if IsVirus and not debounce:
		debounce = true
		
		if scanActive and Alive:
			TurnVisible = 0
			target.visible = true
			scanActive = false
		
		for i in range(pNodes.size()):
			if target.global_position == pNodes[i].global_position and Alive:
				target.visible = true
				#PLabel[i].text = "Player " + str(i + 1) + ": " + str(1)
				
				var rng = randi_range(0, 2)
				Singleton.PlayerPowerUps[i][rng] += 1
				
				Singleton.PlayerScores[i] += 1
				VSprite.texture = load("res://Images/Virus-Digital-Dead2.png")
				Alive = false
				await get_tree().create_timer(1.5).timeout
				
				target.visible = false
				pass
		
		if target.global_position == CVTarget.global_position:
			CVTarget.visible = false
			getnewtg()
			print("GOT IT")
			pass
		
		if not CVTarget.visible:
			getnewtg()
			pass
		
		debounce = false
	
	if path.is_empty(): return
	if not Alive: return
	if not IsMyTurn: return
	#print(path)
	
	var tpos = tilemap.map_to_local(path.front())
	target.position = target.position.move_toward(tpos, 3)
	
	if IsVirus and not counted:
		if TurnVisible == 0:
			target.visible = true
			TurnVisible += randi_range(2, 4)
			counted = true
			
		else:
			target.visible = false
			TurnVisible -= 1
			counted = true
	
	if target.position.distance_to(tpos) < 1:
		path.pop_front()
	

func randomSpawn():
	var alltiles = tilemap.get_used_cells()
	#print("Executed")
	for i in alltiles:
		var rng = randi_range(1, 500)
		
		if rng == 1 and not spawned and randi_range(1, 3) == 1:
			target.position = tilemap.map_to_local(i)
			spawned = true

func getnewtg():
	var newCVTarget = VTarget.pick_random()
	
	if newCVTarget == CVTarget:
		getnewtg()
	else:
		CVTarget = newCVTarget
		#print("Got new target")
		return

func scanactivate():
	scanActive = true

func firewallactivate():
	firewallActive = 3
	
	#for i in VTarget:
	#	for tiles in tilemap.get_used_cells():
	#		if tiles == tilemap.local_to_map(i.global_position):
	#			print(tiles)
	#			astar.set_point_solid(tiles, true)
