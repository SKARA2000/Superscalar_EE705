library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.PKG_COMMON.all;
use work.PKG_StoreBuf.all;

entity tb is end entity;

architecture arch1 of tb is

component CPU is
port (
			 
			 -- INPUTS TO FETCH UNIT --
			 CLK	: in std_logic;
			 RST	: in std_logic;
	
			 --Code Memory; Needs to be written in PKG_COMMON
			 I_MEM	: in CODE_MEM;
			
			--- Outputs for Debugging --
			----------------------------
			----------------------------
			-- OUTPUTS FROM FETCH --
			O_NEXT_PC1, O_NEXT_PC2			: out std_logic_vector(31 downto 0);
			O_I1_HIST_IND, O_I2_HIST_IND	: out std_logic_vector(N_Br_TAG - 1 downto 0);
			O_INST1, O_INST2				: out std_logic_vector(31 downto 0);
			O_PREDICTION1, O_PREDICTION2	: out std_logic; 
			
			-- OUTPUTS FROM DECODE --
			O_OPCODE1, O_OPCODE2 				: out std_logic_vector(N_OPCODE_BITS-1 downto 0);
			O_FUNC1, O_FUNC2 					: out std_logic_vector(N_FUNC_BITS-1 downto 0);
			O_SHAMT1, O_SHAMT2 					: out std_logic_vector(N_SHAMT_BITS-1 downto 0);
			O_I1_REG1, O_I1_REG2 				: out std_logic_vector(N_LOG_AR-1 downto 0 );
			O_I2_REG1, O_I2_REG2 				: out std_logic_vector(N_LOG_AR-1 downto 0 );
			O_I1_DEST, O_I2_DEST 				: out std_logic_vector(N_LOG_AR-1 downto 0 );
			O_I1_DEC_Valid, O_I2_DEC_Valid 		: out std_logic;
			O_DEC_CTRL1, O_DEC_CTRL2 			: out std_logic_vector(N_CTRL_BITS-1 downto 0);
			speculative_bit1, speculative_bit2 	: out std_logic;
			O_IMM1, O_IMM2						: out std_logic_vector(31 downto 0);
			jump_valid1, jump_valid2 			: out std_logic;
			jump_addr1, jump_addr2 				: out std_logic_vector(31 downto 0);
			
			-- OUTPUTS FROM DISPATCH --
			 O_O_DS1_FPU_OPR1, O_O_DS1_FPU_OPR2 : out std_logic_vector(31 downto 0);
			 O_O_DS1_FPU_VAL, O_O_DS1_FPU_OPR1_VAL, O_O_DS1_FPU_OPR2_VAL : out std_logic;
			 O_O_DS2_FPU_OPR1, O_O_DS2_FPU_OPR2 : out std_logic_vector(31 downto 0);
			 O_O_DS2_FPU_VAL, O_O_DS2_FPU_OPR1_VAL, O_O_DS2_FPU_OPR2_VAL : out std_logic;
			 O_O_DS1_ALU_OPR1, O_O_DS1_ALU_OPR2 : out std_logic_vector(31 downto 0);
			 O_O_DS1_ALU_VAL, O_O_DS1_ALU_OPR1_VAL, O_O_DS1_ALU_OPR2_VAL : out std_logic;
			 O_O_DS2_ALU_OPR1, O_O_DS2_ALU_OPR2 : out std_logic_vector(31 downto 0);
			 O_O_DS2_ALU_VAL, O_O_DS2_ALU_OPR1_VAL, O_O_DS2_ALU_OPR2_VAL : out std_logic;
			 
			 -- OUTPUTS FROM RS for FPU --
			 O_RS_FPU_DEST_REG 	: out std_logic_vector(N_LOG_RR-1 downto 0) ;
			 O_RS_ALU_DEST_REG 	: out std_logic_vector(N_LOG_RR-1 downto 0) ;
			 O_N_INSTR_IN_STN 	: out std_logic_vector(3 downto 0);
			 
			 -- OUTPUTS FROM FPU--
			 O_FPU_OPR1, O_FPU_OPR2 				: out std_logic_vector(31 downto 0) ;
			 O_FPU_RESULT    						: out std_logic_vector(31 downto 0);
			 O_FPU_DEST_REG  						: out std_logic_vector(N_LOG_RR-1 downto 0);
			 O_FPU_INSTR_VAL 						: out std_logic;
			 O_FPU_ROB_LOC_OUT, O_DREG_FPU_ROB_LOC	: out std_logic_vector(N_LOG_ROB-1 downto 0) ;
			 O_O_DS1_FPU_RR , O_O_DS2_FPU_RR 		: out std_logic_vector(N_LOG_RR-1 downto 0);
			 
			 -- OUTPUTS FROM ALU--
			 O_ALU_OPR1, O_ALU_OPR2 				: out std_logic_vector(31 downto 0) ;
			 O_ALU_RESULT    						: out std_logic_vector(31 downto 0);
			 O_ALU_DEST_REG  						: out std_logic_vector(N_LOG_RR-1 downto 0);
			 O_ALU_INSTR_VAL 						: out std_logic;
			 O_ALU_ROB_LOC_OUT, O_DREG_ALU_ROB_LOC	: out std_logic_vector(N_LOG_ROB-1 downto 0) ;			 
			 O_O_DS1_ALU_RR , O_O_DS2_ALU_RR 		: out std_logic_vector(N_LOG_RR-1 downto 0);			 
			 
			 -- OUTPUTS FROM BR --
			 O_BR_OPR1, O_BR_OPR2 					: out std_logic_vector(31 downto 0) ;
			 O_BR_RESULT    						: out std_logic_vector(31 downto 0);
			 O_BR_DEST_REG  						: out std_logic_vector(N_LOG_RR-1 downto 0);
			 O_BR_INSTR_VAL 						: out std_logic;			 
			 O_BR_ROB_LOC_OUT, O_DREG_BR_ROB_LOC	: out std_logic_vector(N_LOG_ROB-1 downto 0) ;			 
			 O_O_DS1_BR_RR , O_O_DS2_BR_RR 			: out std_logic_vector(N_LOG_RR-1 downto 0);
			 
			 -- OUTPUTS FROM RS for MEM UNIT --
			 O_RS_MEM_VAL			: out std_logic;
			 O_RS_OPR1				: out std_logic_vector(31 downto 0);
			 O_RS_OPR2				: out std_logic_vector(31 downto 0);
			 O_RS_OPR3				: out std_logic_vector(31 downto 0);			 
			 
			 -- OUTPUTS FROM MEMORY --
			 O_MEM_RESULT    : out std_logic_vector(31 downto 0);
			 O_MEM_ADDR		 : out std_logic_vector(31 downto 0);
			 O_IN_FREELOC	 : out std_logic_vector(Buffersize - 1 downto 0);
			 O_OUT_FREELOC	 : out std_logic_vector(Buffersize - 1 downto 0);
			 O_MEM_DEST_REG  : out std_logic_vector(N_LOG_RR-1 downto 0);
			 O_MEM_ROB_LOC	 : out std_logic_vector(N_LOG_ROB-1 downto 0);
			 O_MEM_INSTR_VAL : out std_logic;
			 O_MEM_OPR1		 : out std_logic_vector(31 downto 0);
			 O_MEM_OPR2		 : out std_logic_vector(31 downto 0);
			 O_MEM_OPR3		 : out std_logic_vector(31 downto 0);
			 
			 -- TEMP OUTPUTS --
			 O_TEMP_ROB_L1 , O_TEMP_ROB_L2 	: out std_logic_vector( N_LOG_ROB-1 downto 0 ) ;
			 O_TEMP_ROB_WR1, O_TEMP_ROB_WR2 : out std_logic;
			 O_TEMP_ROB_RR1, O_TEMP_ROB_RR2 : out std_logic_vector(N_LOG_RR-1 downto 0);
			 O_TEMP_ROB_AR1, O_TEMP_ROB_AR2 : out std_logic_vector(N_LOG_AR-1 downto 0);

			 -- ROB --
			 O_I1_VAL , O_I2_VAL 		: out std_logic ;
			 O_ROB_HEAD 				: out std_logic_vector(N_LOG_ROB - 1 downto 0);
			 O_ROB_LAST 				: out std_logic_vector(N_LOG_ROB - 1 downto 0);
			 O_BRTAG					: out ROB_BrTAG_COLUMN;
			 O_ROB_FULL, O_STORE_COMMIT	: out std_logic;
			 O_STORE_LOC_BUFF			: out std_logic_vector(Buffersize - 1 downto 0);
			 O_FLUSH, O_SPEC, O_VALID	: out std_logic_vector(2**N_LOG_ROB - 1 downto 0);
			 
			 -- DISPATCH --
			 O_ARF 		:	out	T_ARCH_REGFILE ;
			 O_RRF 		:	out	T_RNME_REGFILE ;
			 O_ARF_TAG  : 	out	T_ARF_TAG ;
			 O_RR_BUSY  :  out std_logic_vector(N_RNME_REG-1 downto 0); 
			 
			 -- STORE BUFFER OUTPUTS --
			 O_STORE_WRITE			: out std_logic;
			 O_STORE_DATA			: out std_logic_vector(31 downto 0);
			 O_STORE_MEM_ADDR		: out std_logic_vector(31 downto 0);
			 O_STOREBUFF_FREE_LOC	: out std_logic_vector(Buffersize - 1 downto 0) ;
			 
			 -- RS2 outputs --
			 O_RS2_N_RS_ALU : out std_logic_vector(N_LOC_BITS downto 0) ;
			 O_RS2_ALU_ROB_LOC_IN : out std_logic_vector(N_LOG_ROB-1 downto 0) ;
			 O_RS2_ALU_DEST_REG : out std_logic_vector(N_LOG_RR-1 downto 0);
			 O_RS2_ALU_INSTR_VALID : out std_logic		 ;
			 O_FLUSH1 , O_FLUSH2 : out std_logic;
			 O_ROB_BR_RES, O_ROB_BR_VAL: out std_Logic			 
		) ;
