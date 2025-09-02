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
🔍 ChatViewModel: Continuing existing session started at 2025-09-01 05:32:29 +0000
🔍 ChatViewModel: Loaded saved timing data - avg: 4.973616676671164s, total: 69.6306334733963s, count: 14
🔍 ChatViewModel: Loaded model performance data for 7 models
   Qwen3-1.7B-Q4_K_M: avg=5.34s, fast=false
   Qwen2.5-1.5B-Instruct-Q5_K_M: avg=2.40s, fast=true
   gemma-3-1B-It-Q4_K_M: avg=7.21s, fast=false
   Llama-3.2-1B-Instruct-Q4_K_M: avg=3.51s, fast=false
   Phi-4-mini-instruct-Q4_K_M: avg=31.49s, fast=false
   smollm2-1.7b-instruct-q4_k_m: avg=7.12s, fast=false
   Gemma-3N-E4B-It-Q4_K_M: avg=196.60s, fast=false
🔍 ChatViewModel: Syncing initial model state...
🔍 Onboarding check: hasSeenOnboarding = true
🔍 User has already seen onboarding, keeping modal hidden
🔍 TextModalView init
🔍 MainView appeared!
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
🔍 TextModalView: syncProcessingState - resetting isLocalProcessing from false to false
🔍 TextModalView: onAppear - Reset clipboard state and duplicate detection
🔍 ChatViewModel: No model loaded, but selected model exists: Llama-3.2-1B-Instruct-Q4_K_M
🔍 ChatViewModel: Auto-loading selected model on startup...
🔍 HybridLLMService: Loading model: Llama-3.2-1B-Instruct-Q4_K_M
🔍 HybridLLMService: Using llama.cpp for Llama-3.2-1B-Instruct-Q4_K_M
🔍 LLMService: Loading specific model: Llama-3.2-1B-Instruct-Q4_K_M (previous: none)
🔍 LLMService: Found model in Models directory: /private/var/containers/Bundle/Application/49FED6A5-2FB5-4932-B8AF-785693DA63CB/Control LLM.app/Models/Llama-3.2-1B-Instruct-Q4_K_M.gguf
🔍 LLMService: Clearing previous model before loading new one...
🔍 LLMService: Unloading model and cleaning up resources
🔍 LLMService: No model resources to free - already clean
🔍 LLMService: Reset conversation count for new model
🔍 LLMService: Set currentModelFilename to: Llama-3.2-1B-Instruct-Q4_K_M
🔍 LLMService: Starting llama.cpp model loading...
LLMService: Loading model from path: /private/var/containers/Bundle/Application/49FED6A5-2FB5-4932-B8AF-785693DA63CB/Control LLM.app/Models/Llama-3.2-1B-Instruct-Q4_K_M.gguf
LlamaCppBridge: Loading model (real) from /private/var/containers/Bundle/Application/49FED6A5-2FB5-4932-B8AF-785693DA63CB/Control LLM.app/Models/Llama-3.2-1B-Instruct-Q4_K_M.gguf
LlamaCppBridge: Initializing llama backend
LlamaCppBridge: Backend initialized successfully
LlamaCppBridge: Attempting to load model with params: mmap=1, mlock=0, gpu_layers=0
llama[2]: llama_model_load_from_file_impl: using device Metal (Apple A14 GPU) - 4095 MiB free
llama[2]: llama_model_loader: loaded meta data with 36 key-value pairs and 147 tensors from /private/var/containers/Bundle/Application/49FED6A5-2FB5-4932-B8AF-785693DA63CB/Control LLM.app/Models/Llama-3.2-1B-Instruct-Q4_K_M.gguf (version GGUF V3 (latest))
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
LlamaCppBridge: Successfully loaded model from /private/var/containers/Bundle/Application/49FED6A5-2FB5-4932-B8AF-785693DA63CB/Control LLM.app/Models/Llama-3.2-1B-Instruct-Q4_K_M.gguf
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
llama[1]: ggml_metal_init: loaded kernel_add                                    0x10653fc60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_2                             0x117fb0780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_3                             0x117fb1140 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_4                             0x117fb1b60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_5                             0x117fb2580 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_6                             0x117fb2fa0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_7                             0x117fb39c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_fuse_8                             0x117fc4480 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4                             0x117fc4e40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_2                      0x117fc5860 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_3                      0x117fc6280 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_4                      0x117fc6ca0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_5                      0x117fc76c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_6                      0x117fd4180 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_7                      0x117fd4b40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_row_c4_fuse_8                      0x117fd5560 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sub                                    0x117fd5f80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sub_row_c4                             0x117fd69a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul                                    0x117fd73c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_row_c4                             0x117fd7de0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_div                                    0x117ff48a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_div_row_c4                             0x117ff5260 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_add_id                                 0x117ff5500 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_f32                             0x117ff5b60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_f16                             0x117ff61c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_i32                             0x117ff6820 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_repeat_i16                             0x117ff6e80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_scale                                  0x117ff6f40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_scale_4                                0x117ff6fa0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_clamp                                  0x117ff7000 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_tanh                                   0x117ff7060 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_relu                                   0x117ff70c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sigmoid                                0x117ff7120 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu                                   0x117ff7180 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_4                                 0x117ff71e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_erf                               0x117ff7240 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_erf_4                             0x117ff72a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_quick                             0x117ff7300 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_gelu_quick_4                           0x117ff7360 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_silu                                   0x117ff73c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_silu_4                                 0x117ff7420 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_elu                                    0x117ff7480 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_abs                                    0x117ff74e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sgn                                    0x117ff7540 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_step                                   0x117ff75a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_hardswish                              0x117ff7600 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_hardsigmoid                            0x117ff7660 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_exp                                    0x117ff76c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f16                           0x117ff7e40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f16_4                         0x14c4806c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f32                           0x14c480e40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_soft_max_f32_4                         0x14c481620 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_diag_mask_inf                          0x14c4817a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_diag_mask_inf_8                        0x14c481920 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_f32                           0x14c481c80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_f16                           0x14c481fe0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_bf16                          0x14c482340 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q4_0                          0x14c4826a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q4_1                          0x14c482a00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q5_0                          0x14c482d60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q5_1                          0x14c4830c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q8_0                          0x14c483420 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_mxfp4                         0x14c483780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q2_K                          0x14c483ae0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q3_K                          0x14c483e40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q4_K                          0x14c51c240 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q5_K                          0x14c51c540 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_q6_K                          0x14c51c8a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq2_xxs                       0x14c51cc00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq2_xs                        0x14c51cf60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq3_xxs                       0x14c51d2c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq3_s                         0x14c51d620 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq2_s                         0x14c51d980 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq1_s                         0x14c51dce0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq1_m                         0x14c51e040 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq4_nl                        0x14c51e3a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_iq4_xs                        0x14c51e700 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_get_rows_i32                           0x14c51eac0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_f32                           0x14c51efa0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_f16                           0x14c51f4e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_bf16                          0x14c51fa20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q8_0                          0x14c51ff60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q4_0                          0x14c5bc060 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q4_1                          0x14c5bc9c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q5_0                          0x14c5bcf00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_q5_1                          0x14c5bd440 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_rows_iq4_nl                        0x14c5bd980 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rms_norm                               0x14c5bde60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rms_norm_mul                           0x14c5be340 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rms_norm_mul_add                       0x14c5be820 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_l2_norm                                0x14c5bea00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_group_norm                             0x14c5bed60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_norm                                   0x14c5bef40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_ssm_conv_f32                           0x14c5bf5a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_ssm_scan_f32                           0x14c5bfe40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_ssm_scan_f32_group                     0x14c6447e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rwkv_wkv6_f32                          0x14c644840 | th_max =  384 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rwkv_wkv7_f32                          0x14c6448a0 | th_max =  448 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f32_f32                         0x14c644f60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f32_f32_c4                      0x14c645680 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32                        0x14c645da0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32_c4                     0x14c6464c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32_1row                   0x14c646be0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_f32_l4                     0x14c647300 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_bf16_bf16                       0x14c647a20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32                         0x14c6981e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32_c4                      0x14c6988a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32_1row                    0x14c698fc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f32_l4                      0x14c6996e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_f16_f16                         0x14c699e00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q4_0_f32                        0x14c69a520 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q4_1_f32                        0x14c69ac40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q5_0_f32                        0x14c69b360 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q5_1_f32                        0x14c69ba80 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q8_0_f32                        0x14c6e4240 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_mxfp4_f32                       0x14c6e4900 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_2                0x14c6e5140 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_3                0x14c6e5980 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_4                0x14c6e61c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_f16_f32_r1_5                0x14c6e6a00 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_2               0x14c6e7240 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_3               0x14c6e7a80 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_4               0x14c720360 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_0_f32_r1_5               0x14c720b40 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_2               0x14c721380 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_3               0x14c721bc0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_4               0x14c722400 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_1_f32_r1_5               0x14c722c40 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_2               0x14c723480 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_3               0x14c723cc0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_4               0x14c7545a0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_0_f32_r1_5               0x14c754d80 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_2               0x14c7555c0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_3               0x14c755e00 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_4               0x14c756640 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_1_f32_r1_5               0x14c756e80 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_2               0x14c7576c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_3               0x14c757f00 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_4               0x14c788000 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q8_0_f32_r1_5               0x14c788fc0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_2              0x14c789800 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_3              0x14c78a040 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_4              0x14c78a880 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_mxfp4_f32_r1_5              0x14c78b0c0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_2               0x14c78b900 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_3               0x14c7ac1e0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_4               0x14c7ac9c0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q4_K_f32_r1_5               0x14c7ad200 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_2               0x14c7ada40 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_3               0x14c7ae280 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_4               0x14c7aeac0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q5_K_f32_r1_5               0x14c7af300 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_2               0x14c7afb40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_3               0x14c7ec420 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_4               0x14c7ecc00 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_q6_K_f32_r1_5               0x14c7ed440 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_2             0x14c7edc80 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_3             0x14c7ee4c0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_4             0x14c7eed00 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_ext_iq4_nl_f32_r1_5             0x14c7ef540 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q2_K_f32                        0x14c7efc60 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q3_K_f32                        0x14cc18420 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q4_K_f32                        0x14cc18ae0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q5_K_f32                        0x14cc19200 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_q6_K_f32                        0x14cc19920 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq2_xxs_f32                     0x14cc1a040 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq2_xs_f32                      0x14cc1a760 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq3_xxs_f32                     0x14cc1ae80 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq3_s_f32                       0x14cc1b5a0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq2_s_f32                       0x14cc1bcc0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq1_s_f32                       0x14cc88480 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq1_m_f32                       0x14cc88b40 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq4_nl_f32                      0x14cc89260 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_iq4_xs_f32                      0x14cc89980 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_f32_f32                      0x14cc8a100 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_f16_f32                      0x14cc8a880 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_bf16_f32                     0x14cc8b000 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q4_0_f32                     0x14cc8b780 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q4_1_f32                     0x14cc8bf00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q5_0_f32                     0x14cd18000 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q5_1_f32                     0x14cd18e40 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q8_0_f32                     0x14cd195c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_mxfp4_f32                    0x14cd19d40 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q2_K_f32                     0x14cd1a4c0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q3_K_f32                     0x14cd1ac40 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q4_K_f32                     0x14cd1b3c0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q5_K_f32                     0x14cd1bb40 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_q6_K_f32                     0x14cd78360 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq2_xxs_f32                  0x14cd78a80 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq2_xs_f32                   0x14cd79200 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq3_xxs_f32                  0x14cd79980 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq3_s_f32                    0x14cd7a100 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq2_s_f32                    0x14cd7a880 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq1_s_f32                    0x14cd7b000 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq1_m_f32                    0x14cd7b780 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq4_nl_f32                   0x14cd7bf00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mv_id_iq4_xs_f32                   0x14cdf4000 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_f32_f32                         0x14cdf4c60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_f16_f32                         0x14cdf5200 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_bf16_f32                        0x14cdf57a0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q4_0_f32                        0x14cdf5d40 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q4_1_f32                        0x14cdf62e0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q5_0_f32                        0x14cdf6880 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q5_1_f32                        0x14cdf6e20 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q8_0_f32                        0x14cdf73c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_mxfp4_f32                       0x14cdf7960 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_mxfp4_f32                       0x14cdf7a80 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q2_K_f32                        0x14ce9c000 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q3_K_f32                        0x14ce9ca80 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q4_K_f32                        0x14ce9d020 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q5_K_f32                        0x14ce9d5c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_q6_K_f32                        0x14ce9db60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq2_xxs_f32                     0x14ce9e100 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq2_xs_f32                      0x14ce9e6a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq3_xxs_f32                     0x14ce9ec40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq3_s_f32                       0x14ce9f1e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq2_s_f32                       0x14ce9f780 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq1_s_f32                       0x14ce9fd20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq1_m_f32                       0x14cf34360 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq4_nl_f32                      0x14cf348a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_iq4_xs_f32                      0x14cf34e40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_map0_f16                     0x14cf351a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_map1_f32                     0x14cf35500 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_f32_f16                      0x14cf35aa0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_f16_f16                      0x14cf36040 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_bf16_f16                     0x14cf365e0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q4_0_f16                     0x14cf36b80 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q4_1_f16                     0x14cf37120 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q5_0_f16                     0x14cf376c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q5_1_f16                     0x14cf37c60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q8_0_f16                     0x14cfc42a0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_mxfp4_f16                    0x14cfc47e0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q2_K_f16                     0x14cfc4d80 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q3_K_f16                     0x14cfc5320 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q4_K_f16                     0x14cfc58c0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q5_K_f16                     0x14cfc5e60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_q6_K_f16                     0x14cfc6400 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq2_xxs_f16                  0x14cfc69a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq2_xs_f16                   0x14cfc6f40 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq3_xxs_f16                  0x14cfc74e0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq3_s_f16                    0x14cfc7a80 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq2_s_f16                    0x14d0780c0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq1_s_f16                    0x14d078600 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq1_m_f16                    0x14d078ba0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq4_nl_f16                   0x14d079140 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mul_mm_id_iq4_xs_f16                   0x14d0796e0 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_norm_f32                          0x14d07a220 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_norm_f16                          0x14d07ad60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_multi_f32                         0x14d07b8a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_multi_f16                         0x14d0b8480 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_vision_f32                        0x14d0b8f60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_vision_f16                        0x14d0b9aa0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_neox_f32                          0x14d0ba5e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_rope_neox_f16                          0x14d0bb120 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_f16                             0x14d0bb720 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_f32                             0x14d0bbd20 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_ext_f16                         0x14d10c3c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_im2col_ext_f32                         0x14d10c960 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_conv_transpose_1d_f32_f32              0x14d10cc00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_conv_transpose_1d_f16_f32              0x14d10cea0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_upscale_f32                            0x14d10d680 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pad_f32                                0x14d10dce0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pad_reflect_1d_f32                     0x14d10e400 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_timestep_embedding_f32                 0x14d10e580 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_arange_f32                             0x14d10e700 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_argsort_f32_i32_asc                    0x14d10e7c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_argsort_f32_i32_desc                   0x14d10e8e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_leaky_relu_f32                         0x14d10ea60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h64                 0x14d10f4e0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h80                 0x14d174060 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h96                 0x14d174ae0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h112                0x14d1755c0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h128                0x14d1760a0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h192                0x14d176b80 | th_max =  384 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_hk192_hv128         0x14d177660 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_h256                0x14d1ac1e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_f16_hk576_hv512         0x14d1acc60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h64                0x14d1ad740 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h80                0x14d1ae220 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h96                0x14d1aed00 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h112               0x14d1af7e0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h128               0x14d1dc360 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h192               0x14d1dcde0 | th_max =  384 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_hk192_hv128        0x14d1dd8c0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_h256               0x14d1de3a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_bf16_hk576_hv512        0x14d1dee80 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h64                0x14d1df960 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h80                0x14d1fc4e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h96                0x14d1fcf60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h112               0x14d1fda40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h128               0x14d1fe520 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h192               0x14d1ff000 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_hk192_hv128        0x14d1ffae0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_h256               0x14d228660 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_0_hk576_hv512        0x14d2290e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h64                0x14d229bc0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h80                0x14d22a6a0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h96                0x14d22b180 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h112               0x14d22bc60 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h128               0x14d2487e0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h192               0x14d249260 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_hk192_hv128        0x14d249d40 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_h256               0x14d24a820 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q4_1_hk576_hv512        0x14d24b300 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h64                0x14d24bde0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h80                0x14d274960 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h96                0x14d2753e0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h112               0x14d275ec0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h128               0x14d2769a0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h192               0x14d277480 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_hk192_hv128        0x14d277f60 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_h256               0x14d2a0060 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_0_hk576_hv512        0x14d2a1500 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h64                0x14d2a1fe0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h80                0x14d2a2ac0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h96                0x14d2a35a0 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h112               0x14d2c4180 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h128               0x14d2c4c00 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h192               0x14d2c56e0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_hk192_hv128        0x14d2c61c0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_h256               0x14d2c6ca0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q5_1_hk576_hv512        0x14d2c7780 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h64                0x14d2e8300 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h80                0x14d2e8d80 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h96                0x14d2e9860 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h112               0x14d2ea340 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h128               0x14d2eae20 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h192               0x14d2eb900 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_hk192_hv128        0x14d318480 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_h256               0x14d318f00 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_q8_0_hk576_hv512        0x14d3199e0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h64             0x14d31a4c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h64            0x14d31a580 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h64            0x14d31ba80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h64            0x14d344600 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h64            0x14d345080 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h64            0x14d345b60 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h64            0x14d346640 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h96             0x14d347120 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h96            0x14d347c00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h96            0x14d368780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h96            0x14d369200 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h96            0x14d369ce0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h96            0x14d36a7c0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h96            0x14d36b2a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h128            0x14d36bd80 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h128           0x14d398900 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h128           0x14d399380 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h128           0x14d399e60 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h128           0x14d39a940 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h128           0x14d39b420 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h128           0x14d39bf00 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h192            0x14d3b8000 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h192           0x14d3b9500 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h192           0x14d3b9fe0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h192           0x14d3baac0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h192           0x14d3bb5a0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h192           0x14d3e0120 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h192           0x14d3e0ba0 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_hk192_hv128      0x14d3e1680 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_hk192_hv128      0x14d3e2160 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_hk192_hv128      0x14d3e2c40 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_hk192_hv128      0x14d3e3720 | th_max =  832 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_hk192_hv128      0x1500002a0 | th_max =  768 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_hk192_hv128      0x150000d20 | th_max =  704 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_hk192_hv128      0x150001800 | th_max =  896 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_h256            0x1500022e0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_h256           0x150002dc0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_h256           0x1500038a0 | th_max =  640 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_h256           0x150020420 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_h256           0x150020ea0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_h256           0x150021980 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_h256           0x150022460 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_f16_hk576_hv512      0x150022f40 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_bf16_hk576_hv512      0x150023a20 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_0_hk576_hv512      0x15004c5a0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q4_1_hk576_hv512      0x15004d020 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_0_hk576_hv512      0x15004db00 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q5_1_hk576_hv512      0x15004e5e0 | th_max =  512 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_flash_attn_ext_vec_q8_0_hk576_hv512      0x15004f0c0 | th_max =  576 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_f32                                0x15004f5a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_set_i32                                0x15004fa80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_f32                            0x150090180 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_f16                            0x150090780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_bf16                           0x150090de0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f16_f32                            0x150091440 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f16_f16                            0x150091aa0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_bf16_f32                           0x150092100 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_bf16_bf16                          0x150092760 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q8_0                           0x150092dc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q4_0                           0x150093420 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q4_1                           0x150093a80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q5_0                           0x15012c180 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_q5_1                           0x15012c780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_f32_iq4_nl                         0x15012cde0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_0_f32                           0x15012d440 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_0_f16                           0x15012daa0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_1_f32                           0x15012e100 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q4_1_f16                           0x15012e760 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_0_f32                           0x15012edc0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_0_f16                           0x15012f420 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_1_f32                           0x15012fa80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q5_1_f16                           0x1501cc180 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q8_0_f32                           0x1501cc780 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cpy_q8_0_f16                           0x1501ccde0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_concat                                 0x1501cd7a0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sqr                                    0x1501cd860 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sqrt                                   0x1501cd8c0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sin                                    0x1501cd920 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_cos                                    0x1501cd980 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_neg                                    0x1501cd9e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_reglu                                  0x1501cde00 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_geglu                                  0x1501ce280 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_swiglu                                 0x1501ce700 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_swiglu_oai                             0x1501ceb80 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_geglu_erf                              0x1501cf000 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_geglu_quick                            0x1501cf480 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_sum_rows                               0x1501cfde0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_mean                                   0x1502547e0 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_argmax                                 0x150254840 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pool_2d_avg_f32                        0x150254c60 | th_max = 1024 | th_width =   32
llama[1]: ggml_metal_init: loaded kernel_pool_2d_max_f32                        0x1502550e0 | th_max = 1024 | th_width =   32
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
     - modelPath: /private/var/containers/Bundle/Application/49FED6A5-2FB5-4932-B8AF-785693DA63CB/Control LLM.app/Models/Llama-3.2-1B-Instruct-Q4_K_M.gguf
