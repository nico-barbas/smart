package smart

Begin_Decorator :: union {
	Condition_Proc_Decorator,
	Condition_Property_Decorator,
	Ignore_Property_Decorator,
	Ignore_Proc_Decorator,
}

End_Decorator :: union {
	Property_Decorator,
}

Result_Modifier_Decorator :: union {
	Result_Always_Decorator,
	Result_Transformer_Decorator,
}

Condition_Proc_Decorator :: struct {
	condition_proc: #type proc(node: ^Behavior_Node) -> Condition_Proc_Result,
}

Condition_Property_Decorator :: struct {
	key:      string,
	expected: Blackboard_Value,
}

Ignore_Property_Decorator :: struct {
	key:      string,
	expected: Blackboard_Value,
}

Ignore_Proc_Decorator :: struct {
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