end component;

signal CLK, RST : std_logic;
signal I_MEM: CODE_MEM;
			 
-- OUTPUT SIGNALS --
-- OUTPUTS FROM FETCH --
signal O_NEXT_PC1, O_NEXT_PC2			: std_logic_vector(31 downto 0);
signal O_I1_HIST_IND, O_I2_HIST_IND	: std_logic_vector(N_Br_TAG - 1 downto 0);
signal O_INST1, O_INST2				: std_logic_vector(31 downto 0);
signal O_PREDICTION1, O_PREDICTION2	: std_logic; 

-- OUTPUTS FROM DECODE --
signal O_OPCODE1, O_OPCODE2 				: std_logic_vector(N_OPCODE_BITS-1 downto 0);
signal O_FUNC1, O_FUNC2 					: std_logic_vector(N_FUNC_BITS-1 downto 0);
signal O_SHAMT1, O_SHAMT2 					: std_logic_vector(N_SHAMT_BITS-1 downto 0);
signal O_I1_REG1, O_I1_REG2 				: std_logic_vector(N_LOG_AR-1 downto 0 );
signal O_I2_REG1, O_I2_REG2 				: std_logic_vector(N_LOG_AR-1 downto 0 );
signal O_I1_DEST, O_I2_DEST 				: std_logic_vector(N_LOG_AR-1 downto 0 );
signal O_I1_DEC_Valid, O_I2_DEC_Valid 		: std_logic;
signal O_DEC_CTRL1, O_DEC_CTRL2 			: std_logic_vector(N_CTRL_BITS-1 downto 0);
signal speculative_bit1, speculative_bit2 	: std_logic;
signal O_IMM1, O_IMM2						: std_logic_vector(31 downto 0);
signal jump_valid1, jump_valid2 			: std_logic;
signal jump_addr1, jump_addr2 				: std_logic_vector(31 downto 0);

