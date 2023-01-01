package smart

Begin_Decorator :: union {
	Condition_Decorator,
	Ignore_Decorator,
}

End_Decorator :: union {
	Property_Decorator,
}

Result_Modifier_Decorator :: union {
	Result_Always_Decorator,
	Result_Transformer_Decorator,
}

Condition_Decorator :: struct {
	condition_proc: #type proc(node: ^Behavior_Node) -> Condition_Proc_Result,
}

Ignore_Decorator :: struct {
	ignore_proc: #type proc(node: ^Behavior_Node) -> Condition_Proc_Result,
}

Property_Decorator :: struct {
	trigger: Behavior_Result,
	key:     string,
	value:   Blackboard_Value,
}

Result_Always_Decorator :: struct {
	output: Behavior_Result,
}

Result_Transformer_Decorator :: struct {
	expected: Behavior_Result,
	output:   Behavior_Result,
}
