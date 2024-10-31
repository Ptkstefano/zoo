extends Node

var modifier_list = []

func add_peep_group_modifiers(group_modifiers):
	for modifier in group_modifiers:
		if modifier_list.size() > 100:
			modifier_list.remove_at(0)
			
		modifier_list.append(modifier)
