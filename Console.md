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
🔍 ChatViewModel: Continuing existing session started at 2025-09-02 05:32:43 +0000
🔍 ChatViewModel: Loaded saved timing data - avg: 6.327234489697936s, total: 892.1400630474091s, count: 141
🔍 ChatViewModel: Loaded model performance data for 7 models
   Gemma-3N-E4B-It-Q4_K_M: avg=196.60s, fast=false
   Qwen2.5-1.5B-Instruct-Q5_K_M: avg=2.40s, fast=true
   smollm2-1.7b-instruct-q4_k_m: avg=6.70s, fast=false
   gemma-3-1B-It-Q4_K_M: avg=7.37s, fast=false
   Qwen3-1.7B-Q4_K_M: avg=5.67s, fast=false
   Phi-4-mini-instruct-Q4_K_M: avg=31.49s, fast=false
   Llama-3.2-1B-Instruct-Q4_K_M: avg=3.16s, fast=false
🔍 ChatViewModel: Syncing initial model state...
🔍 Onboarding check: hasSeenOnboarding = true
🔍 User has already seen onboarding, keeping modal hidden
🔍 TextModalView init
🔍 MainView appeared!
ModelManager: Loading available models...
ModelManager: Found model: smollm2-1.7b-instruct-q4_k_m
ModelManager: Found model in bundle root: smollm2-1.7b-instruct-q4_k_m
ModelManager: Found model: Qwen3-1.7B-Q4_K_M
ModelManager: Found model in bundle root: Qwen3-1.7B-Q4_K_M
ModelManager: Found model in bundle root: Llama-3.2-1B-Instruct-Q4_K_M
ModelManager: Found model: Llama-3.2-1B-Instruct-Q4_K_M
ModelManager: Found model in bundle root: gemma-3-1B-It-Q4_K_M
ModelManager: Found model: gemma-3-1B-It-Q4_K_M
ModelManager: Loaded 4 available models
ModelManager: Available models: ["Qwen3-1.7B-Q4_K_M", "gemma-3-1B-It-Q4_K_M", "smollm2-1.7b-instruct-q4_k_m", "Llama-3.2-1B-Instruct-Q4_K_M"]
🔍 TextModalView: syncProcessingState - resetting isLocalProcessing from false to false
🔍 TextModalView: onAppear - Reset clipboard state and duplicate detection
🔍 ChatViewModel: No model loaded, but selected model exists: Qwen3-1.7B-Q4_K_M
🔍 ChatViewModel: Auto-loading selected model on startup...
🔍 HybridLLMService: Loading model: Qwen3-1.7B-Q4_K_M
🔍 HybridLLMService: Using llama.cpp for Qwen3-1.7B-Q4_K_M
🔍 LLMService: Loading specific model: Qwen3-1.7B-Q4_K_M (previous: none)
🔍 LLMService: Found model in Models directory: /private/var/containers/Bundle/Application/99A71485-B560-4F0F-AABD-91CE6E0291BA/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf
🔍 LLMService: Clearing previous model before loading new one...
🔍 LLMService: Unloading model and cleaning up resources
🔍 LLMService: No model resources to free - already clean
🔍 LLMService: Reset conversation count for new model
🔍 LLMService: Set currentModelFilename to: Qwen3-1.7B-Q4_K_M
🔍 LLMService: Starting llama.cpp model loading...
LLMService: Loading model from path: /private/var/containers/Bundle/Application/99A71485-B560-4F0F-AABD-91CE6E0291BA/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf
LlamaCppBridge: Loading model (real) from /private/var/containers/Bundle/Application/99A71485-B560-4F0F-AABD-91CE6E0291BA/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf
LlamaCppBridge: Initializing llama backend
LlamaCppBridge: Backend initialized successfully
LlamaCppBridge: Attempting to load model with params: mmap=1, mlock=0, gpu_layers=0
llama[2]: llama_model_load_from_file_impl: using device Metal (Apple A14 GPU) - 4095 MiB free
llama[2]: llama_model_loader: loaded meta data with 32 key-value pairs and 310 tensors from /private/var/containers/Bundle/Application/99A71485-B560-4F0F-AABD-91CE6E0291BA/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf (version GGUF V3 (latest))
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
LlamaCppBridge: Successfully loaded model from /private/var/containers/Bundle/Application/99A71485-B560-4F0F-AABD-91CE6E0291BA/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf
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
llama[1]: ggml_metal_init: loaded kernel_add                                    0x10615bd20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_2                             0x11756c840 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_3                             0x11756d200 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_4                             0x11756dc20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_5                             0x11756e640 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_6                             0x11756f060 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_7                             0x11756fa80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_8                             0x11759c540 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4                             0x11759cf00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_2                      0x11759d920 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_3                      0x11759e340 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_4                      0x11759ed60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_5                      0x11759f780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_6                      0x1175c0240 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_7                      0x1175c0c00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_8                      0x1175c1620 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sub                                    0x1175c2040 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sub_row_c4                             0x1175c2a60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul                                    0x1175c3480 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_row_c4                             0x1175c3ea0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_div                                    0x1175f0960 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_div_row_c4                             0x1175f1320 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_id                                 0x1175f15c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_f32                             0x1175f1c20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_f16                             0x1175f2280 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_i32                             0x1175f28e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_i16                             0x1175f2f40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_scale                                  0x1175f3000 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_scale_4                                0x1175f3060 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_clamp                                  0x1175f30c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_tanh                                   0x1175f3120 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_relu                                   0x1175f3180 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sigmoid                                0x1175f31e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu                                   0x1175f3240 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_4                                 0x1175f32a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_erf                               0x1175f3300 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_erf_4                             0x1175f3360 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_quick                             0x1175f33c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_quick_4                           0x1175f3420 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_silu                                   0x1175f3480 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_silu_4                                 0x1175f34e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_elu                                    0x1175f3540 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_abs                                    0x1175f35a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sgn                                    0x1175f3600 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_step                                   0x1175f3660 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_hardswish                              0x1175f36c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_hardsigmoid                            0x1175f3720 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_exp                                    0x1175f3780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f16                           0x1175f3f00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f16_4                         0x117690000 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f32                           0x117690f00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f32_4                         0x1176916e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_diag_mask_inf                          0x117691860 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_diag_mask_inf_8                        0x1176919e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_f32                           0x117691d40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_f16                           0x1176920a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_bf16                          0x117692400 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q4_0                          0x117692760 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q4_1                          0x117692ac0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q5_0                          0x117692e80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q5_1                          0x117693180 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q8_0                          0x1176934e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_mxfp4                         0x117693840 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q2_K                          0x117693ba0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q3_K                          0x117693f00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q4_K                          0x117748000 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q5_K                          0x117748600 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q6_K                          0x117748960 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq2_xxs                       0x117748cc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq2_xs                        0x117749020 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq3_xxs                       0x117749380 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq3_s                         0x1177496e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq2_s                         0x117749a40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq1_s                         0x117749da0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq1_m                         0x11774a100 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq4_nl                        0x11774a460 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq4_xs                        0x11774a7c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_i32                           0x11774ab20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_f32                           0x11774b060 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_f16                           0x11774b5a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_bf16                          0x11774bae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q8_0                          0x1177fc0c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q4_0                          0x1177fc5a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q4_1                          0x1177fcae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q5_0                          0x1177fd020 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q5_1                          0x1177fd560 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_iq4_nl                        0x1177fdaa0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rms_norm                               0x1177fdf80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rms_norm_mul                           0x1177fe460 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rms_norm_mul_add                       0x1177fe940 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_l2_norm                                0x1177feb20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_group_norm                             0x1177fef40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_norm                                   0x1177ff060 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_ssm_conv_f32                           0x1177ff6c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_ssm_scan_f32                           0x1177fff60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_ssm_scan_f32_group                     0x11787c060 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rwkv_wkv6_f32                          0x11787c8a0 | th_max =  384 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rwkv_wkv7_f32                          0x11787c900 | th_max =  448 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f32_f32                         0x11787cfc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f32_f32_c4                      0x11787d6e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32                        0x11787de00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32_c4                     0x11787e520 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32_1row                   0x11787ec40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32_l4                     0x11787f360 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_bf16                       0x11787fa80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32                         0x1178c02a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32_c4                      0x1178c0960 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32_1row                    0x1178c1080 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32_l4                      0x1178c17a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f16                         0x1178c1ec0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q4_0_f32                        0x1178c25e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q4_1_f32                        0x1178c2d00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q5_0_f32                        0x1178c3420 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q5_1_f32                        0x1178c3b40 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q8_0_f32                        0x117954300 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_mxfp4_f32                       0x1179549c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_2                0x117955200 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_3                0x117955a40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_4                0x117956280 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_5                0x117956ac0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_2               0x117957300 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_3               0x117957b40 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_4               0x1179a8420 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_5               0x1179a8c00 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_2               0x1179a9440 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_3               0x1179a9c80 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_4               0x1179aa4c0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_5               0x1179aad00 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_2               0x1179ab540 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_3               0x1179abd80 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_4               0x1179d8660 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_5               0x1179d8e40 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_2               0x1179d9680 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_3               0x1179d9ec0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_4               0x1179da700 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_5               0x1179daf40 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_2               0x1179db780 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_3               0x1179fc060 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_4               0x1179fc840 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_5               0x1179fd080 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_2              0x1179fd8c0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_3              0x1179fe100 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_4              0x1179fe940 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_5              0x1179ff180 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_2               0x1179ff9c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_3               0x117a382a0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_4               0x117a38a80 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_5               0x117a392c0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_2               0x117a39b00 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_3               0x117a3a340 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_4               0x117a3ab80 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_5               0x117a3b3c0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_2               0x117a3bc00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_3               0x117a604e0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_4               0x117a60cc0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_5               0x117a61500 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_2             0x117a61d40 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_3             0x117a62580 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_4             0x117a62dc0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_5             0x117a63600 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q2_K_f32                        0x117a63d20 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q3_K_f32                        0x117a944e0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q4_K_f32                        0x117a94ba0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q5_K_f32                        0x117a952c0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q6_K_f32                        0x117a959e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq2_xxs_f32                     0x117a96100 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq2_xs_f32                      0x117a96820 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq3_xxs_f32                     0x117a96f40 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq3_s_f32                       0x117a97660 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq2_s_f32                       0x117a97d80 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq1_s_f32                       0x117af8540 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq1_m_f32                       0x117af8c00 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq4_nl_f32                      0x117af9320 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq4_xs_f32                      0x117af9a40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_f32_f32                      0x117afa1c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_f16_f32                      0x117afa940 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_bf16_f32                     0x117afb0c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q4_0_f32                     0x117afb840 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q4_1_f32                     0x117b74060 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q5_0_f32                     0x117b74780 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q5_1_f32                     0x117b74f00 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q8_0_f32                     0x117b75680 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_mxfp4_f32                    0x117b75e00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q2_K_f32                     0x117b76580 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q3_K_f32                     0x117b76d00 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q4_K_f32                     0x117b77480 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q5_K_f32                     0x117b77c00 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q6_K_f32                     0x117bfc420 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq2_xxs_f32                  0x117bfcb40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq2_xs_f32                   0x117bfd2c0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq3_xxs_f32                  0x117bfda40 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq3_s_f32                    0x117bfe1c0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq2_s_f32                    0x117bfe940 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq1_s_f32                    0x117bff0c0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq1_m_f32                    0x117bff840 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq4_nl_f32                   0x15ec58060 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq4_xs_f32                   0x15ec58780 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_f32_f32                         0x15ec58d20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_f16_f32                         0x15ec592c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_bf16_f32                        0x15ec59860 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q4_0_f32                        0x15ec59e00 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q4_1_f32                        0x15ec5a3a0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q5_0_f32                        0x15ec5a940 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q5_1_f32                        0x15ec5aee0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q8_0_f32                        0x15ec5b480 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_mxfp4_f32                       0x15ec5ba20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_mxfp4_f32                       0x15ecec060 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q2_K_f32                        0x15ecec5a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q3_K_f32                        0x15ececb40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q4_K_f32                        0x15eced0e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q5_K_f32                        0x15eced680 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q6_K_f32                        0x15ecedc20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq2_xxs_f32                     0x15ecee1c0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq2_xs_f32                      0x15ecee760 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq3_xxs_f32                     0x15eceed00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq3_s_f32                       0x15ecef2a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq2_s_f32                       0x15ecef840 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq1_s_f32                       0x15ecefde0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq1_m_f32                       0x15ed9c420 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq4_nl_f32                      0x15ed9c960 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq4_xs_f32                      0x15ed9cf00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_map0_f16                     0x15ed9d260 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_map1_f32                     0x15ed9d5c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_f32_f16                      0x15ed9db60 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_f16_f16                      0x15ed9e100 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_bf16_f16                     0x15ed9e6a0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q4_0_f16                     0x15ed9ec40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q4_1_f16                     0x15ed9f1e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q5_0_f16                     0x15ed9f780 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q5_1_f16                     0x15ed9fd20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q8_0_f16                     0x15ee34360 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_mxfp4_f16                    0x15ee348a0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q2_K_f16                     0x15ee34e40 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q3_K_f16                     0x15ee353e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q4_K_f16                     0x15ee35980 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q5_K_f16                     0x15ee35f20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q6_K_f16                     0x15ee364c0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq2_xxs_f16                  0x15ee36a60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq2_xs_f16                   0x15ee37000 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq3_xxs_f16                  0x15ee375a0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq3_s_f16                    0x15ee37b40 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq2_s_f16                    0x15eec4180 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq1_s_f16                    0x15eec46c0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq1_m_f16                    0x15eec4c60 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq4_nl_f16                   0x15eec5200 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq4_xs_f16                   0x15eec57a0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_norm_f32                          0x15eec62e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_norm_f16                          0x15eec6e20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_multi_f32                         0x15eec7960 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_multi_f16                         0x15ef24540 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_vision_f32                        0x15ef25020 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_vision_f16                        0x15ef25b60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_neox_f32                          0x15ef266a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_neox_f16                          0x15ef271e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_f16                             0x15ef277e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_f32                             0x15ef27de0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_ext_f16                         0x15ef5c480 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_ext_f32                         0x15ef5ca20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_conv_transpose_1d_f32_f32              0x15ef5ccc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_conv_transpose_1d_f16_f32              0x15ef5cf60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_upscale_f32                            0x15ef5d740 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pad_f32                                0x15ef5dda0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pad_reflect_1d_f32                     0x15ef5e4c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_timestep_embedding_f32                 0x15ef5e640 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_arange_f32                             0x15ef5e7c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_argsort_f32_i32_asc                    0x15ef5e880 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_argsort_f32_i32_desc                   0x15ef5e9a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_leaky_relu_f32                         0x15ef5eb20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h64                 0x15ef5f5a0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h80                 0x15effc120 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h96                 0x15effcba0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h112                0x15effd680 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h128                0x15effe160 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h192                0x15effec40 | th_max =  384 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_hk192_hv128         0x15efff720 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h256                0x15f0342a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_hk576_hv512         0x15f034d20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h64                0x15f035800 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h80                0x15f0362e0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h96                0x15f036dc0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h112               0x15f037960 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h128               0x15f058420 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h192               0x15f058ea0 | th_max =  384 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_hk192_hv128        0x15f059980 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h256               0x15f05a460 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_hk576_hv512        0x15f05af40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h64                0x15f05ba20 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h80                0x15f0945a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h96                0x15f095020 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h112               0x15f095b00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h128               0x15f0965e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h192               0x15f0970c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_hk192_hv128        0x15f097ba0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h256               0x15f0bc720 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_hk576_hv512        0x15f0bd1a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h64                0x15f0bdc80 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h80                0x15f0be760 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h96                0x15f0bf240 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h112               0x15f0bfd20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h128               0x15f0e48a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h192               0x15f0e5320 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_hk192_hv128        0x15f0e5e00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h256               0x15f0e68e0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_hk576_hv512        0x15f0e73c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h64                0x15f0e7ea0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h80                0x15f10ca20 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h96                0x15f10d4a0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h112               0x15f10df80 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h128               0x15f10ea60 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h192               0x15f10f540 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_hk192_hv128        0x15f13c0c0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h256               0x15f13cb40 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_hk576_hv512        0x15f13d620 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h64                0x15f13e100 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h80                0x15f13ebe0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h96                0x15f13f6c0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h112               0x15f16c240 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h128               0x15f16ccc0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h192               0x15f16d7a0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_hk192_hv128        0x15f16e280 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h256               0x15f16ed60 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_hk576_hv512        0x15f16f840 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h64                0x15f1883c0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h80                0x15f188e40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h96                0x15f189920 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h112               0x15f18a400 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h128               0x15f18aee0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h192               0x15f18b9c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_hk192_hv128        0x15f1b4540 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h256               0x15f1b4fc0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_hk576_hv512        0x15f1b5aa0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h64             0x15f1b6580 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h64            0x15f1b7060 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h64            0x15f1b7b40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h64            0x15f1e06c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h64            0x15f1e1140 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h64            0x15f1e1c20 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h64            0x15f1e2700 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h96             0x15f1e31e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h96            0x15f1e3cc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h96            0x15f210840 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h96            0x15f2112c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h96            0x15f211da0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h96            0x15f212880 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h96            0x15f213360 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h128            0x15f213e40 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h128           0x15f2409c0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h128           0x15f241440 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h128           0x15f241f20 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h128           0x15f242a00 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h128           0x15f2434e0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h128           0x15f260060 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h192            0x15f260ae0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h192           0x15f2615c0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h192           0x15f2620a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h192           0x15f262b80 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h192           0x15f263660 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h192           0x15f28c1e0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h192           0x15f28cc60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_hk192_hv128      0x15f28d740 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_hk192_hv128      0x15f28e220 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_hk192_hv128      0x15f28ed00 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_hk192_hv128      0x15f28f7e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_hk192_hv128      0x15f2b0360 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_hk192_hv128      0x15f2b0de0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_hk192_hv128      0x15f2b18c0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h256            0x15f2b23a0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h256           0x15f2b2e80 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h256           0x15f2b3960 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h256           0x15f2dc4e0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h256           0x15f2dcf60 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h256           0x15f2dda40 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h256           0x15f2de520 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_hk576_hv512      0x15f2df000 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_hk576_hv512      0x15f2dfae0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_hk576_hv512      0x15f300660 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_hk576_hv512      0x15f3010e0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_hk576_hv512      0x15f301bc0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_hk576_hv512      0x15f3026a0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_hk576_hv512      0x15f303180 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_f32                                0x15f303660 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_i32                                0x15f303b40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_f32                            0x15f34c240 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_f16                            0x15f34c840 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_bf16                           0x15f34cea0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f16_f32                            0x15f34d500 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f16_f16                            0x15f34db60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_bf16_f32                           0x15f34e1c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_bf16_bf16                          0x15f34e2e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q8_0                           0x15f34ef40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q4_0                           0x15f34f5a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q4_1                           0x15f34fc00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q5_0                           0x15f3dc240 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q5_1                           0x15f3dc840 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_iq4_nl                         0x15f3dcea0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_0_f32                           0x15f3dd500 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_0_f16                           0x15f3ddb60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_1_f32                           0x15f3de1c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_1_f16                           0x15f3de820 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_0_f32                           0x15f3dee80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_0_f16                           0x15f3df4e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_1_f32                           0x15f3dfb40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_1_f16                           0x162480240 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q8_0_f32                           0x162480840 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q8_0_f16                           0x162480ea0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_concat                                 0x162481860 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sqr                                    0x162481920 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sqrt                                   0x162481980 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sin                                    0x1624819e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cos                                    0x162481a40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_neg                                    0x162481aa0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_reglu                                  0x162481ec0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_geglu                                  0x162482340 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_swiglu                                 0x1624827c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_swiglu_oai                             0x162482c40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_geglu_erf                              0x1624830c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_geglu_quick                            0x162483540 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sum_rows                               0x162483ea0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mean                                   0x16250c8a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_argmax                                 0x16250c900 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pool_2d_avg_f32                        0x16250cd20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pool_2d_max_f32                        0x16250d1a0 | th_max = 1024 | th_width =   32
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
     - modelPath: /private/var/containers/Bundle/Application/99A71485-B560-4F0F-AABD-91CE6E0291BA/Control LLM.app/Models/Qwen3-1.7B-Q4_K_M.gguf
