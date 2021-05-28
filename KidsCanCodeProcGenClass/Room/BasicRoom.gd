extends RigidBody2D

var size

func makeRoom( _pos : Vector2 , _size : Vector2 ):
	position = _pos
	size = _size
	
	var s = RectangleShape2D.new()
	s.extents = size
	$CollisionShape2D.set_shape( s )
