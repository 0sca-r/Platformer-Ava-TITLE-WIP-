extends KinematicBody2D

var input_states = preload("input_states.gd")

var key_left = input_states.new("key_left")
var key_right = input_states.new("key_right")
var key_up = input_states.new("key_up")
var key_test = input_states.new("key_test")
var key_alt_test = input_states.new("key_alt_test")

const GRAVITY_VEC = Vector2(0,0)
const FLOOR_NORMAL = Vector2(0,-1)
const SLOPE_SLIDE_STOP = 25.0
const MIN_ONAIR_TIME = 0.01
const WALK_SPEED = 250 # pixels/sec
const ACC_SPEED = 30
const JUMP_SPEED = 280
const SIDING_CHANGE_SPEED = 10
const JUMP_NUM = 0
const CAN_DASH = true

const hazard_class = preload("res://hazard.gd")
const checkpoint_class = preload("res://checkpoint.gd")
var linear_vel = Vector2()
var onair_time = 0 # 
var on_floor = false
var on_wall = false
var health = 3
var dead = false
var anim=""


#halberding
var RotateSpeed = 5
var Radius = 100
var _centre = self.get_position()
var _angle = 0


#direction stuff
var dir_prev = ""
var dir = ""
var dir_next = ""


var pstate_prev = ""
var pstate = ""
var pstate_next = "grounded"


#cache the sprite here for fast access (we will set scale to flip it often)
#onready var sprite = get_node("Sprite")
#onready var player = get_node("player")
onready var rotate = get_node("rotate")
onready var particles = get_node("Particles2D")
onready var dash_ready = get_node("Dash_Particles")
onready var timer = get_node("Timer_Dash")
onready var collision_shape = get_node("CollisionShape2D")
onready var Hitbox = get_node("Area2D")
onready var anime = get_node("rotate/Anim")
onready var label = get_node("Label")
onready var Position2d = get_node("Position2D")
#onready var hazard_class = get_node("res://hazard.gd")
func change_dir():
	if (dir == "right" and dir_next == "left") or (dir == "left" and dir_next == "right"):
		rotate.set_scale((rotate.get_scale()) * Vector2(-1,1))

func _on_timer_timeout():
	CAN_DASH = true
	dash_ready.set_emitting(true)
	
func death():
	print("u dead")
	#change to the position of the checkpoint
	set_position(Vector2(415,310))
	health = 3
	
#func gravity(delta):
	### Apply Gravity
	
func _draw():
	draw_line(Vector2(0,0), Vector2(50, 50), Color(255, 0, 0), 1)
	draw_line(Vector2(0,0), Vector2(Position2d.get_position()), Color(255, 0, 0), 1)

	
	
func _process(delta):
	#increment counters
	
	onair_time+=delta
	
	dir_prev = dir
	dir = dir_next
	
	#gravity
	linear_vel += delta * GRAVITY_VEC
	### Move and Slide
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP )

	#raycast.add_exception(self) 
	
	#collision_shape.set_trigger(true)
	### MOVEMENT ###
	
#	gravity(delta)
	
	# Detect Floor
	if (is_on_floor()):
		onair_time=0
		JUMP_NUM = 0
	#this is the wall jump code i know it says ceiling just chill
	if (is_on_wall()):
		if (key_up.check() == 1):
			if (dir == "right"):
				JUMP_NUM = 0
				linear_vel.y =-JUMP_SPEED
				linear_vel.x =-JUMP_SPEED
			if (dir == "left"):
				JUMP_NUM = 0
				linear_vel.y =-JUMP_SPEED
				linear_vel.x =JUMP_SPEED
	
	on_floor = onair_time < MIN_ONAIR_TIME
	on_wall = onair_time < MIN_ONAIR_TIME
	### CONTROL ###
	
	# Horizontal Movement
	var target_speed = 0
	if key_left.check() == 2:
		target_speed += -1
		dir_next = "left"
	if key_right.check() == 2:
		target_speed +=  1
		dir_next = "right"
	anime.play("Run")
	target_speed *= WALK_SPEED
	linear_vel.x = lerp( linear_vel.x, target_speed, 0.1 )
	
	if (key_right.check() == 0) and (key_left.check() == 0):
		anime.play("Idle")
	# Jumping
	if ((JUMP_NUM <= 2) and (key_up.check() == 1)):
		linear_vel.y=-JUMP_SPEED
		JUMP_NUM += 1




	# Dashing
	if (key_test.check() == 2)  and (CAN_DASH == true):
		timer.start()
		if dir == "left":
			#move(Vector2(-100,0))
			CAN_DASH = false
			linear_vel.x=-700
			particles.set_emitting(true)
		if dir == "right":
			#move(Vector2(100,0))
			CAN_DASH = false
			linear_vel.x=700
			#particles.set_global_rotd(180)

	if (CAN_DASH == false):
		GRAVITY_VEC = Vector2(0,0)
		#particles.set_emitting(true)
	else:
		GRAVITY_VEC = Vector2(0,900)
		#particles.set_emitting(false)
	#collisions



#"halberding"
	if key_alt_test.check() == 2:
		_angle += RotateSpeed * delta;
		linear_vel.x = 0
		linear_vel.y = 0
		linear_vel -= delta * GRAVITY_VEC

		if dir == "left":
			Position2d.set_position(Vector2(-50,0))
			var offset = Vector2(sin(_angle), cos(_angle)) * Radius;
			var pos = offset + Position2d.get_position()
			if on_floor == true:
				_angle = 0
			move_and_slide(pos) 

		if dir == "right":
			Position2d.set_position(Vector2(50,0))
			var offset = Vector2(cos(_angle), sin(_angle)) * Radius;
			var pos = offset + Position2d.get_position()
			if on_floor == true:
				_angle = 0
			move_and_slide(pos) 
	
	
	update()






	#print(dir)
	change_dir()
func _ready():
	set_process(true)
	timer.connect("timeout",self,"_on_timer_timeout")
	anime.play("Idle")
	
	
	#Area2d.connect("body_enter",self,"_on_Hitbox_body_enter")
	
#FUCKING WORKS ALSKSLFK
func _on_Area2D_body_entered( body ):
	if body is hazard_class:
		health -= 1
		print(health)
		if health < 1:
			death()
	if body is checkpoint_class:
		health += 1
		print(health)



