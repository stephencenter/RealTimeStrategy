extends Node2D

onready var interface : CanvasLayer = $Interface
onready var object_container : Node = $ObjectContainer
onready var options_menu : Node = $Interface/Centered/OptionsMenu
onready var player_scene = load("res://Scenes/Ingame/Player.tscn")

var start_time : int = 0
var the_player : Node2D = null
var state_path : Array = []
enum GameState {TITLESCREEN=0, INGAME=1, OPTIONS=2}

# Update
func _ready():
    start_new_game()
    
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
    start_new_game()
    advance_game_state(GameState.INGAME)
    
func ingame_process(_delta):        
    if Input.is_action_just_pressed("pause"):
        interface.open_options_menu()
        advance_game_state(GameState.OPTIONS)
    
func options_process(_delta):   
    if Input.is_action_just_pressed("pause"):
        interface.close_options_menu()
        revert_game_state()
    
func start_new_game():
    # Generate new RNG seed
    randomize()
     
    # Clear objects
    for object in object_container.get_children():
        object_container.remove_child(object)
    
    # Spawn Player
    the_player = player_scene.instance()
    the_player.global_position = get_viewport().get_visible_rect().size/2
    add_new_object(the_player)
    
    # Get the time the game started
    start_time = OS.get_unix_time()

# Helpers
func get_player():
    return the_player

func get_player_global_position():
    # Returns the position of the player relative to the world origin
    if the_player != null:
        return get_player().global_position
        
    return Vector2.ZERO
    
func get_player_screen_position():
    # Returns the position of the player relative to the top-left corner of the screen
    if the_player != null:
        return get_player().get_global_transform_with_canvas().origin
        
    return Vector2.ZERO
    
func get_cursor_screen_position():
    return get_global_mouse_position() - get_visible_world_rect()[0]

func get_visible_world_rect() -> Array:
    # Returns the global_position of the top-left and bottom-right
    # corners of the visible world space as an array.
    # index 0 is top-left, index 1 is bot-right
    var screen_size = get_viewport().get_visible_rect().size
    var player_pos = get_player_global_position()
    var screen_pos = get_player_screen_position()
    var top_left = player_pos - screen_pos
    var bot_right = top_left + screen_size
    
    return [top_left, bot_right]
    
func does_rect_contain_point(r_topleft, r_botright, point) -> bool:
    if point.x < r_topleft.x or point.x > r_botright.x:
        return false
        
    if point.y < r_topleft.y or point.y > r_botright.y:
        return false
        
    return true
    
func is_object_on_screen(object) -> bool:
    var world_rect =  get_visible_world_rect()    
    return does_rect_contain_point(world_rect[0], world_rect[1], object.global_position)
    
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
