Successfully loaded font: IBMPlexMono-Regular
Successfully loaded font: IBMPlexMono-Medium
Successfully loaded font: IBMPlexMono-Bold
Info.plist configuration "(no name)" for UIWindowSceneSessionRoleApplication contained UISceneDelegateClassName key, but could not load class with name "Control_LLM.SceneDelegate".
Info.plist configuration "(no name)" for UIWindowSceneSessionRoleApplication contained UISceneDelegateClassName key, but could not load class with name "Control_LLM.SceneDelegate".
Control_LLMApp: 🚀 APP STARTUP - initializeAllServices() called
Control_LLMApp: App state at startup:
Control_LLMApp: - First run: true
Control_LLMApp: - App lifecycle state: 1
Control_LLMApp: - Background time remaining: 1.7976931348623157e+308
MetalMemoryManager: Metal setup completed with memory pooling
Shortcuts Integration Helper initialized
App is active
[16:01:08.486] [SECURITY] DebugFlagManager.swift:319 debugPrint(_:category:) - BackgroundSecurityManager: App became active - showing sensitive content
App became active - sensitive content shown
LlamaCppBridge: Starting Metal shader compilation...
LlamaCppBridge: Initializing backend for Metal shader compilation
LlamaCppBridge: Metal compilation status set to IN PROGRESS
LlamaCppBridge: About to call ggml_backend_metal_init()...
ggml_metal_init: allocating
ggml_metal_init: picking default device: Apple A14 GPU
ggml_metal_load_library: using embedded metal library
fopen failed for data file: errno = 2 (No such file or directory)
Errors found! Invalidating cache...
Warning: Compilation succeeded with: 

program_source:495:28: warning: unused variable 'ksigns64' [-Wunused-const-variable]
GGML_TABLE_BEGIN(uint64_t, ksigns64, 128)
                           ^
program_source:1091:26: warning: unused variable 'kvalues_iq4nl' [-Wunused-const-variable]
GGML_TABLE_BEGIN(int8_t, kvalues_iq4nl, 16)
                         ^
program_source:1097:26: warning: unused variable 'kvalues_mxfp4' [-Wunused-const-variable]
GGML_TABLE_BEGIN(int8_t, kvalues_mxfp4, 16)
                         ^
