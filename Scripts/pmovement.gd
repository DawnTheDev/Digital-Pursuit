extends Node

class_name PlayerMovement

var astar = AStarGrid2D.new()
var tilemap: TileMapLayer
var path: Array[Vector2i] = []
var pNodes

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
		print("EXECUTED")
	

func setVirus(active: Array, Sprite: Sprite2D):
	IsVirus = true
	VTarget = active
	
	CVTarget = active.pick_random()
	VSprite = Sprite

func setpathid(start, goal):
	#print(str(start) + " " + str(goal))
	if not IsVirus:
		return astar.get_id_path(start, goal).slice(1,3)
		
	else:
		return astar.get_id_path(start, goal).slice(1,2)

func setplayers(array):
	pNodes = array

func setturn(active: bool):
	IsMyTurn = active

func calpath(id):
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
		for i in range(pNodes.size()):
			if target.global_position == pNodes[i].global_position and Alive:
				target.visible = true
				#PLabel[i].text = "Player " + str(i + 1) + ": " + str(1)
				Singleton.PlayerScores[i] += 1
				VSprite.texture = load("res://Images/Virus Digital Dead.png")
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
	target.position = target.position.move_toward(tpos, 2)
	
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
		
		if rng == 1 and not spawned:
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
