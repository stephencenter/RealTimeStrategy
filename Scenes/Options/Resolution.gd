extends OptionButton

onready var the_game = get_tree().get_root().get_node("Game")
onready var ACTIVE_STATES : Array = [the_game.GameState.OPTIONS]

var current_aspect_ratio : int = -1
onready var config = get_tree().get_root().get_node("Game/SettingsManager")

const RESOLUTION_LIST : Dictionary = {
    0: [[1280, 720], [1366, 768], [1600, 900], [1920, 1080], [2560, 1440], [3840, 2160]],
    1: [[1152, 720], [1440, 900], [1680, 1050], [1920, 1200]],
    2: [[800, 600], [960, 720], [1024, 768], [1200, 900], [1280, 960], [1440, 1080], [1600, 1200]],
    3: [[1920, 800], [2560, 1080], [3440, 1440], [5120, 2160]]
}

func _ready():
    var ratio = get_current_aspect_ratio()
    if ratio != current_aspect_ratio:
        current_aspect_ratio = ratio
        repopulate_resolution_list()
    
func _process(_delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        select(config.get_setting("resolution_id"))
        return    
        
    var ratio = get_current_aspect_ratio()
    if ratio != current_aspect_ratio:
        current_aspect_ratio = ratio
        repopulate_resolution_list()
    
    var selected_resolution = RESOLUTION_LIST[current_aspect_ratio][get_selected_id()]
    config.set_temp_setting("resolution_x", selected_resolution[0])
    config.set_temp_setting("resolution_y", selected_resolution[1])

func repopulate_resolution_list():
    clear()
    
    var screen_size = OS.get_screen_size()
    var index = 0
    for reso in RESOLUTION_LIST[current_aspect_ratio]:
        if not reso[0] > screen_size.x or not reso[1] > screen_size.y:
            add_item("%sx%s" % [reso[0], reso[1]], index)
            
        index += 1

func update_current_aspect_ratio():
    if config.temp_settings.has("aspect_ratio"):
        current_aspect_ratio = config.get_temp_setting("aspect_ratio")
    else:
        current_aspect_ratio = config.get_setting("aspect_ratio")

func get_current_aspect_ratio():
    if config.temp_settings.has("aspect_ratio"):
        return config.get_temp_setting("aspect_ratio")
    else:
        return config.get_setting("aspect_ratio")
    
