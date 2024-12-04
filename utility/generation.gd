extends Node3D

@export var roomScene : PackedScene
@export var dungeonWidth : int = 9
@export var dungeonHeight : int = 7
@export var mainBranchLength : int = 8
@export var roomSize : Vector3 = Vector3(30,0,30)

#@onready var camera = $Camera3D
@onready var player = $Player
@onready var mapHud = %Map

@export var enemyScene : PackedScene
var remainingEnemies : int = 0

var floors = []
var mainBranch = []
var endRoom = []
var rooms = {}
var lastDirection = ""
var moveHistory = 0

var startNode = []
var endNode = []

var completed = []

func _ready():
	generateDungeon()
	#for floor in floors:
		#print(floor)
	startRun()
	#print(mapHud.dungeon)

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
	addBranches()
#INSTANTIATE ROOMS
	for x in range(dungeonWidth):
		for z in range(dungeonHeight):
			if floors[x][z] != 0:
				instantiateRoom(x,z)
#CLEAN
	for room in rooms:
		generateDoors(room[0],room[1])
	startRoom()

func instantiateRoom(x,z):
	var newRoom = roomScene.instantiate()
	newRoom.location = [x,z]
	newRoom.roomStart.connect(self.roomActivate)
	
	rooms[[x,z]] = [newRoom,1]
	newRoom.position = Vector3(x * roomSize.x, 0, z * roomSize.z)
	if floors[x][z] == 2:
		startNode.append([x,z])
		startNode.append(newRoom)
		rooms[[x,z]] = [newRoom,2]
	elif floors[x][z] == 3:
		endNode.append([x,z])
		endNode.append(newRoom)
		rooms[[x,z]] = [newRoom,3]
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
				if mainBranch.size() > 1:
					mainBranch.pop_back()
					current = mainBranch.back()
				else:
					print("No more backtrack, dungeon generation done.")
					return
	floors[current[0]][current[1]] = 3

func addBranches():
	var branchCandidates
	var minBranchLength = 1#floor(mainBranchLength/3)
	var maxBranchLength = 2#mainBranchLength/2
	var baseProbability = 0.2#(1/mainBranchLength) + 0.15
	var branchProbability = baseProbability
	if mainBranch.size() > 2:
		branchCandidates = mainBranch.slice(0, mainBranch.size() - 2)
		for room in branchCandidates:
			if randf_range(0,1) <= branchProbability:
				if generateBranch(room,minBranchLength,maxBranchLength): #0.275
					branchProbability = baseProbability - 0.16#(maxBranchLength*0.015)
				else:
					branchProbability += 0.9 #(mainBranchLength/mainBranchLength^2) - 0.07
			else:
				branchProbability += 0.9 #(mainBranchLength/mainBranchLength^2) - 0.07
			branchProbability = clamp(branchProbability, 0, 1)
	else:
		return

func generateBranch(start, min_length, max_length):
	var branch_length = randi_range(min_length, max_length)
	var current = start
	var branch = []
	var lastDirection = ""
	var moveHistory = 0
	
	for i in range(branch_length):
		var validDirs = getValidDirections(current)
		if validDirs.size() == 0:
			break
		var chosenDirection = chooseDirection(validDirs, 0.9)
		if chosenDirection == null:
			break
		current = moveInDirection(current, chosenDirection)
		floors[current[0]][current[1]] = 1
		branch.append(current)
		
	if branch.size() >= min_length:
		return true
	else:
		for room in branch:
			floors[room[0]][room[1]] = 0
		return false

func generateDoors(x,z):
	var target = rooms[[x,z]][0]
	var doorDirections = hasRooms(x,z)
	for direction in doorDirections:
		match direction:
			"left":
				target.doorW = true
				target.doors.append("left")
			"right":
				target.doorE = true
				target.doors.append("right")
			"up":
				target.doorN = true
				target.doors.append("up")
			"down":
				target.doorS = true
				target.doors.append("down")
	target.drawDoors()

func startRoom():
	#camera.position = startNode[1].position
	#camera.position.y += 3
	player.position = startNode[1].position
	player.position.y += 2
	#print(endNode)

func startRun():
	completed.append(startNode[0])
	completedDoors(completed[0][0],completed[0][1])
	mapHud.dungeon = floors

