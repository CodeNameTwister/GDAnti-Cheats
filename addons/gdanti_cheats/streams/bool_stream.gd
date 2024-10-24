class_name BoolStream extends StreamValue
var value : bool:
	set(e):
		set_stream(e)
	get:
		return get_stream()

func _init_value() -> void:
	_slot[_idx].set_value(false)
