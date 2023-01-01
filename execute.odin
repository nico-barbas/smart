package smart

Behavior_Result :: enum {
	Success,
	Failure,
	Running,
}

run :: proc(tree: ^Behavior_Tree) -> (result: Behavior_Result) {
	execute :: proc(tree: ^Behavior_Tree, node: ^Behavior_Node) -> (result: Behavior_Result) {
		for decorator in node.before_execution {
			switch d in decorator {
			case Condition_Decorator:
				if !(d.condition_proc(node)) {
					result = .Failure
					return
				}
			case Ignore_Decorator:
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
			if n->predicate() {
				result = execute(tree, n.left)
			} else {
				result = execute(tree, n.left)
			}

		case ^Behavior_Action:
			switch n->action() {
			case .Done:
				result = .Success
			case .Not_Done:
				result = .Running
			}
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

	result = execute(tree, tree.root)
	return
}
