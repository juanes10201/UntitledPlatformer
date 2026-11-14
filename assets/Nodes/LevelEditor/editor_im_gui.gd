extends Node2D

@export var EditorPlace : Node2D
var AnalizedBody : Node2D = null
@export var Editor : Node2D

var SelectingMultipleRepeatedElements : Dictionary = {}
var SelectingMultipleAnalize : Array[Dictionary] = []

var SelectingMultipleAmount : int = 0

func _calculate_multiple() -> void:
	if((!SelectingMultipleRepeatedElements
	|| SelectingMultipleAmount != EditorPlace.SelectedNodes.size())
	&& EditorPlace.SelectedNodes):
		SelectingMultipleAnalize = []
		SelectingMultipleAmount = EditorPlace.SelectedNodes.size()
		var ExampleNode : Node2D = EditorPlace.SelectedNodes[0]
		#Crear un diccionario que contenga todos los Nodos que esten
		for property in ExampleNode.get_property_list() :
			if(property.usage & PROPERTY_USAGE_EDITOR && property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
				SelectingMultipleRepeatedElements.set(property.name, 0)
		#Luego pasar por cada elemento de cada nodo y checkear la cantidad de veces que este
		for node in EditorPlace.SelectedNodes:
			for property in node.get_property_list() :
				if(property.usage & PROPERTY_USAGE_EDITOR && property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
					if(property.name in SelectingMultipleRepeatedElements && node.get(property.name) == ExampleNode.get(property.name)):
						SelectingMultipleRepeatedElements[property.name] += 1
		#Ahora volver a pasar por el primer nodo y pasar a SelectingMultipleAnalize los que estan
		for property in ExampleNode.get_property_list() :
			if(property.usage & PROPERTY_USAGE_EDITOR && property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
				#La cantidad de veces que esta tiene que ser igual a la longitud de la cantidad de elementos
				if(SelectingMultipleRepeatedElements[property.name] >= EditorPlace.SelectedNodes.size()):
					SelectingMultipleAnalize.append(property)
	#Finalmente mostrar en la interfaz los datos
	if(EditorPlace.SelectedNodes):
		#AnalizedBody = EditorPlace.SelectedNodes[0]
		for property in SelectingMultipleAnalize:
			if(ImGuiShowProperty(property)):
				for node in EditorPlace.SelectedNodes:
					node.set(property.name, AnalizedBody.get(property.name))
			
			##Resetear los elementos para volver a precalcular todo
			##SelectingMultipleRepeatedElements = {}
var FontPointers : Array = []

func _ready() -> void:
	SetupImGui()

func SetupImGui() -> void:
	print("Loading ImGui!")
	FontPointers = ImGuiGD.GetFontPtrs()
	var Style = ImGui.GetStyle()
	Style.WindowRounding = 12.0
	var cols = Style.Colors
	cols[ImGui.Col_WindowBg] = Color("11032bad")
	cols[ImGui.Col_TitleBg] = Color("330d5ecd")
	cols[ImGui.Col_TitleBgActive] = Color("44147bd9")
	cols[ImGui.Col_TitleBgCollapsed] = Color("300b59af")
	cols[ImGui.Col_Button] = Color("44147bff")
	cols[ImGui.Col_Tab] = Color("44147bff")
	cols[ImGui.Col_Header] = Color("44147bff")
	cols[ImGui.Col_MenuBarBg] = Color("44147bff")
	cols[ImGui.Col_ButtonActive] = Color("44147bff")
	cols[ImGui.Col_ButtonHovered] = Color("44147bff")
	cols[ImGui.Col_Separator] = Color("44147bff")
	cols[ImGui.Col_SliderGrab] = Color("44147bff")
	cols[ImGui.Col_SliderGrabActive] = Color("44147bff")
	cols[ImGui.Col_Border] = Color("44147bff")
	cols[ImGui.Col_FrameBg] = Color("330c5e9d")
	cols[ImGui.Col_FrameBgActive] = Color("50188e9d")
	cols[ImGui.Col_FrameBgHovered] = Color("330c5ebc")
	cols[ImGui.Col_BorderShadow] = Color("340d6072")
	cols[ImGui.Col_CheckMark] = Color("cfbcfcff")
	Style.Colors = cols

func DrawImGuiTitle(txt : String) -> void: 
	ImGui.PushFont(FontPointers[1])
	ImGui.Text(txt)
	ImGui.PopFont()

func DrawImGuiSubTitle(txt : String) -> void: 
	ImGui.PushFont(FontPointers[2])
	ImGui.Text(txt)
	ImGui.PopFont()

func AnalizeBody(Body : Node2D) -> void:
	if(EditorPlace.SelectedNodes && EditorPlace.SelectingMultiple):
		AnalizedBody = EditorPlace.SelectedNodes[0]
	else:
		AnalizedBody = Body

func AnalizeAdvancedBodyTick() -> void:
	if(AnalizedBody):
		ImGui.Text("All variables in " + str(AnalizedBody.name))
		for property in AnalizedBody.get_property_list() :
			if(property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
				ImGui.Text(property.name + ": " + str(AnalizedBody.get(property.name)))

func ImGuiShowProperty(property) -> bool:
	#Enum
	if(!AnalizedBody): return false
	var ChangedValue : bool = false
	if property.type == TYPE_INT && property.hint == PROPERTY_HINT_ENUM:
		var options : PackedStringArray = property.hint_string.split(",")
		var raw_value = AnalizedBody.get(property.name)
		if typeof(raw_value) == TYPE_INT or typeof(raw_value) == TYPE_FLOAT:
			var arr = [AnalizedBody.get(property.name) as int]
			if ImGui.Combo(property.name, arr, options):
				AnalizedBody.set(property.name, arr[0])
				ChangedValue = true
	#all other data types
	else:
		match property.type:
			TYPE_COLOR:
				var col: Color = AnalizedBody.get(property.name)
				var arr := [col.r, col.g, col.b, col.a]
				if(ImGui.ColorEdit4(property.name, arr)):
					AnalizedBody.set(property.name, Color(arr[0], arr[1], arr[2], arr[3]))
					ChangedValue = true
			TYPE_BOOL:
				var arr := [AnalizedBody.get(property.name)]
				if(ImGui.Checkbox(property.name, arr )):
					AnalizedBody.set(property.name, arr[0])
					ChangedValue = true
			TYPE_INT:
				var arr := [AnalizedBody.get(property.name)]
				if(ImGui.InputInt(property.name, arr )):
					AnalizedBody.set(property.name, arr[0])
					ChangedValue = true
			TYPE_FLOAT:
				var arr := [AnalizedBody.get(property.name)]
				if(ImGui.InputFloat(property.name, arr )):
					AnalizedBody.set(property.name, arr[0])
					ChangedValue = true
			TYPE_VECTOR2:
				var v : Vector2 = AnalizedBody.get(property.name)
				var arr := [v.x, v.y]
				if(ImGui.InputFloat2(property.name, arr)):
					AnalizedBody.set(property.name, Vector2(arr[0], arr[1]) )
					ChangedValue = true
	return ChangedValue

var LastImGuiTitle : String = ""
var DrawedImGuiTitle : bool = false
var OpenedCategories : Dictionary[String, bool] = {}
const InternalVariablesCategoryName : String = "Internal"
@export var GeneralVariables : Array[String] = []

func AnalizeBodyTick() -> void:
	#If selected multiple elements
	if(EditorPlace.SelectingMultiple):
		_calculate_multiple()
	else:
		if(AnalizedBody):
			DrawImGuiTitle("Inspecting " + str(AnalizedBody.name))
			for property in AnalizedBody.get_property_list() :
				#En caso de ser una variable @Export
				if((property.usage & PROPERTY_USAGE_EDITOR
				&& property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE)
				|| property.name in GeneralVariables):
					######Esto cambia dependiendo del tipo d variable######
					if(LastImGuiTitle == InternalVariablesCategoryName):
						continue
					if(!DrawedImGuiTitle):
						#ImGui.PushFont(FontPointers[1])
						var section_open = ImGui.CollapsingHeader(LastImGuiTitle)
						#ImGui.PopFont()
						OpenedCategories[LastImGuiTitle] = section_open
						DrawedImGuiTitle = true
					if(OpenedCategories[LastImGuiTitle]):
						ImGuiShowProperty(property)
				elif(property.usage & PROPERTY_USAGE_GROUP):#PROPERTY_USAGE_CATEGORY):# || property.usage & PROPERTY_USAGE_GROUP):
					#Si esta documentada por Godot entonces no es una categoria propia
					LastImGuiTitle = property.name
					DrawedImGuiTitle = false

func _process(delta):
	ImGui.Begin("Node Parameters")
	AnalizeBodyTick()
	ImGui.End()
	if(Editor.AdvancedMode):
		AnalizeAdvancedBodyTick()
	if(EditorPlace.LastCollidedBody != AnalizedBody):
		AnalizeBody(EditorPlace.LastCollidedBody)
