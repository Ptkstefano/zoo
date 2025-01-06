extends CanvasLayer

func apply_color(color):
	var stylebox = $InfoBorderPanel.get_theme_stylebox("panel")
	stylebox.border_color = color
