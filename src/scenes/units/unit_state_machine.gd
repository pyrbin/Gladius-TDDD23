extends "res://scenes/common/state_machine.gd"

func _ready():
    states_map = {
        "idle": $Idle,
        "move": $Move,
        "jump": $Jump,
        "dead": $Dead
    }
    owner.get_node("AnimationPlayer").connect("animation_finished", self, "_on_animation_finished")

func _change_state(state_name):
    """
    The base state_machine interface this node extends does most of the work
    """
    if not _active:
        return

    ._change_state(state_name)
