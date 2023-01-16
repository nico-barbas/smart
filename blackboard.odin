package smart

Blackboard :: map[string]Blackboard_Value

Blackboard_Value :: union {
	bool,
	int,
	f32,
	string,
	Blackboard,
	rawptr,
}

Blackboard_Value_Kind :: enum {
	Bool,
	Int,
	Float,
	String,
	Nested_Blackboard,
	Rawptr,
}

value_equal :: proc(v1, v2: Blackboard_Value) -> (ok: bool) {
	t := value_type(v1)
	if value_type(v2) != t {
		ok = false
		return
	}

	switch v in v1 {
	case bool:
		ok = v == v2.(bool)

	case int:
		ok = v == v2.(int)

	case f32:
		ok = v == v2.(f32)

	case string:
		ok = v == v2.(string)

	case Blackboard:
		ok = len(v) == len(v2.(Blackboard))

	case rawptr:
		ok = v == v2.(rawptr)

	}

	return
}

value_type :: proc(value: Blackboard_Value) -> (kind: Blackboard_Value_Kind) {
	switch v in value {
	case bool:
		kind = .Bool
	case int:
		kind = .Int

	case f32:
		kind = .Float

	case string:
		kind = .String

	case Blackboard:
		kind = .Nested_Blackboard

	case rawptr:
		kind = .Rawptr

	}

	return
}
