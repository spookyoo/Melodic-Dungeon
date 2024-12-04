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
	for child in get_children():
		child.modulate.a = 0.0
		child.get_node("inner").color = Color(0.584, 0.468, 0.718)
	
	var grid = getGrid(x,z)
	for row in range(grid.size()):
		for column in range(grid[row].size()):
			if (grid[row][column] > 0):
				if (grid[row][column] == 1 || grid[row][column] == 3):
					if getAdjacent(row,column,grid):
						getChildAt(row,column).modulate.a = 1.0
						if grid[row][column] == 1:
							getChildAt(row,column).get_node("inner").color = Color(0.338, 0.247, 0.438)
						else:
							getChildAt(row,column).get_node("inner").color = Color(0.747, 0.365, 0.683)
				else:
					getChildAt(row,column).modulate.a = 1.0

	getChildAt(2,2).modulate.a = 1.0
	getChildAt(2,2).get_node("inner").color = Color(0.831, 0.745, 0.894)
	getAdjacent(2,2,grid)
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
	newGrid[2][2] = 2
	newGrid.reverse()
	return newGrid

func getAdjacent(x,z,grid):
	if z > 0 && grid[x][z-1] == 2:
		return true
	if z < 4 && grid[x][z+1] == 2:
		return true
	if x > 0 && grid[x-1][z] == 2:
		return true
	if x < 4 && grid[x+1][z] == 2:
		return true
	return false

func inBounds(x, z):
	return (x > -1 && x < 5) && (z > -1 && z < 5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
