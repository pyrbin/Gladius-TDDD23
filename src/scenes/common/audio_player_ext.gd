extends AudioStreamPlayer

onready var tween_out = get_node("TweenOut")
onready var tween_in = get_node("TweenIn")

export var transition_duration = 1.00
export var transition_type = 1

var _next_stream = null
var _original_volume = null

func _ready():
    tween_in.connect("tween_completed", self, "_on_TweenIn_tween_completed")
    tween_out.connect("tween_completed", self, "_on_TweenOut_tween_completed")

func fade_out(next_stream=null):
    _next_stream = next_stream
    _original_volume = self.volume_db
    tween_out.interpolate_property(self, "volume_db", self.volume_db, -80, transition_duration, transition_type, Tween.EASE_IN, 0)
    tween_out.start()

func fade_in():
    var target_volume = self.volume_db
    self.play()
    tween_in.interpolate_property(self, "volume_db", -80, target_volume, transition_duration, transition_type, Tween.EASE_IN, 0)
    tween_in.start()

func _on_TweenIn_tween_completed(streamer, key):
    pass
    
func _on_TweenOut_tween_completed(streamer, key):
    streamer.stop()
    streamer.volume_db = _original_volume
    if _next_stream != null:
        utils.play_sound(_next_stream, streamer)
