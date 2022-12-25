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
	rawptr,
}

Behavior_Node :: struct {
	parent:     ^Behavior_Node,
	blackboard: Blackboard,
	derived:    Any_Behavior_Node,
}

Any_Behavior_Node :: union {
	^Behavior_Sequence,
	^Behavior_Branch,
	^Behavior_Condition,
	^Behavior_Action,
}

Behavior_Sequence :: struct {
	using base:  Behavior_Node,
	children:    [dynamic]^Behavior_Node,
	halt_signal: Behavior_Result,
}

Behavior_Branch :: struct {
	using base: Behavior_Node,
	predicate:  ^Behavior_Node,
	left:       ^Behavior_Node,
	right:      ^Behavior_Node,
}

Behavior_Condition :: struct {
	using base:     Behavior_Node,
	condition_proc: proc(node: ^Behavior_Node) -> Condition_Proc_Result,
}

Condition_Proc_Result :: bool

Behavior_Action :: struct {
	using base:  Behavior_Node,
	action_proc: proc(node: ^Behavior_Node) -> Action_Proc_Result,
}

Action_Proc_Result :: enum {
	Done,
	Not_Done,
}
