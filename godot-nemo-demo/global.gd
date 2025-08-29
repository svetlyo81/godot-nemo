extends Node

var llama: Llama
var rag: Rag
var diffusion: Diffusion

func _ready():
	var modelPath = ProjectSettings.globalize_path("res://")
	
	llama = Llama.new()
	llama.set_path(modelPath + "Mistral-Nemo-Instruct-2407.Q5_K_M.gguf") # https://huggingface.co/bartowski/Mistral-Nemo-Instruct-2407-GGUF/blob/9124e92876a2a7c0e8741d7176343f45b3896960/Mistral-Nemo-Instruct-2407-Q5_K_M.gguf
	llama.initialize()
	
	rag = Rag.new()
	rag.set_path(modelPath + "mxbai-embed-large-v1.Q5_K_M.gguf") # https://huggingface.co/ChristianAzinn/mxbai-embed-large-v1-gguf/blob/main/mxbai-embed-large-v1.Q5_K_M.gguf
	rag.set_db_path(modelPath + "llm.db")
	rag.initialize()
	
	# https://github.com/Adriankhl/godot-llm-template?tab=readme-ov-file#vector-database
	'''if rag != null:
		var array = rag.retrieve_similar_texts("Godot engine", "id='myid' AND type=2023", 6)
		for s in array: print (s, "\n\n")'''
	
	
	diffusion = Diffusion.new()
	
	# https://huggingface.co/Lykon/dreamshaper-xl-lightning/blob/main/DreamShaperXL_Lightning-SFW.safetensors
	diffusion.set_path(modelPath + "DreamShaperXL_Turbo-Lightning-SFW.safetensors")

func diffusion_start() -> PackedByteArray:
	var buffer = diffusion.start()
	var alloc_fails = diffusion.get_alloc_fail_count()
	
	if alloc_fails == 1:
		diffusion.freeModel()
		llama.freeModel()
		llama.set_should_use_gpu(true)
		
		if llama.set_gpu_free_mem(8000):
			llama.initialize()
			buffer = diffusion.start()
			alloc_fails = diffusion.get_alloc_fail_count()
		else:
			alloc_fails = 2
		
		if alloc_fails == 2:
			diffusion.freeModel()
			llama.freeModel()
			llama.set_should_use_gpu(false)
			llama.initialize()
			buffer = diffusion.start()
	
	return buffer
