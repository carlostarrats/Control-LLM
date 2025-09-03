🔇 Console flooding prevention enabled
🔍 App starting...
🔍 App started successfully
🔗 Initializing Shortcuts integration...
Shortcuts Service initialized
Shortcuts Integration Helper initialized
🔗 Shortcuts integration initialized with App Intents
🔍 MainView init
🔍 Init check: hasSeenOnboarding = true
🔍 ChatViewModel: init
🔍 ChatViewModel: Continuing existing session started at 2025-09-03 15:29:19 +0000
🔍 ChatViewModel: Loaded saved timing data - avg: 6.294737670570612s, total: 1007.1580272912979s, count: 160
🔍 ChatViewModel: Loaded model performance data for 7 models
   smollm2-1.7b-instruct-q4_k_m: avg=6.53s, fast=false
   gemma-3-1B-It-Q4_K_M: avg=7.30s, fast=false
   Qwen3-1.7B-Q4_K_M: avg=5.64s, fast=false
   Llama-3.2-1B-Instruct-Q4_K_M: avg=5.34s, fast=false
   Phi-4-mini-instruct-Q4_K_M: avg=31.49s, fast=false
   Gemma-3N-E4B-It-Q4_K_M: avg=196.60s, fast=false
   Qwen2.5-1.5B-Instruct-Q5_K_M: avg=2.40s, fast=true
