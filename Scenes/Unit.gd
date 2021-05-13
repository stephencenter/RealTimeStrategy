extends KinematicBody2D

onready var the_game = get_tree().get_root().get_node("Game")
onready var ACTIVE_STATES : Array = [the_game.GameState.INGAME]
onready var timer_class = load("res://Scenes/SmartTimer.gd")

const MOVE_SPEED : float = 200.0
const TARGET_DISTANCE_THRESHOLD = 10.0
const TARGET_TIMEOUT_THRESHOLD_START = 0.2
const TARGET_TIMEOUT_THRESHOLD_END = 5.0
const TARGET_TIMEOUT_TIME = 1.0
var action_list : Array = []

# Navigation
onready var nav_stop_timer = timer_class.new(ACTIVE_STATES, the_game)
onready var nav_2D = get_parent().get_node("Navigation2D")
var current_velocity : Vector2
var adjusted_move_speed : float
var previous_point
var stuck : bool

func _process(_delta):
    if not the_game.is_any_current_state(ACTIVE_STATES) or action_list.size() == 0:
        return
        
    var current_action = action_list[0]
    if current_action[0] == "move":
        move_along_path(nav_2D.get_simple_path(global_position, current_action[1], true))
            
        if global_position.distance_to(current_action[1]) < TARGET_DISTANCE_THRESHOLD:
            action_list.remove(0)
            print("pog")
            return
        
        if previous_point == null:
            previous_point = global_position
            
        var distance_from_point = global_position.distance_to(previous_point)
        
        if nav_stop_timer.is_stopped():
            if stuck and can_unit_stop(current_action[2], current_action):
                stuck = false
                action_list.remove(0)
                print("alt pog")
                
            elif distance_from_point < TARGET_TIMEOUT_THRESHOLD_START:
                stuck = true
                nav_stop_timer.start(TARGET_TIMEOUT_TIME)
                
            previous_point = global_position
            
        else:
            if distance_from_point > TARGET_TIMEOUT_THRESHOLD_END:
                stuck = false
                nav_stop_timer.stop()

func can_unit_stop(unit_list, action) -> bool:    
    for unit in unit_list:
        if not action in unit.action_list:
            print(unit.name, " was ignored")
            continue
            
        if not unit.stuck:
            return false
            
    return true
            
func move_along_path(nav_path):
    if nav_path.size() > 0:
        nav_path.remove(0)
        if nav_path.size() != 0:
            var speed_ratio = current_velocity.length()/MOVE_SPEED
            if speed_ratio == 0:
                adjusted_move_speed = MOVE_SPEED
                
            else:
                adjusted_move_speed = clamp(MOVE_SPEED/speed_ratio, MOVE_SPEED, MOVE_SPEED*5)
            
            current_velocity = position.direction_to(nav_path[0])*adjusted_move_speed
            current_velocity = move_and_slide(current_velocity)
