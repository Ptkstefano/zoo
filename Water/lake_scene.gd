extends Node2D
class_name Lake


var line_points
var shoreline_points
var cells

signal lake_removed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$WaterFill.polygon = shoreline_points
	$ShoreLine.points = shoreline_points
	$RemovalArea/CollisionPolygon2D.polygon = line_points
	$RemovalArea.area_entered.connect(on_removal)
	
	var new_navigation_mesh = NavigationPolygon.new()
	new_navigation_mesh.add_outline(line_points)
	NavigationServer2D.bake_from_source_geometry_data(new_navigation_mesh, NavigationMeshSourceGeometryData2D.new());
	$NavigationRegion2D.navigation_polygon = new_navigation_mesh
	#$NavigationObstacle2D.vertices = line_points
	$StaticBody2D/CollisionPolygon2D.polygon = shrink_polygon(line_points, 0.04)
	#$Area2D/CollisionPolygon2D.polygon = shrink_polygon(line_points, 0.04)
	SignalBus.obstacle_changed.emit()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_removal(bulldozer):
	lake_removed.emit(cells)
	SignalBus.obstacle_changed.emit()
	queue_free()

func shrink_polygon(vertices, shrink_factor: float):
	# Step 1: Calculate the centroid of the polygon
	var centroid = Vector2(0, 0)
	for vertex in vertices:
		centroid += vertex
	centroid /= vertices.size()
	
	# Step 2: Move each vertex towards the centroid by shrink_factor
	var new_vertices = []
	for vertex in vertices:
		var direction = centroid - vertex
		var new_vertex = vertex + direction * shrink_factor
		new_vertices.append(new_vertex)

	return new_vertices
