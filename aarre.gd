extends Node3D

var assigned_plr: int
var pos_x: int
var pos_z: int
var node_block

func attach_treasure(block):
	node_block = block

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pos_x = node_block.pos_x
	pos_z = node_block.pos_z