✅ HybridLLMService: Model loaded with llama.cpp
✅ ChatViewModel: Auto-loaded model on startup - loaded: true, model: Qwen3-1.7B-Q4_K_M
App is being debugged, do not track this hang
Hang detected: 0.33s (debugger attached, not reporting)
🔍 Sheet detent changed to: PresentationDetent(id: Large), isSheetExpanded: true
🔍 Sheet expansion state changed to: true
App is being debugged, do not track this hang
Hang detected: 0.86s (debugger attached, not reporting)
Send button pressed!
Send button pressed!
🔍 Setting isLocalProcessing = true for immediate button change
🔍 TextModalView: isLocalProcessing changed, updating effective processing state
🔍 TextModalView: updateEffectiveProcessingState - changing from false to true (llm.isProcessing: false, isLocalProcessing: true)
Donating message sent intent: 'Hi'
🔍 TextModalView: sendMessage called with text: 'Hi'
🔍 TextModalView: sendMessage called with text: 'Hi'
🔍 TextModalView: isDuplicateMessage: false
🔍 TextModalView: Sending message through MainViewModel
🔍 TextModalView: Setting llm.isProcessing = true before sending message
🔍 TextModalView: llm.isProcessing set to: true
🔍 MainViewModel: sendTextMessage called with text: Hi...
🔍 MainViewModel: Current messages count: 0
🔍 MainViewModel: User message added. New count: 1
🔍 MainViewModel: No file detected, sending text normally
🔍 TextModalView: About to create placeholder message
🔍 TextModalView: About to clear messageText
🔍 TextModalView: LLM call already made through ChatViewModel, no duplicate call needed
🔍 TextModalView: About to start polling
🔍 TextModalView: sendMessage completed successfully
🔍 TextModalView: llm.isProcessing changed to true, updating effective processing state
🔍 ChatViewModel: Added user message to history.
🔍 ChatViewModel: buildSafeHistory called with 1 messages
🔍 ChatViewModel: Full history content:
   [0] User: Hi...
