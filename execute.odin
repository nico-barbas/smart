package smart

Behavior_Result :: enum {
	Success,
	Failure,
	Running,
}

execute :: proc(tree: ^Behavior_Tree) -> (result: Behavior_Result) {
	return
}
