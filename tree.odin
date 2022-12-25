package smart

import "core:runtime"

Behavior_Tree :: struct {
	allocator: runtime.Allocator,
	root:      ^Behavior_Node,
}

Blackboard :: map[string]Blackboard_Value

Blackboard_Value :: union {
	bool,
	int,
	f32,
	string,
	Blackboard,
	rawptr,
}

Behavior_Node :: struct {
	parent:           ^Behavior_Node,
	blackboard:       ^Blackboard,
	derived:          Any_Behavior_Node,
	before_execution: [dynamic]Begin_Decorator,
	after_execution:  [dynamic]End_Decorator,
	result_modifier:  Result_Modifier_Decorator,
}

Any_Behavior_Node :: union {
	^Behavior_Sequence,
	^Behavior_Branch,
	^Behavior_Action,
}

Behavior_Sequence :: struct {
	using base:  Behavior_Node,
	children:    [dynamic]^Behavior_Node,
	halt_signal: Behavior_Result,
}

Behavior_Branch :: struct {
	using base: Behavior_Node,
	predicate:  proc(node: ^Behavior_Node) -> Condition_Proc_Result,
	left:       ^Behavior_Node,
	right:      ^Behavior_Node,
}

Condition_Proc_Result :: bool

Behavior_Action :: struct {
	using base: Behavior_Node,
	action:     proc(node: ^Behavior_Node) -> Action_Proc_Result,
}

Action_Proc_Result :: enum {
	Done,
	Not_Done,
}
