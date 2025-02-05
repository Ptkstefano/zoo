extends Node

enum PEEP_THOUGHTS {
	## Positive
	SEEN_FAVORITE_ANIMAL,
	EXCEEDED_ANIMAL_RATING_EXPECTATIONS,
	SEEN_ALL_DESIRED_ANIMALS,
	GREAT_VALUE_FOOD,
	FILLED_NEEDS,
	ATE_AT_RESTAURANT,
	ONLY_SAW_HAPPY_ANIMALS,
	MISSED_ANIMAL,
	NO_TOILET,
	NO_FOOD,
	NO_REST_SPOT,
	TOO_EXPENSIVE,
	NO_SHOP_STOCK,
	EMPTY_SHOP,
	NO_DESIRABLE_QUALITY,
	NO_FOOD_SHOP_IN_RANGE,
	SAW_UNHAPPY_ANIMAL,
	SEEN_FEW_ANIMALS,
	SAW_DEAD_ANIMAL,
	GREAT_VALUE_ENTRANCE,
}

var peep_thoughts = {
	## Positive
	PEEP_THOUGHTS.SEEN_FAVORITE_ANIMAL: PeepThought.new("We found our favorite animal!", 1, true),
	PEEP_THOUGHTS.EXCEEDED_ANIMAL_RATING_EXPECTATIONS: PeepThought.new("We saw lots of great animals!", 1, true),
	PEEP_THOUGHTS.SEEN_ALL_DESIRED_ANIMALS: PeepThought.new("We saw all animals we wanted to see!", 1, true),
	PEEP_THOUGHTS.GREAT_VALUE_FOOD: PeepThought.new("The food we bought was of great value!", 0.5, true),
	PEEP_THOUGHTS.FILLED_NEEDS: PeepThought.new("We were confortable in our visit", 0.5, true),
	PEEP_THOUGHTS.ATE_AT_RESTAURANT:  PeepThought.new("We ate at a good restaurant", 0.5, true),
	PEEP_THOUGHTS.ONLY_SAW_HAPPY_ANIMALS:  PeepThought.new("All the animals seemed happy!", 0.5, true),
	PEEP_THOUGHTS.GREAT_VALUE_ENTRANCE: PeepThought.new("The entrance price was really good!", 0.5, true),
	## Negative
	PEEP_THOUGHTS.MISSED_ANIMAL: PeepThought.new("We did not see an animal we came to see", -0.5, false),
	PEEP_THOUGHTS.NO_TOILET: PeepThought.new("We could not find a toilet", -2, false),
	PEEP_THOUGHTS.NO_FOOD: PeepThought.new("We could not find food", -1, false),
	PEEP_THOUGHTS.NO_REST_SPOT: PeepThought.new("We got tired and found no benches", -1, false),
	PEEP_THOUGHTS.TOO_EXPENSIVE: PeepThought.new("The product we wanted was too expensive", -0.25, false),
	PEEP_THOUGHTS.NO_SHOP_STOCK: PeepThought.new("We wanted to buy an item, but it was out of stock", -0.5, false),
	PEEP_THOUGHTS.EMPTY_SHOP: PeepThought.new("We went to an empty shop", -0.25, false),
	PEEP_THOUGHTS.NO_DESIRABLE_QUALITY: PeepThought.new("We found no products we wanted to buy", -0.25, false),
	PEEP_THOUGHTS.NO_FOOD_SHOP_IN_RANGE: PeepThought.new("All eateries were too f/ar away from us", -0.25, false),
	PEEP_THOUGHTS.SAW_UNHAPPY_ANIMAL: PeepThought.new("We saw an unhappy animal", -1.5, false),
	PEEP_THOUGHTS.SEEN_FEW_ANIMALS: PeepThought.new("We saw too few animals for a zoo trip", -1.5, false),
	PEEP_THOUGHTS.SAW_DEAD_ANIMAL: PeepThought.new("We saw a dead animal", -1, false)
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
