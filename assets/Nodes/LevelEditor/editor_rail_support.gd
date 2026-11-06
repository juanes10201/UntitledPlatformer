extends Node2D

var PointAmount = 0 
@onready var Rail = get_parent()
@export var NodeCachePoints : Node2D
@export var SampleCachePoint : Node2D

var cache_global_pos : Vector2

func _cache_points() -> void:
	cache_global_pos = Rail.global_position
	PointAmount = Rail.points.size()
	NodeCachePoints.set_cache_nodes_amount(PointAmount)
	for i in range(Rail.points.size()):
		var _point_global_pos = Rail.points[i]+Rail.global_position
		if(i < NodeCachePoints.CacheNodes.size()):
			NodeCachePoints.CacheNodes[i].position = _point_global_pos
			NodeCachePoints.CacheNodes[i].visible = true

func _ready() -> void:
	_cache_points()

func _process(delta: float) -> void:
	#print(Rail.global_position)
	#print("Rail points: " + str(Rail.points.size()) )
	#print("Current: " + str(NodeCachePoints.CacheNodes.size()-NodeCachePoints.ExtraCacheAmount) )
	if(Rail.points.size() != NodeCachePoints.CacheNodes.size()-NodeCachePoints.ExtraCacheAmount || Rail.global_position != cache_global_pos):
		_cache_points()
	else:
		for i in range(Rail.points.size()):
			if(i < NodeCachePoints.CacheNodes.size()):
				var _point_new_pos = NodeCachePoints.CacheNodes[i].global_position-Rail.global_position
				Rail.points[i] = _point_new_pos
