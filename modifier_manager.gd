extends Node

enum PEEP_MODIFIERS {
	## Positive
	SEEN_FAVORITE_ANIMAL,
	EXCEEDED_ANIMAL_RATING_EXPECTATIONS,
	SEEN_ALL_DESIRED_ANIMALS,
	GREAT_VALUE_FOOD,
	FILLED_NEEDS,
	
	## Negative
	MISSED_ANIMAL,
	NO_TOILET,
	NO_FOOD,
	NO_REST_SPOT,
	TOO_EXPENSIVE,
}

var peep_modifiers = {
	## Positive
	PEEP_MODIFIERS.SEEN_FAVORITE_ANIMAL: PeepModifier.new("Group found their favorite animal in the zoo", 1),
	PEEP_MODIFIERS.EXCEEDED_ANIMAL_RATING_EXPECTATIONS: PeepModifier.new("Group saw more great animals than they were expecting", 1),
	PEEP_MODIFIERS.SEEN_ALL_DESIRED_ANIMALS: PeepModifier.new("Group saw all the animals they wanted to see", 1),
	PEEP_MODIFIERS.GREAT_VALUE_FOOD: PeepModifier.new("Group bought food at great value", 0.5),
	PEEP_MODIFIERS.FILLED_NEEDS: PeepModifier.new("Group had no unfulfilled needs", 0.5),
	## Negative
	PEEP_MODIFIERS.MISSED_ANIMAL: PeepModifier.new("Group left without seeing animal they came to see", -0.5),
	PEEP_MODIFIERS.NO_TOILET: PeepModifier.new("Group could not find a toilet in time", -2),
	PEEP_MODIFIERS.NO_FOOD: PeepModifier.new("Group could not find food in time", -1),
	PEEP_MODIFIERS.NO_REST_SPOT: PeepModifier.new("Group could not find a rest spot in time", -1),
	PEEP_MODIFIERS.TOO_EXPENSIVE: PeepModifier.new("Group found no adequately priced items in shop", -0.25)
}
