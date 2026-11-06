extends Node2D

@export var ExtraCacheAmount = 2
@export var SampleNode : Node
var CacheNodes : Array[Node] = [] 

#func _process(delta: float) -> void:
	#print(CacheNodes)
	#if(Edition.Is_in_editor):
	#	for _node in CacheNodes:
	#		if(!_node):
	#			CacheNodes = []
	#			_tick_cache_nodes_size()

func _tick_cache_nodes_size() -> void:
	CacheNodes = get_children()

func set_sample_node(_sample : Node) -> void:
	_tick_cache_nodes_size()
	SampleNode = _sample

func get_cache_node(id : int) -> Node:
	_tick_cache_nodes_size()
	return CacheNodes[id]

func set_cache_nodes_amount(amount : int, show : bool = false) -> void:
	_tick_cache_nodes_size()
	var _dif_amount = amount-CacheNodes.size()+ExtraCacheAmount
	print(_dif_amount)
	if(_dif_amount > 0):
		for i in range(_dif_amount):
			var copy : Node = SampleNode.duplicate()
			add_child(copy)
			copy.visible = show
			print("Added child " + str(SampleNode))
	elif(_dif_amount < 0):
		for i in range(CacheNodes.size()-1, CacheNodes.size()-1-abs(_dif_amount)):
			get_cache_node(i).queue_free()
	_tick_cache_nodes_size()
