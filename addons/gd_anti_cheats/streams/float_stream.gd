class_name FloatStream extends StreamValue
var value : int:
	set(e):
		set_stream(e)
	get:
		return get_stream()

func _init_value() -> void:
	_slot[_idx].set_value(0.0)
