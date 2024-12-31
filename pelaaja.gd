extends Node3D

var pos_x: int
var pos_z: int
var playerno: int
var score: int = 0

func check_direction(dir):
	var allowed = false
	if dir == "left":
		$Ray.target_position = Vector3(-3,0,0)
	if dir == "right":
		$Ray.target_position = Vector3(3,0,0)
	if dir == "up":
		$Ray.target_position = Vector3(0,0,-3)
	if dir == "down":
		$Ray.target_position = Vector3(0,0,3)
	$Ray.force_raycast_update()
	if $Ray.get_collider() == null:
		allowed = true
	return allowed
	
func move_left():
	if check_direction("left") && $player_timer.time_left == 0:
		pos_x -= 1
		$player_timer.start()

func move_right():
	if check_direction("right") && $player_timer.time_left == 0:
		pos_x += 1
		$player_timer.start()

func move_up():
	if check_direction("up") && $player_timer.time_left == 0:
		pos_z -= 1
		$player_timer.start()
		
func move_down():
	if check_direction("down") && $player_timer.time_left == 0:
		pos_z += 1
		$player_timer.start()

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
