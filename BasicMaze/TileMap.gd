extends TileMap

const N = 1
const E = 2
const S = 4
const W = 8

var tileSize = 64
var width = 40
var height = 40
var spacing = 2
var eraseDensity = .6

var mySeed = 0

const SN_ROAD = 5
const EW_ROAD = 10

onready var tileMapCamera = $Camera2D

# Notice the keys are actually direction vectors.
# Note the use of spacing here.
var cellWalls = {
	Vector2( 0  , -spacing ) : N,
	Vector2( spacing  , 0 ) : E,
	Vector2( 0  ,spacing ): S, 
	Vector2( -spacing , 0) :W
}

# Render as isometric

func _ready():
	randomize()

	if( !mySeed ):
		mySeed = randi()
	makeBlankMap()
	
	tileMapCamera.set_zoom( Vector2( 3 , 3 ) )
	tileMapCamera.set_position( Vector2( width * 50 / 2 , height * 50 / 2 ) )

	makeMaze()
	_eraseWalls()

func makeBlankMap():
	for x in range( 0 , width ):
		for y in range( 0, height ):
			set_cell( x, y ,  N|S|E|W )

func makeMaze():
	var unvisited : Array = []
	var stack : Array = []

	# Populate unvisited with all checked nodes
	for x in range( 0 , width , spacing ):
		for y in range( 0, height , spacing ):
			unvisited.append( Vector2( x , y ) )

	var currentCell = Vector2( 0 , 0 )
	unvisited.erase( currentCell )

	while unvisited:
		var neighborCells = checkNeighbors( currentCell, unvisited )
		if( neighborCells.size() > 0 ):
			# first put it in the stack, we may need to go back.
			var nextCell : Vector2 = neighborCells[randi() % neighborCells.size()]
			stack.append( currentCell )

			# delta will always be a valid key for 'cell-walls'
			var delta : Vector2 = nextCell - currentCell
			
			# Delta and -delta return integers of 1, 2, 4 or 8
			var currentWalls : int = get_cellv( currentCell ) - cellWalls[delta]
			var nextWalls : int = get_cellv( nextCell ) - cellWalls[-delta]
			
			# Set walls to new values
			set_cellv( nextCell , nextWalls )
			set_cellv( currentCell , currentWalls )

			if delta.x != 0:
				set_cellv( currentCell + delta / spacing , SN_ROAD )
			else:
				set_cellv( currentCell + delta / spacing , EW_ROAD )

			# remove checks
			currentCell = nextCell
			unvisited.erase( currentCell )
		else:
			# current has no valid neighbors. So pop off stack, and run it again.
			#yield(get_tree().create_timer(.005), "timeout")
			currentCell = stack.pop_back()

func _eraseWalls():
	for _c in range( spacing , int( width * height * eraseDensity / spacing ) ):
		var x = int( rand_range( 2 , width / 2 - 2 ) ) * spacing
		var y = int( rand_range( 2 , height / 2 - 2 ) ) * spacing

		print( x , " " , y )

		var currentV = Vector2( x , y )
		var currentWalls = get_cellv( currentV )
		
		var dir : Vector2 = cellWalls.keys()[randi() % cellWalls.size()]

		# Bitwise math. IE a cell of 15 is true if neighbor is 8.
		if currentWalls & cellWalls[dir]:
			currentWalls = currentWalls - cellWalls[dir]
			
			var neighborV : Vector2 = currentV + dir  
			var neighborWalls = get_cellv( neighborV ) - cellWalls[-dir]
			set_cellv( neighborV , neighborWalls)
			set_cellv( currentV , currentWalls )

			if dir.x != 0:
				set_cellv( currentV + dir / spacing , SN_ROAD )
			else:
				set_cellv( currentV + dir / spacing , EW_ROAD )



# Check all the neighbors of a cell and return a list of those found inside unvisited.
func checkNeighbors( cell : Vector2 , unvisited : Array ):
	var list : Array = []

	# cell + n are two vectors that give us a direction change
	for n in cellWalls.keys():
		if cell + n in unvisited:
			list.append( cell + n )

	return list
