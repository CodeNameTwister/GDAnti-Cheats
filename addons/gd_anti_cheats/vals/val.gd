class_name _VAL extends Object
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	GDAnti-Cheats
#
#	https://github.com/CodeNameTwister/GDAnti-Cheats
#	author:	"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
var _value : Variant = null

func set_value(v : Variant) -> void:
	_value = v

func get_value() -> Variant:
	return _value

func unset() -> void:
	_value = null
