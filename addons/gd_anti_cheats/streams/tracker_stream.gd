class_name TrackerStream extends StreamValue
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	GDAnti-Cheats
#
#	https://github.com/CodeNameTwister/GDAnti-Cheats
#	author:	"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Value uppdated
signal updated(last_value : Variant, new_value : Variant)
# Not pass validation
signal error(last_value : Variant, new_value : Variant)

var _typeof : int = -1

var value : Variant:
	set(e):
		if _typeof == -1:
			_slot[_idx].set_value(value)
			_typeof = typeof(e)
		set_stream(e)
	get:
		return get_stream()

func get_type() -> int:
	return _typeof

## Virtual function
func _is_valid(_last_value : Variant, new_value : Variant) -> bool:
	#TODO: Override Function
	#Simple validator type:
	#region same_type
	return typeof(new_value) == _typeof
	#endregion

func _init_value() -> void:
	_slot[_idx].set_value(null)

func get_stream(current_variant : Variant = null) -> Variant:
	return _slot[_idx].get_value()

func set_stream(value: Variant) -> void:
	var last_value : Variant = _slot[_idx].get_value()
	if _is_valid(last_value, value):
		if _flush_idx > flush_rate:
			for x in _slot.size():
				if x == _idx:continue
				_slot[x].free()
				_slot[x] = _VAL.new()
			_flush_idx = 0
		if flush_value.is_valid():
			flush_value.call(_slot[_idx])
		else:
			_slot[_idx].set_value(null)
		_idx = wrapi(_idx + 1, 0, _slot.size())
		_slot[_idx].set_value(value)
		_flush_idx += 1
		updated.emit(last_value, value)
		return
	error.emit(last_value, value)
