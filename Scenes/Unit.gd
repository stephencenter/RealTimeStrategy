extends KinematicBody2D

onready var the_game = get_tree().get_root().get_node("Game")
onready var ACTIVE_STATES : Array = [the_game.GameState.INGAME]
onready var timer_class = load("res://Scenes/SmartTimer.gd")

const MOVE_SPEED : float = 200.0
const TARGET_DISTANCE_THRESHOLD = 10.0
const TARGET_TIMEOUT_THRESHOLD_START = 0.4
const TARGET_TIMEOUT_THRESHOLD_END = 10.0
const TARGET_TIMEOUT_TIME = 0.5
var action_queue : Array = []

# Navigation
onready var nav_stop_timer = timer_class.new(ACTIVE_STATES, the_game)
onready var nav_2D = get_parent().get_node("Navigation2D")
var current_velocity : Vector2
var adjusted_move_speed : float
var is_stuck : bool
var stuck_point

# Animation
onready var move_bob_timer = timer_class.new(ACTIVE_STATES, the_game)
const MOVE_BOB_DURATION : float = 2.0
const MOVE_BOB_AMOUNT : float = 4.0
var bobbing_up : bool = false

func _process(delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return
        
    handle_animations(delta)
    
    if action_queue.size() == 0:
        return
        
    var current_action = action_queue[0]
    if current_action[0] == "move":
        action_move(current_action[1], current_action[2], current_action)
        
func action_move(target_point : Vector2, unit_list : Array, assigned_action : Array):
    # Move the unit to the next point in its pathfinding algorithm
    move_along_path(nav_2D.get_simple_path(global_position, target_point, true))
    
    # If the unit has reached its goal, then the action is completed and removed from the queue
    if global_position.distance_to(target_point) < TARGET_DISTANCE_THRESHOLD:
        action_queue.remove(0)
        return
    
    if stuck_point == null:
        stuck_point = global_position
    
    # This is the distance the unit currently is from the stuck_point
    var distance_from_stuck_point = global_position.distance_to(stuck_point)
    
    # The nav_timer counts down when the unit is stuck on something.
    # While counting down, stuck_point is frozen at the point the unit got stuck at. 
    if nav_stop_timer.is_stopped():
        # If the unit has been stuck for enough time, and all other units in the group
        # are also either stuck or finished moving, then the unit will give up trying to 
        # reach the point
        if is_stuck and are_all_units_stuck(unit_list, assigned_action):
            is_stuck = false
            action_queue.remove(0)
            
        # If the distance the unit traveled since the last time the stuck_point was updated
        # is less than a certain amount, then the timer is started
        elif distance_from_stuck_point < TARGET_TIMEOUT_THRESHOLD_START:
            is_stuck = true
            nav_stop_timer.start(TARGET_TIMEOUT_TIME)
        
        stuck_point = global_position
        
    else:
        # If the unit gets far enough away from the stuck_point, then the unit is 
        # considered "unstuck" and the timer is canceled
        if distance_from_stuck_point > TARGET_TIMEOUT_THRESHOLD_END:
            is_stuck = false
            nav_stop_timer.stop()
    
func are_all_units_stuck(unit_list, action) -> bool:
    for unit in unit_list:
        if not action in unit.action_queue:
            continue
            
        if not unit.is_stuck:
            return false
            
    return true
            
func move_along_path(nav_path):
    if nav_path.size() > 0:
        nav_path.remove(0)
        
    if nav_path.size() > 0:
        # The pathfinding algorithm sometimes tries to take shortcuts, which results in the unit
        # slowly sliding along walls. If that happens, we'll speed up the unit so they always
        # go the same speed
        var speed_ratio = current_velocity.length()/MOVE_SPEED
        if speed_ratio == 0:
            adjusted_move_speed = MOVE_SPEED
            
        else:
            adjusted_move_speed = clamp(MOVE_SPEED/speed_ratio, MOVE_SPEED, MOVE_SPEED*3)
        
        current_velocity = position.direction_to(nav_path[0])*adjusted_move_speed
        current_velocity = move_and_slide(current_velocity)

func handle_animations(delta):
    if move_bob_timer.is_stopped():
        bobbing_up = not bobbing_up
        move_bob_timer.start(MOVE_BOB_DURATION)
        
    if bobbing_up:
        $Sprite.position.y -= MOVE_BOB_AMOUNT*delta
    else:
        $Sprite.position.y += MOVE_BOB_AMOUNT*delta
        
    if abs(current_velocity.x) > MOVE_SPEED/2:
        if current_velocity.x > 0:
            $Sprite.flip_h = true
            
        else:
            $Sprite.flip_h = false
