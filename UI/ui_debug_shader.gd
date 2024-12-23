extends VBoxContainer

func _ready():
	$R.value_changed.connect(change)
	$G.value_changed.connect(change)
	$B.value_changed.connect(change)
	$Quant.value_changed.connect(change)
	$Bright.value_changed.connect(change)
	$Contrast.value_changed.connect(change)
	
func change(a):
	%PostFX.material.set("shader_param/saturation_r", $R.value)
	%PostFX.material.set("shader_param/saturation_g", $G.value)
	%PostFX.material.set("shader_param/saturation_b", $B.value)
	%PostFX.material.set("shader_param/color_quantization", $Quant.value)
	%PostFX.material.set("shader_param/brightness", $Bright.value)
	%PostFX.material.set("shader_param/contrast", $Contrast.value)
