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
🔍 ChatViewModel: Loaded saved timing data - avg: 5.972770719628059s, total: 1140.7992074489594s, count: 191
🔍 ChatViewModel: Loaded model performance data for 7 models
   Qwen3-1.7B-Q4_K_M: avg=5.32s, fast=false
   smollm2-1.7b-instruct-q4_k_m: avg=6.53s, fast=false
   gemma-3-1B-It-Q4_K_M: avg=7.00s, fast=false
   Gemma-3N-E4B-It-Q4_K_M: avg=196.60s, fast=false
   Qwen2.5-1.5B-Instruct-Q5_K_M: avg=2.40s, fast=true
   Llama-3.2-1B-Instruct-Q4_K_M: avg=5.34s, fast=false
   Phi-4-mini-instruct-Q4_K_M: avg=31.49s, fast=false
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
🔍 ChatViewModel: No model loaded, but selected model exists: Llama-3.2-1B-Instruct-Q4_K_M
🔍 ChatViewModel: Auto-loading selected model on startup...
🔍 HybridLLMService: Loading model: Llama-3.2-1B-Instruct-Q4_K_M
🔍 HybridLLMService: Using llama.cpp for Llama-3.2-1B-Instruct-Q4_K_M
🔍 LLMService: Loading specific model: Llama-3.2-1B-Instruct-Q4_K_M (previous: none)
🔍 LLMService: Found model in Models directory: /private/var/containers/Bundle/Application/D4A4ADB3-5DBD-41A0-A4A6-BDB98B960C1E/Control LLM.app/Models/Llama-3.2-1B-Instruct-Q4_K_M.gguf
🔍 LLMService: Clearing previous model before loading new one...
🔍 LLMService: Unloading model and cleaning up resources
🔍 LLMService: No model resources to free - already clean
🔍 LLMService: Reset conversation count for new model
🔍 LLMService: Set currentModelFilename to: Llama-3.2-1B-Instruct-Q4_K_M
🔍 LLMService: Starting llama.cpp model loading...
LLMService: Loading model from path: /private/var/containers/Bundle/Application/D4A4ADB3-5DBD-41A0-A4A6-BDB98B960C1E/Control LLM.app/Models/Llama-3.2-1B-Instruct-Q4_K_M.gguf
LlamaCppBridge: Loading model (real) from /private/var/containers/Bundle/Application/D4A4ADB3-5DBD-41A0-A4A6-BDB98B960C1E/Control LLM.app/Models/Llama-3.2-1B-Instruct-Q4_K_M.gguf
LlamaCppBridge: Initializing llama backend
LlamaCppBridge: Backend initialized successfully
LlamaCppBridge: Attempting to load model with params: mmap=1, mlock=0, gpu_layers=0
llama[2]: llama_model_load_from_file_impl: using device Metal (Apple A14 GPU) - 4089 MiB free
🔍 DEBUG: Window background after change: UIExtendedSRGBColorSpace 0.08 0.08 0.08 1
🔍 DEBUG: Root VC background: UIExtendedSRGBColorSpace 0.08 0.08 0.08 1
llama[2]: llama_model_loader: loaded meta data with 36 key-value pairs and 147 tensors from /private/var/containers/Bundle/Application/D4A4ADB3-5DBD-41A0-A4A6-BDB98B960C1E/Control LLM.app/Models/Llama-3.2-1B-Instruct-Q4_K_M.gguf (version GGUF V3 (latest))
llama[2]: llama_model_loader: Dumping metadata keys/values. Note: KV overrides do not apply in this output.
llama[2]: llama_model_loader: - kv   0:                       general.architecture str              = llama
llama[2]: llama_model_loader: - kv   1:                               general.type str              = model
llama[2]: llama_model_loader: - kv   2:                               general.name str              = Llama-3.2-1B-Instruct
llama[2]: llama_model_loader: - kv   3:                           general.finetune str              = Instruct
llama[2]: llama_model_loader: - kv   4:                           general.basename str              = Llama-3.2-1B-Instruct
llama[2]: llama_model_loader: - kv   5:                       general.quantized_by str              = Unsloth
llama[2]: llama_model_loader: - kv   6:                         general.size_label str              = 1B
llama[2]: llama_model_loader: - kv   7:                           general.repo_url str              = https://huggingface.co/unsloth
llama[2]: llama_model_loader: - kv   8:                          llama.block_count u32              = 16
llama[2]: llama_model_loader: - kv   9:                       llama.context_length u32              = 131072
llama[2]: llama_model_loader: - kv  10:                     llama.embedding_length u32              = 2048
llama[2]: llama_model_loader: - kv  11:                  llama.feed_forward_length u32              = 8192
llama[2]: llama_model_loader: - kv  12:                 llama.attention.head_count u32              = 32
llama[2]: llama_model_loader: - kv  13:              llama.attention.head_count_kv u32              = 8
llama[2]: llama_model_loader: - kv  14:                       llama.rope.freq_base f32              = 500000.000000
llama[2]: llama_model_loader: - kv  15:     llama.attention.layer_norm_rms_epsilon f32              = 0.000010
llama[2]: llama_model_loader: - kv  16:                 llama.attention.key_length u32              = 64
llama[2]: llama_model_loader: - kv  17:               llama.attention.value_length u32              = 64
llama[2]: llama_model_loader: - kv  18:                           llama.vocab_size u32              = 128256
llama[2]: llama_model_loader: - kv  19:                 llama.rope.dimension_count u32              = 64
llama[2]: llama_model_loader: - kv  20:                       tokenizer.ggml.model str              = gpt2
llama[2]: llama_model_loader: - kv  21:                         tokenizer.ggml.pre str              = llama-bpe
llama[2]: llama_model_loader: - kv  22:                      tokenizer.ggml.tokens arr[str,128256]  = ["!", "\"", "#", "$", "%", "&", "'", ...
llama[2]: llama_model_loader: - kv  23:                  tokenizer.ggml.token_type arr[i32,128256]  = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ...
llama[2]: llama_model_loader: - kv  24:                      tokenizer.ggml.merges arr[str,280147]  = ["Ġ Ġ", "Ġ ĠĠĠ", "ĠĠ ĠĠ", "...
llama[2]: llama_model_loader: - kv  25:                tokenizer.ggml.bos_token_id u32              = 128000
llama[2]: llama_model_loader: - kv  26:                tokenizer.ggml.eos_token_id u32              = 128009
llama[2]: llama_model_loader: - kv  27:            tokenizer.ggml.padding_token_id u32              = 128004
llama[2]: llama_model_loader: - kv  28:               tokenizer.ggml.add_bos_token bool             = true
llama[2]: llama_model_loader: - kv  29:                    tokenizer.chat_template str              = {{- bos_token }}\n{%- if custom_tools ...
llama[2]: llama_model_loader: - kv  30:               general.quantization_version u32              = 2
llama[2]: llama_model_loader: - kv  31:                          general.file_type u32              = 15
llama[2]: llama_model_loader: - kv  32:                      quantize.imatrix.file str              = Llama-3.2-1B-Instruct-GGUF/imatrix_un...
llama[2]: llama_model_loader: - kv  33:                   quantize.imatrix.dataset str              = unsloth_calibration_Llama-3.2-1B-Inst...
llama[2]: llama_model_loader: - kv  34:             quantize.imatrix.entries_count i32              = 112
llama[2]: llama_model_loader: - kv  35:              quantize.imatrix.chunks_count i32              = 689
llama[2]: llama_model_loader: - type  f32:   34 tensors
llama[2]: llama_model_loader: - type q4_K:   96 tensors
llama[2]: llama_model_loader: - type q6_K:   17 tensors
llama[2]: print_info: file format = GGUF V3 (latest)
llama[2]: print_info: file type   = Q4_K - Medium
llama[2]: print_info: file size   = 762.81 MiB (5.18 BPW)
llama[1]: init_tokenizer: initializing tokenizer for type 2
llama[1]: load: control token: 128254 '<|reserved_special_token_246|>' is not marked as EOG
llama[1]: load: control token: 128252 '<|reserved_special_token_244|>' is not marked as EOG
llama[1]: load: control token: 128251 '<|reserved_special_token_243|>' is not marked as EOG
llama[1]: load: control token: 128250 '<|reserved_special_token_242|>' is not marked as EOG
llama[1]: load: control token: 128248 '<|reserved_special_token_240|>' is not marked as EOG
llama[1]: load: control token: 128247 '<|reserved_special_token_239|>' is not marked as EOG
llama[1]: load: control token: 128245 '<|reserved_special_token_237|>' is not marked as EOG
llama[1]: load: control token: 128244 '<|reserved_special_token_236|>' is not marked as EOG
llama[1]: load: control token: 128243 '<|reserved_special_token_235|>' is not marked as EOG
llama[1]: load: control token: 128240 '<|reserved_special_token_232|>' is not marked as EOG
llama[1]: load: control token: 128238 '<|reserved_special_token_230|>' is not marked as EOG
llama[1]: load: control token: 128235 '<|reserved_special_token_227|>' is not marked as EOG
llama[1]: load: control token: 128234 '<|reserved_special_token_226|>' is not marked as EOG
llama[1]: load: control token: 128229 '<|reserved_special_token_221|>' is not marked as EOG
llama[1]: load: control token: 128227 '<|reserved_special_token_219|>' is not marked as EOG
llama[1]: load: control token: 128226 '<|reserved_special_token_218|>' is not marked as EOG
llama[1]: load: control token: 128224 '<|reserved_special_token_216|>' is not marked as EOG
llama[1]: load: control token: 128223 '<|reserved_special_token_215|>' is not marked as EOG
llama[1]: load: control token: 128221 '<|reserved_special_token_213|>' is not marked as EOG
llama[1]: load: control token: 128219 '<|reserved_special_token_211|>' is not marked as EOG
llama[1]: load: control token: 128218 '<|reserved_special_token_210|>' is not marked as EOG
llama[1]: load: control token: 128217 '<|reserved_special_token_209|>' is not marked as EOG
llama[1]: load: control token: 128216 '<|reserved_special_token_208|>' is not marked as EOG
llama[1]: load: control token: 128215 '<|reserved_special_token_207|>' is not marked as EOG
llama[1]: load: control token: 128213 '<|reserved_special_token_205|>' is not marked as EOG
llama[1]: load: control token: 128211 '<|reserved_special_token_203|>' is not marked as EOG
llama[1]: load: control token: 128210 '<|reserved_special_token_202|>' is not marked as EOG
llama[1]: load: control token: 128209 '<|reserved_special_token_201|>' is not marked as EOG
llama[1]: load: control token: 128208 '<|reserved_special_token_200|>' is not marked as EOG
llama[1]: load: control token: 128207 '<|reserved_special_token_199|>' is not marked as EOG
llama[1]: load: control token: 128204 '<|reserved_special_token_196|>' is not marked as EOG
llama[1]: load: control token: 128202 '<|reserved_special_token_194|>' is not marked as EOG
llama[1]: load: control token: 128197 '<|reserved_special_token_189|>' is not marked as EOG
llama[1]: load: control token: 128195 '<|reserved_special_token_187|>' is not marked as EOG
llama[1]: load: control token: 128194 '<|reserved_special_token_186|>' is not marked as EOG
llama[1]: load: control token: 128191 '<|reserved_special_token_183|>' is not marked as EOG
llama[1]: load: control token: 128190 '<|reserved_special_token_182|>' is not marked as EOG
llama[1]: load: control token: 128188 '<|reserved_special_token_180|>' is not marked as EOG
llama[1]: load: control token: 128187 '<|reserved_special_token_179|>' is not marked as EOG
llama[1]: load: control token: 128185 '<|reserved_special_token_177|>' is not marked as EOG
llama[1]: load: control token: 128184 '<|reserved_special_token_176|>' is not marked as EOG
llama[1]: load: control token: 128183 '<|reserved_special_token_175|>' is not marked as EOG
llama[1]: load: control token: 128178 '<|reserved_special_token_170|>' is not marked as EOG
llama[1]: load: control token: 128177 '<|reserved_special_token_169|>' is not marked as EOG
llama[1]: load: control token: 128176 '<|reserved_special_token_168|>' is not marked as EOG
llama[1]: load: control token: 128175 '<|reserved_special_token_167|>' is not marked as EOG
llama[1]: load: control token: 128174 '<|reserved_special_token_166|>' is not marked as EOG
llama[1]: load: control token: 128173 '<|reserved_special_token_165|>' is not marked as EOG
llama[1]: load: control token: 128172 '<|reserved_special_token_164|>' is not marked as EOG
llama[1]: load: control token: 128169 '<|reserved_special_token_161|>' is not marked as EOG
llama[1]: load: control token: 128167 '<|reserved_special_token_159|>' is not marked as EOG
llama[1]: load: control token: 128166 '<|reserved_special_token_158|>' is not marked as EOG
llama[1]: load: control token: 128160 '<|reserved_special_token_152|>' is not marked as EOG
llama[1]: load: control token: 128159 '<|reserved_special_token_151|>' is not marked as EOG
llama[1]: load: control token: 128157 '<|reserved_special_token_149|>' is not marked as EOG
llama[1]: load: control token: 128156 '<|reserved_special_token_148|>' is not marked as EOG
llama[1]: load: control token: 128154 '<|reserved_special_token_146|>' is not marked as EOG
llama[1]: load: control token: 128152 '<|reserved_special_token_144|>' is not marked as EOG
llama[1]: load: control token: 128151 '<|reserved_special_token_143|>' is not marked as EOG
llama[1]: load: control token: 128150 '<|reserved_special_token_142|>' is not marked as EOG
llama[1]: load: control token: 128147 '<|reserved_special_token_139|>' is not marked as EOG
llama[1]: load: control token: 128144 '<|reserved_special_token_136|>' is not marked as EOG
llama[1]: load: control token: 128142 '<|reserved_special_token_134|>' is not marked as EOG
llama[1]: load: control token: 128141 '<|reserved_special_token_133|>' is not marked as EOG
llama[1]: load: control token: 128140 '<|reserved_special_token_132|>' is not marked as EOG
llama[1]: load: control token: 128133 '<|reserved_special_token_125|>' is not marked as EOG
llama[1]: load: control token: 128130 '<|reserved_special_token_122|>' is not marked as EOG
llama[1]: load: control token: 128128 '<|reserved_special_token_120|>' is not marked as EOG
llama[1]: load: control token: 128127 '<|reserved_special_token_119|>' is not marked as EOG
llama[1]: load: control token: 128126 '<|reserved_special_token_118|>' is not marked as EOG
llama[1]: load: control token: 128125 '<|reserved_special_token_117|>' is not marked as EOG
llama[1]: load: control token: 128124 '<|reserved_special_token_116|>' is not marked as EOG
llama[1]: load: control token: 128123 '<|reserved_special_token_115|>' is not marked as EOG
llama[1]: load: control token: 128122 '<|reserved_special_token_114|>' is not marked as EOG
llama[1]: load: control token: 128121 '<|reserved_special_token_113|>' is not marked as EOG
llama[1]: load: control token: 128120 '<|reserved_special_token_112|>' is not marked as EOG
llama[1]: load: control token: 128119 '<|reserved_special_token_111|>' is not marked as EOG
llama[1]: load: control token: 128116 '<|reserved_special_token_108|>' is not marked as EOG
llama[1]: load: control token: 128115 '<|reserved_special_token_107|>' is not marked as EOG
llama[1]: load: control token: 128114 '<|reserved_special_token_106|>' is not marked as EOG
llama[1]: load: control token: 128113 '<|reserved_special_token_105|>' is not marked as EOG
llama[1]: load: control token: 128111 '<|reserved_special_token_103|>' is not marked as EOG
llama[1]: load: control token: 128110 '<|reserved_special_token_102|>' is not marked as EOG
llama[1]: load: control token: 128107 '<|reserved_special_token_99|>' is not marked as EOG
llama[1]: load: control token: 128106 '<|reserved_special_token_98|>' is not marked as EOG
llama[1]: load: control token: 128105 '<|reserved_special_token_97|>' is not marked as EOG
llama[1]: load: control token: 128104 '<|reserved_special_token_96|>' is not marked as EOG
llama[1]: load: control token: 128103 '<|reserved_special_token_95|>' is not marked as EOG
llama[1]: load: control token: 128100 '<|reserved_special_token_92|>' is not marked as EOG
llama[1]: load: control token: 128097 '<|reserved_special_token_89|>' is not marked as EOG
llama[1]: load: control token: 128096 '<|reserved_special_token_88|>' is not marked as EOG
llama[1]: load: control token: 128094 '<|reserved_special_token_86|>' is not marked as EOG
llama[1]: load: control token: 128093 '<|reserved_special_token_85|>' is not marked as EOG
llama[1]: load: control token: 128090 '<|reserved_special_token_82|>' is not marked as EOG
llama[1]: load: control token: 128089 '<|reserved_special_token_81|>' is not marked as EOG
llama[1]: load: control token: 128087 '<|reserved_special_token_79|>' is not marked as EOG
llama[1]: load: control token: 128085 '<|reserved_special_token_77|>' is not marked as EOG
llama[1]: load: control token: 128080 '<|reserved_special_token_72|>' is not marked as EOG
llama[1]: load: control token: 128077 '<|reserved_special_token_69|>' is not marked as EOG
llama[1]: load: control token: 128076 '<|reserved_special_token_68|>' is not marked as EOG
llama[1]: load: control token: 128073 '<|reserved_special_token_65|>' is not marked as EOG
llama[1]: load: control token: 128070 '<|reserved_special_token_62|>' is not marked as EOG
llama[1]: load: control token: 128069 '<|reserved_special_token_61|>' is not marked as EOG
llama[1]: load: control token: 128067 '<|reserved_special_token_59|>' is not marked as EOG
llama[1]: load: control token: 128064 '<|reserved_special_token_56|>' is not marked as EOG
llama[1]: load: control token: 128062 '<|reserved_special_token_54|>' is not marked as EOG
llama[1]: load: control token: 128061 '<|reserved_special_token_53|>' is not marked as EOG
llama[1]: load: control token: 128060 '<|reserved_special_token_52|>' is not marked as EOG
llama[1]: load: control token: 128054 '<|reserved_special_token_46|>' is not marked as EOG
llama[1]: load: control token: 128045 '<|reserved_special_token_37|>' is not marked as EOG
llama[1]: load: control token: 128044 '<|reserved_special_token_36|>' is not marked as EOG
llama[1]: load: control token: 128043 '<|reserved_special_token_35|>' is not marked as EOG
llama[1]: load: control token: 128042 '<|reserved_special_token_34|>' is not marked as EOG
llama[1]: load: control token: 128038 '<|reserved_special_token_30|>' is not marked as EOG
llama[1]: load: control token: 128037 '<|reserved_special_token_29|>' is not marked as EOG
llama[1]: load: control token: 128035 '<|reserved_special_token_27|>' is not marked as EOG
llama[1]: load: control token: 128034 '<|reserved_special_token_26|>' is not marked as EOG
llama[1]: load: control token: 128033 '<|reserved_special_token_25|>' is not marked as EOG
llama[1]: load: control token: 128032 '<|reserved_special_token_24|>' is not marked as EOG
llama[1]: load: control token: 128030 '<|reserved_special_token_22|>' is not marked as EOG
llama[1]: load: control token: 128029 '<|reserved_special_token_21|>' is not marked as EOG
llama[1]: load: control token: 128028 '<|reserved_special_token_20|>' is not marked as EOG
llama[1]: load: control token: 128026 '<|reserved_special_token_18|>' is not marked as EOG
llama[1]: load: control token: 128025 '<|reserved_special_token_17|>' is not marked as EOG
llama[1]: load: control token: 128024 '<|reserved_special_token_16|>' is not marked as EOG
llama[1]: load: control token: 128022 '<|reserved_special_token_14|>' is not marked as EOG
llama[1]: load: control token: 128020 '<|reserved_special_token_12|>' is not marked as EOG
llama[1]: load: control token: 128017 '<|reserved_special_token_9|>' is not marked as EOG
llama[1]: load: control token: 128016 '<|reserved_special_token_8|>' is not marked as EOG
llama[1]: load: control token: 128015 '<|reserved_special_token_7|>' is not marked as EOG
llama[1]: load: control token: 128014 '<|reserved_special_token_6|>' is not marked as EOG
llama[1]: load: control token: 128013 '<|reserved_special_token_5|>' is not marked as EOG
llama[1]: load: control token: 128011 '<|reserved_special_token_3|>' is not marked as EOG
llama[1]: load: control token: 128010 '<|python_tag|>' is not marked as EOG
llama[1]: load: control token: 128006 '<|start_header_id|>' is not marked as EOG
llama[1]: load: control token: 128003 '<|reserved_special_token_1|>' is not marked as EOG
llama[1]: load: control token: 128002 '<|reserved_special_token_0|>' is not marked as EOG
llama[1]: load: control token: 128000 '<|begin_of_text|>' is not marked as EOG
llama[1]: load: control token: 128041 '<|reserved_special_token_33|>' is not marked as EOG
llama[1]: load: control token: 128063 '<|reserved_special_token_55|>' is not marked as EOG
llama[1]: load: control token: 128046 '<|reserved_special_token_38|>' is not marked as EOG
llama[1]: load: control token: 128007 '<|end_header_id|>' is not marked as EOG
llama[1]: load: control token: 128065 '<|reserved_special_token_57|>' is not marked as EOG
llama[1]: load: control token: 128171 '<|reserved_special_token_163|>' is not marked as EOG
llama[1]: load: control token: 128162 '<|reserved_special_token_154|>' is not marked as EOG
llama[1]: load: control token: 128165 '<|reserved_special_token_157|>' is not marked as EOG
llama[1]: load: control token: 128057 '<|reserved_special_token_49|>' is not marked as EOG
llama[1]: load: control token: 128050 '<|reserved_special_token_42|>' is not marked as EOG
llama[1]: load: control token: 128056 '<|reserved_special_token_48|>' is not marked as EOG
llama[1]: load: control token: 128230 '<|reserved_special_token_222|>' is not marked as EOG
llama[1]: load: control token: 128098 '<|reserved_special_token_90|>' is not marked as EOG
llama[1]: load: control token: 128153 '<|reserved_special_token_145|>' is not marked as EOG
llama[1]: load: control token: 128084 '<|reserved_special_token_76|>' is not marked as EOG
llama[1]: load: control token: 128082 '<|reserved_special_token_74|>' is not marked as EOG
llama[1]: load: control token: 128102 '<|reserved_special_token_94|>' is not marked as EOG
llama[1]: load: control token: 128253 '<|reserved_special_token_245|>' is not marked as EOG
llama[1]: load: control token: 128179 '<|reserved_special_token_171|>' is not marked as EOG
llama[1]: load: control token: 128071 '<|reserved_special_token_63|>' is not marked as EOG
llama[1]: load: control token: 128135 '<|reserved_special_token_127|>' is not marked as EOG
llama[1]: load: control token: 128161 '<|reserved_special_token_153|>' is not marked as EOG
llama[1]: load: control token: 128164 '<|reserved_special_token_156|>' is not marked as EOG
llama[1]: load: control token: 128134 '<|reserved_special_token_126|>' is not marked as EOG
llama[1]: load: control token: 128249 '<|reserved_special_token_241|>' is not marked as EOG
llama[1]: load: control token: 128004 '<|finetune_right_pad_id|>' is not marked as EOG
llama[1]: load: control token: 128036 '<|reserved_special_token_28|>' is not marked as EOG
llama[1]: load: control token: 128148 '<|reserved_special_token_140|>' is not marked as EOG
llama[1]: load: control token: 128181 '<|reserved_special_token_173|>' is not marked as EOG
llama[1]: load: control token: 128222 '<|reserved_special_token_214|>' is not marked as EOG
llama[1]: load: control token: 128075 '<|reserved_special_token_67|>' is not marked as EOG
llama[1]: load: control token: 128241 '<|reserved_special_token_233|>' is not marked as EOG
llama[1]: load: control token: 128051 '<|reserved_special_token_43|>' is not marked as EOG
llama[1]: load: control token: 128068 '<|reserved_special_token_60|>' is not marked as EOG
llama[1]: load: control token: 128149 '<|reserved_special_token_141|>' is not marked as EOG
llama[1]: load: control token: 128201 '<|reserved_special_token_193|>' is not marked as EOG
llama[1]: load: control token: 128058 '<|reserved_special_token_50|>' is not marked as EOG
llama[1]: load: control token: 128146 '<|reserved_special_token_138|>' is not marked as EOG
llama[1]: load: control token: 128143 '<|reserved_special_token_135|>' is not marked as EOG
llama[1]: load: control token: 128023 '<|reserved_special_token_15|>' is not marked as EOG
llama[1]: load: control token: 128039 '<|reserved_special_token_31|>' is not marked as EOG
llama[1]: load: control token: 128132 '<|reserved_special_token_124|>' is not marked as EOG
llama[1]: load: control token: 128101 '<|reserved_special_token_93|>' is not marked as EOG
llama[1]: load: control token: 128212 '<|reserved_special_token_204|>' is not marked as EOG
llama[1]: load: control token: 128189 '<|reserved_special_token_181|>' is not marked as EOG
llama[1]: load: control token: 128225 '<|reserved_special_token_217|>' is not marked as EOG
llama[1]: load: control token: 128129 '<|reserved_special_token_121|>' is not marked as EOG
llama[1]: load: control token: 128005 '<|reserved_special_token_2|>' is not marked as EOG
llama[1]: load: control token: 128078 '<|reserved_special_token_70|>' is not marked as EOG
llama[1]: load: control token: 128163 '<|reserved_special_token_155|>' is not marked as EOG
llama[1]: load: control token: 128072 '<|reserved_special_token_64|>' is not marked as EOG
llama[1]: load: control token: 128112 '<|reserved_special_token_104|>' is not marked as EOG
llama[1]: load: control token: 128186 '<|reserved_special_token_178|>' is not marked as EOG
llama[1]: load: control token: 128095 '<|reserved_special_token_87|>' is not marked as EOG
llama[1]: load: control token: 128109 '<|reserved_special_token_101|>' is not marked as EOG
llama[1]: load: control token: 128099 '<|reserved_special_token_91|>' is not marked as EOG
llama[1]: load: control token: 128138 '<|reserved_special_token_130|>' is not marked as EOG
llama[1]: load: control token: 128193 '<|reserved_special_token_185|>' is not marked as EOG
llama[1]: load: control token: 128199 '<|reserved_special_token_191|>' is not marked as EOG
llama[1]: load: control token: 128048 '<|reserved_special_token_40|>' is not marked as EOG
llama[1]: load: control token: 128088 '<|reserved_special_token_80|>' is not marked as EOG
llama[1]: load: control token: 128192 '<|reserved_special_token_184|>' is not marked as EOG
llama[1]: load: control token: 128136 '<|reserved_special_token_128|>' is not marked as EOG
llama[1]: load: control token: 128092 '<|reserved_special_token_84|>' is not marked as EOG
llama[1]: load: control token: 128158 '<|reserved_special_token_150|>' is not marked as EOG
llama[1]: load: control token: 128049 '<|reserved_special_token_41|>' is not marked as EOG
llama[1]: load: control token: 128031 '<|reserved_special_token_23|>' is not marked as EOG
llama[1]: load: control token: 128255 '<|reserved_special_token_247|>' is not marked as EOG
llama[1]: load: control token: 128182 '<|reserved_special_token_174|>' is not marked as EOG
llama[1]: load: control token: 128066 '<|reserved_special_token_58|>' is not marked as EOG
llama[1]: load: control token: 128180 '<|reserved_special_token_172|>' is not marked as EOG
llama[1]: load: control token: 128233 '<|reserved_special_token_225|>' is not marked as EOG
llama[1]: load: control token: 128079 '<|reserved_special_token_71|>' is not marked as EOG
llama[1]: load: control token: 128081 '<|reserved_special_token_73|>' is not marked as EOG
llama[1]: load: control token: 128231 '<|reserved_special_token_223|>' is not marked as EOG
llama[1]: load: control token: 128196 '<|reserved_special_token_188|>' is not marked as EOG
llama[1]: load: control token: 128047 '<|reserved_special_token_39|>' is not marked as EOG
llama[1]: load: control token: 128083 '<|reserved_special_token_75|>' is not marked as EOG
llama[1]: load: control token: 128139 '<|reserved_special_token_131|>' is not marked as EOG
llama[1]: load: control token: 128131 '<|reserved_special_token_123|>' is not marked as EOG
llama[1]: load: control token: 128118 '<|reserved_special_token_110|>' is not marked as EOG
llama[1]: load: control token: 128053 '<|reserved_special_token_45|>' is not marked as EOG
llama[1]: load: control token: 128220 '<|reserved_special_token_212|>' is not marked as EOG
llama[1]: load: control token: 128108 '<|reserved_special_token_100|>' is not marked as EOG
llama[1]: load: control token: 128091 '<|reserved_special_token_83|>' is not marked as EOG
llama[1]: load: control token: 128203 '<|reserved_special_token_195|>' is not marked as EOG
llama[1]: load: control token: 128059 '<|reserved_special_token_51|>' is not marked as EOG
llama[1]: load: control token: 128019 '<|reserved_special_token_11|>' is not marked as EOG
llama[1]: load: control token: 128170 '<|reserved_special_token_162|>' is not marked as EOG
llama[1]: load: control token: 128205 '<|reserved_special_token_197|>' is not marked as EOG
llama[1]: load: control token: 128040 '<|reserved_special_token_32|>' is not marked as EOG
llama[1]: load: control token: 128200 '<|reserved_special_token_192|>' is not marked as EOG
llama[1]: load: control token: 128236 '<|reserved_special_token_228|>' is not marked as EOG
llama[1]: load: control token: 128145 '<|reserved_special_token_137|>' is not marked as EOG
llama[1]: load: control token: 128168 '<|reserved_special_token_160|>' is not marked as EOG
llama[1]: load: control token: 128214 '<|reserved_special_token_206|>' is not marked as EOG
llama[1]: load: control token: 128137 '<|reserved_special_token_129|>' is not marked as EOG
llama[1]: load: control token: 128232 '<|reserved_special_token_224|>' is not marked as EOG
llama[1]: load: control token: 128239 '<|reserved_special_token_231|>' is not marked as EOG
llama[1]: load: control token: 128055 '<|reserved_special_token_47|>' is not marked as EOG
llama[1]: load: control token: 128228 '<|reserved_special_token_220|>' is not marked as EOG
llama[1]: load: control token: 128206 '<|reserved_special_token_198|>' is not marked as EOG
llama[1]: load: control token: 128018 '<|reserved_special_token_10|>' is not marked as EOG
llama[1]: load: control token: 128012 '<|reserved_special_token_4|>' is not marked as EOG
llama[1]: load: control token: 128198 '<|reserved_special_token_190|>' is not marked as EOG
llama[1]: load: control token: 128021 '<|reserved_special_token_13|>' is not marked as EOG
llama[1]: load: control token: 128086 '<|reserved_special_token_78|>' is not marked as EOG
llama[1]: load: control token: 128074 '<|reserved_special_token_66|>' is not marked as EOG
llama[1]: load: control token: 128027 '<|reserved_special_token_19|>' is not marked as EOG
llama[1]: load: control token: 128242 '<|reserved_special_token_234|>' is not marked as EOG
llama[1]: load: control token: 128155 '<|reserved_special_token_147|>' is not marked as EOG
llama[1]: load: control token: 128052 '<|reserved_special_token_44|>' is not marked as EOG
llama[1]: load: control token: 128246 '<|reserved_special_token_238|>' is not marked as EOG
llama[1]: load: control token: 128117 '<|reserved_special_token_109|>' is not marked as EOG
llama[1]: load: control token: 128237 '<|reserved_special_token_229|>' is not marked as EOG
llama[2]: load: printing all EOG tokens:
llama[2]: load:   - 128001 ('<|end_of_text|>')
llama[2]: load:   - 128008 ('<|eom_id|>')
llama[2]: load:   - 128009 ('<|eot_id|>')
llama[2]: load: special tokens cache size = 256
llama[2]: load: token to piece cache size = 0.7999 MB
llama[2]: print_info: arch             = llama
llama[2]: print_info: vocab_only       = 0
llama[2]: print_info: n_ctx_train      = 131072
llama[2]: print_info: n_embd           = 2048
llama[2]: print_info: n_layer          = 16
llama[2]: print_info: n_head           = 32
llama[2]: print_info: n_head_kv        = 8
llama[2]: print_info: n_rot            = 64
llama[2]: print_info: n_swa            = 0
llama[2]: print_info: is_swa_any       = 0
llama[2]: print_info: n_embd_head_k    = 64
llama[2]: print_info: n_embd_head_v    = 64
llama[2]: print_info: n_gqa            = 4
llama[2]: print_info: n_embd_k_gqa     = 512
llama[2]: print_info: n_embd_v_gqa     = 512
llama[2]: print_info: f_norm_eps       = 0.0e+00
llama[2]: print_info: f_norm_rms_eps   = 1.0e-05
llama[2]: print_info: f_clamp_kqv      = 0.0e+00
llama[2]: print_info: f_max_alibi_bias = 0.0e+00
llama[2]: print_info: f_logit_scale    = 0.0e+00
llama[2]: print_info: f_attn_scale     = 0.0e+00
llama[2]: print_info: n_ff             = 8192
llama[2]: print_info: n_expert         = 0
llama[2]: print_info: n_expert_used    = 0
llama[2]: print_info: causal attn      = 1
llama[2]: print_info: pooling type     = 0
llama[2]: print_info: rope type        = 0
llama[2]: print_info: rope scaling     = linear
llama[2]: print_info: freq_base_train  = 500000.0
llama[2]: print_info: freq_scale_train = 1
llama[2]: print_info: n_ctx_orig_yarn  = 131072
llama[2]: print_info: rope_finetuned   = unknown
llama[2]: print_info: model type       = 1B
llama[2]: print_info: model params     = 1.24 B
llama[2]: print_info: general.name     = Llama-3.2-1B-Instruct
llama[2]: print_info: vocab type       = BPE
llama[2]: print_info: n_vocab          = 128256
llama[2]: print_info: n_merges         = 280147
llama[2]: print_info: BOS token        = 128000 '<|begin_of_text|>'
llama[2]: print_info: EOS token        = 128009 '<|eot_id|>'
llama[2]: print_info: EOT token        = 128009 '<|eot_id|>'
llama[2]: print_info: EOM token        = 128008 '<|eom_id|>'
llama[2]: print_info: PAD token        = 128004 '<|finetune_right_pad_id|>'
llama[2]: print_info: LF token         = 198 'Ċ'
llama[2]: print_info: EOG token        = 128001 '<|end_of_text|>'
llama[2]: print_info: EOG token        = 128008 '<|eom_id|>'
llama[2]: print_info: EOG token        = 128009 '<|eot_id|>'
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
llama[1]: load_tensors: tensor 'token_embd.weight' (q6_K) (and 162 others) cannot be used with preferred buffer type CPU_REPACK, using CPU instead
llama[2]: load_tensors: offloading 0 repeating layers to GPU
llama[2]: load_tensors: offloaded 0/17 layers to GPU
llama[2]: load_tensors:   CPU_Mapped model buffer size =   762.81 MiB
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
LlamaCppBridge: Successfully loaded model from /private/var/containers/Bundle/Application/D4A4ADB3-5DBD-41A0-A4A6-BDB98B960C1E/Control LLM.app/Models/Llama-3.2-1B-Instruct-Q4_K_M.gguf
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
llama[2]: llama_context: freq_base     = 500000.0
llama[2]: llama_context: freq_scale    = 1
llama[3]: llama_context: n_ctx_per_seq (1024) < n_ctx_train (131072) -- the full capacity of the model will not be utilized
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
llama[1]: ggml_metal_init: loaded kernel_add                                    0x13a04b960 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_2                             0x13f9dc480 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_3                             0x13f9dce40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_4                             0x13f9dd860 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_5                             0x13f9de280 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_6                             0x13f9deca0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_7                             0x13f9df6c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_8                             0x13fa08180 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4                             0x13fa08b40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_2                      0x13fa09560 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_3                      0x13fa09f80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_4                      0x13fa0a9a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_5                      0x13fa0b3c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_6                      0x13fa0bde0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_7                      0x13fa3c8a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_8                      0x13fa3d260 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sub                                    0x13fa3dc80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sub_row_c4                             0x13fa3e6a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul                                    0x13fa3f0c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_row_c4                             0x13fa3fae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_div                                    0x13fa685a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_div_row_c4                             0x13fa68f60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_id                                 0x13fa69200 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_f32                             0x13fa69860 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_f16                             0x13fa69ec0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_i32                             0x13fa6a520 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_i16                             0x13fa6ab80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_scale                                  0x13fa6ac40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_scale_4                                0x13fa6aca0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_clamp                                  0x13fa6ad00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_tanh                                   0x13fa6ad60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_relu                                   0x13fa6adc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sigmoid                                0x13fa6ae20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu                                   0x13fa6ae80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_4                                 0x13fa6aee0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_erf                               0x13fa6af40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_erf_4                             0x13fa6afa0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_quick                             0x13fa6b000 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_quick_4                           0x13fa6b060 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_silu                                   0x13fa6b0c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_silu_4                                 0x13fa6b120 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_elu                                    0x13fa6b180 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_abs                                    0x13fa6b1e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sgn                                    0x13fa6b240 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_step                                   0x13fa6b2a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_hardswish                              0x13fa6b300 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_hardsigmoid                            0x13fa6b360 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_exp                                    0x13fa6b3c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f16                           0x13fa6bb40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f16_4                         0x13fb28360 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f32                           0x13fb28ae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f32_4                         0x13fb292c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_diag_mask_inf                          0x13fb29440 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_diag_mask_inf_8                        0x13fb295c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_f32                           0x13fb29920 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_f16                           0x13fb29c80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_bf16                          0x13fb29fe0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q4_0                          0x13fb2a340 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q4_1                          0x13fb2a6a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q5_0                          0x13fb2aa00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q5_1                          0x13fb2ad60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q8_0                          0x13fb2b0c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_mxfp4                         0x13fb2b600 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q2_K                          0x13fb2b7e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q3_K                          0x13fb2bb40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q4_K                          0x13fb2bea0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q5_K                          0x13fbbc2a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q6_K                          0x13fbbc5a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq2_xxs                       0x13fbbc900 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq2_xs                        0x13fbbcc60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq3_xxs                       0x13fbbcfc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq3_s                         0x13fbbd320 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq2_s                         0x13fbbd680 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq1_s                         0x13fbbd9e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq1_m                         0x13fbbdd40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq4_nl                        0x13fbbe0a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq4_xs                        0x13fbbe400 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_i32                           0x13fbbe760 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_f32                           0x13fbbeca0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_f16                           0x13fbbf1e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_bf16                          0x13fbbf720 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q8_0                          0x13fbbfc60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q4_0                          0x140454240 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q4_1                          0x140454720 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q5_0                          0x140454c60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q5_1                          0x1404551a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_iq4_nl                        0x1404556e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rms_norm                               0x140455bc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rms_norm_mul                           0x1404560a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rms_norm_mul_add                       0x140456580 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_l2_norm                                0x140456760 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_group_norm                             0x140456ac0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_norm                                   0x140456ca0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_ssm_conv_f32                           0x140457300 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_ssm_scan_f32                           0x140457ba0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_ssm_scan_f32_group                     0x1404cc4e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rwkv_wkv6_f32                          0x1404cc540 | th_max =  384 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rwkv_wkv7_f32                          0x1404cc5a0 | th_max =  448 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f32_f32                         0x1404ccc60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f32_f32_c4                      0x1404cd380 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32                        0x1404cdaa0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32_c4                     0x1404ce1c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32_1row                   0x1404ce8e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32_l4                     0x1404cf000 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_bf16                       0x1404cf720 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32                         0x1404cfe40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32_c4                      0x14054c600 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32_1row                    0x14054ccc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32_l4                      0x14054d3e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f16                         0x14054db00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q4_0_f32                        0x14054e220 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q4_1_f32                        0x14054e940 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q5_0_f32                        0x14054f060 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q5_1_f32                        0x14054f780 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q8_0_f32                        0x14054fea0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_mxfp4_f32                       0x1405a4660 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_2                0x1405a4e40 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_3                0x1405a5680 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_4                0x1405a5ec0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_5                0x1405a6700 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_2               0x1405a6f40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_3               0x1405a7780 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_4               0x1405cc060 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_5               0x1405cc840 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_2               0x1405cd080 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_3               0x1405cd8c0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_4               0x1405ce100 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_5               0x1405ce940 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_2               0x1405cf180 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_3               0x1405cf9c0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_4               0x1405fc2a0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_5               0x1405fca80 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_2               0x1405fd2c0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_3               0x1405fdb00 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_4               0x1405fe340 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_5               0x1405feb80 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_2               0x1405ff3c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_3               0x1405ffc00 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_4               0x1406304e0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_5               0x140630cc0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_2              0x140631500 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_3              0x140631d40 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_4              0x140632580 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_5              0x140632dc0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_2               0x140633600 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_3               0x140633e40 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_4               0x14065c720 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_5               0x14065cf00 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_2               0x14065d740 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_3               0x14065df80 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_4               0x14065e7c0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_5               0x14065f000 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_2               0x14065f840 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_3               0x14068c0c0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_4               0x14068c8a0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_5               0x14068d0e0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_2             0x14068d920 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_3             0x14068e160 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_4             0x14068e9a0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_5             0x14068f1e0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q2_K_f32                        0x14068f960 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q3_K_f32                        0x1406c4120 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q4_K_f32                        0x1406c47e0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q5_K_f32                        0x1406c4f00 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q6_K_f32                        0x1406c5620 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq2_xxs_f32                     0x1406c5d40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq2_xs_f32                      0x1406c6520 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq3_xxs_f32                     0x1406c6b80 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq3_s_f32                       0x1406c72a0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq2_s_f32                       0x1406c79c0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq1_s_f32                       0x140750180 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq1_m_f32                       0x140750840 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq4_nl_f32                      0x140750f60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq4_xs_f32                      0x140751680 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_f32_f32                      0x140751e00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_f16_f32                      0x140752580 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_bf16_f32                     0x140752d00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q4_0_f32                     0x140753480 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q4_1_f32                     0x140753c00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q5_0_f32                     0x1407c0420 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q5_1_f32                     0x1407c0b40 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q8_0_f32                     0x1407c12c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_mxfp4_f32                    0x1407c1a40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q2_K_f32                     0x1407c21c0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q3_K_f32                     0x1407c2940 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q4_K_f32                     0x1407c30c0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q5_K_f32                     0x1407c3840 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q6_K_f32                     0x140c40060 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq2_xxs_f32                  0x140c40780 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq2_xs_f32                   0x140c40f00 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq3_xxs_f32                  0x140c41680 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq3_s_f32                    0x140c41e00 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq2_s_f32                    0x140c42580 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq1_s_f32                    0x140c42d00 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq1_m_f32                    0x140c43480 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq4_nl_f32                   0x140c43c00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq4_xs_f32                   0x140c9c420 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_f32_f32                         0x140c9c960 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_f16_f32                         0x140c9cf00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_bf16_f32                        0x140c9d4a0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q4_0_f32                        0x140c9da40 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q4_1_f32                        0x140c9dfe0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q5_0_f32                        0x140c9e580 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q5_1_f32                        0x140c9eb20 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q8_0_f32                        0x140c9f180 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_mxfp4_f32                       0x140c9f660 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_mxfp4_f32                       0x140c9f780 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q2_K_f32                        0x140d24240 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q3_K_f32                        0x140d24780 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q4_K_f32                        0x140d24d20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q5_K_f32                        0x140d252c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q6_K_f32                        0x140d25860 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq2_xxs_f32                     0x140d25e00 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq2_xs_f32                      0x140d263a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq3_xxs_f32                     0x140d26940 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq3_s_f32                       0x140d26ee0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq2_s_f32                       0x140d27480 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq1_s_f32                       0x140d27a20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq1_m_f32                       0x140da4060 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq4_nl_f32                      0x140da45a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq4_xs_f32                      0x140da4b40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_map0_f16                     0x140da4ea0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_map1_f32                     0x140da5200 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_f32_f16                      0x140da57a0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_f16_f16                      0x140da5d40 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_bf16_f16                     0x140da62e0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q4_0_f16                     0x140da6880 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q4_1_f16                     0x140da6e20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q5_0_f16                     0x140da73c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q5_1_f16                     0x140da7960 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q8_0_f16                     0x140da7f00 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_mxfp4_f16                    0x140e6c000 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q2_K_f16                     0x140e6ca80 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q3_K_f16                     0x140e6d020 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q4_K_f16                     0x140e6d5c0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q5_K_f16                     0x140e6db60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q6_K_f16                     0x140e6e1c0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq2_xxs_f16                  0x140e6e6a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq2_xs_f16                   0x140e6ec40 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq3_xxs_f16                  0x140e6f1e0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq3_s_f16                    0x140e6f780 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq2_s_f16                    0x140e6fd20 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq1_s_f16                    0x140f04360 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq1_m_f16                    0x140f048a0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq4_nl_f16                   0x140f04e40 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq4_xs_f16                   0x140f053e0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_norm_f32                          0x140f05f20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_norm_f16                          0x140f06a60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_multi_f32                         0x140f075a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_multi_f16                         0x140f4c180 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_vision_f32                        0x140f4cc60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_vision_f16                        0x140f4d7a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_neox_f32                          0x140f4e2e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_neox_f16                          0x140f4ee20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_f16                             0x140f4f420 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_f32                             0x140f4fa20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_ext_f16                         0x140fa0060 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_ext_f32                         0x140fa0600 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_conv_transpose_1d_f32_f32              0x140fa08a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_conv_transpose_1d_f16_f32              0x140fa0b40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_upscale_f32                            0x140fa1320 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pad_f32                                0x140fa1a40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pad_reflect_1d_f32                     0x140fa20a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_timestep_embedding_f32                 0x140fa2220 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_arange_f32                             0x140fa23a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_argsort_f32_i32_asc                    0x140fa2460 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_argsort_f32_i32_desc                   0x140fa2580 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_leaky_relu_f32                         0x140fa2700 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h64                 0x140fa3180 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h80                 0x140fa3c60 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h96                 0x1410207e0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h112                0x1410212c0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h128                0x141021da0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h192                0x141022880 | th_max =  384 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_hk192_hv128         0x141023360 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h256                0x141023e40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_hk576_hv512         0x1410489c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h64                0x141049440 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h80                0x141049f20 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h96                0x14104aa00 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h112               0x14104b4e0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h128               0x141068060 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h192               0x141068ae0 | th_max =  384 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_hk192_hv128        0x1410695c0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h256               0x14106a0a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_hk576_hv512        0x14106ab80 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h64                0x14106b660 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h80                0x14109c1e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h96                0x14109cc60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h112               0x14109d740 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h128               0x14109e220 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h192               0x14109ed00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_hk192_hv128        0x14109f7e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h256               0x1410c0360 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_hk576_hv512        0x1410c0de0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h64                0x1410c18c0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h80                0x1410c23a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h96                0x1410c2e80 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h112               0x1410c3960 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h128               0x1410f04e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h192               0x1410f0f60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_hk192_hv128        0x1410f1a40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h256               0x1410f2520 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_hk576_hv512        0x1410f3000 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h64                0x1410f3ae0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h80                0x141114660 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h96                0x1411150e0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h112               0x141115bc0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h128               0x1411166a0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h192               0x141117180 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_hk192_hv128        0x141117c60 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h256               0x14113c7e0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_hk576_hv512        0x14113d260 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h64                0x14113dd40 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h80                0x14113e820 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h96                0x14113f300 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h112               0x14113fde0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h128               0x141178960 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h192               0x1411793e0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_hk192_hv128        0x141179ec0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h256               0x14117a9a0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_hk576_hv512        0x14117b480 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h64                0x14117bf60 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h80                0x14119c060 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h96                0x14119d500 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h112               0x14119dfe0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h128               0x14119eac0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h192               0x14119f5a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_hk192_hv128        0x1411c4180 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h256               0x1411c4c00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_hk576_hv512        0x1411c56e0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h64             0x1411c61c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h64            0x1411c6ca0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h64            0x1411c7780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h64            0x1411e8300 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h64            0x1411e8d80 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h64            0x1411e9860 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h64            0x1411ea340 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h96             0x1411eae20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h96            0x1411eb900 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h96            0x141220480 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h96            0x141220fc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h96            0x141221a40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h96            0x141222520 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h96            0x141223000 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h128            0x141223ae0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h128           0x141248600 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h128           0x141249080 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h128           0x141249b60 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h128           0x14124a640 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h128           0x14124b120 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h128           0x14124bc00 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h192            0x141268780 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h192           0x141269200 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h192           0x141269ce0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h192           0x14126a7c0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h192           0x14126b2a0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h192           0x14126bd80 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h192           0x141290900 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_hk192_hv128      0x141291380 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_hk192_hv128      0x141291e60 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_hk192_hv128      0x141292940 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_hk192_hv128      0x141293420 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_hk192_hv128      0x141293f00 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_hk192_hv128      0x1412c0000 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_hk192_hv128      0x1412c1500 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h256            0x1412c1fe0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h256           0x1412c2ac0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h256           0x1412c35a0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h256           0x1412e4120 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h256           0x1412e4ba0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h256           0x1412e5680 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h256           0x1412e6160 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_hk576_hv512      0x1412e6c40 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_hk576_hv512      0x1412e7720 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_hk576_hv512      0x1413042a0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_hk576_hv512      0x141304d20 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_hk576_hv512      0x141305800 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_hk576_hv512      0x1413062e0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_hk576_hv512      0x141306dc0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_f32                                0x1413072a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_i32                                0x141307780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_f32                            0x141307de0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_f16                            0x14133c4e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_bf16                           0x14133cae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f16_f32                            0x14133d140 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f16_f16                            0x14133d7a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_bf16_f32                           0x14133de00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_bf16_bf16                          0x14133e460 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q8_0                           0x14133eac0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q4_0                           0x14133f120 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q4_1                           0x14133f780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q5_0                           0x14133fde0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q5_1                           0x1413e04e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_iq4_nl                         0x1413e0ae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_0_f32                           0x1413e1140 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_0_f16                           0x1413e17a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_1_f32                           0x1413e1e00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_1_f16                           0x1413e2460 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_0_f32                           0x1413e2ac0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_0_f16                           0x1413e3120 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_1_f32                           0x1413e3780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_1_f16                           0x1413e3de0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q8_0_f32                           0x14289c4e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q8_0_f16                           0x14289cae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_concat                                 0x14289d4a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sqr                                    0x14289d560 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sqrt                                   0x14289d5c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sin                                    0x14289d620 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cos                                    0x14289d680 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_neg                                    0x14289d6e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_reglu                                  0x14289db00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_geglu                                  0x14289df80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_swiglu                                 0x14289e400 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_swiglu_oai                             0x14289e880 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_geglu_erf                              0x14289ed00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_geglu_quick                            0x14289f180 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sum_rows                               0x14289fae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mean                                   0x1429244e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_argmax                                 0x142924540 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pool_2d_avg_f32                        0x142924960 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pool_2d_max_f32                        0x142924de0 | th_max = 1024 | th_width =   32
llama[1]: set_abort_callback: call
llama[2]: llama_context:        CPU  output buffer size =     0.49 MiB
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
llama[2]: llama_kv_cache_unified:        CPU KV buffer size =    32.00 MiB
llama[2]: llama_kv_cache_unified: size =   32.00 MiB (  1024 cells,  16 layers,  1/1 seqs), K (f16):   16.00 MiB, V (f16):   16.00 MiB
llama[1]: llama_context: enumerating backends
llama[1]: llama_context: backend_ptrs.size() = 3
llama[1]: llama_context: max_nodes = 1176
llama[1]: llama_context: worst-case: n_tokens = 512, n_seqs = 1, n_outputs = 0
llama[1]: graph_reserve: reserving a graph for ubatch with n_tokens =  512, n_seqs =  1, n_outputs =  512
llama[1]: graph_reserve: reserving a graph for ubatch with n_tokens =    1, n_seqs =  1, n_outputs =    1
llama[1]: graph_reserve: reserving a graph for ubatch with n_tokens =  512, n_seqs =  1, n_outputs =  512
llama[2]: llama_context:        CPU compute buffer size =   254.50 MiB
llama[2]: llama_context: graph nodes  = 566
llama[2]: llama_context: graph splits = 226 (with bs=512), 1 (with bs=1)
LlamaCppBridge: Successfully created context
✅ LLMService: Model loaded successfully with llama.cpp
✅ LLMService: Successfully loaded model Llama-3.2-1B-Instruct-Q4_K_M
🔍 LLMService: Final state after loading:
     - currentModelFilename: Llama-3.2-1B-Instruct-Q4_K_M
     - isModelLoaded: true
     - modelPath: /private/var/containers/Bundle/Application/D4A4ADB3-5DBD-41A0-A4A6-BDB98B960C1E/Control LLM.app/Models/Llama-3.2-1B-Instruct-Q4_K_M.gguf
✅ HybridLLMService: Model loaded with llama.cpp
✅ ChatViewModel: Auto-loaded model on startup - loaded: true, model: Llama-3.2-1B-Instruct-Q4_K_M