--DISPATCH SIGNALS--
signal O_O_DS1_FPU_OPR1, O_O_DS1_FPU_OPR2 :  std_logic_vector(31 downto 0);
signal O_O_DS1_FPU_VAL, O_O_DS1_FPU_OPR1_VAL, O_O_DS1_FPU_OPR2_VAL :  std_logic;
signal O_O_DS2_FPU_OPR1, O_O_DS2_FPU_OPR2 :  std_logic_vector(31 downto 0);
signal O_O_DS2_FPU_VAL, O_O_DS2_FPU_OPR1_VAL, O_O_DS2_FPU_OPR2_VAL :  std_logic;
signal O_O_DS1_ALU_OPR1, O_O_DS1_ALU_OPR2 :  std_logic_vector(31 downto 0);
signal O_O_DS1_ALU_VAL, O_O_DS1_ALU_OPR1_VAL, O_O_DS1_ALU_OPR2_VAL :  std_logic;
signal O_O_DS2_ALU_OPR1, O_O_DS2_ALU_OPR2 :  std_logic_vector(31 downto 0);
signal O_O_DS2_ALU_VAL, O_O_DS2_ALU_OPR1_VAL, O_O_DS2_ALU_OPR2_VAL :  std_logic;
-- OUTPUTS FROM RS for FPU --
signal O_RS_FPU_DEST_REG 	:  std_logic_vector(N_LOG_RR-1 downto 0) ;
signal O_RS_ALU_DEST_REG 	:  std_logic_vector(N_LOG_RR-1 downto 0) ;
signal O_N_INSTR_IN_STN 	:  std_logic_vector(3 downto 0);
-- OUTPUTS FROM FPU--
signal O_FPU_OPR1, O_FPU_OPR2 				:  std_logic_vector(31 downto 0) ;
signal O_FPU_RESULT    						:  std_logic_vector(31 downto 0);
signal O_FPU_DEST_REG  						:  std_logic_vector(N_LOG_RR-1 downto 0);
signal O_FPU_INSTR_VAL 						:  std_logic;
signal O_FPU_ROB_LOC_OUT, O_DREG_FPU_ROB_LOC	:  std_logic_vector(N_LOG_ROB-1 downto 0) ;
signal O_O_DS1_FPU_RR , O_O_DS2_FPU_RR 		:  std_logic_vector(N_LOG_RR-1 downto 0);
-- OUTPUTS FROM ALU--
signal O_ALU_OPR1, O_ALU_OPR2 				:  std_logic_vector(31 downto 0) ;
signal O_ALU_RESULT    						:  std_logic_vector(31 downto 0);
signal O_ALU_DEST_REG  						:  std_logic_vector(N_LOG_RR-1 downto 0);
signal O_ALU_INSTR_VAL 						:  std_logic;
signal O_ALU_ROB_LOC_OUT, O_DREG_ALU_ROB_LOC	:  std_logic_vector(N_LOG_ROB-1 downto 0) ;			 
signal O_O_DS1_ALU_RR , O_O_DS2_ALU_RR 		:  std_logic_vector(N_LOG_RR-1 downto 0);			 
-- OUTPUTS FROM BR --
signal O_BR_OPR1, O_BR_OPR2 					:  std_logic_vector(31 downto 0) ;
signal O_BR_RESULT    						:  std_logic_vector(31 downto 0);
signal O_BR_DEST_REG  						:  std_logic_vector(N_LOG_RR-1 downto 0);
signal O_BR_INSTR_VAL 						:  std_logic;			 
signal O_BR_ROB_LOC_OUT, O_DREG_BR_ROB_LOC	:  std_logic_vector(N_LOG_ROB-1 downto 0) ;			 
signal O_O_DS1_BR_RR , O_O_DS2_BR_RR 			:  std_logic_vector(N_LOG_RR-1 downto 0);	 
-- OUTPUTS FROM RS for MEM UNIT --
signal O_RS_MEM_VAL				: std_logic;
signal O_RS_OPR1				: std_logic_vector(31 downto 0);
signal O_RS_OPR2				: std_logic_vector(31 downto 0);
signal O_RS_OPR3				: std_logic_vector(31 downto 0);
-- OUTPUTS FROM MEMORY --
signal O_MEM_RESULT    :  std_logic_vector(31 downto 0);
signal O_MEM_ADDR		 :  std_logic_vector(31 downto 0);
signal O_IN_FREELOC	 :  std_logic_vector(Buffersize - 1 downto 0);
signal O_OUT_FREELOC	 :  std_logic_vector(Buffersize - 1 downto 0);
signal O_MEM_DEST_REG  :  std_logic_vector(N_LOG_RR-1 downto 0);
signal O_MEM_ROB_LOC	 :  std_logic_vector(N_LOG_ROB-1 downto 0);
signal O_MEM_INSTR_VAL :  std_logic;
signal O_MEM_OPR1		 :  std_logic_vector(31 downto 0);
signal O_MEM_OPR2		 :  std_logic_vector(31 downto 0);
signal O_MEM_OPR3		 :  std_logic_vector(31 downto 0);
 -- TEMP OUTPUTS --
