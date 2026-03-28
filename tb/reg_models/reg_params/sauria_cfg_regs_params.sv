/**********Weights Dimensions********************* */
    
//IDX 33
parameter WEI_W_LIM_LSB              = 0;
parameter WEI_W_STEP_LSB             = WEI_W_LIM_LSB   + WEI_TILE_DIM_SIZE;

parameter WEI_K_LIM_LOWER_LSB        = WEI_W_STEP_LSB  + WEI_TILE_DIM_SIZE;           //FP-Only
parameter WEI_K_LIM_LOWER_MSB        = SAURIA_REG_SIZE - 1;                           //FP-Only
parameter WEI_K_LIM_LOWER_SIZE       = WEI_K_LIM_LOWER_MSB - WEI_K_LIM_LOWER_LSB + 1; //FP-Only

//IDX 34
parameter WEI_K_LIM_LSB              = 0;
parameter WEI_K_LIM_MSB              = WEI_TILE_DIM_SIZE - WEI_K_LIM_LOWER_SIZE - 1;
parameter WEI_K_LIM_SIZE             = WEI_K_LIM_MSB - WEI_K_LIM_LSB + 1;
parameter WEI_K_STEP_LSB             = WEI_K_LIM_MSB  + 1;
    
parameter WEI_TILE_K_LIM_LOWER_LSB   =  WEI_K_STEP_LSB + WEI_TILE_DIM_SIZE;
parameter WEI_TILE_K_LIM_LOWER_MSB   = SAURIA_REG_SIZE - 1;;
parameter WEI_TILE_K_LIM_LOWER_SIZE  = WEI_TILE_K_LIM_LOWER_MSB - WEI_TILE_K_LIM_LOWER_LSB + 1;

//IDX 35
parameter WEI_TILE_K_LIM_LSB         = 0;
parameter WEI_TILE_K_LIM_MSB         = WEI_TILE_DIM_SIZE - WEI_TILE_K_LIM_LOWER_SIZE - 1;
parameter WEI_TILE_K_LIM_SIZE        = WEI_TILE_K_LIM_MSB - WEI_TILE_K_LIM_LSB + 1;

parameter WEI_TILE_K_STEP_LSB        = WEI_TILE_K_LIM_MSB + 1;
    
parameter WEI_COLS_ACTIVE_LOWER_LSB  = WEI_TILE_K_STEP_LSB + WEI_TILE_DIM_SIZE;
parameter WEI_COLS_ACTIVE_LOWER_MSB  = SAURIA_REG_SIZE - 1;
parameter WEI_COLS_ACTIVE_LOWER_SIZE = WEI_COLS_ACTIVE_LOWER_MSB - WEI_COLS_ACTIVE_LOWER_LSB + 1;
   
//IDX 36
parameter WEI_COLS_ACTIVE_LSB        = 0;
parameter WEI_COLS_ACTIVE_SIZE       = COLS_ACTIVE_SIZE - WEI_COLS_ACTIVE_LOWER_SIZE;
parameter WEI_COLS_ACTIVE_MSB        = WEI_COLS_ACTIVE_LSB + WEI_COLS_ACTIVE_SIZE - 1;

parameter WEI_ALIGNED_FLAG_LSB       = WEI_COLS_ACTIVE_MSB + 1;
