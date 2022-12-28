package smart

import "core:runtime"

Behavior_Tree :: struct {
	allocator:  runtime.Allocator,
	blackboard: Blackboard,
	root:       ^Behavior_Node,
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

new_node :: proc(tree: ^Behavior_Tree, $T: typeid) -> ^T {
	node := new(T, tree.allocator)
	node.derived = node
	init_behavior_node(tree, node)
	return node
}

new_node_from :: proc(tree: ^Behavior_Tree, from: $T) -> ^T {
	node := new_clone(from, tree.allocator)
	node.derived = node
	init_behavior_node(tree, node)
	return node
}

init_behavior_node :: proc(tree: ^Behavior_Tree, node: ^Behavior_Node) {
	switch n in node.derived {
	case ^Behavior_Sequence:
		n.children.allocator = tree.allocator
	case ^Behavior_Branch:
	case ^Behavior_Action:
	}

	node.blackboard = &tree.blackboard
	node.before_execution.allocator = tree.allocator
	node.after_execution.allocator = tree.allocator
}

destroy_node :: proc(tree: ^Behavior_Tree, node: ^Behavior_Node) {
	switch n in node.derived {
	case ^Behavior_Sequence:
		for child in n.children {
			destroy_node(tree, child)
		}
	case ^Behavior_Branch:
		destroy_node(tree, n.left)
		destroy_node(tree, n.right)

	case ^Behavior_Action:

	}
	delete(node.before_execution)
	delete(node.after_execution)
	free(node)
}

destroy_blackboard :: proc(b: Blackboard) {
	for _, value in b {
		#partial switch v in value {
		case Blackboard:
			destroy_blackboard(v)
		}
	}
	delete(b)
}

new_tree :: proc(allocator := context.allocator) -> (tree: ^Behavior_Tree) {
	tree = new(Behavior_Tree)
	tree.allocator = allocator
	tree.blackboard.allocator = allocator

	return tree
}

set_tree_root :: proc(tree: ^Behavior_Tree, root: ^Behavior_Node) {
	tree.root = root
}

destroy_tree :: proc(tree: ^Behavior_Tree) {
	context.allocator = tree.allocator
	destroy_node(tree, tree.root)
	destroy_blackboard(tree.blackboard)
}
