extends Node2D

@export var ExtraCacheAmount = 2
@export var SampleNode : Node
var CacheNodes : Array[Node] = [] 

#Esto es usado para marcar los nodos como usados/tomados temporalmente
var UsedNodes : Array[bool] = []

#func _process(delta: float) -> void:
	#print(CacheNodes)
	#if(Edition.Is_in_editor):
	#	for _node in CacheNodes:
	#		if(!_node):
	#			CacheNodes = []
	#			_tick_cache_nodes_size()

func get_unused_node() -> Node:
	for i in range(CacheNodes.size()):
		if(!UsedNodes[i]):
			UsedNodes[i] = true
			return CacheNodes[i]
	return null

func set_unused_node(_node : Node) -> void:
	UsedNodes[CacheNodes.find(_node)] = false

func reset_used_id() -> void:
	UsedNodes.clear()
	_tick_cache_nodes_size()

func set_used_id(state : bool, id : int) -> void:
	UsedNodes[id] = state

func get_used_id(id : int) -> bool:
	return UsedNodes[id]

func _tick_cache_nodes_size() -> void:
	CacheNodes = get_children()
	UsedNodes.resize(CacheNodes.size())

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
			if("Id" in copy): copy.id = i
			print("Added child " + str(SampleNode))
	elif(_dif_amount < 0):
		for i in range(CacheNodes.size()-1, CacheNodes.size()-1-abs(_dif_amount)):
			get_cache_node(i).queue_free()
	_tick_cache_nodes_size()
