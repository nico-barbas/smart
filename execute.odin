package smart

Behavior_Result :: enum {
	Success,
	Failure,
	Running,
}

run :: proc(tree: ^Behavior_Tree, dt: f32) -> (result: Behavior_Result) {
	execute :: proc(tree: ^Behavior_Tree, node: ^Behavior_Node) -> (result: Behavior_Result) {
		for decorator in node.before_execution {
			switch d in decorator {
			case Condition_Proc_Decorator:
				if !(d.condition_proc(node)) {
					result = .Failure
					return
				}

			case Condition_Property_Decorator:
				if v, exist := node.blackboard[d.key]; exist {
					if value_equal(v, d.expected) {
						result = .Failure
						return
					}
				}

			case Ignore_Property_Decorator:
				if v, exist := node.blackboard[d.key]; exist {
					if value_equal(v, d.expected) {
						result = .Success
						return
					}
				}

			case Ignore_Proc_Decorator:
				if d.ignore_proc(node) {
					result = .Success
					return
				}
			}
		}

		switch n in node.derived {
		case ^Behavior_Sequence:
			for child in n.children {
				result = execute(tree, child)
				if result == n.halt_signal || result == .Running {
					break
				}
			}

		case ^Behavior_Branch:
			if n->predicate_proc() {
				result = execute(tree, n.left)
			} else {
				result = execute(tree, n.left)
			}

		case ^Behavior_Action:
			result = n->action_proc()
		}

		for decorator in node.after_execution {
			switch d in decorator {
			case Property_Decorator:
				if result == d.trigger {
					node.blackboard[d.key] = d.value
				}
			}
		}
		return
	}

	if .Utility_Based in tree.options {
		tree.utility_refresh_time += dt
		should_refresh := tree.utility_refresh_time >= tree.utility_refresh_rate
		if should_refresh || .Force_Utility_Refresh in tree.flags {
			tree.utility_refresh_time = 0
			tree.flags -= {.Force_Utility_Refresh}
			refresh_nodes_utility(tree)
			sort_nodes_by_utility(tree)
		}
	}

	result = execute(tree, tree.root)
	return
}
