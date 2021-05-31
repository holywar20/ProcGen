extends Node2D

var room = preload("res://Room/BasicRoom.tscn")

var tileSize = 32
var numRooms = 40
var minSize = 4
var maxSize = 10
var hspread = 400
var cull = 0.5

var path # AStar pathfinding object

func _ready():
	randomize()
	makeRooms()

func _draw():
	for room in $Rooms.get_children():
		draw_rect( Rect2( room.position - room.size , room.size * 2 ) , Color8( 32, 255, 0 , 255 ) , false )
	
	if( path ):
		for p in path.get_points():
			for c in path.get_point_connections( p ):
				var pp = path.get_point_position( p )
				var cc = path.get_point_position( c )
				
				draw_line( Vector2(pp.x , pp.y) , Vector2(cc.x , cc.y ), Color8( 200, 255, 0 , 255 ) )

func _process( delta ):
	update()

func _input( event ):
	if event.is_action_pressed('ui_select'):
		for room in $Rooms.get_children():
			room.queue_free()
		makeRooms()

func makeRooms():
	for i in range( numRooms ):
		var pos = Vector2( rand_range(-hspread, hspread ) ,0)
		var r = room.instance()
		
		var w = minSize + randi() % ( maxSize - minSize )
		var h = minSize + randi() % ( maxSize - minSize )
		r.makeRoom( pos , Vector2( w , h ) * tileSize )
		$Rooms.add_child( r )
		
	yield( get_tree().create_timer(1.1) , 'timeout' )
	
	var roomPositions = []
	for room in $Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.mode = RigidBody2D.MODE_STATIC
			roomPositions.append( Vector3( room.position.x , room.position.y , 0 ) )
			
	yield( get_tree() , 'idle_frame' )
	
	# Generate a minimum spanning tree
	path = findMST( roomPositions )
	
func findMST( nodes ):
	# Prims Algortithm
	var path = AStar.new()
	path.add_point( path.get_available_point_id() ,  nodes.pop_front() )
	
	while nodes:
		var minDist = INF
		var minPos = null
		var current = null
		
		for p1 in path.get_points():
			p1 = path.get_point_position( p1 )
			
			for p2 in nodes:
				if p1.distance_to(p2) < minDist:
					minDist = p1.distance_to( p2 )
					minPos = p2
					current = p1
		var newPoint = path.get_available_point_id()
		path.add_point( newPoint , minPos  )
		path.connect_points( path.get_closest_point( current ) , newPoint )
		nodes.erase( minPos )
		
	return path