✅ HybridLLMService: Model loaded with llama.cpp
✅ ChatViewModel: Auto-loaded model on startup - loaded: true, model: Llama-3.2-1B-Instruct-Q4_K_M
App is being debugged, do not track this hang
Hang detected: 0.89s (debugger attached, not reporting)
Send button pressed!
Send button pressed!
🔍 Setting isLocalProcessing = true for immediate button change
🔍 TextModalView: isLocalProcessing changed, updating effective processing state
🔍 TextModalView: updateEffectiveProcessingState - changing from false to true (llm.isProcessing: false, isLocalProcessing: true)
🔍 TextModalView: generatingOverlay appeared - llm.isProcessing: false, isLocalProcessing: true, effectiveIsProcessing: true
Donating message sent intent: 'Hi'
🔍 TextModalView: sendMessage called with text: 'Hi'
🔍 TextModalView: sendMessage called with text: 'Hi'
🔍 TextModalView: isDuplicateMessage: false
🔍 TextModalView: Sending message through MainViewModel
🔍 TextModalView: Setting llm.isProcessing = true before sending message
🔍 TextModalView: llm.isProcessing set to: true
🔍 TextModalView: llm.isProcessing changed to true, updating effective processing state
🔍 MainViewModel: sendTextMessage called with text: Hi...
🔍 MainViewModel: Current messages count: 0
🔍 MainViewModel: User message added. New count: 1
🔍 MainViewModel: No file detected, sending text normally
🔍 TextModalView: About to create placeholder message
🔍 TextModalView: About to clear messageText
🔍 TextModalView: LLM call already made through ChatViewModel, no duplicate call needed
🔍 TextModalView: About to start polling
🔍 TextModalView: sendMessage completed successfully
🔍 ChatViewModel: Added user message to history.
🔍 ChatViewModel: buildSafeHistory called with 1 messages
🔍 ChatViewModel: Full history content:
   [0] User: Hi...
