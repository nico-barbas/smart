package smart

import "core:math"
import "core:sort"

Utility_Score :: distinct int

refresh_nodes_utility :: proc(tree: ^Behavior_Tree) {
	utility :: proc(tree: ^Behavior_Tree, node: ^Behavior_Node) -> (score: Utility_Score) {
		switch n in node.derived {
		case ^Behavior_Sequence:
			utility_max := Utility_Score(int(math.inf_f32(-1)))
			utility_sum: Utility_Score = 0
			for child in n.children {
				child_score := utility(tree, child)
				utility_sum += child_score
				utility_max = max(utility_max, child_score)
			}

			if n.override_utility_score {
				n.utility_score = n.utility_proc(n)
			} else {
				switch n.halt_signal {
				case .Failure:
					n.utility_score = utility_sum / Utility_Score(len(n.children))
				case .Success:
					n.utility_score = utility_max
				case .Running:
					assert(false)
				}
			}

		case ^Behavior_Branch:
			utility_max := Utility_Score(int(math.inf_f32(-1)))
			utility_max = max(utility_max, utility(tree, n.left))
			n.utility_score = max(utility_max, utility(tree, n.right))

		case ^Behavior_Action:
			n.utility_score = n->utility_proc()

		}
		score = node.utility_score
		return
	}

	utility(tree, tree.root)
}

sort_nodes_by_utility :: proc(tree: ^Behavior_Tree) {
	sort_node :: proc(tree: ^Behavior_Tree, node: ^Behavior_Node) {
		#partial switch n in node.derived {
		case ^Behavior_Sequence:
			if n.skip_utility_sort {
				return
			}

			it := sort.Interface {
				collection = n,
				len = proc(it: sort.Interface) -> int {
					n := cast(^Behavior_Sequence)it.collection
					return len(n.children)
				},
				less = proc(it: sort.Interface, i, j: int) -> bool {
					n := cast(^Behavior_Sequence)it.collection
					return n.children[i].utility_score < n.children[j].utility_score
				},
				swap = proc(it: sort.Interface, i, j: int) {
					n := cast(^Behavior_Sequence)it.collection
					n.children[i], n.children[j] = n.children[j], n.children[i]
				},
			}

			sort.sort(it)
		}
	}
}
