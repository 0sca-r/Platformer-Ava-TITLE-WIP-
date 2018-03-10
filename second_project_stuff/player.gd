extends KinematicBody2D

var input_states = preload("input_states.gd")
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var key_left = input_states.new("key_left")
var key_right = input_states.new("key_right")
var key_up = input_states.new("key_up")
var key_test = input_states.new("key_test")

export var spd = 900
export var acc = 8
export var air_acc = 3
export var vspd = -200
export var grav = 3

#dashing varibles
var can_dash = true
onready var timer = get_node("Timer")# timer to reset dash state
var dash_press_count = 0 # keep track of double tap count
var dash_speed = 30 # the dash speed

var jump_num = 0
var raycast_down = null
var current_spd = Vector2(0,0)

var pstate_prev = ""
var pstate = ""
var pstate_next = "grounded"

var dir_prev = ""
var dir = ""
var dir_next = ""
var rotate = ""

var anim_player = null
var anim = ""
var anim_new = ""
var anim_speed = 1.0
var anim_blend = 0.2

#func move(speed, acceleration, delta):
	#current_spd.x = lerp(current_spd.x, speed, acceleration * delta)
	#set_linear_velocity(Vector2(current_spd.x,get_linear_velocity().y))
	
func touching_ground():
	if raycast_down.is_colliding():
		return true
	else:
		return false 
		

		
func _ready():
	#get_node(Camera2D).set_zoom(get_node(Camera2D).get_zoom() * get_node("/root/gobal").viewport_scale)
	
	#the raycast is a ray that is "casted" down, like a collision box.
	raycast_down = get_node("RayCast2D")
	raycast_down.add_exception(self)
	rotate = get_node("rotate")
	#initilazation stuff is here
	set_fixed_process(true)
	
	
	timer.connect("timeout", self, "on_timer_complete")
	
	#anim_player = get_node("rotate/character sprites/AnimationPlayer")
	
#when timer runs out this will run
func on_timer_complete():
	print("timeout")
	can_dash = true
	pstate_next = "airbourne"
	

func change_dir():
	if (dir == "right" and dir_next == "left") or (dir == "left" and dir_next == "right"):
		rotate.set_scale((rotate.get_scale()) * Vector2(-1,1))
		
func _fixed_process(delta):
	#ui_label_value.set_text(str(timer.get_time_left()))
	move(Vector2(delta, grav))
	
	pstate_prev = pstate
	pstate = pstate_next
	
	dir_prev = dir
	dir = dir_next
	
	touching_ground()
	
	if (pstate == "grounded"):
		grounded_state(delta)
	elif (pstate == "airbourne"):
		airbourne_state(delta)
	if (pstate == "dashing"):
		dashing_state(delta)
	
	#if anim != anim_new:
	#	anim_new = anim
#		anim_player.play(anim, anim_blend, anim_speed)
	
	
	#------------dashing stuff---------------------------------------------
	 # only attempt to dash if the player's not dashing
	if (key_test.check() == 1 and can_dash == true):
		pstate_next = "dashing"
		
		
   

   
	
func grounded_state(delta):
	jump_num = 0
	if key_left.check() == 2:
		move(Vector2(-40, 3))
		dir_next = "left"
		anim = "walk"
		anim_speed = 2.0
	elif key_right.check() == 2:
		move(Vector2(40, 3))
		dir_next = "right"
		anim = "walk"
		anim_speed = 2.0
	else:
		move(Vector2(0, 0))
		anim = "base"
		
	change_dir()
	#vertical movement code
	if touching_ground():
		if key_up.check() == 1:
			move(Vector2(3,5000))
			pstate_next = "airbourne"
	#else:
		
		
func airbourne_state(delta):
#move left/right while midair, also change direction player is facing
	change_dir()
	if key_left.check() == 2:
		move(Vector2(-40, 3))
		dir_next = "left"
	elif key_right.check() == 2:
		move(Vector2(40, 3))
		dir_next = "right"
	else:
		move(Vector2(0, acc))
	change_dir()
#double jump code/state switch
	if touching_ground():
		pstate_next = "grounded"
	if key_up.check() == 1 and jump_num < 1:
		move(Vector2(0,vspd))
		jump_num += 1
		
func dashing_state(delta):
	if (dir == "right"):
		grav -= 3
		move(Vector2(60,0))
		can_dash = false
		timer.start()
		
	if (dir == "left"):
		grav -= 3
		move(Vector2(-60,0))
		can_dash = false
		timer.start()

