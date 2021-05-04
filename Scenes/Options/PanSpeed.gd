extends HSlider

onready var the_game = get_tree().get_root().get_node("Game")
onready var ACTIVE_STATES : Array = [the_game.GameState.OPTIONS]

onready var config = get_tree().get_root().get_node("Game/SettingsManager")
onready var percentage_label = get_parent().get_node("Label2")

func _process(_delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        value = config.get_setting("pan_speed")
        return
    
    config.set_temp_setting("pan_speed", value)
    percentage_label.text = "%s%%" % (config.get_temp_setting("pan_speed")*100)