signal O_TEMP_ROB_L1 , O_TEMP_ROB_L2 	:  std_logic_vector( N_LOG_ROB-1 downto 0 ) ;
signal O_TEMP_ROB_WR1, O_TEMP_ROB_WR2 :  std_logic;
signal O_TEMP_ROB_RR1, O_TEMP_ROB_RR2 :  std_logic_vector(N_LOG_RR-1 downto 0);
signal O_TEMP_ROB_AR1, O_TEMP_ROB_AR2 :  std_logic_vector(N_LOG_AR-1 downto 0);
-- ROB --
signal O_I1_VAL , O_I2_VAL 		:  std_logic ;
signal O_ROB_HEAD 				:  std_logic_vector(N_LOG_ROB - 1 downto 0);
signal O_ROB_LAST 				:  std_logic_vector(N_LOG_ROB - 1 downto 0);
signal O_BRTAG					:  ROB_BrTAG_COLUMN;
signal O_ROB_FULL, O_STORE_COMMIT	:  std_logic;
signal O_STORE_LOC_BUFF			:  std_logic_vector(Buffersize - 1 downto 0);
signal O_FLUSH, O_SPEC, O_VALID	:  std_logic_vector(2**N_LOG_ROB - 1 downto 0);
-- DISPATCH --
signal O_ARF 		:		T_ARCH_REGFILE ;
signal O_RRF 		:		T_RNME_REGFILE ;
signal O_ARF_TAG  : 		T_ARF_TAG ;
signal O_RR_BUSY  :   std_logic_vector(N_RNME_REG-1 downto 0); 
-- STORE BUFFER OUTPUTS --
signal O_STORE_WRITE			:  std_logic;
signal O_STORE_DATA			:  std_logic_vector(31 downto 0);
signal O_STORE_MEM_ADDR		:  std_logic_vector(31 downto 0);
signal O_STOREBUFF_FREE_LOC	:  std_logic_vector(Buffersize - 1 downto 0);
 
