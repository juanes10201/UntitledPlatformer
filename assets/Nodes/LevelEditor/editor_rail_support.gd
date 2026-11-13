extends Node2D

var PointAmount = 0 
@onready var Rail = get_parent()
@export var NodeCachePoints : Node2D
@export var SampleCachePoint : Node2D

var cache_global_pos : Vector2

var OpacityShowPoint : float = .7
var OpacityHidePoint : float = .2

func _cache_points() -> void:
	if(!Edition.Is_in_editor): return
	cache_global_pos = Rail.global_position
	PointAmount = Rail.points.size()
	NodeCachePoints.set_cache_nodes_amount(PointAmount)
	for i in range(Rail.points.size()):
		var _point_global_pos = Rail.points[i]+Rail.global_position
		if(i < NodeCachePoints.CacheNodes.size()):
			NodeCachePoints.CacheNodes[i].position = _point_global_pos
			NodeCachePoints.CacheNodes[i].visible = true

func _ready() -> void:
	if(!Edition.Is_in_editor): queue_free()
	_cache_points()

func _process(delta: float) -> void:
	#print(Rail.global_position)
	#print("Rail points: " + str(Rail.points.size()) )
	#print("Current: " + str(NodeCachePoints.CacheNodes.size()-NodeCachePoints.ExtraCacheAmount) )
	if(Rail.points.size() != NodeCachePoints.CacheNodes.size()-NodeCachePoints.ExtraCacheAmount || Rail.global_position != cache_global_pos):
		_cache_points()
	#else:
	for i in range(Rail.points.size()):
		if(i < NodeCachePoints.CacheNodes.size()):
			var CachePoint : Node2D = NodeCachePoints.CacheNodes[i]
			var _point_new_pos = CachePoint.global_position-Rail.global_position
			Rail.set_point_position(i, _point_new_pos)
			if(!Edition.Is_playing_in_editor):
				CachePoint.modulate.a = OpacityShowPoint
			else:
				CachePoint.modulate.a = OpacityHidePoint
			#print("Asdsdjo")
