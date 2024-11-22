extends Node3D

@export var doorN = false
@export var doorE = false
@export var doorS = false
@export var doorW = false

var location
var doors = []

signal roomStart #signal -> generation

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func drawDoors():
	if doorN:
		$wallN.visible = false
		$wallN/CollisionShape3D.disabled = true
		$doorN.visible = true
		$doorN/CollisionShape3DL.disabled = false
		$doorN/CollisionShape3DR.disabled = false
	if doorE:
		$wallE.visible = false
		$wallE/CollisionShape3D.disabled = true
		$doorE.visible = true
		$doorE/CollisionShape3DL.disabled = false
		$doorE/CollisionShape3DR.disabled = false
	if doorS:
		$wallS.visible = false
		$wallS/CollisionShape3D.disabled = true
		$doorS.visible = true
		$doorS/CollisionShape3DL.disabled = false
		$doorS/CollisionShape3DR.disabled = false
	if doorW:
		$wallW.visible = false
		$wallW/CollisionShape3D.disabled = true
		$doorW.visible = true
		$doorW/CollisionShape3DL.disabled = false
		$doorW/CollisionShape3DR.disabled = false

func openDoors(directions):
	for direction in directions:
		match direction:
			"up":
				$doorN/door.visible = false
				$doorN/door/CollisionShape3D.disabled = true
			"right":
				$doorE/door.visible = false
				$doorE/door/CollisionShape3D.disabled = true
			"down":
				$doorS/door.visible = false
				$doorS/door/CollisionShape3D.disabled = true
			"left":
				$doorW/door.visible = false
				$doorW/door/CollisionShape3D.disabled = true

func closeDoors(directions):
	for direction in directions:
		match direction:
			"up":
				$doorN/door.visible = true
				$doorN/door/CollisionShape3D.disabled = false
			"right":
				$doorE/door.visible = true
				$doorE/door/CollisionShape3D.disabled = false
			"down":
				$doorS/door.visible = true
				$doorS/door/CollisionShape3D.disabled = false
			"left":
				$doorW/door.visible = true
				$doorW/door/CollisionShape3D.disabled = false
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_room_entered(area):
	roomStart.emit(location[0],location[1])
