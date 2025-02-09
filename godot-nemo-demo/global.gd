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
	
	# https://huggingface.co/latent-consistency/lcm-lora-sdv1-5/blob/main/pytorch_lora_weights.safetensors -> lcm-lora-sdv1-5.safetensors
	
	# https://civitai.com/models/4384?modelVersionId=94081
	diffusion.set_path(modelPath + "dreamshaper_631BakedVae.safetensors")
	
	# https://huggingface.co/lllyasviel/ControlNet-v1-1/blob/main/control_v11f1p_sd15_depth.pth
	# sd -M convert -m control_v11f1p_sd15_depth.pth -o control_depth.gguf -v --type q8_0
	#Global.diffusion.set_control_path(modelPath + "control_depth.gguf")
	
