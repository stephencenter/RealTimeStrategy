extends Node2D

onready var the_game = get_tree().get_root().get_node("Game")
onready var interface : CanvasLayer = get_tree().get_root().get_node("Game/Interface")
onready var ACTIVE_STATES : Array = [the_game.GameState.INGAME]

const PLAYER_MAX_SPEED : float = 250.0
const PLAYER_ACCELERATION : float = 0.2
const PLAYER_DECELERATION : float = 0.1
const PLAYER_TURN_SPEED : float = 20.0
const JOY_LEFT_DEADZONE : float = 0.05
const JOY_RIGHT_DEADZONE : float = 0.5
const JOY_CROSSHAIR_DISTANCE : float = 120.0

onready var joy_crosshair : Sprite = $Crosshair

var current_velocity : Vector2
var movement_vector : Vector2
var current_aim : Vector2
var aim_vector : Vector2
var aimed_mouse : bool = false

# Updates        
func _process(delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return
        
    process_input(delta)
    process_movement(delta)
    process_rotation(delta)
    update_crosshair_position()

func _input(event):
    if event is InputEventMouseMotion:
        if Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN:
            get_viewport().warp_mouse(joy_crosshair.global_position)
            
        interface.enable_mouse_cursor()
        aimed_mouse = true
    
func process_input(_delta):
    movement_vector = get_movement_vector()
    aim_vector = get_aim_joystick()
    
    if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
        aim_vector = get_global_mouse_position() - global_position
    
func process_movement(delta):
    movement_vector = movement_vector*PLAYER_MAX_SPEED
    
    if movement_vector.length() > 0:
        current_velocity = current_velocity.linear_interpolate(movement_vector, PLAYER_ACCELERATION)
    else:
        current_velocity = current_velocity.linear_interpolate(Vector2.ZERO, PLAYER_DECELERATION)
    
    global_position += current_velocity*delta
        
func process_rotation(delta):
    # The player's sprite doesn't just snap to the desired angle, it instead
    # gradually turns at a speed dependent on PLAYER_TURN_SPEED.
    # This is purely visual and does not affect the direction bullets are fired in.
    if aim_vector.length() > 0:
        current_aim = aim_vector
    
    # This calculates the desired angle based on joystick/cursor position, as
    # well as the shortest route to achieve that angle
    var desired_angle = int(rad2deg(current_aim.angle()))
    var current_angle = int(global_rotation_degrees)
    var difference = (desired_angle - current_angle + 540) % 360 - 180
      
    if abs(difference) < PLAYER_TURN_SPEED:
        global_rotation_degrees = desired_angle
    elif difference < 0:
        global_rotation -= PLAYER_TURN_SPEED*delta
    else:
        global_rotation += PLAYER_TURN_SPEED*delta
    
func get_movement_vector() -> Vector2:
    var move_vec : Vector2 = Vector2()
    
    if Input.is_action_pressed("move_up"):
        move_vec.y -= Input.get_action_strength("move_up")
    if Input.is_action_pressed("move_down"):
        move_vec.y += Input.get_action_strength("move_down")
    if Input.is_action_pressed("move_left"):
        move_vec.x -= Input.get_action_strength("move_left")
    if Input.is_action_pressed("move_right"):
        move_vec.x += Input.get_action_strength("move_right")
        
    if move_vec.length() < JOY_LEFT_DEADZONE:
        return Vector2.ZERO
        
    return move_vec

func get_aim_joystick() -> Vector2:
    if aimed_mouse:
        aimed_mouse = false
        return aim_vector
        
    var aim_vec : Vector2 = Vector2()
    
    if Input.is_action_pressed("aim_up"):
        aim_vec.y -= Input.get_action_strength("aim_up")
    if Input.is_action_pressed("aim_down"):
        aim_vec.y += Input.get_action_strength("aim_down")
    if Input.is_action_pressed("aim_left"):
        aim_vec.x -= Input.get_action_strength("aim_left")
    if Input.is_action_pressed("aim_right"):
        aim_vec.x += Input.get_action_strength("aim_right")
    
    if aim_vec.length() < JOY_RIGHT_DEADZONE:
        return Vector2.ZERO
        
    interface.enable_joystick_cursor()
    return aim_vec.normalized()
      
func update_crosshair_position():
    var angle_vec = Vector2(cos(global_rotation), sin(global_rotation))
    joy_crosshair.global_position = global_position + angle_vec*JOY_CROSSHAIR_DISTANCE
    joy_crosshair.global_rotation = 0

func get_crosshair_position():
    return joy_crosshair.global_position
