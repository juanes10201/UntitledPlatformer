extends Line2D

@export var FallCooldown : Timer
@export var MoveRef : Node2D
@export var Path : Path2D
@export var PathFollow : PathFollow2D
@onready var Player = SaveGame.get_player()
var PlayerDistance : Vector2
@export var DistanceCollide : int = 7
var PlayerOffset : float
@export var MoveSpeed : float = 700
@export var OnWaterSpeedMult : float = 0.8
@export var PlayerMovOffset : Vector2 = Vector2(0.0, -5.0)
var PlayerSnapped : bool = false
@export var EndWithSlam : bool = false

@export var KickDirection : Global.GravityDirections = Global.GravityDirections.MAIN

@export var KickMult : float = 30
@onready var InitialCollisionArea = $InitialCollisionArea
@onready var InitialCollisionAreaShape = $InitialCollisionArea/CollisionShape2D
@export var EndSpeed : float = 1000.0

@export var AddedPlayerGradient : GradientTexture1D
@onready var InitialGradient : Gradient = gradient.duplicate()

const AreaCollisionExpand : float = 100.0
const MarginPlayerGradient : float = 20.0

var CurrentAngle : float = -45.0

var NormalizedVel : Vector2

const MarginNewPointEditor : Vector2 = Vector2(20.0, 0.0)
const MarginButtonAddNewPointEditor : Vector2 = Vector2(25.0, -25.0)
@export var AddPointEditorButton : Button
@export var RemovePointEditorButton : Button
@onready var EditorRailSupport : Node2D = $EditorRailSupport

var MinPointRail : Vector2 = Vector2(0.0, 0.0)
var MaxPointRail : Vector2 = Vector2(0.0, 0.0)

func update_added_gradient() -> void:
	var _base_gradient : Gradient = AddedPlayerGradient.get_gradient()
	var _gradient_length = AddedPlayerGradient.get_width()
	
	var _initial_point : Vector2 = points[points.size()-1]
	var _final_point : Vector2  = points[0]
	
	var _rail_length = _initial_point.distance_to(_final_point)
	var _relative_player_length = (Player.global_position).distance_to(_initial_point+global_position)
	#Esto marca el pto desde 0.0 a 1.0 en el que se encuentra el jugador
	
	var _player_rail_length = 1.0-_relative_player_length/_rail_length
	var _relative_gradient : Gradient
	
	if(Player.global_position.x <= (MinPointRail.x+global_position.x+MarginPlayerGradient) || Player.global_position.y >= (MaxPointRail.y+global_position.y) ):
		_player_rail_length = 0.0
	elif(Player.global_position.x > (MinPointRail.x+global_position.x-MarginPlayerGradient) || Player.global_position.y <= (MinPointRail.x+global_position.y+MarginPlayerGradient)):
		_player_rail_length = 1.0
	print("Min point: " + str(MinPointRail))
	print("Max point: " + str(MaxPointRail))
	print("Length: " + str(_rail_length))
	print("relative: " + str(_relative_player_length))
	print(_player_rail_length)
	if(PlayerSnapped):
		#_player_rail_length = clamp$"../TextArea/DashTutorial2"f(_player_rail_length, 0.0, 1.0)
		_relative_gradient = _base_gradient.duplicate()
		for i in range(_relative_gradient.offsets.size()):
			var _offset = _relative_gradient.get_offset(i)
			var _new_offset = _offset*_player_rail_length
			_relative_gradient.set_offset(i, _new_offset)
	else:
		_relative_gradient = InitialGradient
	
	gradient = _relative_gradient
	#texture.set_gradient(_relative_gradient)

func editor_remove_point() -> void:
	if(points.size() <= 2): queue_free()
	remove_point(points.size()-1)
	if(EditorRailSupport):
		EditorRailSupport._cache_points()
		EditorRailSupport.NodeCachePoints.CacheNodes[points.size()].hide()

func editor_add_point() -> void:
	var NewPosition : Vector2 = points[points.size()-1]+MarginNewPointEditor 
	add_point(NewPosition)
	if(EditorRailSupport):
		EditorRailSupport._cache_points()

func reload_path() -> void:
	ReloadedPath = true
	var min_pos : Vector2 = points[0]
	var max_pos : Vector2 = points[0]
	#Esto todavia no esta porque la parte donde se centra la posicion esta mal hecha.
	#Basicamente lo que pasa es que el centro del node de rail no es el mismo que el de los puntos del line2d
	#hay que tener en cuenta que el tamaño de la colision se centra automaticamente
	#entonces lo que hice es 'desentrarlo', pero eso es solo una parte del problema
	#lo que queda ahora es centrarlo para la posicion del medio del otro
	#y eso se haria primero calculando el punto(que es igual al promedio de todos los demas puntos
	#y despues sumarle la distancia que tiene al mismo en cada eje
	Path.global_position = self.global_position
	Path.curve.clear_points()
	var MediumPoint : Vector2 = Vector2(0.0, 0.0)
	for point in points:
		if(point.x < min_pos.x): min_pos.x = point.x
		if(point.y < min_pos.y): min_pos.y = point.y
		if(point.x > max_pos.x): max_pos.x = point.x
		if(point.y > max_pos.y): max_pos.y = point.y
		MediumPoint.x += point.x
		MediumPoint.y += point.y
		Path.curve.add_point(point)
	MediumPoint.x /= points.size()
	MediumPoint.y /= points.size()
	InitialCollisionAreaShape.shape.size.x = abs(max_pos.x-min_pos.x)
	InitialCollisionAreaShape.shape.size.y = abs(max_pos.y-min_pos.y)
	InitialCollisionArea.position.x = MediumPoint.x#abs(max_pos.x-min_pos.x)/2
	InitialCollisionArea.position.y = MediumPoint.y#abs(max_pos.y-min_pos.y)/2
	
	InitialCollisionAreaShape.shape.size.x += AreaCollisionExpand
	InitialCollisionAreaShape.shape.size.y += AreaCollisionExpand
	MinPointRail = Vector2(min_pos.x, min_pos.y)
	MaxPointRail = Vector2(max_pos.x, max_pos.y)