🔍 ChatViewModel: After maxMessages trim: 1 messages
🔍 ChatViewModel: Initial character count: 2
🔍 ChatViewModel: Final result: 1 messages, 2 characters
🔍 ChatViewModel: Final history content:
   [0] User: Hi...
🔍 HybridLLMService: Loading model: Llama-3.2-1B-Instruct-Q4_K_M
🔍 HybridLLMService: Using llama.cpp for Llama-3.2-1B-Instruct-Q4_K_M
🔍 LLMService: Model Llama-3.2-1B-Instruct-Q4_K_M already loaded, skipping reload
✅ HybridLLMService: Model loaded with llama.cpp
🔍 HybridLLMService: generateResponse called with useRawPrompt: false
Donating message sent intent: 'Hi'
🔍 HybridLLMService: Generating response with llama.cpp
🔍 HybridLLMService: useRawPrompt flag: false
🔍 HybridLLMService: Using regular chat path
🔍🔍🔍 LLMService.chat: ENTRY POINT - userText parameter: 'Hi...'
🔍 LLMService.chat: History count: 1
🔍 LLMService: Starting conversation #1 with model Llama-3.2-1B-Instruct-Q4_K_M
🔍🔍🔍 LLMService.buildPrompt: ENTRY POINT - userText parameter: 'Hi...'
🔍 LLMService: buildPrompt called with history count: 1
🔍 LLMService: Building prompt with 1 history messages for model Llama-3.2-1B-Instruct-Q4_K_M
  Message 0: User - Hi
