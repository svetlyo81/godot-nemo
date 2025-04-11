extends Control

var thread: Thread

# Called when the node enters the scene tree for the first time.
func _ready():
	thread = Thread.new()
	
	Global.llama.response.connect(_on_llama_response)
	Global.llama.finish.connect(_on_llama_finish)
	Global.llama.set_sys_prompt("You are an AI Large Language Model trained to generate a random Stable Diffusion prompt for Dreamshaper 6. You never include style in your prompt. You never refer to artists, copyrighted works, copyright owners, or anything else that may infringe copyright in your prompt.")
	Global.llama.set_prompt("landscape")
	
	'''var file = FileAccess.open("res://grammar.gbnf", FileAccess.READ)
	if(file != null):
		var content = file.get_as_text()
		file.close()
		Global.llama.set_grammar(content)'''

func _on_generate_button_pressed():
	if Global.llama != null && !Global.llama.is_running() && Global.diffusion != null && !Global.diffusion.is_running():
		$RichTextLabel.text = ""
		thread.start(llama_test, Thread.PRIORITY_HIGH)

func llama_test():
	Global.llama.start()
func _on_llama_response(val):
	call_deferred("_deferred_llama_response", val)
func _deferred_llama_response(val:String):
	$RichTextLabel.text += val
func _on_llama_finish():
	call_deferred("_deferred_llama_finish")
func _deferred_llama_finish():
	if Global.llama != null && Global.llama.is_running():
		Global.llama.stop()
		
		Global.diffusion.set_prompt($RichTextLabel.text + "<lora:lcm-lora-sdv1-5:0.7>")
		
		Global.diffusion.set_param("width", 768)
		Global.diffusion.set_param("height", 512)
		Global.diffusion.set_param("sample_method", 9) # lcm
		Global.diffusion.set_param("cfg_scale", 2.0)
		Global.diffusion.set_param("sample_steps", 6.0)
		#Global.diffusion.set_param("seed", 13722)
		#Global.diffusion.set_param("strength", 1.0)
		#Global.diffusion.set_param("control_strength", 0.9)
		#Global.diffusion.set_param("enable_taesd", 1)
		#Global.diffusion.set_param("enable_vae_tiling", 1)
		
		'''var image = Image.load_from_file("res://reference_image.png") # img2img
		Global.diffusion.set_image(image.save_png_to_buffer())
		
		image = Image.load_from_file("res://mask_image.png") # inpainting
		Global.diffusion.set_mask_image(image.save_png_to_buffer())
		
		image = Image.load_from_file("res://depth_map.png") # controlnet depth
		Global.diffusion.set_control_image(image.save_png_to_buffer())'''
		
		thread.wait_to_finish()
		thread.start(diffusion_test, Thread.PRIORITY_HIGH)

func diffusion_test():
	var image = Image.new()
	image.load_png_from_buffer(Global.diffusion.start())
	var texture = ImageTexture.create_from_image(image)
	call_deferred("_deferred_diffusion_finish", texture)
func _deferred_diffusion_finish(val:ImageTexture):
	$TextureRect.texture = val
	thread.wait_to_finish()

func _exit_tree():
	if thread != null && thread.is_started(): thread.wait_to_finish()
	thread = null
