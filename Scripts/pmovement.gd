extends Node

class_name PlayerMovement

var astar = AStarGrid2D.new()
var tilemap: TileMapLayer
var path: Array[Vector2i] = []

var IsMyTurn: bool
var spawned = false

var IsVirus = false

var target: Node2D

func _init(_tilemap: TileMapLayer, _target):
	tilemap = _tilemap
	target = _target
	
	astar.region = tilemap.get_used_rect()
	astar.cell_size = tilemap.tile_set.tile_size
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	
	while not spawned:
		await randomSpawn()
	


func setpathid(start, goal):
	#print(str(start) + " " + str(goal))
	
	return astar.get_id_path(start, goal).slice(1,3)

func setturn(active: bool):
	IsMyTurn = active

func calpath(id):
	path = id
	print("CALCULAED PATH: " + str(path))
	#print(IsMyTurn)

func _physics_process(delta):
	if path.is_empty(): return
	#print(1)
	if not IsMyTurn: return
	#print(path)
	
	var tpos = tilemap.map_to_local(path.front())
	target.position = target.position.move_toward(tpos, 2)
	
	if target.position.distance_to(tpos) < 1:
		path.pop_front()

func randomSpawn():
	var alltiles = tilemap.get_used_cells()
	#print("Executed")
	for i in alltiles:
		var rng = randi_range(1, 250)
		
		if rng == 1 and not spawned:
			target.position = tilemap.map_to_local(i)
			spawned = true