🔍 LLMService: Building prompt for model: Llama-3.2-1B-Instruct-Q4_K_M using universal chat template
🔍 LLMService: Using universal chat template for model: Llama-3.2-1B-Instruct-Q4_K_M
🔧 LLMService: Calling llm_bridge_apply_chat_template_messages...
LlamaCppBridge: Using chat template: {{- bos_token }}
{%- if custom_tools is defined %}
    {%- set tools = custom_tools %}
{%- endif %}
{%- if not tools_in_user_message is defined %}
    {%- set tools_in_user_message = true %}
{%- endif %}
{%- if not date_string is defined %}
    {%- if strftime_now is defined %}
        {%- set date_string = strftime_now("%d %b %Y") %}
    {%- else %}
        {%- set date_string = "26 Jul 2024" %}
    {%- endif %}
{%- endif %}
{%- if not tools is defined %}
    {%- set tools = none %}
{%- endif %}

{#- This block extracts the system message, so we can slot it into the right place. #}
{%- if messages[0]['role'] == 'system' %}
    {%- set system_message = messages[0]['content']|trim %}
    {%- set messages = messages[1:] %}
{%- else %}
    {%- set system_message = "" %}
{%- endif %}

{#- System message #}
{{- "<|start_header_id|>system<|end_header_id|>\n\n" }}
{%- if tools is not none %}
    {{- "Environment: ipython\n" }}
{%- endif %}
{{- "Cutting Knowledge Date: December 2023\n" }}
{{- "Today Date: " + date_string + "\n\n" }}
{%- if tools is not none and not tools_in_user_message %}
    {{- "You have access to the following functions. To call a function, please respond with JSON for a function call." }}
    {{- 'Respond in the format {"name": function name, "parameters": dictionary of argument name and its value}.' }}
    {{- "Do not use variables.\n\n" }}
    {%- for t in tools %}
        {{- t | tojson(indent=4) }}
        {{- "\n\n" }}
    {%- endfor %}
{%- endif %}
{{- system_message }}
{{- "<|eot_id|>" }}

{#- Custom tools are passed in a user message with some extra guidance #}
{%- if tools_in_user_message and not tools is none %}
    {#- Extract the first user message so we can plug it in here #}
    {%- if messages | length != 0 %}
        {%- set first_user_message = messages[0]['content']|trim %}
        {%- set messages = messages[1:] %}
    {%- else %}
        {{- raise_exception("Cannot put tools in the first user message when there's no first user message!") }}
{%- endif %}
    {{- '<|start_header_id|>user<|end_header_id|>\n\n' -}}
    {{- "Given the following functions, please respond with a JSON for a function call " }}
    {{- "with its proper arguments that best answers the given prompt.\n\n" }}
    {{- 'Respond in the format {"name": function name, "parameters": dictionary of argument name and its value}.' }}
    {{- "Do not use variables.\n\n" }}
    {%- for t in tools %}
        {{- t | tojson(indent=4) }}
        {{- "\n\n" }}
    {%- endfor %}
    {{- first_user_message + "<|eot_id|>"}}
{%- endif %}

{%- for message in messages %}
    {%- if not (message.role == 'ipython' or message.role == 'tool' or 'tool_calls' in message) %}
        {{- '<|start_header_id|>' + message['role'] + '<|end_header_id|>\n\n'+ message['content'] | trim + '<|eot_id|>' }}
    {%- elif 'tool_calls' in message %}
        {%- if not message.tool_calls|length == 1 %}
            {{- raise_exception("This model only supports single tool-calls at once!") }}
        {%- endif %}
        {%- set tool_call = message.tool_calls[0].function %}
        {{- '<|start_header_id|>assistant<|end_header_id|>\n\n' -}}
        {{- '{"name": "' + tool_call.name + '", ' }}
        {{- '"parameters": ' }}
        {{- tool_call.arguments | tojson }}
        {{- "}" }}
        {{- "<|eot_id|>" }}
    {%- elif message.role == "tool" or message.role == "ipython" %}
        {{- "<|start_header_id|>ipython<|end_header_id|>\n\n" }}
        {%- if message.content is mapping or message.content is iterable %}
            {{- message.content | tojson }}
        {%- else %}
            {{- message.content }}
        {%- endif %}
        {{- "<|eot_id|>" }}
    {%- endif %}
{%- endfor %}
{%- if add_generation_prompt %}
    {{- '<|start_header_id|>assistant<|end_header_id|>\n\n' }}
{%- endif %}
✅ LLMService: Applied model chat template (300 bytes)
🔍 LLMService: Final prompt length: 300 characters
🔍 LLMService: Final prompt preview: <|start_header_id|>system<|end_header_id|>

You are a helpful assistant. Give clear, accurate answers. Say "I don't know" if uncertain.<|eot_id|><|start_header_id|>user<|end_header_id|>

Hi<|eot_id|><...
🔧 LLMService: Calling llm_bridge_generate_stream_block...
LlamaCppBridge: Starting streaming generation with max_tokens=2048 for model Llama-3.2-1B-Instruct-Q4_K_M
LlamaCppBridge: Prompt length: 300 characters
LlamaCppBridge: Prompt preview: <|start_header_id|>system<|end_header_id|>

You are a helpful assistant. Give clear, accurate answers. Say "I don't know" if uncertain.<|eot_id|><|start_header_id|>user<|end_header_id|>

Hi<|eot_id|><...
LlamaCppBridge: Using standard tokenization (add_special=true, parse_special=true)
LlamaCppBridge: Tokenized prompt into 44 tokens
🔍 TextModalView: Starting monitorAssistantStream
🔍 TextModalView: File processing completed, stopping polling
🔍 TextModalView: isLocalProcessing changed, updating effective processing state
🔍 TextModalView: Added empty placeholder message (0.3s delay)
🔍 TextModalView: Placeholder added, starting polling
✅ Lottie: Loaded animation 'thinkingAnimation' using .named()
✅ Lottie: Animation 'thinkingAnimation' started playing
LlamaCppBridge: Starting generation loop for 2048 tokens
LlamaCppBridge: Token 1: 'It' -> 'It'
LlamaCppBridge: Token 2: ' seems' -> ' seems'
LlamaCppBridge: Token 3: ' like' -> ' like'
LlamaCppBridge: Token 4: ' we' -> ' we'
LlamaCppBridge: Token 5: ''re' -> ''re'
App is being debugged, do not track this hang
Hang detected: 0.26s (debugger attached, not reporting)
LlamaCppBridge: Hit end token at position 24
LlamaCppBridge: Generation loop completed. Generated 24 tokens.
LlamaCppBridge: Resetting context after chunk completion to free memory
LlamaCppBridge: Streaming generation completed
🔍 ChatViewModel: Saved model performance data for 7 models
🔍 ChatViewModel: Updated performance for Llama-3.2-1B-Instruct-Q4_K_M: 1.95s (avg: 3.32s)
🔍 ChatViewModel: Updated global response duration: 1.95s (avg: 4.77s)
🔍 TextModalView: llm.isProcessing changed to false, updating effective processing state
🔍 TextModalView: updateEffectiveProcessingState - changing from true to false (llm.isProcessing: false, isLocalProcessing: false)
🔍 MainViewModel: Regular chat completed - isProcessing: false, transcript: ''
Snapshotting a view (0x113540380, UIKeyboardImpl) that is not in a visible window requires afterScreenUpdates:YES.