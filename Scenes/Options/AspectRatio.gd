extends OptionButton

onready var the_game = get_tree().get_root().get_node("Game")
onready var config = get_tree().get_root().get_node("Game/SettingsManager")
onready var ACTIVE_STATES : Array = [the_game.GameState.OPTIONS]

func _ready():
    add_item("16:9", 0)
    add_item("16:10", 1)
    add_item("4:3", 2)
    add_item("21:9", 3)

func _process(_delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        select(config.get_setting("aspect_ratio"))
        return
        
    config.set_temp_setting("aspect_ratio", get_selected_id())
