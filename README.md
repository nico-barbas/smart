# Smart, a simple Behavior Tree library

A straight forward implementation of Behavior Trees for game AIs and automation.

Example:
```
import "smart"

main :: proc() {
  tree := smart.new_tree()
  
  root := smart.new_node(tree, smart.Behavior_Sequence_Node)
  
  smart.add_sequence_children(
    root,
    smart.new_node_from(tree, smart.Behavior_Action_Node{},
    // Add your nodes with logic and decorators
  )
  tree.root = root
  
  running := true
  for running {
    elapsed_time := 0
    smart.run(tree, elapsed_time)
  }
}
```
