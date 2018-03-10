extends Area2D

const player = preload("res://alt_player.gd")
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

#func _ready():
	# Called every time the node is added to the scene.
	# Initialization here

func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == "player":
			get_tree().change_scene("world2.tscn")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Checkpoint_body_entered( body ):
	print("thub")
	if body is player:
		print("thub")
		get_tree().change_scene("world2.tscn")
