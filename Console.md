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
🔍 ChatViewModel: Continuing existing session started at 2025-09-04 15:57:24 +0000
🔍 ChatViewModel: Loaded saved timing data - avg: 5.963292706608772s, total: 1192.6585413217545s, count: 200
🔍 ChatViewModel: Loaded model performance data for 7 models
   Llama-3.2-1B-Instruct-Q4_K_M: avg=5.72s, fast=false
   Qwen2.5-1.5B-Instruct-Q5_K_M: avg=2.40s, fast=true
   Phi-4-mini-instruct-Q4_K_M: avg=31.49s, fast=false
   Qwen3-1.7B-Q4_K_M: avg=5.29s, fast=false
   gemma-3-1B-It-Q4_K_M: avg=7.00s, fast=false
   smollm2-1.7b-instruct-q4_k_m: avg=6.53s, fast=false
   Gemma-3N-E4B-It-Q4_K_M: avg=196.60s, fast=false
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
🔍 FORCE SHOWING ONBOARDING FOR TESTING
🔍 MainView appeared!
🔍 TextModalView: syncProcessingState - resetting isLocalProcessing from false to false
🔍 TextModalView: onAppear - Reset clipboard state and duplicate detection
🎯 TARS onAppear - Starting with animationTime: 0.0
🔍 TextModalView init
🔍 DEBUG: Setting window background to DARK
🔍 DEBUG: isSettingsSheetExpanded: false
🔍 DEBUG: isSheetExpanded: false
🔍 DEBUG: Window found: true
🔍 DEBUG: Window frame: (0.0, 0.0, 390.0, 844.0)
🔍 DEBUG: Window safe area: UIEdgeInsets(top: 47.0, left: 0.0, bottom: 34.0, right: 0.0)
🔍 DEBUG: Set root view controller background to DARK
🔍 ChatViewModel: No model loaded, but selected model exists: Qwen3-1.7B-Q4_K_M
🔍 ChatViewModel: Auto-loading selected model on startup...
🔍 HybridLLMService: Loading model: Qwen3-1.7B-Q4_K_M
🔍 HybridLLMService: Using llama.cpp for Qwen3-1.7B-Q4_K_M
🔍 LLMService: Loading specific model: Qwen3-1.7B-Q4_K_M (previous: none)
🔍 LLMService: Found model in Models directory: /private/var/containers/Bundle/Application/72DA49F7-CA6C-446E-B4BC-AE96CA0C24E6/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf
🔍 LLMService: Clearing previous model before loading new one...
🔍 LLMService: Unloading model and cleaning up resources
🔍 LLMService: No model resources to free - already clean
🔍 LLMService: Reset conversation count for new model
🔍 LLMService: Set currentModelFilename to: Qwen3-1.7B-Q4_K_M
🔍 LLMService: Starting llama.cpp model loading...
LLMService: Loading model from path: /private/var/containers/Bundle/Application/72DA49F7-CA6C-446E-B4BC-AE96CA0C24E6/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf
LlamaCppBridge: Loading model (real) from /private/var/containers/Bundle/Application/72DA49F7-CA6C-446E-B4BC-AE96CA0C24E6/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf
LlamaCppBridge: Initializing llama backend
LlamaCppBridge: Backend initialized successfully
LlamaCppBridge: Attempting to load model with params: mmap=1, mlock=0, gpu_layers=0
llama[2]: llama_model_load_from_file_impl: using device Metal (Apple A14 GPU) - 4089 MiB free
llama[2]: llama_model_loader: loaded meta data with 32 key-value pairs and 310 tensors from /private/var/containers/Bundle/Application/72DA49F7-CA6C-446E-B4BC-AE96CA0C24E6/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf (version GGUF V3 (latest))
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
🔍 DEBUG: Window background after change: UIExtendedSRGBColorSpace 0.08 0.08 0.08 1
🔍 DEBUG: Root VC background: UIExtendedSRGBColorSpace 0.08 0.08 0.08 1
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
LlamaCppBridge: Successfully loaded model from /private/var/containers/Bundle/Application/72DA49F7-CA6C-446E-B4BC-AE96CA0C24E6/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf
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
llama[1]: ggml_metal_init: loaded kernel_add                                    0x10444b960 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_2                             0x1187f8480 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_3                             0x1187f8e40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_4                             0x1187f9860 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_5                             0x1187fa280 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_6                             0x1187faca0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_7                             0x1187fb6c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_8                             0x118828180 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4                             0x118828b40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_2                      0x118829560 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_3                      0x118829f80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_4                      0x11882a9a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_5                      0x11882b3c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_6                      0x11882bde0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_7                      0x1188648a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_8                      0x118865260 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sub                                    0x118865c80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sub_row_c4                             0x1188666a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul                                    0x118867120 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_row_c4                             0x118867ae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_div                                    0x1188845a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_div_row_c4                             0x118884f60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_id                                 0x118885200 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_f32                             0x118885860 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_f16                             0x118885ec0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_i32                             0x118886520 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_i16                             0x118886b80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_scale                                  0x118886c40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_scale_4                                0x118886ca0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_clamp                                  0x118886d00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_tanh                                   0x118886d60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_relu                                   0x118886dc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sigmoid                                0x118886e20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu                                   0x118886e80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_4                                 0x118886ee0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_erf                               0x118886f40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_erf_4                             0x118886fa0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_quick                             0x118887000 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_quick_4                           0x118887060 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_silu                                   0x1188870c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_silu_4                                 0x118887120 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_elu                                    0x118887180 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_abs                                    0x1188871e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sgn                                    0x118887240 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_step                                   0x1188872a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_hardswish                              0x118887300 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_hardsigmoid                            0x118887360 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_exp                                    0x1188873c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f16                           0x118887b40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f16_4                         0x118950360 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f32                           0x118950ae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f32_4                         0x1189512c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_diag_mask_inf                          0x118951440 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_diag_mask_inf_8                        0x1189515c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_f32                           0x118951920 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_f16                           0x118951c80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_bf16                          0x118951fe0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q4_0                          0x118952340 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q4_1                          0x1189526a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q5_0                          0x118952a00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q5_1                          0x118952d60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q8_0                          0x1189530c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_mxfp4                         0x118953420 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q2_K                          0x118953780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q3_K                          0x118953ae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q4_K                          0x118953e40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q5_K                          0x1189e0240 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q6_K                          0x1189e0540 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq2_xxs                       0x1189e08a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq2_xs                        0x1189e0c00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq3_xxs                       0x1189e0f60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq3_s                         0x1189e12c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq2_s                         0x1189e1620 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq1_s                         0x1189e1980 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq1_m                         0x1189e1ce0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq4_nl                        0x1189e2040 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq4_xs                        0x1189e23a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_i32                           0x1189e2700 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_f32                           0x1189e2c40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_f16                           0x1189e3180 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_bf16                          0x1189e36c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q8_0                          0x1189e3cc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q4_0                          0x118a801e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q4_1                          0x118a806c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q5_0                          0x118a80c00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q5_1                          0x118a811a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_iq4_nl                        0x118a816e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rms_norm                               0x118a81bc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rms_norm_mul                           0x118a820a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rms_norm_mul_add                       0x118a82580 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_l2_norm                                0x118a82760 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_group_norm                             0x118a82ac0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_norm                                   0x118a82ca0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_ssm_conv_f32                           0x118a83300 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_ssm_scan_f32                           0x118a83ba0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_ssm_scan_f32_group                     0x118ae84e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rwkv_wkv6_f32                          0x118ae8540 | th_max =  384 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rwkv_wkv7_f32                          0x118ae85a0 | th_max =  448 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f32_f32                         0x118ae8c60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f32_f32_c4                      0x118ae9380 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32                        0x118ae9aa0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32_c4                     0x118aea1c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32_1row                   0x118aea8e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32_l4                     0x118aeb000 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_bf16                       0x118aeb720 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32                         0x118aebe40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32_c4                      0x118b2c600 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32_1row                    0x118b2ccc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32_l4                      0x118b2d3e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f16                         0x118b2db00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q4_0_f32                        0x118b2e220 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q4_1_f32                        0x118b2e940 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q5_0_f32                        0x118b2f060 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q5_1_f32                        0x118b2f780 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q8_0_f32                        0x118b2fea0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_mxfp4_f32                       0x118bb0660 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_2                0x118bb0e40 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_3                0x118bb1680 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_4                0x118bb1ec0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_5                0x118bb2700 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_2               0x118bb2f40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_3               0x118bb3780 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_4               0x118be0060 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_5               0x118be0900 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_2               0x118be1080 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_3               0x118be18c0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_4               0x118be2100 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_5               0x118be2940 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_2               0x118be3180 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_3               0x118be39c0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_4               0x15c0282a0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_5               0x15c028a80 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_2               0x15c0292c0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_3               0x15c029b00 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_4               0x15c02a340 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_5               0x15c02ab80 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_2               0x15c02b3c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_3               0x15c02bc00 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_4               0x15c0544e0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_5               0x15c054cc0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_2              0x15c055500 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_3              0x15c055d40 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_4              0x15c056580 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_5              0x15c056dc0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_2               0x15c057600 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_3               0x15c057e40 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_4               0x15c080720 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_5               0x15c080f00 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_2               0x15c081740 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_3               0x15c081f80 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_4               0x15c0827c0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_5               0x15c083000 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_2               0x15c083840 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_3               0x15c0b8120 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_4               0x15c0b8900 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_5               0x15c0b9140 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_2             0x15c0b9980 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_3             0x15c0ba1c0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_4             0x15c0baa00 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_5             0x15c0bb240 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q2_K_f32                        0x15c0bb960 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q3_K_f32                        0x15c0ec0c0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q4_K_f32                        0x15c0ec780 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q5_K_f32                        0x15c0ecea0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q6_K_f32                        0x15c0ed5c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq2_xxs_f32                     0x15c0edce0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq2_xs_f32                      0x15c0ee400 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq3_xxs_f32                     0x15c0eeb20 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq3_s_f32                       0x15c0ef240 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq2_s_f32                       0x15c0ef960 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq1_s_f32                       0x15c158120 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq1_m_f32                       0x15c1587e0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq4_nl_f32                      0x15c158f00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq4_xs_f32                      0x15c159620 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_f32_f32                      0x15c159da0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_f16_f32                      0x15c15a520 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_bf16_f32                     0x15c15aca0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q4_0_f32                     0x15c15b420 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q4_1_f32                     0x15c15bba0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q5_0_f32                     0x15c1d43c0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q5_1_f32                     0x15c1d4ae0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q8_0_f32                     0x15c1d5260 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_mxfp4_f32                    0x15c1d59e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q2_K_f32                     0x15c1d6160 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q3_K_f32                     0x15c1d68e0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q4_K_f32                     0x15c1d7060 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q5_K_f32                     0x15c1d77e0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q6_K_f32                     0x15c1d7f60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq2_xxs_f32                  0x15c23c060 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq2_xs_f32                   0x15c23ce40 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq3_xxs_f32                  0x15c23d5c0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq3_s_f32                    0x15c23dda0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq2_s_f32                    0x15c23e520 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq1_s_f32                    0x15c23eca0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq1_m_f32                    0x15c23f420 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq4_nl_f32                   0x15c23fba0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq4_xs_f32                   0x15c2a8420 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_f32_f32                         0x15c2a8960 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_f16_f32                         0x15c2a8f00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_bf16_f32                        0x15c2a94a0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q4_0_f32                        0x15c2a9a40 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q4_1_f32                        0x15c2a9fe0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q5_0_f32                        0x15c2aa580 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q5_1_f32                        0x15c2aab20 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q8_0_f32                        0x15c2ab0c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_mxfp4_f32                       0x15c2ab660 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_mxfp4_f32                       0x15c2ab780 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q2_K_f32                        0x15c318240 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q3_K_f32                        0x15c318780 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q4_K_f32                        0x15c318d20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q5_K_f32                        0x15c3192c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q6_K_f32                        0x15c319860 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq2_xxs_f32                     0x15c319e00 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq2_xs_f32                      0x15c31a3a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq3_xxs_f32                     0x15c31a940 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq3_s_f32                       0x15c31aee0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq2_s_f32                       0x15c31b480 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq1_s_f32                       0x15c31ba20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq1_m_f32                       0x15c394060 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq4_nl_f32                      0x15c3945a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq4_xs_f32                      0x15c394b40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_map0_f16                     0x15c394ea0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_map1_f32                     0x15c395200 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_f32_f16                      0x15c3957a0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_f16_f16                      0x15c395d40 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_bf16_f16                     0x15c3962e0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q4_0_f16                     0x15c396880 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q4_1_f16                     0x15c396e80 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q5_0_f16                     0x15c397480 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q5_1_f16                     0x15c397a20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q8_0_f16                     0x10444b2a0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_mxfp4_f16                    0x15c86c000 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q2_K_f16                     0x15c86ca80 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q3_K_f16                     0x15c86d020 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q4_K_f16                     0x15c86d5c0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q5_K_f16                     0x15c86db60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q6_K_f16                     0x15c86e100 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq2_xxs_f16                  0x15c86e6a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq2_xs_f16                   0x15c86ec40 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq3_xxs_f16                  0x15c86f1e0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq3_s_f16                    0x15c86f780 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq2_s_f16                    0x15c86fd20 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq1_s_f16                    0x15c914360 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq1_m_f16                    0x15c9148a0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq4_nl_f16                   0x15c914e40 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq4_xs_f16                   0x15c9153e0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_norm_f32                          0x15c915f20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_norm_f16                          0x15c916a60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_multi_f32                         0x15c9175a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_multi_f16                         0x15c96c180 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_vision_f32                        0x15c96cc60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_vision_f16                        0x15c96d7a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_neox_f32                          0x15c96e2e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_neox_f16                          0x15c96ee20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_f16                             0x15c96f420 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_f32                             0x15c96fa20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_ext_f16                         0x15c9b80c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_ext_f32                         0x15c9b8660 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_conv_transpose_1d_f32_f32              0x15c9b8900 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_conv_transpose_1d_f16_f32              0x15c9b8ba0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_upscale_f32                            0x15c9b9380 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pad_f32                                0x15c9b99e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pad_reflect_1d_f32                     0x15c9ba100 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_timestep_embedding_f32                 0x15c9ba280 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_arange_f32                             0x15c9ba400 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_argsort_f32_i32_asc                    0x15c9ba4c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_argsort_f32_i32_desc                   0x15c9ba5e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_leaky_relu_f32                         0x15c9ba760 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h64                 0x15c9bb1e0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h80                 0x15c9bbcc0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h96                 0x15ca387e0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h112                0x15ca39260 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h128                0x15ca39d40 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h192                0x15ca3a820 | th_max =  384 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_hk192_hv128         0x15ca3b300 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h256                0x15ca3bde0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_hk576_hv512         0x15ca5c960 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h64                0x15ca5d3e0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h80                0x15ca5dec0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h96                0x15ca5e9a0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h112               0x15ca5f480 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h128               0x15ca5ff60 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h192               0x15ca84060 | th_max =  384 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_hk192_hv128        0x15ca85500 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h256               0x15ca85fe0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_hk576_hv512        0x15ca86ac0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h64                0x15ca875a0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h80                0x15cab01e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h96                0x15cab0c60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h112               0x15cab1740 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h128               0x15cab2220 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h192               0x15cab2d00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_hk192_hv128        0x15cab37e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h256               0x15cac8360 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_hk576_hv512        0x15cac8de0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h64                0x15cac98c0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h80                0x15caca3a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h96                0x15cacae80 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h112               0x15cacb960 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h128               0x15cb044e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h192               0x15cb04f60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_hk192_hv128        0x15cb05a40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h256               0x15cb06520 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_hk576_hv512        0x15cb07000 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h64                0x15cb07ae0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h80                0x15cb28660 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h96                0x15cb290e0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h112               0x15cb29bc0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h128               0x15cb2a6a0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h192               0x15cb2b180 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_hk192_hv128        0x15cb2bc60 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h256               0x15cb587e0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_hk576_hv512        0x15cb59260 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h64                0x15cb59d40 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h80                0x15cb5a820 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h96                0x15cb5b300 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h112               0x15cb5bde0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h128               0x15cb7c960 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h192               0x15cb7d3e0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_hk192_hv128        0x15cb7dec0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h256               0x15cb7e9a0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_hk576_hv512        0x15cb7f480 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h64                0x15cb7ff60 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h80                0x15cba4060 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h96                0x15cba5500 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h112               0x15cba5fe0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h128               0x15cba6ac0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h192               0x15cba75a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_hk192_hv128        0x15cbc0120 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h256               0x15cbc0ba0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_hk576_hv512        0x15cbc1680 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h64             0x15cbc2160 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h64            0x15cbc2c40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h64            0x15cbc3720 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h64            0x15cbec2a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h64            0x15cbecd20 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h64            0x15cbed800 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h64            0x15cbee2e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h96             0x15cbeedc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h96            0x15cbef8a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h96            0x15ec14420 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h96            0x15ec14ea0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h96            0x15ec15980 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h96            0x15ec16460 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h96            0x15ec16f40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h128            0x15ec17a20 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h128           0x15ec405a0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h128           0x15ec41020 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h128           0x15ec41b00 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h128           0x15ec425e0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h128           0x15ec430c0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h128           0x15ec43ba0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h192            0x15ec68720 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h192           0x15ec69200 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h192           0x15ec69ce0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h192           0x15ec6a7c0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h192           0x15ec6b2a0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h192           0x15ec6bd80 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h192           0x15ec90900 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_hk192_hv128      0x15ec91380 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_hk192_hv128      0x15ec91e60 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_hk192_hv128      0x15ec92940 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_hk192_hv128      0x15ec93420 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_hk192_hv128      0x15ec93f00 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_hk192_hv128      0x15ecbc000 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_hk192_hv128      0x15ecbd500 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h256            0x15ecbdfe0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h256           0x15ecbeac0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h256           0x15ecbf5a0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h256           0x15ece8120 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h256           0x15ece8ba0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h256           0x15ece9680 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h256           0x15ecea160 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_hk576_hv512      0x15eceac40 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_hk576_hv512      0x15eceb720 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_hk576_hv512      0x15ed082a0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_hk576_hv512      0x15ed08de0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_hk576_hv512      0x15ed09800 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_hk576_hv512      0x15ed0a2e0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_hk576_hv512      0x15ed0adc0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_f32                                0x15ed0b2a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_i32                                0x15ed0b780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_f32                            0x15ed0bde0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_f16                            0x15ed584e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_bf16                           0x15ed58ae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f16_f32                            0x15ed59140 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f16_f16                            0x15ed597a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_bf16_f32                           0x15ed59e00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_bf16_bf16                          0x15ed5a460 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q8_0                           0x15ed5aac0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q4_0                           0x15ed5b120 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q4_1                           0x15ed5b780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q5_0                           0x15ed5bde0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q5_1                           0x15eddc4e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_iq4_nl                         0x15eddcae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_0_f32                           0x15eddd140 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_0_f16                           0x15eddd7a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_1_f32                           0x15eddde00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_1_f16                           0x15edde460 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_0_f32                           0x15eddeac0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_0_f16                           0x15eddf120 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_1_f32                           0x15eddf780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_1_f16                           0x15eddfde0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q8_0_f32                           0x15eea84e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q8_0_f16                           0x15eea8ae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_concat                                 0x15eea94a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sqr                                    0x15eea9560 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sqrt                                   0x15eea95c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sin                                    0x15eea9620 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cos                                    0x15eea9680 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_neg                                    0x15eea96e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_reglu                                  0x15eea9b00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_geglu                                  0x15eea9f80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_swiglu                                 0x15eeaa400 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_swiglu_oai                             0x15eeaa880 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_geglu_erf                              0x15eeaad00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_geglu_quick                            0x15eeab180 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sum_rows                               0x15eeabae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mean                                   0x15ef3c480 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_argmax                                 0x15ef3c4e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pool_2d_avg_f32                        0x15ef3c900 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pool_2d_max_f32                        0x15ef3cd80 | th_max = 1024 | th_width =   32
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
     - modelPath: /private/var/containers/Bundle/Application/72DA49F7-CA6C-446E-B4BC-AE96CA0C24E6/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf
✅ HybridLLMService: Model loaded with llama.cpp
✅ ChatViewModel: Auto-loaded model on startup - loaded: true, model: Qwen3-1.7B-Q4_K_M
🔍 TextModalView init