ggml_metal_init: GPU name:   Apple A14 GPU
ggml_metal_init: GPU family: MTLGPUFamilyApple7  (1007)
ggml_metal_init: GPU family: MTLGPUFamilyCommon3 (3003)
ggml_metal_init: GPU family: MTLGPUFamilyMetal3  (5001)
ggml_metal_init: simdgroup reduction   = true
ggml_metal_init: simdgroup matrix mul. = true
ggml_metal_init: has residency sets    = true
ggml_metal_init: has bfloat            = true
ggml_metal_init: use bfloat            = true
ggml_metal_init: hasUnifiedMemory      = true
ggml_metal_init: recommendedMaxWorkingSetSize  =  4294.98 MB
fopen failed for data file: errno = 2 (No such file or directory)
Errors found! Invalidating cache...
ggml_metal_init: loaded kernel_add                                    0x14aed5bc0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_add_fuse_2                             0x14aed65e0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_add_fuse_3                             0x14aed7000 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_add_fuse_4                             0x14aed7a20 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_add_fuse_5                             0x14aed7ea0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_add_fuse_6                             0x14afb8600 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_add_fuse_7                             0x14afb8fc0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_add_fuse_8                             0x14afb99e0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_add_row_c4                             0x14afba400 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_add_row_c4_fuse_2                      0x14afbae80 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_add_row_c4_fuse_3                      0x14afbb960 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_add_row_c4_fuse_4                      0x14afe4300 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_add_row_c4_fuse_5                      0x14afe4cc0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_add_row_c4_fuse_6                      0x14afe56e0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_add_row_c4_fuse_7                      0x14afe6100 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_add_row_c4_fuse_8                      0x14afe6b20 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_sub                                    0x14afe7540 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_sub_row_c4                             0x14afe7f60 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_mul                                    0x14c00c960 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_mul_row_c4                             0x14c00d380 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_div                                    0x14c00dda0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_div_row_c4                             0x14c00e7c0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_add_id                                 0x14c00ea60 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_repeat_f32                             0x14c00f0c0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_repeat_f16                             0x14c00f720 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_repeat_i32                             0x14c00fd80 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_repeat_i16                             0x14c04c4e0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_scale                                  0x14c04c540 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_scale_4                                0x14c04c5a0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_clamp                                  0x14c04c600 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_tanh                                   0x14c04c660 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_relu                                   0x14c04c6c0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_sigmoid                                0x14c04c720 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_gelu                                   0x14c04c780 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_gelu_4                                 0x14c04c7e0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_gelu_erf                               0x14c04c840 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_gelu_erf_4                             0x14c04c8a0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_gelu_quick                             0x14c04c900 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_gelu_quick_4                           0x14c04c960 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_silu                                   0x14c04c9c0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_silu_4                                 0x14c04ca20 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_elu                                    0x14c04ca80 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_abs                                    0x14c04cae0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_sgn                                    0x14c04cb40 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_step                                   0x14c04cba0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_hardswish                              0x14c04cc00 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_hardsigmoid                            0x14c04cc60 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_exp                                    0x14c04ccc0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_soft_max_f16                           0x14c04d440 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_soft_max_f16_4                         0x14c04dc20 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_soft_max_f32                           0x14c04e400 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_soft_max_f32_4                         0x14c04ebe0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_diag_mask_inf                          0x14c04ed60 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_diag_mask_inf_8                        0x14c04eee0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_f32                           0x14c04f240 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_f16                           0x14c04f5a0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_bf16                          0x14c04f900 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_q4_0                          0x14c04fd20 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_q4_1                          0x14c134060 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_q5_0                          0x14c134360 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_q5_1                          0x14c1346c0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_q8_0                          0x14c134a20 | th_max = 1024 | th_width =   32
[16:01:16.599] [SECURITY] DebugFlagManager.swift:319 debugPrint(_:category:) - BackgroundSecurityManager: Device orientation changed - content remains visible
ggml_metal_init: loaded kernel_get_rows_mxfp4                         0x14c134d80 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_q2_K                          0x14c135080 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_q3_K                          0x14c135440 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_q4_K                          0x14c1357a0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_q5_K                          0x14c135b00 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_q6_K                          0x14c135e60 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_iq2_xxs                       0x14c1361c0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_iq2_xs                        0x14c136520 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_iq3_xxs                       0x14c136880 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_iq3_s                         0x14c136be0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_iq2_s                         0x14c136f40 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_iq1_s                         0x14c137300 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_iq1_m                         0x14c1376c0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_iq4_nl                        0x14c137a20 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_iq4_xs                        0x14c137d80 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_get_rows_i32                           0x14c214120 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_set_rows_f32                           0x14c214600 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_set_rows_f16                           0x14c214b40 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_set_rows_bf16                          0x14c215080 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_set_rows_q8_0                          0x14c2155c0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_set_rows_q4_0                          0x14c215b00 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_set_rows_q4_1                          0x14c216040 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_set_rows_q5_0                          0x14c216580 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_set_rows_q5_1                          0x14c216ac0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_set_rows_iq4_nl                        0x14c217000 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_rms_norm                               0x14c2174e0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_rms_norm_mul                           0x14c2179c0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_rms_norm_mul_add                       0x14c217ea0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_l2_norm                                0x14c268120 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_group_norm                             0x14c2684e0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_norm                                   0x14c2686c0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_ssm_conv_f32                           0x14c268d20 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_ssm_scan_f32                           0x14c2695c0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_ssm_scan_f32_group                     0x14c269e60 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_rwkv_wkv6_f32                          0x14c269f20 | th_max =  384 | th_width =   32
ggml_metal_init: loaded kernel_rwkv_wkv7_f32                          0x14c269f80 | th_max =  448 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_f32_f32                         0x14c26a640 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_f32_f32_c4                      0x14c26ad60 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_bf16_f32                        0x14c26b480 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_bf16_f32_c4                     0x14c26bba0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_bf16_f32_1row                   0x14c2d42a0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_bf16_f32_l4                     0x14c2d4960 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_bf16_bf16                       0x14c2d5080 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_f16_f32                         0x14c2d5860 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_f16_f32_c4                      0x14c2d5f80 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_f16_f32_1row                    0x14c2d66a0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_f16_f32_l4                      0x14c2d6dc0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_f16_f16                         0x14c2d74e0 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_q4_0_f32                        0x14c2d7c00 | th_max =  832 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_q4_1_f32                        0x14c350300 | th_max =  832 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_q5_0_f32                        0x14c3509c0 | th_max =  576 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_q5_1_f32                        0x14c3510e0 | th_max =  576 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_q8_0_f32                        0x14c351800 | th_max = 1024 | th_width =   32
ggml_metal_init: loaded kernel_mul_mv_mxfp4_f32                       0x14c351f20 | th_max = 1024 | th_width =   32