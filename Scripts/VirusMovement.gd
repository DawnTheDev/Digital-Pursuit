extends Node

class_name VirusMovement

var astar = AStarGrid2D.new()
var tilemap: TileMapLayer
var path: Array[Vector2i] = []

var IsMyTurn: bool
var spawned = false

var target: Node2D

func _init(_tilemap, _target):
	tilemap = _tilemap
	target = _target
	
	astar.region = tilemap.get_used_rect()
	astar.cell_size = tilemap.tile_set.tile_size
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	
	while not spawned:
		await randomSpawn()



func randomSpawn():
	var alltiles = tilemap.get_used_cells()
	#print("Executed")
	for i in alltiles:
		var rng = randi_range(1, 250)
		
		if rng == 1 and not spawned:
			target.position = tilemap.map_to_local(i)
			spawned = true
