package smart

import "core:runtime"

when ODIN_DEBUG {
	import "core:log"
}

Behavior_Tree :: struct {
	allocator:            runtime.Allocator,
	blackboard:           Blackboard,
	root:                 ^Behavior_Node,
	options:              Behavior_Tree_Options,
	flags:                Behavior_Tree_Flags,
	utility_refresh_rate: f32,
	utility_refresh_time: f32,
}

Behavior_Tree_Options :: distinct bit_set[Behavior_Tree_Option]

Behavior_Tree_Option :: enum {
	Utility_Based,
	Utility_Sort_Sequences,
	Utility_Sort_Selectors,
}

Behavior_Tree_Flags :: distinct bit_set[Behavior_Tree_Flag]

Behavior_Tree_Flag :: enum {
	Force_Utility_Refresh,
}

Behavior_Node :: struct {
	parent:           ^Behavior_Node,
	blackboard:       ^Blackboard,
	derived:          Any_Behavior_Node,
	before_execution: [dynamic]Begin_Decorator,
	after_execution:  [dynamic]End_Decorator,
	result_modifier:  Result_Modifier_Decorator,

	// Utility extension
	utility_score:    Utility_Score,
	utility_proc:     proc(node: ^Behavior_Node) -> Utility_Score,
}

Any_Behavior_Node :: union {
	^Behavior_Sequence,
	^Behavior_Branch,
	^Behavior_Action,
}

Behavior_Sequence :: struct {
	using base:             Behavior_Node,
	children:               [dynamic]^Behavior_Node,
	halt_signal:            Behavior_Result,
	override_utility_score: bool,
	skip_utility_sort:      bool,
}

Behavior_Branch :: struct {
	using base:     Behavior_Node,
	predicate_proc: proc(node: ^Behavior_Node) -> Condition_Proc_Result,
	left:           ^Behavior_Node,
	right:          ^Behavior_Node,
}

Condition_Proc_Result :: bool

Behavior_Action :: struct {
	using base:  Behavior_Node,
	action_proc: proc(node: ^Behavior_Node) -> Behavior_Result,
}

new_node :: proc(
	tree: ^Behavior_Tree,
	$T: typeid,
	begins: []Begin_Decorator = nil,
	ends: []End_Decorator = nil,
	modifier: Result_Modifier_Decorator = nil,
) -> ^T {
	node := new(T, tree.allocator)
	node.derived = node
	init_behavior_node(tree, node)

	if len(begins) > 0 {
		for decorator in begins {
			append(&node.before_execution, decorator)
		}
	}
	if len(ends) > 0 {
		for decorator in ends {
			append(&node.after_execution, decorator)
		}
	}

	if modifier != nil {
		node.result_modifier = modifier
	}
	return node
}

new_node_from :: proc(
	tree: ^Behavior_Tree,
	from: $T,
	begins: []Begin_Decorator = nil,
	ends: []End_Decorator = nil,
	modifier: Result_Modifier_Decorator = nil,
) -> ^T {
	node := new_clone(from, tree.allocator)
	node.derived = node
	init_behavior_node(tree, node)

	if len(begins) > 0 {
		for decorator in begins {
			append(&node.before_execution, decorator)
		}
	}
	if len(ends) > 0 {
		for decorator in ends {
			append(&node.after_execution, decorator)
		}
	}

	if modifier != nil {
		node.result_modifier = modifier
	}
	return node
}

init_behavior_node :: proc(tree: ^Behavior_Tree, node: ^Behavior_Node) {
	when ODIN_DEBUG {
		if .Utility_Based in tree.options && node.utility_proc == nil {
			log.errorf(
				"In a Utility based Tree, Behavior nodes must have a utility callback procedure\n",
			)
		}
	}

	switch n in node.derived {
	case ^Behavior_Sequence:
		n.children.allocator = tree.allocator
	case ^Behavior_Branch:
	case ^Behavior_Action:
		when ODIN_DEBUG {
			if n.action_proc == nil {
				log.errorf("Behavior Action nodes must have a callback procedure\n")
			}
		}
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

add_sequence_children :: proc(sequence: ^Behavior_Sequence, children: ..^Behavior_Node) {
	for child in children {
		child.parent = sequence
		append(&sequence.children, child)
	}
}
