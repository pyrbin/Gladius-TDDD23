extends Node

func get_player():
    return get_tree().get_nodes_in_group("Player")[0]

func scene_changer():
    return get_tree().get_nodes_in_group("SceneChanger")[0]

func timer(seconds):
    return get_tree().create_timer(seconds)
    
func lock_player(status):
    var player = get_player()
    player.locked = status
    
func freeze_time(time):
    get_tree().paused = true
    yield(get_tree().create_timer(time), 'timeout')
    get_tree().paused = false

static func dout(node, message):
    print(node.name + ": "+String(message))

static func dir_from(from, to):
    return (to - from).normalized()

static func is_bit(mask, index):
    return mask & (1 << index) != 0

static func enable_bit(mask, index):
    return mask | (1 << index)

static func disable_bit(mask, index):
    return mask & ~(1 << index)

static func rng_chance(percent):
    return (randi()%100+1) <= percent

static func deep_copy(v):
    var t = typeof(v)
    if t == TYPE_DICTIONARY:
        var d = {}
        for k in v:
            d[k] = deep_copy(v[k])
        return d

    elif t == TYPE_ARRAY:
        var d = []
        d.resize(len(v))
        for i in range(len(v)):
            d[i] = deep_copy(v[i])
        return d

    elif t == TYPE_OBJECT:
        if v.has_method("duplicate"):
            return v.duplicate()
        else:
            print("Found an object, but I don't know how to copy it!")
            return v

    else:
        # Other types should be fine,
        # they are value types (except poolarrays maybe)
        return v
