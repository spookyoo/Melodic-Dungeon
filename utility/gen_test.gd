extends Node3D

@export var roomScene : PackedScene
@export var dungeonWidth : int = 12
@export var dungeonHeight : int = 12
@export var mainBranchLength : int = 8
@export var roomSize : Vector3 = Vector3(30,0,30)

@onready var camera = $Camera3D

var floors = []
var mainBranch = []
var endRoom = []
var rooms = {}
var lastDirection = ""
var moveHistory = 0

var starterNode
var endNode


func _ready():
	print("---------------------")
	generateDungeon()
	print(rooms)

func _input(event):
	if Input.is_action_just_pressed("reload"):
		get_tree().change_scene_to_file("res://environment/gen_test.tscn")

func generateDungeon():
	floors = []
	for x in range(dungeonWidth):
		var column = []
		for z in range(dungeonHeight):
			column.append(0)
		floors.append(column)
#PATHING
	mainPath()
#INSTANTIATE ROOMS
	for x in range(dungeonWidth):
		for z in range(dungeonHeight):
			if floors[x][z] != 0:
				instantiateRoom(x,z)
#CLEAN

func instantiateRoom(x,z):
	var newRoom = roomScene.instantiate()
	rooms[[x,z]] = [newRoom,1]
	newRoom.position = Vector3(x * roomSize.x, 0, z * roomSize.z)
	add_child(newRoom)

func mainPath():
	var backtrack
	var previous
	var current = [0, randi_range(dungeonHeight/4,(dungeonHeight/4)*3)]
	var verticalChance = 0.3
	var previousDir = ""
	var consecutiveMoves = 0
	
	floors[current[0]][current[1]] = 2
	for room in range(mainBranchLength):
		while true:
			var validDirections = getValidDirections(current)
			if validDirections.size() > 0:
				var direction = chooseDirection(validDirections, verticalChance)
				current = moveInDirection(current, direction)
				floors[current[0]][current[1]] = 1
				mainBranch.append(current)
				break
			else:
				# BACKTRACK
				print("BACKTRACK")
				if mainBranch.size() > 1:
					mainBranch.pop_back()
					current = mainBranch.back()
				else:
					print("No more backtrack, dungeon generation done.")
					return
	floors[current[0]][current[1]] = 3

#HELPER FUNCTIONS
func moveInDirection(current, direction):
	if direction == "up":
		return [current[0], current[1] - 1]
	elif direction == "down":
		return [current[0], current[1] + 1]
	elif direction == "right":
		return [current[0] + 1, current[1]]
	
func getValidDirections(current):
	var validDirs = []
	if validUp(current[0], current[1]):
		validDirs.append("up")
	if validDown(current[0], current[1]):
		validDirs.append("down")
	if validRight(current[0], current[1]):
		validDirs.append("right")
	return validDirs

func chooseDirection(validDirs, verticalChance):
	var maxStraightLength = ceil(mainBranchLength/3)
	var chosenDirection = ""

	if moveHistory >= maxStraightLength or not validDirs.has(lastDirection):
		validDirs.erase(lastDirection)  # Force change in direction
		moveHistory = 0

	# Choose a new direction based on verticalChance (favor vertical or horizontal)
	if validDirs.has("right") and randf_range(0, 1) > verticalChance:
		chosenDirection = "right"
	else:
		if validDirs.size() > 0:
			chosenDirection = validDirs[randi_range(0, validDirs.size() - 1)]
		else:
			return null  # or any default direction you prefer

	# Track the new direction and update consecutive move counter
	if chosenDirection == lastDirection:
		moveHistory += 1
	else:
		lastDirection = chosenDirection
		moveHistory = 1
	return chosenDirection

func isSquare(current, direction):
	var col = current[0]
	var row = current[1]
	
	match direction:
		"up":
			return hasUp(col, row) and (hasLeft(col, row-1) or hasRight(col, row-1))
		"down":
			return hasDown(col, row) and (hasLeft(col, row+1) or hasRight(col, row+1))
		"right":
			return hasRight(col, row) and (hasUp(col+1, row) or hasDown(col+1, row))
		"left":
			return hasLeft(col, row) and (hasUp(col-1, row) or hasDown(col-1, row))
	return false

func hasRooms(column, row):
	var roomDirs = []
	if hasLeft(column,row):
		roomDirs.append("left")
	if hasRight(column,row):
		roomDirs.append("right")
	if hasUp(column,row):
		roomDirs.append("up")
	if hasDown(column,row):
		roomDirs.append("down")
	return roomDirs

func hasLeft(column, row):
	return inBounds(column-1, row) && floors[column-1][row] != 0
	
func hasRight(column, row):
	return inBounds(column+1, row) &&  floors[column+1][row] != 0

func hasUp(column, row):
	return inBounds(column, row-1) && floors[column][row-1] != 0

func hasDown(column, row):
	return inBounds(column, row+1) && floors[column][row+1] != 0

func validLeft(column, row):
	return inBounds(column-1, row) && !hasLeft(column,row)

func validRight(column, row):
	return inBounds(column+1, row) && !hasRight(column,row)

func validUp(column, row):
	return inBounds(column, row-1) && !hasUp(column,row)

func validDown(column, row):
	return inBounds(column, row+1) && !hasDown(column,row)

func inBounds(column, row):
	return (column > -1 && column < dungeonWidth) && (row > -1 && row < dungeonHeight)
	
func printGrid():
	for row in range(dungeonHeight):
		var line = ""
		for col in range(dungeonWidth):
			line += str(floors[col][row]) + " "
		print(line)
