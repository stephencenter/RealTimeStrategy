extends Node2D

onready var interface : CanvasLayer = $Interface
onready var object_container : Node = $ObjectContainer
onready var options_menu : Node = $Interface/Centered/OptionsMenu
onready var camera : Camera2D = $Camera2D

var start_time : int = 0
var state_path : Array = []
enum GameState {TITLESCREEN=0, INGAME=1, OPTIONS=2}

# Updates
func _process(delta):
    if state_path.empty():
        state_path = [GameState.TITLESCREEN]
    
    if is_current_state(GameState.TITLESCREEN):
        titlescreen_process(delta)
        
    elif is_current_state(GameState.INGAME):
        ingame_process(delta)
        
    elif is_current_state(GameState.OPTIONS):
        options_process(delta)

func titlescreen_process(_delta):
    advance_game_state(GameState.INGAME)
    
func ingame_process(_delta):        
    if Input.is_action_just_pressed("pause"):
        interface.open_options_menu()
        advance_game_state(GameState.OPTIONS)
    
func options_process(_delta):   
    if Input.is_action_just_pressed("pause"):
        interface.close_options_menu()
        revert_game_state()

# Helpers    
func get_cursor_screen_position():
    return get_global_mouse_position() - get_visible_world_rect()[0]

func get_visible_world_rect() -> Array:
    # Returns the global_position of the top-left and bottom-right
    # corners of the visible world space as an array.
    # index 0 is top-left, index 1 is bot-right
    var screen_size = get_viewport().get_visible_rect().size
    var top_left = camera.offset - screen_size/2
    var bot_right = top_left + screen_size
    
    return [top_left, bot_right]
    
func does_rect_contain_point(rect_p1 : Vector2, rect_p2 : Vector2, point : Vector2) -> bool:
    # rect_p1 and rect_p2 must be opposite corners of a rectangle,
    # i.e. top-left and bot-right, or top-right and bot-left
    var r_topleft = Vector2(min(rect_p1.x, rect_p2.x), min(rect_p1.y, rect_p2.y))
    var r_botright = Vector2(max(rect_p1.x, rect_p2.x), max(rect_p1.y, rect_p2.y))
    
    if point.x < r_topleft.x or point.x > r_botright.x:
        return false
        
    if point.y < r_topleft.y or point.y > r_botright.y:
        return false
        
    return true
    
func is_object_on_screen(object) -> bool:
    var world_rect =  get_visible_world_rect()    
    return does_rect_contain_point(world_rect[0], world_rect[1], object.global_position)
    
func get_objects_in_rect(rect_p1, rect_p2) -> Array:
    var objects_in_rect : Array = []
    
    for object in object_container.get_children():
        if does_rect_contain_point(rect_p1, rect_p2, object.global_position):
            objects_in_rect.append(object)
            
    return objects_in_rect
    
func get_objects_in_radius(point : Vector2, radius : float) -> Array:
    var objects_in_rect : Array = []
    
    for object in object_container.get_children():
        if object.global_position.distance_to(point) <= radius:
            objects_in_rect.append(object)
            
    return objects_in_rect
    
func add_new_object(var the_object):
    object_container.add_child(the_object)
    
func get_current_state() -> int:
    return state_path.back()
    
func is_current_state(state : int) -> bool:
     return state == get_current_state()
    
func is_any_current_state(state_list : Array) -> bool:
    return state_list.has(get_current_state())

func advance_game_state(state : int):
    if not is_current_state(state):
        state_path.append(state)
    
func revert_game_state():
    if not state_path.empty():
        state_path.remove(state_path.size() - 1)
