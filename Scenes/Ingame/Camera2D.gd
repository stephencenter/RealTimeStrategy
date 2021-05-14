extends Camera2D

onready var the_game = get_tree().get_root().get_node("Game")
onready var ACTIVE_STATES : Array = [the_game.GameState.INGAME]
onready var config = get_tree().get_root().get_node("Game/SettingsManager")

const EDGEPAN_SPEED : float = 1000.0
const EDGEPAN_ZONE : float = 0.02
const MIN_ZOOM : float = 2.0
const MAX_ZOOM : float = 0.5
const ZOOM_ADJUST : float = 0.1
var previous_mousepos : Vector2

func _ready():
    previous_mousepos = get_global_mouse_position()

func _process(delta):
    var new_mousepos = get_global_mouse_position()
    
    if not the_game.is_any_current_state(ACTIVE_STATES):
        previous_mousepos = new_mousepos
        return
    
    if Input.is_action_pressed("grab_camera"):
        offset += (previous_mousepos - new_mousepos)
        new_mousepos += (previous_mousepos - new_mousepos)
        
    elif config.get_setting("pan_enabled"):
        camera_edge_pan(delta)
        
    if Input.is_action_just_released("camera_zoom_in"):
        zoom.x = max(zoom.x - ZOOM_ADJUST, MAX_ZOOM)
        zoom.y = max(zoom.y - ZOOM_ADJUST, MAX_ZOOM)
        
    elif Input.is_action_just_released("camera_zoom_out"):
        zoom.x = min(zoom.x + ZOOM_ADJUST, MIN_ZOOM)
        zoom.y = min(zoom.y + ZOOM_ADJUST, MIN_ZOOM)
    
    previous_mousepos = new_mousepos

func camera_edge_pan(delta):
    var screen_size = get_viewport().get_visible_rect().size
    var zone_size = screen_size.x*EDGEPAN_ZONE*zoom.x
    var cursor_pos = the_game.get_cursor_screen_position() + (screen_size*zoom - screen_size)/2
    
    if cursor_pos.x < zone_size:
        offset.x -= EDGEPAN_SPEED*delta*config.get_setting("pan_speed")*zoom.x
        
    if cursor_pos.x > screen_size.x*zoom.x - zone_size:
        offset.x += EDGEPAN_SPEED*delta*config.get_setting("pan_speed")*zoom.x
        
    if cursor_pos.y < zone_size:
        offset.y -= EDGEPAN_SPEED*delta*config.get_setting("pan_speed")*zoom.y
        
    if cursor_pos.y > screen_size.y*zoom.y - zone_size:
        offset.y += EDGEPAN_SPEED*delta*config.get_setting("pan_speed")*zoom.y
