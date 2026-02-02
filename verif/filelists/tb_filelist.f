//Include Files under $SAURIA/tb
+incdir+$SAURIA/tb

//Include Files under $SAURIA/tb/packages
+incdir+$SAURIA/tb/packages

$SAURIA/tb/packages/sauria_common_pkg.sv
$SAURIA/tb/packages/sauria_tb_top_pkg.sv

//Include Files under $SAURIA/tb/common
+incdir+$SAURIA/tb/common

$SAURIA/tb/common/sauria_imports.sv
//Include Files under $SAURIA/tb/common/seq_items
+incdir+$SAURIA/tb/common/seq_items

//Include Files under $SAURIA/tb/common/seq_items/sauria_axi4_seq_items
+incdir+$SAURIA/tb/common/seq_items/sauria_axi4_seq_items


//Include Files under $SAURIA/tb/common/seq_items/sauria_axi4_lite_seq_items
+incdir+$SAURIA/tb/common/seq_items/sauria_axi4_lite_seq_items




//Include Files under $SAURIA/tb/golden_models
+incdir+$SAURIA/tb/golden_models

$SAURIA/tb/golden_models/sauria_base_model.sv
$SAURIA/tb/golden_models/sauria_dma_mem_req_shape_model.sv
$SAURIA/tb/golden_models/sauria_tensor_ptr_model.sv

//Include Files under $SAURIA/tb/interfaces
+incdir+$SAURIA/tb/interfaces

$SAURIA/tb/interfaces/sauria_subsystem_ifc.sv
$SAURIA/tb/interfaces/sauria_df_controller_ifc.sv
$SAURIA/tb/interfaces/sauria_axi_ifcs.sv
//Include Files under $SAURIA/tb/interfaces/interface_connections
+incdir+$SAURIA/tb/interfaces/interface_connections



//Include Files under $SAURIA/tb/agents
+incdir+$SAURIA/tb/agents

//Include Files under $SAURIA/tb/agents/sauria_axi4_lite_agent
+incdir+$SAURIA/tb/agents/sauria_axi4_lite_agent


//Include Files under $SAURIA/tb/agents/sauria_axi4_agent
+incdir+$SAURIA/tb/agents/sauria_axi4_agent



//Include Files under $SAURIA/tb/scoreboards
+incdir+$SAURIA/tb/scoreboards

$SAURIA/tb/scoreboards/sauria_dma_req_addr_scbd.sv
$SAURIA/tb/common/sauria_env.sv

//Include Files under $SAURIA/tb/seqs
+incdir+$SAURIA/tb/seqs

//Include Files under $SAURIA/tb/seqs/core_weights_cfg_seqs
+incdir+$SAURIA/tb/seqs/core_weights_cfg_seqs


//Include Files under $SAURIA/tb/seqs/df_controller_cfg_seqs
+incdir+$SAURIA/tb/seqs/df_controller_cfg_seqs

$SAURIA/tb/seqs/df_controller_cfg_seqs/sauria_rand_df_controller_cfg_seq.sv
$SAURIA/tb/seqs/df_controller_cfg_seqs/sauria_stand_alone_OFF_df_controller_cfg_seq.sv

//Include Files under $SAURIA/tb/seqs/dma_controller_cfg_seqs
+incdir+$SAURIA/tb/seqs/dma_controller_cfg_seqs

$SAURIA/tb/seqs/dma_controller_cfg_seqs/sauria_ifmaps_eq_array_dma_ctrl_seq.sv

//Include Files under $SAURIA/tb/seqs/core_psums_cfg_seqs
+incdir+$SAURIA/tb/seqs/core_psums_cfg_seqs


//Include Files under $SAURIA/tb/seqs/core_ifmaps_cfg_seqs
+incdir+$SAURIA/tb/seqs/core_ifmaps_cfg_seqs


//Include Files under $SAURIA/tb/seqs/base_seqs
+incdir+$SAURIA/tb/seqs/base_seqs


//Include Files under $SAURIA/tb/seqs/core_main_controller_cfg_seqs
+incdir+$SAURIA/tb/seqs/core_main_controller_cfg_seqs


$SAURIA/tb/tb_top.sv

