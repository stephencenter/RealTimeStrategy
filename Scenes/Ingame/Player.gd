extends Node2D

onready var the_game = get_tree().get_root().get_node("Game")
onready var interface : CanvasLayer = get_tree().get_root().get_node("Game/Interface")
onready var ACTIVE_STATES : Array = [the_game.GameState.INGAME]

var selected_units : Array = []
var select_point_one
var select_point_two

# Updates
func _process(_delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return
    
    print(selected_units)        
    update()

func _draw():
    if select_point_one != null and select_point_two != null:
        draw_line(select_point_one, Vector2(select_point_two.x, select_point_one.y), Color(0, 0.5, 1, 1), 3.0, true) 
        draw_line(Vector2(select_point_two.x, select_point_one.y), select_point_two, Color(0, 0.5, 1, 1), 3.0, true) 
        draw_line(select_point_two, Vector2(select_point_one.x, select_point_two.y), Color(0, 0.5, 1, 1), 3.0, true) 
        draw_line(Vector2(select_point_one.x, select_point_two.y), select_point_one, Color(0, 0.5, 1, 1), 3.0, true)
        
func _input(_event):
    if Input.is_action_just_pressed("drag_select"):
        select_point_one = get_global_mouse_position() - global_position
        
    if Input.is_action_just_released("drag_select") and select_point_one != null and select_point_two != null:
        var new_units : Array = the_game.get_objects_in_rect(select_point_one, select_point_two)
        if new_units.size() > 0:
            selected_units = new_units
        
    if not Input.is_action_pressed("drag_select"):
        select_point_one = null
        select_point_two = null
    
    else:
        select_point_two = get_global_mouse_position() - global_position
