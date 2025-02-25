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
	ENTRANCE_TOO_EXPENSIVE,
}

var bubbles = {
	'NONE': -1,
	'HAPPY_SMILE': 0,
	'SAD_SMILE': 1,
	'THUMBS_UP': 2,
	'THUMBS_DOWN': 3,
	'NO_TOILET': 4,
	'NO_BENCH': 5,
	'NO_FOOD': 6
}

var peep_thoughts = {
	## Positive
	PEEP_THOUGHTS.SEEN_FAVORITE_ANIMAL: PeepThought.new('THOUGHT_SEEN_FAVORITE_ANIMAL', 1, true, bubbles['HAPPY_SMILE']),
	PEEP_THOUGHTS.EXCEEDED_ANIMAL_RATING_EXPECTATIONS: PeepThought.new('THOUGHT_EXCEEDED_ANIMAL_RATING_EXPECTATIONS', 1, true, bubbles['NONE']),
	PEEP_THOUGHTS.SEEN_ALL_DESIRED_ANIMALS: PeepThought.new('THOUGHT_SEEN_ALL_DESIRED_ANIMALS', 1, true, bubbles['NONE']),
	PEEP_THOUGHTS.GREAT_VALUE_FOOD: PeepThought.new('THOUGHT_GREAT_VALUE_FOOD', 0.5, true, bubbles['THUMBS_UP']),
	PEEP_THOUGHTS.FILLED_NEEDS: PeepThought.new('THOUGHT_FILLED_NEEDS', 0.5, true, bubbles['NONE']),
	PEEP_THOUGHTS.ATE_AT_RESTAURANT:  PeepThought.new('THOUGHT_ATE_AT_RESTAURANT', 0.5, true, bubbles['NONE']),
	PEEP_THOUGHTS.ONLY_SAW_HAPPY_ANIMALS:  PeepThought.new('THOUGHT_ONLY_SAW_HAPPY_ANIMALS', 0.5, true, bubbles['NONE']),
	PEEP_THOUGHTS.GREAT_VALUE_ENTRANCE: PeepThought.new('THOUGHT_GREAT_VALUE_ENTRANCE', 0.5, true, bubbles['THUMBS_UP']),
	## Negative
	PEEP_THOUGHTS.MISSED_ANIMAL: PeepThought.new('THOUGHT_MISSED_ANIMAL', -0.5, false, bubbles['SAD_SMILE']),
	PEEP_THOUGHTS.NO_TOILET: PeepThought.new('THOUGHT_NO_TOILET', -2, false, bubbles['NO_TOILET']),
	PEEP_THOUGHTS.NO_FOOD: PeepThought.new('THOUGHT_NO_FOOD', -1, false, bubbles['NO_FOOD']),
	PEEP_THOUGHTS.NO_REST_SPOT: PeepThought.new('THOUGHT_NO_REST_SPOT', -1, false, bubbles['NO_BENCH']),
	PEEP_THOUGHTS.TOO_EXPENSIVE: PeepThought.new('THOUGHT_TOO_EXPENSIVE', -0.25, false, bubbles['NONE']),
	PEEP_THOUGHTS.NO_SHOP_STOCK: PeepThought.new('THOUGHT_NO_SHOP_STOCK', -0.5, false, bubbles['THUMBS_DOWN']),
	PEEP_THOUGHTS.EMPTY_SHOP: PeepThought.new('THOUGHT_EMPTY_SHOP', -0.25, false, bubbles['THUMBS_DOWN']),
	PEEP_THOUGHTS.NO_DESIRABLE_QUALITY: PeepThought.new('THOUGHT_NO_DESIRABLE_QUALITY', -0.25, false, bubbles['NONE']),
	PEEP_THOUGHTS.NO_FOOD_SHOP_IN_RANGE: PeepThought.new('THOUGHT_NO_FOOD_SHOP_IN_RANGE', -0.25, false, bubbles['NO_FOOD']),
	PEEP_THOUGHTS.SAW_UNHAPPY_ANIMAL: PeepThought.new('THOUGHT_SAW_UNHAPPY_ANIMAL', -1.5, false, bubbles['SAD_SMILE']),
	PEEP_THOUGHTS.SEEN_FEW_ANIMALS: PeepThought.new('THOUGHT_SEEN_FEW_ANIMALS', -1.5, false, bubbles['NONE']),
	PEEP_THOUGHTS.SAW_DEAD_ANIMAL: PeepThought.new('THOUGHT_SAW_DEAD_ANIMAL', -1, false, bubbles['SAD_SMILE']),
	PEEP_THOUGHTS.ENTRANCE_TOO_EXPENSIVE: PeepThought.new('THOUGHT_ENTRANCE_TOO_EXPENSIVE', 0, false, bubbles['THUMBS_DOWN']),
	
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
