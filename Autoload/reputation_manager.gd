extends Node

#var current_guest_happiness : int:
	#set(value):
		#current_guest_happiness = clampi(value, 0, 100)
#
#var available_amenities
