extends Node3D

@export var doorN = false
@export var doorE = false
@export var doorS = false
@export var doorW = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func doors():
	if doorN:
		$wallN.visible = false
		$wallN.use_collision = false
		$doorN.visible = true
		$doorN/doorL.use_collision = true
		$doorN/doorR.use_collision = true
		$doorN/doorM.use_collision = true
	if doorE:
		$wallE.visible = false
		$wallE.use_collision = false
		$doorE.visible = true
		$doorE/doorL.use_collision = true
		$doorE/doorR.use_collision = true
		$doorE/doorM.use_collision = true
	if doorS:
		$wallS.visible = false
		$wallS.use_collision = false
		$doorS.visible = true
		$doorS/doorL.use_collision = true
		$doorS/doorR.use_collision = true
		$doorS/doorM.use_collision = true
	if doorW:
		$wallW.visible = false
		$wallW.use_collision = false
		$doorW.visible = true
		$doorW/doorL.use_collision = true
		$doorW/doorR.use_collision = true
		$doorW/doorM.use_collision = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