🔍 ChatViewModel: After maxMessages trim: 1 messages
🔍 ChatViewModel: Initial character count: 2
🔍 ChatViewModel: Final result: 1 messages, 2 characters
🔍 ChatViewModel: Final history content:
   [0] User: Hi...
🔍 HybridLLMService: Loading model: Qwen3-1.7B-Q4_K_M
🔍 HybridLLMService: Using llama.cpp for Qwen3-1.7B-Q4_K_M
🔍 LLMService: Model Qwen3-1.7B-Q4_K_M already loaded, skipping reload
✅ HybridLLMService: Model loaded with llama.cpp
🔍 HybridLLMService: generateResponse called with useRawPrompt: false
Donating message sent intent: 'Hi'
🔍 HybridLLMService: Generating response with llama.cpp
🔍 HybridLLMService: useRawPrompt flag: false
🔍 HybridLLMService: Using regular chat path
🔍🔍🔍 LLMService.chat: ENTRY POINT - userText parameter: 'Hi...'
🔍 LLMService.chat: History count: 1
🔍 LLMService: Starting conversation #1 with model Qwen3-1.7B-Q4_K_M
🔍🔍🔍 LLMService.buildPrompt: ENTRY POINT - userText parameter: 'Hi...'
🔍 LLMService: buildPrompt called with history count: 1
🔍 LLMService: Building prompt with 1 history messages for model Qwen3-1.7B-Q4_K_M
  Message 0: User - Hi
