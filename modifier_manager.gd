extends Node

enum PEEP_MODIFIERS {
	## Positive
	SEEN_FAVORITE_ANIMAL,
	EXCEEDED_ANIMAL_RATING_EXPECTATIONS,
	SEEN_ALL_DESIRED_ANIMALS,
	GREAT_VALUE_FOOD,
	FILLED_NEEDS,
	ATE_AT_RESTAURANT,
	
	## Negative
	MISSED_ANIMAL,
	NO_TOILET,
	NO_FOOD,
	NO_REST_SPOT,
	TOO_EXPENSIVE,
	NO_SHOP_STOCK,
	EMPTY_SHOP,
	NO_DESIRABLE_QUALITY,
	NO_FOOD_SHOP_IN_RANGE
}

var peep_modifiers = {
	## Positive
	PEEP_MODIFIERS.SEEN_FAVORITE_ANIMAL: PeepModifier.new("Group found their favorite animal in the zoo", 1),
	PEEP_MODIFIERS.EXCEEDED_ANIMAL_RATING_EXPECTATIONS: PeepModifier.new("Group saw more great animals than they were expecting", 1),
	PEEP_MODIFIERS.SEEN_ALL_DESIRED_ANIMALS: PeepModifier.new("Group saw all the animals they wanted to see", 1),
	PEEP_MODIFIERS.GREAT_VALUE_FOOD: PeepModifier.new("Group bought food at great value", 0.5),
	PEEP_MODIFIERS.FILLED_NEEDS: PeepModifier.new("Group had no unfulfilled needs", 0.5),
	PEEP_MODIFIERS.ATE_AT_RESTAURANT:  PeepModifier.new("Group ate at restaurant", 0.5),
	## Negative
	PEEP_MODIFIERS.MISSED_ANIMAL: PeepModifier.new("Group left without seeing animal they came to see", -0.5),
	PEEP_MODIFIERS.NO_TOILET: PeepModifier.new("Group could not find a toilet in time", -2),
	PEEP_MODIFIERS.NO_FOOD: PeepModifier.new("Group could not find food in time", -1),
	PEEP_MODIFIERS.NO_REST_SPOT: PeepModifier.new("Group could not find a rest spot in time", -1),
	PEEP_MODIFIERS.TOO_EXPENSIVE: PeepModifier.new("Group found no adequately priced items in shop", -0.25),
	PEEP_MODIFIERS.NO_SHOP_STOCK: PeepModifier.new("Group wanted to buy out of stock item", -0.5),
	PEEP_MODIFIERS.EMPTY_SHOP: PeepModifier.new("Group found shop with no items available", -0.25),
	PEEP_MODIFIERS.NO_DESIRABLE_QUALITY: PeepModifier.new("Group found no item of suitable quality level", -0.25),
	PEEP_MODIFIERS.NO_FOOD_SHOP_IN_RANGE: PeepModifier.new("Group found no food shop in reasonable distance", -0.25),
}


enum ANIMAL_MODIFIERS {
	## Positive
	OK_HABITAT,
	GOOD_HABITAT,
	IDEAL_HABITAT,
	HAS_FAVORITE_TREE,
	HAS_SHELTER,
	## Negative
	BAD_HABITAT,
	TOO_CROWDED,
	HERD_TOO_SMALL,
	HERD_TOO_BIG,
	NO_WATER,
	NO_FAVORITE_TREE,
	HUNGRY,
}

var animal_modifiers = {
	## Positive
	ANIMAL_MODIFIERS.OK_HABITAT: AnimalModifier.new("My habitat is ok", 1),
	ANIMAL_MODIFIERS.GOOD_HABITAT: AnimalModifier.new("My habitat is decent", 1.5),
	ANIMAL_MODIFIERS.IDEAL_HABITAT: AnimalModifier.new("I love my habitat", 2),
	ANIMAL_MODIFIERS.HAS_FAVORITE_TREE: AnimalModifier.new("I have my favorite tree!", 0.5),
	ANIMAL_MODIFIERS.HAS_SHELTER: AnimalModifier.new("I have shelter", 1),
	## Negative
	ANIMAL_MODIFIERS.BAD_HABITAT: AnimalModifier.new("Group found no food shop in reasonable distance", -2),
	ANIMAL_MODIFIERS.TOO_CROWDED: AnimalModifier.new("Group found no food shop in reasonable distance", -1),
	ANIMAL_MODIFIERS.HERD_TOO_SMALL: AnimalModifier.new("Group found no food shop in reasonable distance", -1),
	ANIMAL_MODIFIERS.HERD_TOO_BIG: AnimalModifier.new("Group found no food shop in reasonable distance", -1),
	ANIMAL_MODIFIERS.NO_WATER: AnimalModifier.new("Group found no food shop in reasonable distance", -1),
	ANIMAL_MODIFIERS.NO_FAVORITE_TREE: AnimalModifier.new("Group found no food shop in reasonable distance", -1),
	ANIMAL_MODIFIERS.HUNGRY: AnimalModifier.new("Group found no food shop in reasonable distance", -5),
}
