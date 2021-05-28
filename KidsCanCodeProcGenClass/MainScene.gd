extends Node2D

var room = preload("res://Room/BasicRoom.tscn")

var tileSize = 32
var numRooms = 40
var minSize = 4
var maxSize = 10

func _ready():
	randomize()
	makeRooms()

func _draw():
	for room in $Rooms.get_children():
		draw_rect( Rect2( room.position - room.size , room.size * 2 ) , Color8( 32, 255, 0 , 255 ) , false )

func _process( delta ):
	update()

func _input( event ):
	if event.is_action_pressed('ui_select'):
		for room in $Rooms.get_children():
			room.queue_free()
		makeRooms()

func makeRooms():
	for i in range( numRooms ):
		var pos = Vector2(0,0)
		var r = room.instance()
		
		var w = minSize + randi() % ( maxSize - minSize )
		var h = minSize + randi() % ( maxSize - minSize )
		r.makeRoom( pos , Vector2( w , h ) * tileSize )
		add_child( r )


