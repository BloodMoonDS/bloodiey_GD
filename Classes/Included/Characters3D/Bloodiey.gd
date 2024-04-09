extends CharacterBody3D
@export var GlobalSpeed: float = 1
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 7.0
@export var momentum_increment = 0.05
@export var Gravity_Multiplier = 1
var cur_speed = SPEED
var movetrashx = 0
var movetrashz = 0
@export var max_speed = 12 #Camera is adjusted to Stay at 12 of max speed, this may glitch the camera
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
func _ready():
	if GlobalSpeed < 0.25:
		printerr("ERROR: GLOBALSPEED CAN'T BE LESS THAN 0.25, VALUE HAS BEEN RESTORED TO 0.25")
		GlobalSpeed = 0.25
	if GlobalSpeed > 2:
		print("WARING: GLOBALSPEED CAN ONLY BE FROM 0.1 TO 2")
		GlobalSpeed = 2
func _physics_process(delta):
	var abs = $AnimationTree
	var state_machine = abs["parameters/playback"]
	# Add the gravity.
	if not is_on_floor():
		if velocity.y <= max_speed *-1 * GlobalSpeed:
			velocity.y = max_speed *-1 * GlobalSpeed
		else:
			velocity.y -= gravity * Gravity_Multiplier * delta * GlobalSpeed
		#print(velocity.y)
	# Handle jump.
	if Input.is_action_just_pressed("JumpAccept") and is_on_floor():
		velocity.y = JUMP_VELOCITY + GlobalSpeed
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("MoveLEFT", "MoveRight", "MoveUP", "MoveDOWN")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if cur_speed <= 8:
			state_machine.travel("Bloodiey_Walk")
		else:
			state_machine.travel("Bloodiey_Run")
		if not is_on_floor():
			if velocity.y > 0:
				state_machine.travel("Jump")
			if velocity.y < 0:
				state_machine.travel("Fall")
		velocity.x = direction.x * cur_speed * GlobalSpeed
		velocity.z = direction.z * cur_speed * GlobalSpeed
		
		if cur_speed >= max_speed:
			cur_speed = max_speed
		else:
			cur_speed += momentum_increment * GlobalSpeed
		#print(cur_speed)
		var lookatx = position.x + 0.1 * input_dir.x * -1
		var lookatz = position.z + 0.1 * input_dir.y * -1
		#print(lookatx)
		#print(lookatz)
		$bloodieymdl.look_at(Vector3(lookatx,position.y,lookatz))
	else:
		state_machine.travel("Bloodiey_Stand")
		cur_speed = SPEED
		velocity.x = move_toward(velocity.x, 0, cur_speed)
		velocity.z = move_toward(velocity.z, 0, cur_speed)
		if not is_on_floor():
			if velocity.y > 0:
				state_machine.travel("Jump")
			if velocity.y < 0:
				state_machine.travel("Fall")
	move_and_slide()
		# Camera Follow
	$Camera_Controller.position = lerp($Camera_Controller.position + (direction * 0.20 * GlobalSpeed), position, 0.09 )
	$Camera_Controller.position.y = lerp($Camera_Controller.position.y + (velocity.y * 0.025 * GlobalSpeed), position.y, 0.09 )
func _input(event):
	if event.is_action_pressed("Attack1"):
		print("TODO: Attack 1")
	if event.is_action_pressed("Attack2"):
		print("TODO: Attack 2")
	if event.is_action_pressed("BackBlock"):
		print("TODO: block action")
