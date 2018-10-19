extends Label

signal is_done

export (float) var type_speed = 0.05

var lapsed = 0
var char_num = 0

func is_done():
    return char_num >= text.length()

func _ready():
    lapsed = 0
    set_visible_characters(0)

func _process(delta):
    lapsed = lapsed + delta
    get_visible_characters()
    char_num = lapsed / type_speed
    set_visible_characters(char_num)
    print(char_num)
    if is_done():
        emit_signal("is_done")
        