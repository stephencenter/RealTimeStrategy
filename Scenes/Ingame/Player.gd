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
           
    update()
        
func _input(_event):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return
        
    if Input.is_action_pressed("drag_select") or Input.is_action_just_released("drag_select"):
        action_drag_select()
    
    if Input.is_action_just_pressed("move_or_attack"):
        var target_position = get_global_mouse_position()
        
        for unit in selected_units:
            if Input.is_action_pressed("queue_actions"):
                unit.action_list.append(["move", target_position], selected_units)
                
            else:
                unit.action_list = [["move", target_position, selected_units]]
                
    if Input.is_action_just_pressed("cancel_action"):
        for unit in selected_units:
            unit.action_list = []
                
func _draw():
    var box_color : Color = Color(0, 0.5, 1, 1)
    var hover_select_color : Color = Color(0, 0.5, 1, 0.5)
    var selected_color : Color = Color(0, 0.5, 1, 1)
    var select_radius : float = 50.0
    
    if select_point_one != null and select_point_two != null:
        draw_line(select_point_one, Vector2(select_point_two.x, select_point_one.y), box_color, 3.0, true) 
        draw_line(Vector2(select_point_two.x, select_point_one.y), select_point_two, box_color, 3.0, true) 
        draw_line(select_point_two, Vector2(select_point_one.x, select_point_two.y), box_color, 3.0, true) 
        draw_line(Vector2(select_point_one.x, select_point_two.y), select_point_one, box_color, 3.0, true)
        
        for unit in get_units_in_selection_box():
            if not unit in selected_units:
                draw_set_transform(Vector2(0, 0.5*(unit.global_position.y + select_radius)), 0, Vector2(1, 0.5))
                draw_empty_circle(unit.global_position, select_radius, hover_select_color, 5.0)
            
    for unit in selected_units:
        draw_set_transform(Vector2(0, 0.5*(unit.global_position.y + select_radius)), 0, Vector2(1, 0.5))
        draw_empty_circle(unit.global_position, 50.0, selected_color, 7.0)
                
    draw_set_transform(Vector2.ZERO, 0, Vector2(1, 1))
        
func draw_empty_circle(position : Vector2, radius : float, color : Color, width : float):
    draw_arc(position, radius, 0, PI, 360, color, width, true)
    draw_arc(position, radius, PI, 2*PI, 360, color, width, true)
    
func get_units_in_selection_box() -> Array:
    var new_units : Array = the_game.get_objects_in_rect(select_point_one, select_point_two)
    for p1_unit in the_game.get_objects_in_radius(select_point_one, 50.0):
        if not p1_unit in new_units:
            new_units.append(p1_unit)
            
    for p2_unit in the_game.get_objects_in_radius(select_point_two, 50.0):
        if not p2_unit in new_units:
            new_units.append(p2_unit)
            
    if new_units.size() > 0:
        if select_point_one.distance_to(select_point_two) < 20:
            new_units = [new_units.front()]
            
        return new_units
        
    return selected_units        
    
func action_drag_select():
    if Input.is_action_just_pressed("drag_select"):
        select_point_one = get_global_mouse_position() - global_position
        
    if Input.is_action_just_released("drag_select") and select_point_one != null and select_point_two != null:
        selected_units = get_units_in_selection_box()
        
    if not Input.is_action_pressed("drag_select"):
        select_point_one = null
        select_point_two = null
    
    else:
        select_point_two = get_global_mouse_position() - global_position