signal O_RS2_N_RS_ALU :  std_logic_vector(N_LOC_BITS downto 0);
signal O_RS2_ALU_ROB_LOC_IN :  std_logic_vector(N_LOG_ROB-1 downto 0);
signal O_RS2_ALU_DEST_REG :  std_logic_vector(N_LOG_RR-1 downto 0);
signal O_RS2_ALU_INSTR_VALID :  std_logic	;	 
signal O_FLUSH1 , O_FLUSH2, O_ROB_BR_VAL, O_ROB_BR_RES : std_logic ;
begin

dut:  CPU port map (
						 
			 -- INPUTS TO FETCH UNIT --
			 CLK,
			 RST,
	
			 --Code Memory; Needs to be written in PKG_COMMON
			 I_MEM,
			
			--- Outputs for Debugging --
			----------------------------
			----------------------------
			-- OUTPUTS FROM FETCH --
			O_NEXT_PC1, O_NEXT_PC2,
			O_I1_HIST_IND, O_I2_HIST_IND,
			O_INST1, O_INST2,
			O_PREDICTION1, O_PREDICTION2,
			
			-- OUTPUTS FROM DECODE --
			O_OPCODE1, O_OPCODE2,
			O_FUNC1, O_FUNC2,
			O_SHAMT1, O_SHAMT2,
			O_I1_REG1, O_I1_REG2,
			O_I2_REG1, O_I2_REG2,
			O_I1_DEST, O_I2_DEST,
			O_I1_DEC_Valid, O_I2_DEC_Valid,
			O_DEC_CTRL1, O_DEC_CTRL2,
			speculative_bit1, speculative_bit2,
			O_IMM1, O_IMM2,
			jump_valid1, jump_valid2,
			jump_addr1, jump_addr2,
			
			-- OUTPUTS FROM DISPATCH --
			 O_O_DS1_FPU_OPR1, O_O_DS1_FPU_OPR2,
			 O_O_DS1_FPU_VAL, O_O_DS1_FPU_OPR1_VAL, O_O_DS1_FPU_OPR2_VAL,
			 O_O_DS2_FPU_OPR1, O_O_DS2_FPU_OPR2,
			 O_O_DS2_FPU_VAL, O_O_DS2_FPU_OPR1_VAL, O_O_DS2_FPU_OPR2_VAL,
			 O_O_DS1_ALU_OPR1, O_O_DS1_ALU_OPR2,
			 O_O_DS1_ALU_VAL, O_O_DS1_ALU_OPR1_VAL, O_O_DS1_ALU_OPR2_VAL,
			 O_O_DS2_ALU_OPR1, O_O_DS2_ALU_OPR2,
			 O_O_DS2_ALU_VAL, O_O_DS2_ALU_OPR1_VAL, O_O_DS2_ALU_OPR2_VAL,
			 
			 -- OUTPUTS FROM RS for FPU --
			 O_RS_FPU_DEST_REG,
			 O_RS_ALU_DEST_REG,
			 O_N_INSTR_IN_STN,
			 
			 -- OUTPUTS FROM FPU--
			 O_FPU_OPR1, O_FPU_OPR2,
			 O_FPU_RESULT,
			 O_FPU_DEST_REG,
			 O_FPU_INSTR_VAL,
			 O_FPU_ROB_LOC_OUT, O_DREG_FPU_ROB_LOC,
			 O_O_DS1_FPU_RR , O_O_DS2_FPU_RR,
			 
			 -- OUTPUTS FROM ALU--
			 O_ALU_OPR1, O_ALU_OPR2,
			 O_ALU_RESULT,
			 O_ALU_DEST_REG,
			 O_ALU_INSTR_VAL,
			 O_ALU_ROB_LOC_OUT, O_DREG_ALU_ROB_LOC,
			 O_O_DS1_ALU_RR , O_O_DS2_ALU_RR,
			 
			 -- OUTPUTS FROM BR --
			 O_BR_OPR1, O_BR_OPR2,
			 O_BR_RESULT,
			 O_BR_DEST_REG,
			 O_BR_INSTR_VAL,
			 O_BR_ROB_LOC_OUT, O_DREG_BR_ROB_LOC,
			 O_O_DS1_BR_RR , O_O_DS2_BR_RR,

			 -- OUTPUTS FROM RS for MEM UNIT --
			 O_RS_MEM_VAL,
			 O_RS_OPR1,
			 O_RS_OPR2,
			 O_RS_OPR3,
			 
			 -- OUTPUTS FROM MEMORY --
			 O_MEM_RESULT,
			 O_MEM_ADDR,
			 O_IN_FREELOC,
			 O_OUT_FREELOC,
			 O_MEM_DEST_REG,
			 O_MEM_ROB_LOC,
			 O_MEM_INSTR_VAL,
			 O_MEM_OPR1,
			 O_MEM_OPR2,
			 O_MEM_OPR3,
			 
			 -- TEMP OUTPUTS --
			 O_TEMP_ROB_L1 , O_TEMP_ROB_L2,
			 O_TEMP_ROB_WR1, O_TEMP_ROB_WR2,
			 O_TEMP_ROB_RR1, O_TEMP_ROB_RR2,
			 O_TEMP_ROB_AR1, O_TEMP_ROB_AR2,

			 -- ROB --
			 O_I1_VAL , O_I2_VAL,
			 O_ROB_HEAD,
			 O_ROB_LAST,
			 O_BRTAG,
			 O_ROB_FULL, O_STORE_COMMIT,
			 O_STORE_LOC_BUFF,
			 O_FLUSH, O_SPEC, O_VALID,
			 
			 -- DISPATCH --
			 O_ARF,
			 O_RRF,
			 O_ARF_TAG,
			 O_RR_BUSY,
			 
			 -- STORE BUFFER OUTPUTS --
			 O_STORE_WRITE,
			 O_STORE_DATA,
			 O_STORE_MEM_ADDR,
			 O_STOREBUFF_FREE_LOC,
			 
			 O_RS2_N_RS_ALU ,
			 O_RS2_ALU_ROB_LOC_IN ,
			 O_RS2_ALU_DEST_REG ,
			 O_RS2_ALU_INSTR_VALID ,
			 O_FLUSH1 , O_FLUSH2,
			 O_ROB_BR_RES, O_ROB_BR_VAL

		) ;
	
	process 
		variable v_count : integer := 0;
		variable j: integer := 0;
		file txt_file: text;
		variable txt_line: line;
		variable mem_size: integer := 7;
		type local_mem is array(0 to 6) of bit_vector(31 downto 0);
		variable memory: local_mem;
		variable codeMem: CODE_MEM;
	begin
	
		for i in 0 to 49 loop
			CLK <= '0';
			
			wait for 1 ps;
			
			if(v_count < 2) then
				file_open(txt_file, "Codemem.txt", read_mode);
				j := 0;
				while not endfile(txt_file) loop
					readline(txt_file, txt_line);
					read(txt_line, memory(j));
					codeMem(j) := to_stdlogicvector(memory(j));
					j := (j + 1);
				end loop;
				file_close(txt_file);
				I_MEM <= codeMem;
			end if;
			
			if (v_count < 3) then
				RST <= '1';
			else 
				RST <= '0';
			end if ;	
			
			wait for 10 ns;
			
			
			CLK <= '1';
			
			wait for 10 ns;
			
			v_count := v_count + 1;
		end loop;
		
		wait;

	end process;	
		
end architecture;
