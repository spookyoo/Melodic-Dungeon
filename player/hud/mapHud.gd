extends GridContainer

@export var gridTile : PackedScene
@export var dungeonWidth : int = 5
@export var dungeonHeight : int = 5

var dungeon
var completed

func _ready():
	var n = 0
	var nTiles = dungeonWidth * dungeonHeight
	for tile in range(nTiles):
		var new = gridTile.instantiate()
		add_child(new)
	#getChildAt(3,3).modulate.a = 1.0

func updateMap(x,z):
	print(completed)
	for child in get_children():
		child.modulate.a = 0.0
		child.get_node("inner").color = Color(0.553, 0.435, 0.687)
	
	var grid = getGrid(x,z)
	print(grid)
	for row in range(grid.size()):
		for column in range(grid[row].size()):
			if (grid[row][column] > 0):
				if (grid[row][column] == 1):
					pass
				else:
					
				#print(str(row) + " " + str(column))
					getChildAt(row,column).modulate.a = 1.0
	getChildAt(2,2).modulate.a = 1.0
	getChildAt(2,2).get_node("inner").color = Color(0.831, 0.745, 0.894)
	return

#HELPER FUNCTIONS
func getChildAt(hudX, hudY):
	return self.get_child(hudX * dungeonWidth + hudY)

func getGrid(x,z):
	var upperX = x + 2
	var lowerX = x - 2
	var upperZ = z + 2
	var lowerZ = z - 2
	var newGrid = []
	
	for row in range(lowerX, upperX+1):
		var gridRow = []
		for column in range(lowerZ, upperZ+1):
			if row < 0 or row >= len(dungeon) or column < 0 or column >= len(dungeon[0]):
				gridRow.append(0)
			elif (dungeon[row][column] > 0):
				if dungeon[row][column] == 3:
					gridRow.append(3)
				elif completed.has([row,column]):
					gridRow.append(2)
				else:
					gridRow.append(1)
			else:
				gridRow.append(0)
		newGrid.append(gridRow)
	newGrid.reverse()
	return newGrid

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
