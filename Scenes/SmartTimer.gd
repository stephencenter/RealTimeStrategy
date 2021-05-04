extends Node
# This is a special class that I use instead of the vanilla Timer class
# It works just like the normal timer, except it only processes during
# specific gamestates
var the_game
var active_states : Array
var _time_left : float
var _stopped : bool

func _init(var states : Array, var root):
    active_states = states
    root.call_deferred("add_child", self)
    the_game = root
    
func _process(delta):
    if not the_game.is_any_current_state(active_states):
        return
    
    if _time_left <= 0 or _stopped:
        _stopped = true
        _time_left = 0
        
    else:
        _time_left -= delta

func start(new_time : float):
    _time_left = new_time
    _stopped = false
    
func stop():
    _stopped = true
    
func is_stopped() -> bool:
    return _stopped
    
func get_time_left() -> float:
    return _time_left