func roomActivate(x,z):
	mapHud.completed = completed
	mapHud.updateMap(x,z)
	#print(str(x) + " " + str(z))
	if ([x,z] != startNode[0]) && !(completed.has([x,z])):
		var target = rooms[[x,z]][0]
		completed.append([x,z])
		closeDoors(x,z)
		
		if [x, z] == endNode[0]:
			# boss room spawning
			var bossScene = preload("res://bosses/RandomizerBoss.tscn")
			var bossInstance = bossScene.instantiate()
			
			# put boss in the center
			var roomCenter = Vector3(x * roomSize.x, 0, z * roomSize.z)
			bossInstance.global_position = roomCenter
			
			add_child(bossInstance)
			remainingEnemies = 1    # track boss as the last enemy
			await isEnemiesDefeated([bossInstance])
		else:
			var enemies = spawnEnemies(x, z)
			remainingEnemies = enemies.size()
			await isEnemiesDefeated(enemies)

		# While theres no more enemies do nothing???
		#while enemies.size() > 0:
			#pass
			
		#await get_tree().create_timer(3.0).timeout
		completedDoors(x,z)
	
func spawnEnemies(x, z) -> Array:
	var enemies = []
	var roomCenter = Vector3(x * roomSize.x, 0, z * roomSize.z)
	var roomMin = Vector3(roomCenter.x - roomSize.x / 2 + 5, 0, roomCenter.z - roomSize.z / 2 + 5)
	var roomMax = Vector3(roomCenter.x + roomSize.x / 2 - 5, 0, roomCenter.z + roomSize.z / 2 - 5)
	var enemyCount = randi_range(3,5)
	#var playerPos = get_node("Player").global_transform.origin
	
	for i in range(enemyCount):
		var randomPosition = Vector3(
			randf_range(roomMin.x, roomMax.x),      # random x
			1, 
			randf_range(roomMin.z, roomMax.z)
		)
		
		var enemyInstance = enemyScene.instantiate()
		add_child(enemyInstance)
		enemyInstance.call_deferred("set", "global_position", randomPosition)
		#enemyInstance.global_position = randomPosition
		#add_child(enemyInstance)
		#call_deferred("add_child", enemyInstance)
		enemies.append(enemyInstance)
	return enemies

func isEnemiesDefeated(enemies : Array):
	while remainingEnemies > 0:
		await get_tree().create_timer(0.5).timeout
		remainingEnemies = 0
		for i in range(enemies.size()):
			if !is_instance_valid(enemies[i]):
				enemies.erase(i)
			else:
				remainingEnemies += 1
	

func closeDoors(x,z):
	var target = rooms[[x,z]][0]
	target.closeDoors(target.doors)
	

func completedDoors(x,z):
	var target = rooms[[x,z]][0]
	target.openDoors(target.doors)
	for adjacent in getAdjacent(x,z):
		var node = rooms[adjacent][0]
		var directions = []
		for room in getAdjacent(adjacent[0],adjacent[1]):
			if completed.has(room):
				if [adjacent[0],adjacent[1]] == [room[0],room[1]+1]:
					directions.append("up")
				if [adjacent[0],adjacent[1]] == [room[0]-1,room[1]]:
					directions.append("right")
				if [adjacent[0],adjacent[1]] == [room[0],room[1]-1]:
					directions.append("down")
				if [adjacent[0],adjacent[1]] == [room[0]+1,room[1]]:
					directions.append("left")
		node.openDoors(directions)

#HELPER FUNCTIONS
func getAdjacent(x,z):
	var adjacent = []
	for room in hasRooms(x,z):
		match room:
			"up":
				adjacent.append([x,z-1])
			"right":
				adjacent.append([x+1,z])
			"down":
				adjacent.append([x,z+1])
			"left":
				adjacent.append([x-1,z])
	return adjacent


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
		validDirs.erase(lastDirection)
		moveHistory = 0

	if validDirs.has("right") and randf_range(0, 1) > verticalChance:
		chosenDirection = "right"
	else:
		if validDirs.size() > 0:
			chosenDirection = validDirs[randi_range(0, validDirs.size() - 1)]
		else:
			return null

	if chosenDirection == lastDirection:
		moveHistory += 1
	else:
		lastDirection = chosenDirection
		moveHistory = 1
	return chosenDirection

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