🔍 LLMService: Qwen3 detected - appended /no_think to disable internal reasoning
🔍 LLMService: Building prompt for model: Qwen3-1.7B-Q4_K_M using universal chat template
🔍 LLMService: Using universal chat template for model: Qwen3-1.7B-Q4_K_M
🔧 LLMService: Calling llm_bridge_apply_chat_template_messages...
LlamaCppBridge: Using chat template: {%- if tools %}
    {{- '<|im_start|>system\n' }}
    {%- if messages[0].role == 'system' %}
        {{- messages[0].content + '\n\n' }}
    {%- endif %}
    {{- "# Tools\n\nYou may call one or more functions to assist with the user query.\n\nYou are provided with function signatures within <tools></tools> XML tags:\n<tools>" }}
    {%- for tool in tools %}
        {{- "\n" }}
        {{- tool | tojson }}
    {%- endfor %}
    {{- "\n</tools>\n\nFor each function call, return a json object with function name and arguments within <tool_call></tool_call> XML tags:\n<tool_call>\n{\"name\": <function-name>, \"arguments\": <args-json-object>}\n</tool_call><|im_end|>\n" }}
{%- else %}
    {%- if messages[0].role == 'system' %}
        {{- '<|im_start|>system\n' + messages[0].content + '<|im_end|>\n' }}
    {%- endif %}
{%- endif %}
{%- set ns = namespace(multi_step_tool=true, last_query_index=messages|length - 1) %}
{%- for forward_message in messages %}
    {%- set index = (messages|length - 1) - loop.index0 %}
    {%- set message = messages[index] %}
    {%- set current_content = message.content if message.content is not none else '' %}
    {%- set tool_start = '<tool_response>' %}
    {%- set tool_start_length = tool_start|length %}
    {%- set start_of_message = current_content[:tool_start_length] %}
    {%- set tool_end = '</tool_response>' %}
    {%- set tool_end_length = tool_end|length %}
    {%- set start_pos = (current_content|length) - tool_end_length %}
    {%- if start_pos < 0 %}
        {%- set start_pos = 0 %}
    {%- endif %}
    {%- set end_of_message = current_content[start_pos:] %}
    {%- if ns.multi_step_tool and message.role == "user" and not(start_of_message == tool_start and end_of_message == tool_end) %}
        {%- set ns.multi_step_tool = false %}
        {%- set ns.last_query_index = index %}
    {%- endif %}
{%- endfor %}
{%- for message in messages %}
    {%- if (message.role == "user") or (message.role == "system" and not loop.first) %}
        {{- '<|im_start|>' + message.role + '\n' + message.content + '<|im_end|>' + '\n' }}
    {%- elif message.role == "assistant" %}
        {%- set content = message.content %}
        {%- set reasoning_content = '' %}
        {%- if message.reasoning_content is defined and message.reasoning_content is not none %}
            {%- set reasoning_content = message.reasoning_content %}
        {%- else %}
            {%- if '</think>' in message.content %}
                {%- set content = (message.content.split('</think>')|last).lstrip('\n') %}
                {%- set reasoning_content = (message.content.split('</think>')|first).rstrip('\n') %}
                {%- set reasoning_content = (reasoning_content.split('<think>')|last).lstrip('\n') %}
            {%- endif %}
        {%- endif %}
        {%- if loop.index0 > ns.last_query_index %}
            {%- if loop.last or (not loop.last and reasoning_content) %}
                {{- '<|im_start|>' + message.role + '\n<think>\n' + reasoning_content.strip('\n') + '\n</think>\n\n' + content.lstrip('\n') }}
            {%- else %}
                {{- '<|im_start|>' + message.role + '\n' + content }}
            {%- endif %}
        {%- else %}
            {{- '<|im_start|>' + message.role + '\n' + content }}
        {%- endif %}
        {%- if message.tool_calls %}
            {%- for tool_call in message.tool_calls %}
                {%- if (loop.first and content) or (not loop.first) %}
                    {{- '\n' }}
                {%- endif %}
                {%- if tool_call.function %}
                    {%- set tool_call = tool_call.function %}
                {%- endif %}
                {{- '<tool_call>\n{"name": "' }}
                {{- tool_call.name }}
                {{- '", "arguments": ' }}
                {%- if tool_call.arguments is string %}
                    {{- tool_call.arguments }}
                {%- else %}
                    {{- tool_call.arguments | tojson }}
                {%- endif %}
                {{- '}\n</tool_call>' }}
            {%- endfor %}
        {%- endif %}
        {{- '<|im_end|>\n' }}
    {%- elif message.role == "tool" %}
        {%- if loop.first or (messages[loop.index0 - 1].role != "tool") %}
            {{- '<|im_start|>user' }}
        {%- endif %}
        {{- '\n<tool_response>\n' }}
        {{- message.content }}
        {{- '\n</tool_response>' }}
        {%- if loop.last or (messages[loop.index0 + 1].role != "tool") %}
            {{- '<|im_end|>\n' }}
        {%- endif %}
    {%- endif %}
{%- endfor %}
{%- if add_generation_prompt %}
    {{- '<|im_start|>assistant\n' }}
    {%- if enable_thinking is defined and enable_thinking is false %}
        {{- '<think>\n\n</think>\n\n' }}
    {%- endif %}
{%- endif %}
✅ LLMService: Applied model chat template (213 bytes)
🔍 LLMService: Final prompt length: 213 characters
🔍 LLMService: Final prompt preview: <|im_start|>system
You are a helpful assistant. Give clear, accurate answers. Say "I don't know" if uncertain.<|im_end|>
<|im_start|>user
Hi<|im_end|>
<|im_start|>user
Hi /no_think<|im_end|>
<|im_star...
🔧 LLMService: Calling llm_bridge_generate_stream_block...
LlamaCppBridge: Starting streaming generation with max_tokens=2048 for model Qwen3-1.7B-Q4_K_M
LlamaCppBridge: Prompt length: 213 characters
LlamaCppBridge: Prompt preview: <|im_start|>system
You are a helpful assistant. Give clear, accurate answers. Say "I don't know" if uncertain.<|im_end|>
<|im_start|>user
Hi<|im_end|>
<|im_start|>user
Hi /no_think<|im_end|>
<|im_star...
LlamaCppBridge: Using standard tokenization (add_special=true, parse_special=true)
LlamaCppBridge: Tokenized prompt into 46 tokens
🔍 TextModalView: Starting monitorAssistantStream
🔍 TextModalView: File processing completed, stopping polling
🔍 TextModalView: isLocalProcessing changed, updating effective processing state
🔍 TextModalView: Added empty placeholder message (0.3s delay)
🔍 TextModalView: Placeholder added, starting polling
✅ Lottie: Loaded animation 'thinkingAnimation' using .named()
✅ Lottie: Animation 'thinkingAnimation' started playing
🔍 TextModalView: generatingOverlay appeared - llm.isProcessing: true, isLocalProcessing: false, effectiveIsProcessing: true
LlamaCppBridge: Starting generation loop for 2048 tokens
LlamaCppBridge: Removed incomplete <think> tag, continuing generation
LlamaCppBridge: Token 1: '<think>' -> ''
LlamaCppBridge: Token 2: '

' -> '

'
LlamaCppBridge: Token 3: '</think>' -> '</think>'
LlamaCppBridge: Token 4: '

' -> '

'
LlamaCppBridge: Token 5: 'Hello' -> 'Hello'
LlamaCppBridge: Hit end token at position 13
LlamaCppBridge: Generation loop completed. Generated 13 tokens.
LlamaCppBridge: Resetting context after chunk completion to free memory
🔍 ChatViewModel: Saved model performance data for 7 models
🔍 ChatViewModel: Updated performance for Qwen3-1.7B-Q4_K_M: 2.63s (avg: 5.63s)
🔍 ChatViewModel: Updated global response duration: 2.63s (avg: 6.30s)
🔍 TextModalView: llm.isProcessing changed to false, updating effective processing state
🔍 TextModalView: updateEffectiveProcessingState - changing from true to false (llm.isProcessing: false, isLocalProcessing: false)
🔍 TextModalView: llm.isProcessing changed to false, resetting isLocalProcessing
LlamaCppBridge: Streaming generation completed
🔍 MainViewModel: Regular chat completed - isProcessing: false, transcript: ''