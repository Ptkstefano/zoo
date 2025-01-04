extends Node

enum PEEP_MODIFIERS {
	## Positive
	SEEN_FAVORITE_ANIMAL,
	EXCEEDED_ANIMAL_RATING_EXPECTATIONS,
	SEEN_ALL_DESIRED_ANIMALS,
	GREAT_VALUE_FOOD,
	FILLED_NEEDS,
	ATE_AT_RESTAURANT,
	ONLY_SAW_HAPPY_ANIMALS,
	
	## Negative
	MISSED_ANIMAL,
	NO_TOILET,
	NO_FOOD,
	NO_REST_SPOT,
	TOO_EXPENSIVE,
	NO_SHOP_STOCK,
	EMPTY_SHOP,
	NO_DESIRABLE_QUALITY,
	NO_FOOD_SHOP_IN_RANGE,
	SAW_UNHAPPY_ANIMAL
}

var peep_modifiers = {
	## Positive
	PEEP_MODIFIERS.SEEN_FAVORITE_ANIMAL: PeepModifier.new("We found our favorite animal!", 1),
	PEEP_MODIFIERS.EXCEEDED_ANIMAL_RATING_EXPECTATIONS: PeepModifier.new("We saw lots of great animals!", 1),
	PEEP_MODIFIERS.SEEN_ALL_DESIRED_ANIMALS: PeepModifier.new("We saw all animals we wanted to see!", 1),
	PEEP_MODIFIERS.GREAT_VALUE_FOOD: PeepModifier.new("The food we bought was of great value!", 0.5),
	PEEP_MODIFIERS.FILLED_NEEDS: PeepModifier.new("We were confortable in our visit", 0.5),
	PEEP_MODIFIERS.ATE_AT_RESTAURANT:  PeepModifier.new("We ate at a good restaurant", 0.5),
	PEEP_MODIFIERS.ONLY_SAW_HAPPY_ANIMALS:  PeepModifier.new("All the animals were happy with their habitats!", 0.5),
	## Negative
	PEEP_MODIFIERS.MISSED_ANIMAL: PeepModifier.new("We did not see an animal we came to see", -0.5),
	PEEP_MODIFIERS.NO_TOILET: PeepModifier.new("We could not find a toilet", -2),
	PEEP_MODIFIERS.NO_FOOD: PeepModifier.new("We could not find food", -1),
	PEEP_MODIFIERS.NO_REST_SPOT: PeepModifier.new("We got tired and found no benches", -1),
	PEEP_MODIFIERS.TOO_EXPENSIVE: PeepModifier.new("The product we wanted was too expensive", -0.25),
	PEEP_MODIFIERS.NO_SHOP_STOCK: PeepModifier.new("We wanted to buy an item, but it was out of stock", -0.5),
	PEEP_MODIFIERS.EMPTY_SHOP: PeepModifier.new("We went to an empty shop", -0.25),
	PEEP_MODIFIERS.NO_DESIRABLE_QUALITY: PeepModifier.new("We found no products we wanted to buy", -0.25),
	PEEP_MODIFIERS.NO_FOOD_SHOP_IN_RANGE: PeepModifier.new("All eateries were too far away from us", -0.25),
	PEEP_MODIFIERS.SAW_UNHAPPY_ANIMAL: PeepModifier.new("We saw an unhappy animal", -1.5),
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