🔍 ChatViewModel: Syncing initial model state...
🔍 TextModalView init
ModelManager: Loading available models...
ModelManager: Found model in bundle root: smollm2-1.7b-instruct-q4_k_m
ModelManager: Found model in bundle root: Qwen3-1.7B-Q4_K_M
ModelManager: Found model in bundle root: Llama-3.2-1B-Instruct-Q4_K_M
ModelManager: Found model in bundle root: gemma-3-1B-It-Q4_K_M
ModelManager: Found model: smollm2-1.7b-instruct-q4_k_m
ModelManager: Found model: Qwen3-1.7B-Q4_K_M
ModelManager: Found model: Llama-3.2-1B-Instruct-Q4_K_M
ModelManager: Found model: gemma-3-1B-It-Q4_K_M
ModelManager: Loaded 4 available models
ModelManager: Available models: ["Qwen3-1.7B-Q4_K_M", "gemma-3-1B-It-Q4_K_M", "smollm2-1.7b-instruct-q4_k_m", "Llama-3.2-1B-Instruct-Q4_K_M"]
🔍 Onboarding check: hasSeenOnboarding = true
🔍 User has already seen onboarding, keeping modal hidden
🔍 MainView appeared!
🔍 TextModalView: syncProcessingState - resetting isLocalProcessing from false to false
🔍 TextModalView: onAppear - Reset clipboard state and duplicate detection
🔍 TextModalView init
🎯 TARS onAppear - Starting with animationTime: 0.0
🔍 DEBUG: Setting window background to ORANGE
🔍 DEBUG: isSettingsSheetExpanded: false
🔍 DEBUG: isSheetExpanded: false
🔍 DEBUG: Window found: true
🔍 DEBUG: Window frame: (0.0, 0.0, 390.0, 844.0)
🔍 DEBUG: Window safe area: UIEdgeInsets(top: 47.0, left: 0.0, bottom: 34.0, right: 0.0)
🔍 DEBUG: Set root view controller background to ORANGE
🔍 ChatViewModel: No model loaded, but selected model exists: Qwen3-1.7B-Q4_K_M
🔍 ChatViewModel: Auto-loading selected model on startup...
🔍 HybridLLMService: Loading model: Qwen3-1.7B-Q4_K_M
🔍 HybridLLMService: Using llama.cpp for Qwen3-1.7B-Q4_K_M
🔍 LLMService: Loading specific model: Qwen3-1.7B-Q4_K_M (previous: none)
🔍 LLMService: Found model in Models directory: /private/var/containers/Bundle/Application/A21158AF-1FFE-41AA-82EE-23CC26A3B928/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf
🔍 LLMService: Clearing previous model before loading new one...
🔍 LLMService: Unloading model and cleaning up resources
🔍 LLMService: No model resources to free - already clean
🔍 LLMService: Reset conversation count for new model
🔍 LLMService: Set currentModelFilename to: Qwen3-1.7B-Q4_K_M
🔍 LLMService: Starting llama.cpp model loading...
LLMService: Loading model from path: /private/var/containers/Bundle/Application/A21158AF-1FFE-41AA-82EE-23CC26A3B928/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf
LlamaCppBridge: Loading model (real) from /private/var/containers/Bundle/Application/A21158AF-1FFE-41AA-82EE-23CC26A3B928/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf
LlamaCppBridge: Initializing llama backend
LlamaCppBridge: Backend initialized successfully
LlamaCppBridge: Attempting to load model with params: mmap=1, mlock=0, gpu_layers=0
llama[2]: llama_model_load_from_file_impl: using device Metal (Apple A14 GPU) - 4089 MiB free
llama[2]: llama_model_loader: loaded meta data with 32 key-value pairs and 310 tensors from /private/var/containers/Bundle/Application/A21158AF-1FFE-41AA-82EE-23CC26A3B928/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf (version GGUF V3 (latest))
llama[2]: llama_model_loader: Dumping metadata keys/values. Note: KV overrides do not apply in this output.
llama[2]: llama_model_loader: - kv   0:                       general.architecture str              = qwen3
llama[2]: llama_model_loader: - kv   1:                               general.type str              = model
llama[2]: llama_model_loader: - kv   2:                               general.name str              = Qwen3-1.7B
llama[2]: llama_model_loader: - kv   3:                           general.basename str              = Qwen3-1.7B
llama[2]: llama_model_loader: - kv   4:                       general.quantized_by str              = Unsloth
llama[2]: llama_model_loader: - kv   5:                         general.size_label str              = 1.7B
llama[2]: llama_model_loader: - kv   6:                           general.repo_url str              = https://huggingface.co/unsloth
llama[2]: llama_model_loader: - kv   7:                          qwen3.block_count u32              = 28
llama[2]: llama_model_loader: - kv   8:                       qwen3.context_length u32              = 40960
llama[2]: llama_model_loader: - kv   9:                     qwen3.embedding_length u32              = 2048
llama[2]: llama_model_loader: - kv  10:                  qwen3.feed_forward_length u32              = 6144
llama[2]: llama_model_loader: - kv  11:                 qwen3.attention.head_count u32              = 16
llama[2]: llama_model_loader: - kv  12:              qwen3.attention.head_count_kv u32              = 8
llama[2]: llama_model_loader: - kv  13:                       qwen3.rope.freq_base f32              = 1000000.000000
llama[2]: llama_model_loader: - kv  14:     qwen3.attention.layer_norm_rms_epsilon f32              = 0.000001
llama[2]: llama_model_loader: - kv  15:                 qwen3.attention.key_length u32              = 128
llama[2]: llama_model_loader: - kv  16:               qwen3.attention.value_length u32              = 128
llama[2]: llama_model_loader: - kv  17:                       tokenizer.ggml.model str              = gpt2
llama[2]: llama_model_loader: - kv  18:                         tokenizer.ggml.pre str              = qwen2
llama[2]: llama_model_loader: - kv  19:                      tokenizer.ggml.tokens arr[str,151936]  = ["!", "\"", "#", "$", "%", "&", "'", ...
llama[2]: llama_model_loader: - kv  20:                  tokenizer.ggml.token_type arr[i32,151936]  = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ...
🔍 DEBUG: Window background after change: UIExtendedSRGBColorSpace 0.7 0.5628 0.28 1
🔍 DEBUG: Root VC background: UIExtendedSRGBColorSpace 0.7 0.5628 0.28 1
llama[2]: llama_model_loader: - kv  21:                      tokenizer.ggml.merges arr[str,151387]  = ["Ġ Ġ", "ĠĠ ĠĠ", "i n", "Ġ t",...
llama[2]: llama_model_loader: - kv  22:                tokenizer.ggml.eos_token_id u32              = 151645
llama[2]: llama_model_loader: - kv  23:            tokenizer.ggml.padding_token_id u32              = 151654
llama[2]: llama_model_loader: - kv  24:               tokenizer.ggml.add_bos_token bool             = false
llama[2]: llama_model_loader: - kv  25:                    tokenizer.chat_template str              = {%- if tools %}\n    {{- '<|im_start|>...
llama[2]: llama_model_loader: - kv  26:               general.quantization_version u32              = 2
llama[2]: llama_model_loader: - kv  27:                          general.file_type u32              = 15
llama[2]: llama_model_loader: - kv  28:                      quantize.imatrix.file str              = Qwen3-1.7B-GGUF/imatrix_unsloth.dat
llama[2]: llama_model_loader: - kv  29:                   quantize.imatrix.dataset str              = unsloth_calibration_Qwen3-1.7B.txt
llama[2]: llama_model_loader: - kv  30:             quantize.imatrix.entries_count i32              = 196
llama[2]: llama_model_loader: - kv  31:              quantize.imatrix.chunks_count i32              = 685
llama[2]: llama_model_loader: - type  f32:  113 tensors
llama[2]: llama_model_loader: - type q4_K:  168 tensors
llama[2]: llama_model_loader: - type q6_K:   29 tensors
llama[2]: print_info: file format = GGUF V3 (latest)
llama[2]: print_info: file type   = Q4_K - Medium
llama[2]: print_info: file size   = 1.03 GiB (5.12 BPW)
llama[1]: init_tokenizer: initializing tokenizer for type 2
llama[1]: load: control token: 151659 '<|fim_prefix|>' is not marked as EOG
llama[1]: load: control token: 151656 '<|video_pad|>' is not marked as EOG
llama[1]: load: control token: 151655 '<|image_pad|>' is not marked as EOG
llama[1]: load: control token: 151653 '<|vision_end|>' is not marked as EOG
llama[1]: load: control token: 151652 '<|vision_start|>' is not marked as EOG
llama[1]: load: control token: 151651 '<|quad_end|>' is not marked as EOG
llama[1]: load: control token: 151649 '<|box_end|>' is not marked as EOG
llama[1]: load: control token: 151648 '<|box_start|>' is not marked as EOG
llama[1]: load: control token: 151646 '<|object_ref_start|>' is not marked as EOG
llama[1]: load: control token: 151644 '<|im_start|>' is not marked as EOG
llama[1]: load: control token: 151661 '<|fim_suffix|>' is not marked as EOG
llama[1]: load: control token: 151647 '<|object_ref_end|>' is not marked as EOG
llama[1]: load: control token: 151660 '<|fim_middle|>' is not marked as EOG
llama[1]: load: control token: 151654 '<|vision_pad|>' is not marked as EOG
llama[1]: load: control token: 151650 '<|quad_start|>' is not marked as EOG
llama[2]: load: printing all EOG tokens:
llama[2]: load:   - 151643 ('<|endoftext|>')
llama[2]: load:   - 151645 ('<|im_end|>')
llama[2]: load:   - 151662 ('<|fim_pad|>')
llama[2]: load:   - 151663 ('<|repo_name|>')
llama[2]: load:   - 151664 ('<|file_sep|>')
llama[2]: load: special tokens cache size = 26
llama[2]: load: token to piece cache size = 0.9311 MB
llama[2]: print_info: arch             = qwen3
llama[2]: print_info: vocab_only       = 0
llama[2]: print_info: n_ctx_train      = 40960
llama[2]: print_info: n_embd           = 2048
llama[2]: print_info: n_layer          = 28
llama[2]: print_info: n_head           = 16
llama[2]: print_info: n_head_kv        = 8
llama[2]: print_info: n_rot            = 128
llama[2]: print_info: n_swa            = 0
llama[2]: print_info: is_swa_any       = 0
llama[2]: print_info: n_embd_head_k    = 128
llama[2]: print_info: n_embd_head_v    = 128
llama[2]: print_info: n_gqa            = 2
llama[2]: print_info: n_embd_k_gqa     = 1024
llama[2]: print_info: n_embd_v_gqa     = 1024
llama[2]: print_info: f_norm_eps       = 0.0e+00
llama[2]: print_info: f_norm_rms_eps   = 1.0e-06
llama[2]: print_info: f_clamp_kqv      = 0.0e+00
llama[2]: print_info: f_max_alibi_bias = 0.0e+00
llama[2]: print_info: f_logit_scale    = 0.0e+00
llama[2]: print_info: f_attn_scale     = 0.0e+00
llama[2]: print_info: n_ff             = 6144
llama[2]: print_info: n_expert         = 0
llama[2]: print_info: n_expert_used    = 0
llama[2]: print_info: causal attn      = 1
llama[2]: print_info: pooling type     = -1
llama[2]: print_info: rope type        = 2
llama[2]: print_info: rope scaling     = linear
llama[2]: print_info: freq_base_train  = 1000000.0
llama[2]: print_info: freq_scale_train = 1
llama[2]: print_info: n_ctx_orig_yarn  = 40960
llama[2]: print_info: rope_finetuned   = unknown
llama[2]: print_info: model type       = 1.7B
llama[2]: print_info: model params     = 1.72 B
llama[2]: print_info: general.name     = Qwen3-1.7B
llama[2]: print_info: vocab type       = BPE
llama[2]: print_info: n_vocab          = 151936
llama[2]: print_info: n_merges         = 151387
llama[2]: print_info: BOS token        = 11 ','
llama[2]: print_info: EOS token        = 151645 '<|im_end|>'
llama[2]: print_info: EOT token        = 151645 '<|im_end|>'
llama[2]: print_info: PAD token        = 151654 '<|vision_pad|>'
llama[2]: print_info: LF token         = 198 'Ċ'
llama[2]: print_info: FIM PRE token    = 151659 '<|fim_prefix|>'
llama[2]: print_info: FIM SUF token    = 151661 '<|fim_suffix|>'
llama[2]: print_info: FIM MID token    = 151660 '<|fim_middle|>'
llama[2]: print_info: FIM PAD token    = 151662 '<|fim_pad|>'
llama[2]: print_info: FIM REP token    = 151663 '<|repo_name|>'
llama[2]: print_info: FIM SEP token    = 151664 '<|file_sep|>'
llama[2]: print_info: EOG token        = 151643 '<|endoftext|>'
llama[2]: print_info: EOG token        = 151645 '<|im_end|>'
llama[2]: print_info: EOG token        = 151662 '<|fim_pad|>'
llama[2]: print_info: EOG token        = 151663 '<|repo_name|>'
llama[2]: print_info: EOG token        = 151664 '<|file_sep|>'
llama[2]: print_info: max token length = 256
llama[2]: load_tensors: loading model tensors, this can take a while... (mmap = true)
llama[1]: load_tensors: layer   0 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer   1 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer   2 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer   3 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer   4 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer   5 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer   6 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer   7 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer   8 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer   9 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  10 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  11 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  12 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  13 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  14 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  15 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  16 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  17 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  18 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  19 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  20 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  21 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  22 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  23 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  24 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  25 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  26 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  27 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: layer  28 assigned to device CPU, is_swa = 0
llama[1]: load_tensors: tensor 'token_embd.weight' (q6_K) (and 310 others) cannot be used with preferred buffer type CPU_REPACK, using CPU instead
llama[2]: load_tensors: offloading 0 repeating layers to GPU
llama[2]: load_tensors: offloaded 0/29 layers to GPU
llama[2]: load_tensors:   CPU_Mapped model buffer size =  1050.43 MiB
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]: .
llama[5]:
LlamaCppBridge: Successfully loaded model from /private/var/containers/Bundle/Application/A21158AF-1FFE-41AA-82EE-23CC26A3B928/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf
LlamaCppBridge: Creating context for model
LlamaCppBridge: Using small model parameters (ctx=1024, batch=2048, threads=4, flash_attn=false) for 0B model
llama[2]: llama_context: constructing llama_context
llama[2]: llama_context: n_seq_max     = 1
llama[2]: llama_context: n_ctx         = 1024
llama[2]: llama_context: n_ctx_per_seq = 1024
llama[2]: llama_context: n_batch       = 1024
llama[2]: llama_context: n_ubatch      = 512
llama[2]: llama_context: causal_attn   = 1
llama[2]: llama_context: flash_attn    = 0
llama[2]: llama_context: kv_unified    = false
llama[2]: llama_context: freq_base     = 1000000.0
llama[2]: llama_context: freq_scale    = 1
llama[3]: llama_context: n_ctx_per_seq (1024) < n_ctx_train (40960) -- the full capacity of the model will not be utilized
llama[2]: ggml_metal_init: allocating
llama[2]: ggml_metal_init: picking default device: Apple A14 GPU
llama[2]: ggml_metal_load_library: using embedded metal library
llama[2]: ggml_metal_init: GPU name:   Apple A14 GPU
llama[2]: ggml_metal_init: GPU family: MTLGPUFamilyApple7  (1007)
llama[2]: ggml_metal_init: GPU family: MTLGPUFamilyCommon3 (3003)
llama[2]: ggml_metal_init: GPU family: MTLGPUFamilyMetal3  (5001)
llama[2]: ggml_metal_init: simdgroup reduction   = true
llama[2]: ggml_metal_init: simdgroup matrix mul. = true
llama[2]: ggml_metal_init: has residency sets    = true
llama[2]: ggml_metal_init: has bfloat            = true
llama[2]: ggml_metal_init: use bfloat            = true
llama[2]: ggml_metal_init: hasUnifiedMemory      = true
llama[2]: ggml_metal_init: recommendedMaxWorkingSetSize  =  4294.98 MB
llama[1]: ggml_metal_init: loaded kernel_add                                    0x116090c60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_2                             0x116091680 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_3                             0x1160920a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_4                             0x116092ac0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_5                             0x1160934e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_6                             0x116093f00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_7                             0x10684bcc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_8                             0x11a0d47e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4                             0x11a0d51a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_2                      0x11a0d5bc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_3                      0x11a0d65e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_4                      0x11a0d7000 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_5                      0x11a0d7a20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_6                      0x11a0f44e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_7                      0x11a0f4ea0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_8                      0x11a0f58c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sub                                    0x11a0f62e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sub_row_c4                             0x11a0f6d00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul                                    0x11a0f7720 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_row_c4                             0x11a1241e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_div                                    0x11a124ba0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_div_row_c4                             0x11a1255c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_id                                 0x11a125860 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_f32                             0x11a125ec0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_f16                             0x11a126520 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_i32                             0x11a126b80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_i16                             0x11a1271e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_scale                                  0x11a1272a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_scale_4                                0x11a127300 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_clamp                                  0x11a127360 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_tanh                                   0x11a1273c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_relu                                   0x11a127420 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sigmoid                                0x11a127480 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu                                   0x11a1274e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_4                                 0x11a127540 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_erf                               0x11a1275a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_erf_4                             0x11a127600 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_quick                             0x11a127660 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_quick_4                           0x11a1276c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_silu                                   0x11a1278a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_silu_4                                 0x11a1277e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_elu                                    0x11a127840 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_abs                                    0x11a127720 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sgn                                    0x11a127900 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_step                                   0x11a127960 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_hardswish                              0x11a1279c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_hardsigmoid                            0x11a127a20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_exp                                    0x11a127a80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f16                           0x11a1d4240 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f16_4                         0x11a1d49c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f32                           0x11a1d51a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f32_4                         0x11a1d5980 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_diag_mask_inf                          0x11a1d5b00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_diag_mask_inf_8                        0x11a1d5c80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_f32                           0x11a1d5fe0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_f16                           0x11a1d6340 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_bf16                          0x11a1d66a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q4_0                          0x11a1d6a00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q4_1                          0x11a1d6d60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q5_0                          0x11a1d70c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q5_1                          0x11a1d7420 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q8_0                          0x11a1d7780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_mxfp4                         0x11a1d7ae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q2_K                          0x11a1d7e40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q3_K                          0x11a258240 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q4_K                          0x11a258540 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q5_K                          0x11a2588a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q6_K                          0x11a258c00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq2_xxs                       0x11a258f60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq2_xs                        0x11a2592c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq3_xxs                       0x11a259620 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq3_s                         0x11a259980 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq2_s                         0x11a259ce0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq1_s                         0x11a25a040 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq1_m                         0x11a25a3a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq4_nl                        0x11a25a700 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq4_xs                        0x11a25aa60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_i32                           0x11a25adc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_f32                           0x11a25b300 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_f16                           0x11a25b840 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_bf16                          0x11a25bd80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q8_0                          0x11a2e0360 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q4_0                          0x11a2e0840 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q4_1                          0x11a2e0d80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q5_0                          0x11a2e12c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q5_1                          0x11a2e1800 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_iq4_nl                        0x11a2e1d40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rms_norm                               0x11a2e2220 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rms_norm_mul                           0x11a2e2700 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rms_norm_mul_add                       0x11a2e2be0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_l2_norm                                0x11a2e2dc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_group_norm                             0x11a2e3120 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_norm                                   0x11a2e3300 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_ssm_conv_f32                           0x11a2e3960 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_ssm_scan_f32                           0x11a370240 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_ssm_scan_f32_group                     0x11a370a80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rwkv_wkv6_f32                          0x11a370b40 | th_max =  384 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rwkv_wkv7_f32                          0x11a370ba0 | th_max =  448 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f32_f32                         0x11a371260 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f32_f32_c4                      0x11a371980 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32                        0x11a3720a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32_c4                     0x11a3727c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32_1row                   0x11a372ee0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32_l4                     0x11a373600 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_bf16                       0x11a373d20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32                         0x11a3cc4e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32_c4                      0x11a3ccba0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32_1row                    0x11a3cd2c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32_l4                      0x11a3cd9e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f16                         0x11a3ce100 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q4_0_f32                        0x11a3ce820 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q4_1_f32                        0x11a3cef40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q5_0_f32                        0x11a3cf660 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q5_1_f32                        0x11a3cfd80 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q8_0_f32                        0x11a448540 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_mxfp4_f32                       0x11a448c00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_2                0x11a449440 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_3                0x11a449e60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_4                0x11a44a520 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_5                0x11a44ad60 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_2               0x11a44b5a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_3               0x11a44bde0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_4               0x11a4786c0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_5               0x11a478ea0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_2               0x11a4796e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_3               0x11a479f20 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_4               0x11a47a760 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_5               0x11a47afa0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_2               0x11a47b7e0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_3               0x11a4a40c0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_4               0x11a4a48a0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_5               0x11a4a50e0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_2               0x11a4a5920 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_3               0x11a4a6160 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_4               0x11a4a69a0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_5               0x11a4a71e0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_2               0x11a4a7a20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_3               0x11a4f0300 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_4               0x11a4f0ae0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_5               0x11a4f1320 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_2              0x11a4f1b60 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_3              0x11a4f23a0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_4              0x11a4f2be0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_5              0x11a4f3420 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_2               0x11a4f3c60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_3               0x11a514540 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_4               0x11a514d20 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_5               0x11a515560 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_2               0x11a515da0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_3               0x11a5165e0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_4               0x11a516e20 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_5               0x11a517660 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_2               0x11a517ea0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_3               0x11a534720 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_4               0x11a534f00 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_5               0x11a535740 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_2             0x11a535f80 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_3             0x11a5367c0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_4             0x11a537000 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_5             0x11a537840 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q2_K_f32                        0x11a537f60 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q3_K_f32                        0x11a570060 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q4_K_f32                        0x11a570d80 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q5_K_f32                        0x11a5714a0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q6_K_f32                        0x11a571bc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq2_xxs_f32                     0x11a5722e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq2_xs_f32                      0x11a572a00 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq3_xxs_f32                     0x11a573120 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq3_s_f32                       0x11a573840 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq2_s_f32                       0x11a5d8060 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq1_s_f32                       0x11a5d8720 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq1_m_f32                       0x11a5d8f60 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq4_nl_f32                      0x11a5d95c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq4_xs_f32                      0x11a5d9ce0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_f32_f32                      0x11a5da460 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_f16_f32                      0x11a5dabe0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_bf16_f32                     0x11a5db360 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q4_0_f32                     0x11a5dbae0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q4_1_f32                     0x11a664300 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q5_0_f32                     0x11a664a20 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q5_1_f32                     0x11a6651a0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q8_0_f32                     0x11a665920 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_mxfp4_f32                    0x11a6660a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q2_K_f32                     0x11a666820 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q3_K_f32                     0x11a666fa0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q4_K_f32                     0x11a667720 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q5_K_f32                     0x11a667ea0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q6_K_f32                     0x11a6c06c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq2_xxs_f32                  0x11a6c0de0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq2_xs_f32                   0x11a6c1560 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq3_xxs_f32                  0x11a6c1ce0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq3_s_f32                    0x11a6c2460 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq2_s_f32                    0x11a6c2be0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq1_s_f32                    0x11a6c3360 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq1_m_f32                    0x11a6c3ae0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq4_nl_f32                   0x11a73c300 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq4_xs_f32                   0x11a73ca20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_f32_f32                         0x11a73cfc0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_f16_f32                         0x11a73d560 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_bf16_f32                        0x11a73db00 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q4_0_f32                        0x11a73e0a0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q4_1_f32                        0x11a73e640 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q5_0_f32                        0x11a73ebe0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q5_1_f32                        0x11a73f180 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q8_0_f32                        0x11a73f720 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_mxfp4_f32                       0x11a73fcc0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_mxfp4_f32                       0x11a7b4300 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q2_K_f32                        0x11a7b4840 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q3_K_f32                        0x11a7b4de0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q4_K_f32                        0x11a7b5380 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q5_K_f32                        0x11a7b5920 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q6_K_f32                        0x11a7b5ec0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq2_xxs_f32                     0x11a7b6460 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq2_xs_f32                      0x11a7b6a00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq3_xxs_f32                     0x11a7b6fa0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq3_s_f32                       0x11a7b7540 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq2_s_f32                       0x11a7b7ae0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq1_s_f32                       0x15dc34120 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq1_m_f32                       0x15dc34660 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq4_nl_f32                      0x15dc34c00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq4_xs_f32                      0x15dc351a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_map0_f16                     0x15dc35500 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_map1_f32                     0x15dc35860 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_f32_f16                      0x15dc35e00 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_f16_f16                      0x15dc363a0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_bf16_f16                     0x15dc36940 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q4_0_f16                     0x15dc36ee0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q4_1_f16                     0x15dc37480 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q5_0_f16                     0x15dc37a20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q5_1_f16                     0x11a5d8f00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q8_0_f16                     0x15dcf0060 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_mxfp4_f16                    0x15dcf0a80 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q2_K_f16                     0x15dcf1020 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q3_K_f16                     0x15dcf15c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q4_K_f16                     0x15dcf1b60 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q5_K_f16                     0x15dcf2100 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q6_K_f16                     0x15dcf26a0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq2_xxs_f16                  0x15dcf2c40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq2_xs_f16                   0x15dcf31e0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq3_xxs_f16                  0x15dcf3780 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq3_s_f16                    0x15dcf3d20 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq2_s_f16                    0x15dd8c3c0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq1_s_f16                    0x15dd8c900 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq1_m_f16                    0x15dd8cea0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq4_nl_f16                   0x15dd8d440 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq4_xs_f16                   0x15dd8d9e0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_norm_f32                          0x15dd8e520 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_norm_f16                          0x15dd8f060 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_multi_f32                         0x15dd8fba0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_multi_f16                         0x15ddf0780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_vision_f32                        0x15ddf1260 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_vision_f16                        0x15ddf1da0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_neox_f32                          0x15ddf28e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_neox_f16                          0x15ddf3420 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_f16                             0x15ddf3a20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_f32                             0x15de4c0c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_ext_f16                         0x15de4c840 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_ext_f32                         0x15de4ccc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_conv_transpose_1d_f32_f32              0x15de4cf60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_conv_transpose_1d_f16_f32              0x15de4d200 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_upscale_f32                            0x15de4d9e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pad_f32                                0x15de4e040 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pad_reflect_1d_f32                     0x15de4e760 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_timestep_embedding_f32                 0x15de4e8e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_arange_f32                             0x15de4ea60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_argsort_f32_i32_asc                    0x15de4eb20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_argsort_f32_i32_desc                   0x15de4ec40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_leaky_relu_f32                         0x15de4edc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h64                 0x15de4f840 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h80                 0x15ded43c0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h96                 0x15ded4e40 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h112                0x15ded5920 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h128                0x15ded6400 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h192                0x15ded6ee0 | th_max =  384 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_hk192_hv128         0x15ded79c0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h256                0x15def4540 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_hk576_hv512         0x15def4fc0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h64                0x15def5aa0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h80                0x15def6580 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h96                0x15def7060 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h112               0x15def7b40 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h128               0x15df306c0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h192               0x15df31140 | th_max =  384 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_hk192_hv128        0x15df31c20 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h256               0x15df32700 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_hk576_hv512        0x15df331e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h64                0x15df33cc0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h80                0x15df5c7e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h96                0x15df5d260 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h112               0x15df5dd40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h128               0x15df5e820 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h192               0x15df5f300 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_hk192_hv128        0x15df5fe40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h256               0x15df809c0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_hk576_hv512        0x15df81440 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h64                0x15df81f20 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h80                0x15df82a00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h96                0x15df834e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h112               0x15dfa0060 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h128               0x15dfa0ae0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h192               0x15dfa15c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_hk192_hv128        0x15dfa20a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h256               0x15dfa2b80 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_hk576_hv512        0x15dfa3660 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h64                0x15dfc81e0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h80                0x15dfc8c60 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h96                0x15dfc9740 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h112               0x15dfca220 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h128               0x15dfcad00 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h192               0x15dfcb7e0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_hk192_hv128        0x15dff4300 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h256               0x15dff4d80 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_hk576_hv512        0x15dff5860 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h64                0x15dff6340 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h80                0x15dff6e20 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h96                0x15dff7900 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h112               0x15e424480 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h128               0x15e424f00 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h192               0x15e4259e0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_hk192_hv128        0x15e426520 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h256               0x15e427000 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_hk576_hv512        0x15e427ae0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h64                0x15e44c660 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h80                0x15e44d0e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h96                0x15e44dbc0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h112               0x15e44e6a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h128               0x15e44f180 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h192               0x15e44fc60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_hk192_hv128        0x15e4747e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h256               0x15e475260 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_hk576_hv512        0x15e475d40 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h64             0x15e476820 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h64            0x15e477300 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h64            0x15e477de0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h64            0x15e4ac960 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h64            0x15e4ad3e0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h64            0x15e4adec0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h64            0x15e4ae9a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h96             0x15e4af480 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h96            0x15e4aff60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h96            0x15e4d0060 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h96            0x15e4d1500 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h96            0x15e4d1fe0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h96            0x15e4d2ac0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h96            0x15e4d35a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h128            0x15e4f4180 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h128           0x15e4f4c00 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h128           0x15e4f56e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h128           0x15e4f61c0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h128           0x15e4f6ca0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h128           0x15e4f7780 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h128           0x15e5202a0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h192            0x15e520d20 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h192           0x15e521800 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h192           0x15e5222e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h192           0x15e522dc0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h192           0x15e5238a0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h192           0x15e548420 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h192           0x15e548ea0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_hk192_hv128      0x15e549980 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_hk192_hv128      0x15e54a460 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_hk192_hv128      0x15e54af40 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_hk192_hv128      0x15e54ba80 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_hk192_hv128      0x15e56c600 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_hk192_hv128      0x15e56d080 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_hk192_hv128      0x15e56db60 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h256            0x15e56e640 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h256           0x15e56f120 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h256           0x15e56fc00 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h256           0x15e58c780 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h256           0x15e58d200 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h256           0x15e58dce0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h256           0x15e58e7c0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_hk576_hv512      0x15e58f2a0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_hk576_hv512      0x15e58fd80 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_hk576_hv512      0x15e5c4900 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_hk576_hv512      0x15e5c5380 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_hk576_hv512      0x15e5c5e60 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_hk576_hv512      0x15e5c6940 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_hk576_hv512      0x15e5c7420 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_f32                                0x15e5c7900 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_i32                                0x15e5c7de0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_f32                            0x15e6044e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_f16                            0x15e604ae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_bf16                           0x15e605140 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f16_f32                            0x15e6057a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f16_f16                            0x15e605e00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_bf16_f32                           0x15e606460 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_bf16_bf16                          0x15e606ac0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q8_0                           0x15e607120 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q4_0                           0x15e607780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q4_1                           0x15e607de0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q5_0                           0x15e6904e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q5_1                           0x15e690ae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_iq4_nl                         0x15e691140 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_0_f32                           0x15e6917a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_0_f16                           0x15e691e00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_1_f32                           0x15e692460 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_1_f16                           0x15e692ac0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_0_f32                           0x15e693120 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_0_f16                           0x15e693780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_1_f32                           0x15e693de0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_1_f16                           0x15e73c4e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q8_0_f32                           0x15e73cae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q8_0_f16                           0x15e73d140 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_concat                                 0x15e73db00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sqr                                    0x15e73dbc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sqrt                                   0x15e73dc20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sin                                    0x15e73dc80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cos                                    0x15e73dce0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_neg                                    0x15e73dd40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_reglu                                  0x15e73e160 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_geglu                                  0x15e73e5e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_swiglu                                 0x15e73ea60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_swiglu_oai                             0x15e73eee0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_geglu_erf                              0x15e73f360 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_geglu_quick                            0x15e73f7e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sum_rows                               0x15e7bc1e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mean                                   0x15e7bcae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_argmax                                 0x15e7bcba0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pool_2d_avg_f32                        0x15e7bcfc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pool_2d_max_f32                        0x15e7bd440 | th_max = 1024 | th_width =   32
llama[1]: set_abort_callback: call
llama[2]: llama_context:        CPU  output buffer size =     0.58 MiB
llama[1]: create_memory: n_ctx = 1024 (padded)
llama[1]: llama_kv_cache_unified: layer   0: dev = CPU
llama[1]: llama_kv_cache_unified: layer   1: dev = CPU
llama[1]: llama_kv_cache_unified: layer   2: dev = CPU
llama[1]: llama_kv_cache_unified: layer   3: dev = CPU
llama[1]: llama_kv_cache_unified: layer   4: dev = CPU
llama[1]: llama_kv_cache_unified: layer   5: dev = CPU
llama[1]: llama_kv_cache_unified: layer   6: dev = CPU
llama[1]: llama_kv_cache_unified: layer   7: dev = CPU
llama[1]: llama_kv_cache_unified: layer   8: dev = CPU
llama[1]: llama_kv_cache_unified: layer   9: dev = CPU
llama[1]: llama_kv_cache_unified: layer  10: dev = CPU
llama[1]: llama_kv_cache_unified: layer  11: dev = CPU
llama[1]: llama_kv_cache_unified: layer  12: dev = CPU
llama[1]: llama_kv_cache_unified: layer  13: dev = CPU
llama[1]: llama_kv_cache_unified: layer  14: dev = CPU
llama[1]: llama_kv_cache_unified: layer  15: dev = CPU
llama[1]: llama_kv_cache_unified: layer  16: dev = CPU
llama[1]: llama_kv_cache_unified: layer  17: dev = CPU
llama[1]: llama_kv_cache_unified: layer  18: dev = CPU
llama[1]: llama_kv_cache_unified: layer  19: dev = CPU
llama[1]: llama_kv_cache_unified: layer  20: dev = CPU
llama[1]: llama_kv_cache_unified: layer  21: dev = CPU
llama[1]: llama_kv_cache_unified: layer  22: dev = CPU
llama[1]: llama_kv_cache_unified: layer  23: dev = CPU
llama[1]: llama_kv_cache_unified: layer  24: dev = CPU
llama[1]: llama_kv_cache_unified: layer  25: dev = CPU
llama[1]: llama_kv_cache_unified: layer  26: dev = CPU
llama[1]: llama_kv_cache_unified: layer  27: dev = CPU
llama[2]: llama_kv_cache_unified:        CPU KV buffer size =   112.00 MiB
llama[2]: llama_kv_cache_unified: size =  112.00 MiB (  1024 cells,  28 layers,  1/1 seqs), K (f16):   56.00 MiB, V (f16):   56.00 MiB
llama[1]: llama_context: enumerating backends
llama[1]: llama_context: backend_ptrs.size() = 3
llama[1]: llama_context: max_nodes = 2480
llama[1]: llama_context: worst-case: n_tokens = 512, n_seqs = 1, n_outputs = 0
llama[1]: graph_reserve: reserving a graph for ubatch with n_tokens =  512, n_seqs =  1, n_outputs =  512
llama[1]: graph_reserve: reserving a graph for ubatch with n_tokens =    1, n_seqs =  1, n_outputs =    1
llama[1]: graph_reserve: reserving a graph for ubatch with n_tokens =  512, n_seqs =  1, n_outputs =  512
llama[2]: llama_context:        CPU compute buffer size =   300.75 MiB
llama[2]: llama_context: graph nodes  = 1098
llama[2]: llama_context: graph splits = 394 (with bs=512), 1 (with bs=1)
LlamaCppBridge: Successfully created context
✅ LLMService: Model loaded successfully with llama.cpp
✅ LLMService: Successfully loaded model Qwen3-1.7B-Q4_K_M
🔍 LLMService: Final state after loading:
     - currentModelFilename: Qwen3-1.7B-Q4_K_M
     - isModelLoaded: true
     - modelPath: /private/var/containers/Bundle/Application/A21158AF-1FFE-41AA-82EE-23CC26A3B928/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf
✅ HybridLLMService: Model loaded with llama.cpp
✅ ChatViewModel: Auto-loaded model on startup - loaded: true, model: Qwen3-1.7B-Q4_K_M
🔍 TextModalView init
🔍 DEBUG: isSheetExpanded changed from false to true
🔍 DEBUG: Setting window background to DARK
🔍 DEBUG: isSettingsSheetExpanded: false
🔍 DEBUG: isSheetExpanded: true
🔍 DEBUG: Window found: true
🔍 DEBUG: Window frame: (0.0, 0.0, 390.0, 844.0)
🔍 DEBUG: Window safe area: UIEdgeInsets(top: 47.0, left: 0.0, bottom: 34.0, right: 0.0)
🔍 DEBUG: Set root view controller background to DARK
🔍 DEBUG: Window background after change: UIExtendedSRGBColorSpace 0.11 0.11 0.11 1
🔍 DEBUG: Root VC background: UIExtendedSRGBColorSpace 0.11 0.11 0.11 1
🔍 TextModalView init
🔍 DEBUG: isSheetExpanded changed from true to false
🎯 TARS onAppear - Starting with animationTime: 0.0
🔍 DEBUG: Setting window background to ORANGE
🔍 DEBUG: isSettingsSheetExpanded: false
🔍 DEBUG: isSheetExpanded: false
🔍 DEBUG: Window found: true
🔍 DEBUG: Window frame: (0.0, 0.0, 390.0, 844.0)
🔍 DEBUG: Window safe area: UIEdgeInsets(top: 47.0, left: 0.0, bottom: 34.0, right: 0.0)
🔍 DEBUG: Set root view controller background to ORANGE
🔍 DEBUG: Window background after change: UIExtendedSRGBColorSpace 0.7 0.5628 0.28 1
🔍 DEBUG: Root VC background: UIExtendedSRGBColorSpace 0.7 0.5628 0.28 1
🔍 TextModalView init
🔍 DEBUG: isSettingsSheetExpanded changed from false to true
🔍 DEBUG: Setting window background to ORANGE
🔍 DEBUG: isSettingsSheetExpanded: true
🔍 DEBUG: isSheetExpanded: false
🔍 DEBUG: Window found: true
🔍 DEBUG: Window frame: (0.0, 0.0, 390.0, 844.0)
🔍 DEBUG: Window safe area: UIEdgeInsets(top: 47.0, left: 0.0, bottom: 34.0, right: 0.0)
🔍 DEBUG: Set root view controller background to ORANGE
🔍 DEBUG: Window background after change: UIExtendedSRGBColorSpace 0.7 0.5628 0.28 1
🔍 DEBUG: Root VC background: UIExtendedSRGBColorSpace 0.7 0.5628 0.28 1
🔍 TextModalView init
🔍 DEBUG: isSettingsSheetExpanded changed from true to false
🔍 DEBUG: Setting window background to ORANGE
🔍 DEBUG: isSettingsSheetExpanded: false
🔍 DEBUG: isSheetExpanded: false
🔍 DEBUG: Window found: true
🔍 DEBUG: Window frame: (0.0, 0.0, 390.0, 844.0)
🔍 DEBUG: Window safe area: UIEdgeInsets(top: 47.0, left: 0.0, bottom: 34.0, right: 0.0)
🔍 DEBUG: Set root view controller background to ORANGE
🔍 DEBUG: Window background after change: UIExtendedSRGBColorSpace 0.7 0.5628 0.28 1
🔍 DEBUG: Root VC background: UIExtendedSRGBColorSpace 0.7 0.5628 0.28 1