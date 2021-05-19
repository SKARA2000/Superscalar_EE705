library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG_COMMON.all;


entity	CPU is
port (
			 
			 -- INPUTS TO FETCH UNIT --
			 CLK: in std_logic;
			 RST: in std_logic;
	
			 --Code Memory; Needs to be written in PKG_COMMON
			 I_MEM: in CODE_MEM;
			 
			-- OUTPUTS FROM DISPATCH --
			 O_O_DS1_FPU_OPR1, O_O_DS1_FPU_OPR2 : out std_logic_vector(31 downto 0);
			 O_O_DS1_FPU_VAL, O_O_DS1_FPU_OPR1_VAL, O_O_DS1_FPU_OPR2_VAL : out std_logic ;
			 O_O_DS2_FPU_OPR1, O_O_DS2_FPU_OPR2 : out std_logic_vector(31 downto 0);
			 O_O_DS2_FPU_VAL, O_O_DS2_FPU_OPR1_VAL, O_O_DS2_FPU_OPR2_VAL : out std_logic ;
			
			 -- OUTPUTS FROM RS --
			 O_FPU_OPR1, O_FPU_OPR2 :out std_logic_vector(31 downto 0) ;
			 O_RS_FPU_DEST_REG :out std_logic_vector(N_LOG_RR-1 downto 0) ;
			 O_N_INSTR_IN_STN : out std_logic_vector(3 downto 0);
			 
			 -- OUTPUTS FROM FPU--
			 O_FPU_RESULT    : out std_logic_vector(31 downto 0);
			 O_FPU_DEST_REG  : out std_logic_vector(N_LOG_RR-1 downto 0);
			 O_FPU_INSTR_VAL : out std_logic;
			 
			 -- OUTPUTS FROM BR --
			 O_BR_RESULT    : out std_logic_vector(31 downto 0);
			 O_BR_DEST_REG  : out std_logic_vector(N_LOG_RR-1 downto 0);
			 O_BR_INSTR_VAL : out std_logic;			 
			 
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
			 O_TEMP_RS1_BUSY_BITS, O_TEMP_RS1_READY_BITS : out std_logic_vector(7 downto 0);
			 O_TEMP_ROB_L1 , O_TEMP_ROB_L2 : out std_logic_vector( N_LOG_ROB-1 downto 0 ) ;
			 O_TEMP_ROB_WR1, O_TEMP_ROB_WR2 : out std_logic;
			 O_TEMP_ROB_RR1, O_TEMP_ROB_RR2 : out std_logic_vector(N_LOG_RR-1 downto 0);
			 O_TEMP_ROB_AR1, O_TEMP_ROB_AR2 : out std_logic_vector(N_LOG_AR-1 downto 0);

			 -- ROB --
			 O_ROB_HEAD : out std_logic_vector(N_LOG_ROB - 1 downto 0);
			 O_ROB_LAST : out std_logic_vector(N_LOG_ROB - 1 downto 0);
			 O_BRTAG: out ROB_BrTAG_COLUMN;
			 O_ROB_FULL, O_STORE_COMMIT: out std_logic;
			 O_STORE_LOC_BUFF: out std_logic_vector(Buffersize - 1 downto 0);
			 O_FLUSH, O_SPEC, O_VALID: out std_logic_vector(2**N_LOG_ROB - 1 downto 0);
			 
			 -- DISPATCH --
			 O_ARF 		:	out	T_ARCH_REGFILE ;
			 O_RRF 		:	out	T_RNME_REGFILE ;
			 O_ARF_TAG  : 	out	T_ARF_TAG ;
			 O_RR_BUSY  :  out std_logic_vector(N_RNME_REG-1 downto 0); 
			 
			 -- STORE BUFFER OUTPUTS --
			 O_STORE_WRITE: out std_logic;
			 O_STORE_DATA: out std_logic_vector(31 downto 0);
			 O_STORE_MEM_ADDR: out std_logic_vector(31 downto 0);
			 O_STOREBUFF_FREE_LOC: out std_logic_vector(Buffersize - 1 downto 0);
			 
			 
			 -- MISC OUTPUTS
			 O_FPU_ROB_LOC_OUT, O_DREG_ROB_LOC, O_TEMP_DS1_FPU_ROB_LOC,O_TEMP_DS2_FPU_ROB_LOC : out std_logic_vector(N_LOG_ROB-1 downto 0) ;
			 O_BR_ROB_LOC_OUT, O_BR_DREG_ROB_LOC, O_TEMP_DS1_BR_ROB_LOC,O_TEMP_DS2_BR_ROB_LOC : out std_logic_vector(N_LOG_ROB-1 downto 0) ;
			 O_I1_VAL , O_I2_VAL : out std_logic ;
			 O_O_DS1_FPU_RR , O_O_DS2_FPU_RR : out std_logic_vector(N_LOG_RR-1 downto 0);
			 O_O_DS1_BR_RR , O_O_DS2_BR_RR : out std_logic_vector(N_LOG_RR-1 downto 0)
		) ;
	
end;
