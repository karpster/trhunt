extends Node3D

var pos_x: int
var pos_z: int
var playerno: int
var score: int = 0
var transit_ready: bool

func check_dir():
	var allowed = false
	$Ray.target_position = Vector3(0,0,3)
	$Ray.force_raycast_update()
	if $Ray.get_collider() == null:
		allowed = true
	return allowed
	
func move_left():
	self.rotation_degrees.y = -90
	if check_dir() && $player_timer.time_left == 0:
		pos_x -= 1
		$player_timer.start()
		$AnimationPlayer.play("walk1")

func move_right():
	self.rotation_degrees.y = 90
	if check_dir() && $player_timer.time_left == 0:
		pos_x += 1
		$player_timer.start()
		$AnimationPlayer.play("walk1")

func move_up():
	self.rotation_degrees.y = 180
	if check_dir() && $player_timer.time_left == 0:
		pos_z -= 1
		$player_timer.start()
		$AnimationPlayer.play("walk1")
		
func move_down():
	self.rotation_degrees.y = 0
	if check_dir() && $player_timer.time_left == 0:
		pos_z += 1
		$player_timer.start()
		$AnimationPlayer.play("walk1")

func _ready():
	$AnimationPlayer.animation_set_next("walk1","idle1")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
