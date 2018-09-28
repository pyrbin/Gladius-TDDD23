extends RichTextLabel

func _ready():
	set_text(CONFIG.get_game_title())
