extends Node

enum DIRECTIONS {
	E,
	S,
	W,
	N
}


enum ANIMAL_SPECIES {
	CAPYBARA,
	AMERICAN_FLAMINGO,
	KARDOFAN_GIRAFFE,
	WHITETAIL_DEER,
	RED_KANGAROO,
	RED_PANDA,
	BLACK_BEAR,
	AFRICAN_ELEPHANT,
	RED_FOX,
	JAGUAR,
	MANED_WOLF,
	SECRETARY_BIRD,
	MUSK_OX,
	BLACK_BUCK,
	ZEBRA,
	GREY_SEAL,
	CASSOWARY,
	PANDA_BEAR,
	DROMEDARY_CAMEL,
	WESTERN_GORILLA,
	LEATHERBACK_TURTLE,
	GOODFELLOWS_TREE_KANGAROO,
	HONEY_BADGER,
	AFRICAN_LION,
	ALASKAN_MOOSE,
	LEMUR,
	
}

enum SCENERY_TYPES{
	TREE,
	VEGETATION,
	DECORATION,
	ROCK
}

enum FIXTURES {
	BENCH,
	DECORATION,
	LIGHT
}

enum FIXTURE_POS {
	SIDE,
	CENTER,
	CORNER
}

enum BUILDING_TYPES {
	EATERY,
	TOILET,
	RESTAURANT,
	SHOP,
	ZOOKEEPER_STATION,
}

enum BUILDING_MENU {
	EATERY,
	RESTAURANT,
	SERVICE,
	ADMINISTRATION
}

enum BUILDINGS {
	ICE_CREAM_SHOP,
	SMALL_BATHROOM,
	ITALIAN_RESTAURANT,
	ZOOKEEPER_STATION
}

enum PRODUCT_TYPES {
	FOOD,
	SOUVENIR,
}

enum FOOD_TYPES {
	SNACK,
	MEAL
}

enum PRODUCTS {
	ICE_CREAM,
	MILK_SHAKE,
	BROWNIE_SUNDAE,
	PASTA_BOLOGNESE,
	PESTO_PASTA,
	SHRIMP_SQUID_INK_PASTA
}

enum PEEP_GROUP_MODIFIERS {
	EXPENSIVE_FOOD,
}

enum UI_BOXES {
	MANAGEMENT,
}

enum FEED_TYPES {
	MEAT,
	HERBIVORE,
	FRUIT,
	BAMBOO,
	SHRIMP,
	TALL_LEAVES,
	
}

enum PAYMENT_ADD_TYPES {
	ENTRANCE,
	PRODUCT
}

enum PAYMENT_REMOVE_TYPES {
	BUILDING_MAINTENANCE,
	PRODUCT_MAINTENANCE,
	CONSTRUCTION,
	RESTOCK,
	FEED,
	SALARY
}

enum TREE_SPECIES {
	ACACIA,
	ALDER,
	ALEPPO_PINE,
	ARAUCARIA,
	BAMBOO,
	BLOODWOOD,
	JACARANDA,
	LIMBER_PINE,
	PALM
}

enum TERRAIN_TYPES {
	## Order must match atlas_y
	GRASS,
	SAND,
	DIRT,
	DECIDUOUS,
	SAVANNA
}

enum HIGHLIGHT_TYPES{
	YELLOW,
	RED,
	BLUE,
	RED_BORDERLESS,
	BULLDOZING,
	BUILDING_E,
	BUILDING_S,
	BUILDING_W,
	BUILDING_N,
}

enum ANIMAL_GENDERS{
	FEMALE,
	MALE
}

enum STAFF_TYPES{
	ZOOKEEPER,
	ZOOKEEPER_UNIQUE,
	SCIENTIST,
	SCIENTIST_UNIQUE,
	JANITOR,
	VETERINARIAN,
	SECURITY_OFFICER
}