func _ready() -> void:
	reload_path()

var ReloadedPath : bool = false

func _process(delta: float) -> void:
	update_added_gradient()
	#update_added_gradient()
	
	#print("pos: " + str(global_position))
	if(Edition.Is_in_editor):
		if(AddPointEditorButton && RemovePointEditorButton):
			AddPointEditorButton.position = points[points.size()-1]+MarginButtonAddNewPointEditor
			RemovePointEditorButton.position = points[points.size()-1]-MarginButtonAddNewPointEditor
		if(!Edition.Is_playing_in_editor): ReloadedPath = false
		elif(!ReloadedPath): reload_path()
		
	#print(PlayerInArea)
	#print(Player.velocity.x)
	var PrevPosition = PathFollow.global_position
	if(Player):
		if(Player.OnWater):
			PathFollow.progress += MoveSpeed * delta * OnWaterSpeedMult
		else:
			PathFollow.progress += MoveSpeed * delta
		PlayerDistance = Path.curve.get_closest_point(to_local(Player.global_position))
		#if(PlayerDistance.distance_to(to_local(Player.global_position)) <= DistanceCollide):
			#print("Snappable")
		if(PlayerInArea && PlayerDistance.distance_to(to_local(Player.global_position)) <= DistanceCollide && !Player.SnappedOnRail && FallCooldown.is_stopped()):
			if(Player.Slide || Player.GroundSmash):
				PlayerOffset = Path.curve.get_closest_offset(to_local(Player.global_position))
				PathFollow.progress = PlayerOffset
				Player.SnappedOnRail = true
				PlayerSnapped = true
				print("Player snapped on rail")
		if(Player.SnappedOnRail && PlayerSnapped):				
			Player.Sprite.JuiceStretchLogic.stretch_size(Vector2(1.2, .8), Vector2(.8, 1.2), .7,true, true)
			Player.Reset_Slide()
			Player.Dashed = false
			Player.PressedSlide = false
			Player.LastDirection = 1 if NormalizedVel.x > 0 else -1
			Player.direction = 1 if NormalizedVel.x > 0 else -1
			Player.global_position = MoveRef.global_position + PlayerMovOffset
			Player.Sprite.rotation_degrees = PathFollow.rotation_degrees
			if(Input.is_action_just_pressed("player_jump")):
				EndPlayerRail(EndWithSlam, Player.jump_velocity * Player.GravityDirection, 90.0, false)
			if(PathFollow.progress_ratio >= 1.0):
				EndPlayerRail(EndWithSlam, EndSpeed, CurrentAngle, true, NormalizedVel.x < 0, NormalizedVel.y < 0)
			FallCooldown.start()
	NormalizedVel = (PathFollow.global_position-PrevPosition).normalized()
	CurrentAngle = rad_to_deg(atan(NormalizedVel.y/NormalizedVel.x))

func _calc_player_velocity(velocity : float, angle : float) -> Vector2:
	var angle_rad = deg_to_rad(angle)
	var x = velocity*cos(angle_rad)
	var y = velocity*sin(angle_rad)
	return Vector2(x, y)

func EndPlayerRail(EndSlam : bool = false, EndSpeed : float = 100.0, Angle : float = 45.0, MoveX : bool = true, InvertXMovement : bool = false, InvertYMovement : bool = false) -> void:
	#var _direction = 1 if NormalizedVel.x >= 0 else -1
	#var InvertSlide : int = 1
	#if Player.Slide && (_direction != Player.SlidingDirection) :
		#print("INVERT")
		#print("Dir: " + str(Player.Sides.LEFT))
		#print("Normalized: " + str(NormalizedVel.x))
		#InvertSlide = -1
	#print(Player.SlidingDirection)
	#print("Invert: " + str(_direction) )
	
	Player.global_position = MoveRef.global_position + PlayerMovOffset
	Player.SnappedOnRail = false
	PlayerSnapped = false
	Player.Sprite.rotation = 0.0
	Player.Reset_Slide()
	Player.PressedSlide = false
	Player._fade_sound(Player.AudioRail)
	if(!EndSlam):
		Player.Reset_Groundsmash(false)
		var _velocity : Vector2 = _calc_player_velocity(EndSpeed, Angle)
		print("velocity: " + str(_velocity))
		print("Angle: " + str(Angle))
		Player.velocity.y = _velocity.y
		if(InvertYMovement): Player.velocity.y *= -1
		if(MoveX):
			#Player.Speed.x = 0.0
			#Player.KickTimer.start()
			Player.Speed.x = _velocity.x*KickMult * KickDirection
			if(InvertXMovement): Player.Speed.x *= -1
			#if(PathFollow.rotation_degrees >= 100.0): Player.KickSpeed.x *= -1
		else:
			Player.Speed.x = 0
	else:
		Player.GroundSmash = true
		Player.PressingGroundSmash = true

var PlayerInArea : bool = false

func _on_initial_collision_area_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		Player = body
		PlayerInArea = true


func _on_initial_collision_area_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		PlayerInArea = false
