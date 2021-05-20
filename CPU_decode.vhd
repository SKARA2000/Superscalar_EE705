library ieee;
use ieee.std_Logic_1164.all;

package PKG_StoreBuf is
	constant MemSize: integer := 32;
	constant OprSize: integer := 32;
	constant BufferSize: integer := 4;
	
	type Buffer_COL is array(0 to 2**BufferSize - 1) of std_Logic_vector((MemSize + OprSize ) downto 0);
	
end package PKG_StoreBuf;

library ieee;
use ieee.std_logic_1164.all;

package PKG_COMMON is

constant PC_LEN: integer := 32;
constant address_bit: integer := 32;
constant ram_size	: integer := 100000;
constant data_bit 		: integer := 32;

constant N_ARCH_REG : integer := 32;
constant N_RNME_REG : integer := 32;
constant N_OPCODE_BITS : integer := 6;
constant N_SHAMT_BITS : integer := 5;
constant N_FUNC_BITS : integer := 6;
constant N_CTRL_BITS : integer := 27;

constant N_ENTRIES_FPU_RS 	: integer := 8;
constant N_TAG_BITS 	: integer := 5 ;
constant N_LOC_BITS  : integer := 3 ;
	
constant N_LOG_AR : integer := 5 ;
constant N_LOG_RR : integer := 5 ;
constant N_LOG_ROB : integer := 7;
constant N_Br_TAG : integer := 4;

constant N_BR_BITS_FOR_RS : integer := 10;
	
type T_ARCH_REGFILE is array (0 to N_ARCH_REG-1) of std_logic_vector(31 downto 0);
type T_RNME_REGFILE is array (0 to N_RNME_REG-1) of std_logic_vector(31 downto 0);
type T_ARF_TAG is array (0 to N_ARCH_REG-1) of std_logic_vector(N_LOG_RR-1 downto 0);
type T_RNME_REG_PTR is array (0 to 2) of std_logic_vector(N_LOG_RR - 1 downto 0);

type T_ARR4_SLV2 is array(0 to 3) of std_logic_vector(1 downto 0);
type T_ARR4_SLV4 is array(0 to 3) of std_logic_vector(3 downto 0);
type T_ARR4_SLV_TAG is array(0 to 3) of std_logic_vector(N_LOG_RR-1 downto 0);
type T_ARR4_SLV32 is array(0 to 3) of std_logic_vector(31 downto 0);

type T_ARR32_SLV5 is array (0 to 31) of std_logic_vector(4 downto 0);
type T_ARR32_SLV32 is array(0 to 31) of std_logic_vector(31 downto 0);
type T_ARR4_SLV_LOC is array(0 to 3) of std_logic_vector(N_LOG_ROB-1 downto 0);

type t_arrN_slv32 is array(0 to N_ENTRIES_FPU_RS - 1) of std_logic_vector(31 downto 0); 
type t_arrN_slvN  is array(0 to N_ENTRIES_FPU_RS - 1) of std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);  
type t_arrN_slvC  is array(0 to N_ENTRIES_FPU_RS - 1) of std_logic_vector(N_CTRL_BITS-1 downto 0);   
	
type t_arr3_slvLoc is array (0 to 2) of std_logic_vector(N_LOC_BITS downto 0);
	
type t_arrN_slvInstr is array(0 to N_ENTRIES_FPU_RS - 1) of std_logic_vector(N_OPCODE_BITS+N_SHAMT_BITS+N_FUNC_BITS-1 downto 0); 
	
-- For forwarding slots
type t_arrData_slv is array (3 downto 0) of std_logic_vector(31 downto 0);
type t_arrTag_slv is array (3 downto 0) of std_logic_vector(N_LOG_RR-1 downto 0);
type t_arrN_slvRr is array (0 to N_ENTRIES_FPU_RS - 1) of std_logic_vector(N_LOG_RR-1 downto 0);   

-- OPCODES --
constant OPCODE_ALU : std_logic_vector(5 downto 0) := "000000" ;
constant OPCODE_FPU : std_logic_vector(5 downto 0) := "000101" ;
constant OPCODE_MEM : std_logic_vector(5 downto 0) := "110011" ;
constant OPCODE_BRN : std_logic_vector(5 downto 0) := "001100" ;

-- For Fetch Unit
type CODE_MEM is array(0 to 2**(PC_LEN/4) - 1) of std_logic_vector(31 downto 0);
type TABLE is array(0 to 2**N_Br_TAG - 1) of std_logic_vector(63 downto 0);	

-- DTYPES FOR ROB --
constant N_ENTRIES_ROB : integer := 128;
type ROB_PC_COLUMN 		is array(N_ENTRIES_ROB-1 downto 0) of std_logic_vector(31 downto 0);
type ROB_LOC_COLUMN 		is array(N_ENTRIES_ROB-1 downto 0) of std_logic_vector(N_LOG_ROB-1 downto 0);
type ROB_BrTAG_COLUMN 	is array(N_ENTRIES_ROB-1 downto 0) of std_logic_vector(3 downto 0);
type ROB_TAG_COLUMN 		is array(N_ENTRIES_ROB-1 downto 0) of std_logic_vector(N_LOG_RR-1 downto 0);

-- Control Bits --
	-- CTRL : ALU_instr FP_instr Mem_instr Br_instr R_type Imm_type RegWrite RegDst RegInSrc ALUSrc Add_sub Logic_ctrl alu_outp_control shift_control Fp_mul/add DataRead DataWrite BrType PCSrc 
	--  27      1          1        1         1        1       1       1       2       2        1       1        2            3              2            1         1         1        2     2    

constant IND_ALU_INSTR : integer := 26;
constant IND_FPU_INSTR : integer := 25;
constant IND_MEM_INSTR : integer := 24;
constant IND_BRN_INSTR : integer := 23;

constant IND_REG_AM : integer := 22;
constant IND_IMM_AM : integer := 21;

constant IND_REG_WR : integer:= 20;
constant IND_FPU_AM : integer:= 6;
 
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG_COMMON.all;
use work.PKG_StoreBuf.all;

entity	CPU is
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
			 O_RS_MEM_VAL		    : out std_logic;
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
			 O_STOREBUFF_FREE_LOC	: out std_logic_vector(Buffersize - 1 downto 0);
			 
			 -- RS2 outputs --
			 O_RS2_N_RS_ALU : out std_logic_vector(N_LOC_BITS downto 0);
			 O_RS2_ALU_ROB_LOC_IN : out std_logic_vector(N_LOG_ROB-1 downto 0);
			 O_RS2_ALU_DEST_REG : out std_logic_vector(N_LOG_RR-1 downto 0);
			 O_RS2_ALU_INSTR_VALID : out std_logic	;
			 O_FLUSH1 , O_FLUSH2 : out std_logic ;
			 O_ROB_BR_RES, O_ROB_BR_VAL: out std_Logic
		) ;
end entity;

architecture ARCH1 of CPU is
--			 -- FORWARDED INPUTS --
--signal TAG_FWD_SLOT : in T_ARR4_SLV_TAG ;
--signal FWD_SLOT_VAL : in std_logic_vector(3 downto 0);
--signal I_OPR_FWD_SLOT : in T_ARR4_SLV32 ;   

component FETCH is 
	port(
		CLK: in std_logic;
		RST: in std_logic;
	
		--Code Memory; Needs to be written in PKG_COMMON
		MEM: in CODE_MEM;
		
		-- Inputs from the Decode Stage
		I_TAG_EXEC1, I_TAG_EXEC2: in std_logic_vector(N_LOG_RR - 1 downto 0);
		I_VAL_EXEC1, I_VAL_EXEC2: in std_logic;
		I_PC_EXEC1, I_PC_EXEC2: in std_logic_vector(31 downto 0); 
		I_HIST_IND_EXEC1, I_HIST_IND_EXEC2: in std_logic_vector(N_Br_TAG - 1 downto 0);
		
		-- Inputs from the Branch Execution Unit
		I_TAG_EXEC3: in std_logic_vector(N_LOG_RR - 1 downto 0);
		I_VAL_EXEC3: in std_logic;
		I_PC_EXEC3: in std_logic_vector(31 downto 0); 
		I_HIST_IND_EXEC3: in std_logic_vector(N_Br_TAG - 1 downto 0);
		
		-- Outputs to the Decode Buffer and itself
		O_NEXT_PC1, O_NEXT_PC2: out std_logic_vector(31 downto 0);
		O_I1_HIST_IND, O_I2_HIST_IND: out std_logic_vector(N_Br_TAG - 1 downto 0);
		O_INST1, O_INST2: out std_logic_vector(31 downto 0);
		O_PREDICTION1, O_PREDICTION2: out std_logic; -- '1' if branch taken, '0' if not taken
		
		--Debugging purpose
		O_HIST_TABLE: out TABLE
	);
end component;


component decode is
port(
	CLK, RST						: in std_logic;
	I_PC1, I_PC2 					: in std_logic_vector(31 downto 0);
	I_I1_HIST_IND, I_I2_HIST_IND	: in std_logic_vector(N_Br_TAG - 1 downto 0);
	INSTR1, INSTR2 					: in std_logic_vector(31 downto 0);
	I_pred_bit1, I_pred_bit2 		: in std_logic;
	I_Branch_Valid 					: in std_logic;
	I_Branch_Result 				: in std_logic;
	I_Branch_tag 					: in std_logic_vector(N_Br_TAG-1 downto 0);
	
	O_PC1, O_PC2 					: out std_logic_vector(31 downto 0);
	O_OPCODE1, O_OPCODE2 			: out std_logic_vector(N_OPCODE_BITS-1 downto 0);
	O_FUNC1, O_FUNC2 				: out std_logic_vector(N_FUNC_BITS-1 downto 0);
	O_SHAMT1, O_SHAMT2 				: out std_logic_vector(N_SHAMT_BITS-1 downto 0);
	O_I1_REG1, O_I1_REG2 			: out std_logic_vector(N_LOG_AR-1 downto 0 );
	O_I2_REG1, O_I2_REG2 			: out std_logic_vector(N_LOG_AR-1 downto 0 );
	O_I1_DEST, O_I2_DEST 			: out std_logic_vector(N_LOG_AR-1 downto 0 );
	O_I1_Valid, O_I2_Valid 			: out std_logic;
	O_CTRL1, O_CTRL2 				: out std_logic_vector(N_CTRL_BITS-1 downto 0);
	-- CTRL : ALU_instr FP_instr Mem_instr Br_instr R_type Imm_type RegWrite RegDst RegInSrc ALUSrc Add_sub Logic_ctrl alu_outp_control shift_control Fp_mul/add DataRead DataWrite BrType PCSrc 
	--  27      1          1        1         1        1       1       1       2       2        1       1        2            3              2            1         1         1        2     2    
	speculative_bit1, speculative_bit2 					: out std_logic;
	O_pred_bit1, O_pred_bit2 							: out std_logic;
	branch_tag1, branch_tag2							: out std_logic_vector(N_Br_TAG-1 downto 0);
	O_IMM1, O_IMM2										: out std_logic_vector(31 downto 0);
	O_I1_HIST_IND, O_I2_HIST_IND 						: out std_logic_vector(N_Br_TAG - 1 downto 0);
	O_I1_DEC_FETCH_HIST_IND, O_I2_DEC_FETCH_HIST_IND	: out std_logic_vector(N_Br_TAG - 1 downto 0);
	O_FETCH_DEC_pred_bit1, O_FETCH_DEC_pred_bit2		: out std_logic;	
	jump_valid1, jump_valid2 							: out std_logic;
	jump_addr1, jump_addr2 								: out std_logic_vector(31 downto 0));
	
end component;


component DISPATCH_STAGE is
	port ( 
			 CLK, RST : in std_logic;
			 -- INPUTS FROM DECODE STAGE --
			 -- opcodes, shift and functional bits --
			 I_OPCODE1, I_OPCODE2 : in std_logic_vector(N_OPCODE_BITS-1 downto 0);
			 I_FUNC1, I_FUNC2		 : in std_logic_vector(N_FUNC_BITS-1 downto 0);
			 I_SHAMT1, I_SHAMT2   : in std_logic_vector(N_SHAMT_BITS-1 downto 0);
			 
			 -- control signals
			 I_CTRL1, I_CTRL2     : in std_logic_vector(N_CTRL_BITS-1 downto 0);
			 
			 -- valid bits
			 I_I1_VAL, I_I2_VAL   : in std_logic;
			 
			 -- Branch bits --
			 I_I1_BR_FIELD, I_I2_BR_FIELD : in std_logic_vector( N_BR_BITS_FOR_RS-1 downto 0 );
			 
			 -- program counter 
			 I_PC1, I_PC2 : in std_logic_vector( 31 downto 0 );
			 
			 -- ARCHITECTURAL REGISTERS --
			 I_I1_REG1, I_I1_REG2 : in std_logic_vector(N_LOG_AR-1 downto 0 );
			 I_I2_REG1, I_I2_REG2 : in std_logic_vector(N_LOG_AR-1 downto 0 );
			 I_I1_DEST, I_I2_DEST : in std_logic_vector(N_LOG_AR-1 downto 0 );
			 
			 -- Immediate operands --
			 I_I1_IMM_OPR, I_I2_IMM_OPR : in std_logic_vector( 31 downto 0 ); 
		 
			 -- FORWARDED INPUTS --
			 --I_TAG_FWD_SLOT : in T_ARR4_SLV_TAG ;
			 I_TAG_FWD_SLOT : in T_ARR4_SLV_TAG ;
			 I_FWD_SLOT_VAL : in std_logic_vector(3 downto 0);
			 I_OPR_FWD_SLOT : in T_ARR4_SLV32 ;   
			 
			 --------------------------------
			 -- INPUTS FROM REORDER BUFFER --
			 --------------------------------
			 -- 2 free locations in ROB
			 I_ROB_FREE_LOC1, I_ROB_FREE_LOC2 : in std_logic_vector( N_LOG_ROB - 1 downto 0) ;	
			 
			 -- write enable signals for ARF
			 I_ROB_REG_WR1, I_ROB_REG_WR2 : in std_logic; 
			 
			 -- rename reg ids 
			 I_ROB_RNME_REG1, I_ROB_RNME_REG2 : in std_logic_vector( N_LOG_RR-1 downto 0 );
			 
			 -- arch reg ids 
			 I_ROB_ARCH_REG1, I_ROB_ARCH_REG2 : in std_logic_vector( N_LOG_AR-1 downto 0 );
			 
			 -- Branch info from ROB
			 I_ROB_BR_VAL, I_BR_RES : in std_logic ;
			 I_ROB_BR_TAG : in std_logic_vector(3 downto 0);
			 
			 -- Flush, Spec bits from ROB
			 I_ROB_FLUSH1, I_ROB_FLUSH2 : in std_logic;

			 -- COMMON OUTPUTS TO RESERVATION STATION --
			 O_DS_ALL_IMM_OPR1, O_DS_ALL_IMM_OPR2 : out std_logic_vector(31 downto 0);
			 
			 -- OUTPUTS TO RESERVATION STATION --
			
			 --- ALU ---	
			 O_DS1_ALU_OPR1, O_DS1_ALU_OPR2 : out std_logic_vector(31 downto 0);
			 O_DS1_ALU_VAL, O_DS1_ALU_OPR1_VAL, O_DS1_ALU_OPR2_VAL : out std_logic ;
			 O_DS1_ALU_ROB_LOC   : out std_logic_vector(N_LOG_ROB-1 downto 0);
			 O_DS1_ALU_INSTR : out std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
			 O_DS1_ALU_CTRL  : out std_logic_vector(N_CTRL_BITS -1 downto 0);
			 O_DS1_ALU_RR    : out std_logic_vector(N_LOG_RR-1 downto 0);
			 
			 O_DS2_ALU_OPR1, O_DS2_ALU_OPR2 : out std_logic_vector(31 downto 0);
			 O_DS2_ALU_VAL, O_DS2_ALU_OPR1_VAL, O_DS2_ALU_OPR2_VAL : out std_logic ;
			 O_DS2_ALU_ROB_LOC   : out std_logic_vector(N_LOG_ROB-1 downto 0);
			 O_DS2_ALU_INSTR : out std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
			 O_DS2_ALU_CTRL  : out std_logic_vector(N_CTRL_BITS -1 downto 0);
			 O_DS2_ALU_RR    : out std_logic_vector(N_LOG_RR-1 downto 0);
			 
			 --- FPU ---
			 O_DS1_FPU_OPR1, O_DS1_FPU_OPR2 : out std_logic_vector(31 downto 0);
			 O_DS1_FPU_VAL, O_DS1_FPU_OPR1_VAL, O_DS1_FPU_OPR2_VAL : out std_logic ;
			 O_DS1_FPU_ROB_LOC   : out std_logic_vector(N_LOG_ROB-1 downto 0);
			 O_DS1_FPU_INSTR : out std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
			 O_DS1_FPU_CTRL  : out std_logic_vector(N_CTRL_BITS-1 downto 0);
			 O_DS1_FPU_RR    : out std_logic_vector(N_LOG_RR-1 downto 0);
			 
			 O_DS2_FPU_OPR1, O_DS2_FPU_OPR2 : out std_logic_vector(31 downto 0);
			 O_DS2_FPU_VAL, O_DS2_FPU_OPR1_VAL, O_DS2_FPU_OPR2_VAL : out std_logic ;
			 O_DS2_FPU_ROB_LOC   : out std_logic_vector(N_LOG_ROB-1 downto 0) ;
			 O_DS2_FPU_INSTR : out std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
			 O_DS2_FPU_CTRL  : out std_logic_vector(N_CTRL_BITS-1 downto 0);
			 O_DS2_FPU_RR    : out std_logic_vector(N_LOG_RR-1 downto 0);
			 
			 -- BRN --
			 O_DS1_BRN_OPR1, O_DS1_BRN_OPR2 : out std_logic_vector(31 downto 0);
			 O_DS1_BRN_VAL, O_DS1_BRN_OPR1_VAL, O_DS1_BRN_OPR2_VAL : out std_logic ;
			 O_DS1_BRN_ROB_LOC   : out std_logic_vector(N_LOG_ROB-1 downto 0);
			 O_DS1_BRN_INSTR : out std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
			 O_DS1_BRN_CTRL  : out std_logic_vector(N_CTRL_BITS-1 downto 0);
			 O_DS1_BRN_RR    : out std_logic_vector(N_LOG_RR-1 downto 0);
			 
			 O_DS2_BRN_OPR1, O_DS2_BRN_OPR2 : out std_logic_vector(31 downto 0);
			 O_DS2_BRN_VAL, O_DS2_BRN_OPR1_VAL, O_DS2_BRN_OPR2_VAL : out std_logic ;
			 O_DS2_BRN_ROB_LOC   : out std_logic_vector(N_LOG_ROB-1 downto 0) ;
			 O_DS2_BRN_INSTR : out std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
			 O_DS2_BRN_CTRL  : out std_logic_vector(N_CTRL_BITS-1 downto 0);
			 O_DS2_BRN_RR    : out std_logic_vector(N_LOG_RR-1 downto 0);

			 -- MEM --
			 O_DS1_MEM_OPR1, O_DS1_MEM_OPR2 : out std_logic_vector(31 downto 0);
			 O_DS1_MEM_VAL, O_DS1_MEM_OPR1_VAL, O_DS1_MEM_OPR2_VAL : out std_logic ;
			 O_DS1_MEM_ROB_LOC   : out std_logic_vector(N_LOG_ROB-1 downto 0);
			 O_DS1_MEM_INSTR : out std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
			 O_DS1_MEM_CTRL  : out std_logic_vector(N_CTRL_BITS-1 downto 0);
			 O_DS1_MEM_RR    : out std_logic_vector(N_LOG_RR-1 downto 0);
			 
			 O_DS2_MEM_OPR1, O_DS2_MEM_OPR2 : out std_logic_vector(31 downto 0);
			 O_DS2_MEM_VAL, O_DS2_MEM_OPR1_VAL, O_DS2_MEM_OPR2_VAL : out std_logic ;
			 O_DS2_MEM_ROB_LOC   : out std_logic_vector(N_LOG_ROB-1 downto 0) ;
			 O_DS2_MEM_INSTR : out std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
			 O_DS2_MEM_CTRL  : out std_logic_vector(N_CTRL_BITS-1 downto 0);
			 O_DS2_MEM_RR    : out std_logic_vector(N_LOG_RR-1 downto 0);
			 
			 -- OUTPUTS TO REORDER BUFFER --
			 O_PC1, O_PC2 : out std_logic_vector( 31 downto 0 );
			 O_I1 , O_I2 : out std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);			 			 
			 O_I1_CTRL, O_I2_CTRL : out std_logic_vector(N_CTRL_BITS - 1 downto 0);			 
			 O_I1_VALID, O_I2_VALID : out std_logic ;			 
			 O_I1_ARCH_REG, O_I2_ARCH_REG : out std_logic_vector(N_LOG_AR-1 downto 0) ;
			 O_I1_RNME_REG, O_I2_RNME_REG : out std_logic_vector(N_LOG_RR-1 downto 0);


			 -- OUTPUTS TO REORDER BUFFER --
			 O_ROB_PC1, O_ROB_PC2 : out std_logic_vector( 31 downto 0 );
			 O_ROB_I1 , O_ROB_I2 : out std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);			 			 
			 O_ROB_I1_CTRL, O_ROB_I2_CTRL : out std_logic_vector(N_CTRL_BITS - 1 downto 0);			 
			 O_ROB_I1_VALID, O_ROB_I2_VALID : out std_logic ;			 
			 O_ROB_I1_ARCH_REG, O_ROB_I2_ARCH_REG : out std_logic_vector(N_LOG_AR-1 downto 0) ;
			 O_ROB_I1_RNME_REG, O_ROB_I2_RNME_REG : out std_logic_vector(N_LOG_RR-1 downto 0);
			 O_ROB_I1_BR_FIELD, O_ROB_I2_BR_FIELD : out std_logic_vector( N_BR_BITS_FOR_RS-1 downto 0 );
			 
			 -- Branch bits --
			 O_I1_BR_FIELD, O_I2_BR_FIELD : out std_logic_vector( N_BR_BITS_FOR_RS-1 downto 0 );
			 
			 
			 -- OUTPUTS TO FETCH AND DECODE --
			 O_STALL : out std_logic ;
			 
			 -- TEMP OUTPUTS --
			 O_RR1_VAL, O_RR2_VAL : out std_logic ;
			 O_RNME_REG_BUSY, O_RNME_REG_VALID,O_ARCH_REG_LOCK : out std_logic_vector(31 downto 0);
			 O_ARF 		:	out	T_ARCH_REGFILE ;
			 O_RRF 		:	out	T_RNME_REGFILE ;
			 O_ARF_TAG  : 	out	T_ARF_TAG ;
			 O_RR_BUSY  :  out std_logic_vector( N_RNME_REG-1 downto 0 )
		);	
			 
end component; 

component RESERVATION_STN is
port ( 
			CLK, RST   		: in std_logic;
			
			-- Dispatch Slots
			D_SLOT_VALID 	: in std_logic_vector(2 downto 0) ;
			DS1_INSTR, DS2_INSTR, DS3_INSTR : in std_logic_vector(N_OPCODE_BITS+N_SHAMT_BITS+N_FUNC_BITS-1 downto 0);
			
			DS1_OPR1, DS1_OPR2, DS2_OPR1, DS2_OPR2, DS3_OPR1, DS3_OPR2 	: in std_logic_vector(31 downto 0);
			DS1_OPR3, DS2_OPR3, DS3_OPR3 : in std_logic_vector(31 downto 0);
			
			DS1_OPR1_VAL, DS1_OPR2_VAL, DS2_OPR1_VAL, DS2_OPR2_VAL, DS3_OPR1_VAL, DS3_OPR2_VAL : in std_logic ;
			DS1_CTRL, DS2_CTRL, DS3_CTRL	: in std_logic_vector(N_CTRL_BITS-1 downto 0);
			DS1_DEST, DS2_DEST, DS3_DEST  : in std_logic_vector(N_LOG_RR-1 downto 0);
			DS1_ROB_LOC, DS2_ROB_LOC, DS3_ROB_LOC : in std_logic_vector(N_LOG_ROB-1 downto 0);
			DS1_SPEC_BrTAG_PRED, DS2_SPEC_BrTAG_PRED, DS3_SPEC_BrTAG_PRED	: in std_logic_vector(N_BR_BITS_FOR_RS-1 downto 0) ;
			
			-- Forwarding slots
			DATA_FWD_SLOT1, DATA_FWD_SLOT2, DATA_FWD_SLOT3, DATA_FWD_SLOT4 : in std_logic_vector(31 downto 0);  
			TAG_FWD_SLOT1, TAG_FWD_SLOT2, TAG_FWD_SLOT3, TAG_FWD_SLOT4 : in std_logic_vector(N_TAG_BITS-1 downto 0);  
			VAL_FWD_SLOTS : in std_logic_vector(3 downto 0);
			
			-- From ROB --
			I_ROB_FLUSH, I_ROB_SPEC : in std_logic_vector(127 downto 0);
			
			-- Outputs
			DREG_OPR1, DREG_OPR2, DREG_OPR3 : out std_logic_vector(31 downto 0);
			DREG_CTRL 				: out std_logic_vector(N_CTRL_BITS-1 downto 0); 	
			DREG_INSTR				: out std_logic_vector(N_OPCODE_BITS+N_SHAMT_BITS+N_FUNC_BITS-1 downto 0);
			DREG_DEST 			   : out std_logic_vector(N_LOG_RR-1 downto 0);
			DREG_ROB_LOC			: out std_logic_vector(N_LOG_ROB-1 downto 0);
			DREG_BR_FIELD			: out std_logic_vector(N_BR_BITS_FOR_RS-1 downto 0);
			
			RS_OUTPUT_VALID      : out std_logic;	
			
			-- TEMP OUTPUTS --
			TEMP_N_INSTR_IN_STN   : out std_logic_vector(N_LOC_BITS downto 0);
			TEMP_ALLOC_BITS : out std_logic_vector(3 downto 0); 
			TEMP_BUSY_BITS, TEMP_READY_BITS : out std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);
			TEMP_ISEQ3, TEMP_ISEQ2 , TEMP_ISEQ1, TEMP_ISEQ0 : out std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);
			TEMP_LOC1, TEMP_LOC2, TEMP_LOC3 : out std_logic_vector(N_LOC_BITS downto 0)

			);
end component;

component FPU is
	port ( 
				CLK, RST 		: in std_logic;
				
				IN_CTRL  		: in std_logic_vector(N_CTRL_BITS-1 downto 0);
				
				IN_INSTR    	: in std_logic_vector(N_OPCODE_BITS + N_SHAMT_BITS + N_FUNC_BITS - 1 downto 0);
				IN_DEST_REG  	: in std_logic_vector(N_LOG_RR - 1 downto 0 );
				IN_INSTR_VAL   : in std_logic;
				IN_ROB_LOC     : in std_logic_vector(N_LOG_ROB-1 downto 0);
				
				FPU_A, FPU_B   : in std_logic_vector (31 downto 0);
				
				O_RESULT     	: out std_logic_vector (31 downto 0); 
				
				O_RES_VAL 		: out std_logic ;
				O_DEST_REG 		: out std_logic_vector(N_LOG_RR-1 downto 0);
				O_ROB_LOC  		: out std_logic_vector(N_LOG_ROB-1 downto 0)
				
			);
	
end component;	

component ALU is
	port(
		inp1: in std_logic_vector(31 downto 0);
		inp2: in std_logic_vector(31 downto 0);
		shift_amt: in std_logic_vector(4 downto 0);
		ALU_instr_control: in std_logic;
		logic_control: in std_logic_vector(1 downto 0);
		shift_control: in std_logic_vector(1 downto 0);
		alu_outp_control: in std_logic_vector(2 downto 0);
		add_sub: in std_logic;
		outp: out std_logic_vector(31 downto 0);
		ovfl: out std_logic;
		carr_ovfl: out std_logic;
		zero: out std_logic;
		Valid: out std_logic;
		location_inp: in std_logic_vector(N_LOG_ROB - 1 downto 0);
		RR_inp: in std_logic_vector(N_LOG_RR - 1 downto 0);
		location: out std_logic_vector(N_LOG_ROB - 1 downto 0);
		RR: out std_logic_vector(N_LOG_RR - 1 downto 0)
	);
end component;
	 
component ROB is 
	port(
		CLK, RST: in std_logic;
		
		--Inputs from Dispatch stage
		I_PC1, I_PC2: in std_logic_vector(31 downto 0);
		I_I1, I_I2: in std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
		I_I1_CTRL, I_I2_CTRL: in std_logic_vector(N_CTRL_BITS - 1 downto 0);
		I_I1_VALID, I_I2_VALID: in std_logic;
		I_I1_SPEC, I_I2_SPEC: in std_logic;
		I_I1_BrTAG, I_I2_BrTAG: in std_logic_vector(N_Br_TAG -1 downto 0);
		I_I1_ARCH_REG, I_I2_ARCH_REG: in std_logic_vector(N_LOG_AR - 1 downto 0);
		I_I1_RNME_REG, I_I2_RNME_REG: in std_logic_vector(N_LOG_RR - 1 downto 0);
		
		--Inputs from the Common Data Bus
		I_TAG_EXEC: in T_ARR4_SLV_TAG;
		I_LOC_EXEC: in T_ARR4_SLV_LOC;
		I_VAL_EXEC: in std_logic_vector(0 to 3);
		I_OPR_EXEC: in T_ARR4_SLV32;
		I_HIST_IND_EXEC: in std_logic_vector(N_Br_TAG - 1 downto 0);
		I_BR_PC_EXEC: in std_logic_vector(31 downto 0);		
		I_STORE_BUFF_IND: in std_logic_vector(BufferSize - 1 downto 0);
		I_SW_VALID: in std_logic;		
		
		--Outputs to dispatch stage
		O_ROB_FREE_LOC1, O_ROB_FREE_LOC2: out std_logic_vector(N_LOG_ROB - 1 downto 0);
		O_ROB_REG_WR1, O_ROB_REG_WR2: out std_logic;
		O_ROB_REG_FLUSH1, O_ROB_REG_FLUSH2: out std_logic;		
		O_ROB_RNME_REG1, O_ROB_RNME_REG2: out std_logic_vector(N_LOG_RR - 1 downto 0);
		O_ROB_ARCH_REG1, O_ROB_ARCH_REG2: out std_logic_vector(N_LOG_AR - 1 downto 0);
		
		--Outputs to Decode and Dispatch Unit
		O_ROB_HIST_IND_EXEC: out std_logic_vector(N_Br_TAG - 1 downto 0);
		O_ROB_BR_PC_EXEC: out std_logic_vector(31 downto 0);		
		O_ROB_DEC_VAL, O_ROB_DEC_BR_RES: out std_logic;
		O_ROB_DEC_TAG: out std_logic_vector(N_Br_TAG - 1 downto 0);	
		
		--Outputs to store buffer
		O_STORE_COMMIT: out std_logic;
		O_LOC_BUFF: out std_logic_vector(BufferSize - 1 downto 0);
		
		--Maintenance Outputs
		O_FULL: out std_logic;
		
		--For debugging purposes
		O_head: out std_logic_vector(N_LOG_ROB - 1 downto 0);
		O_last: out std_logic_vector(N_LOG_ROB - 1 downto 0);
		O_BRTAG: out ROB_BrTAG_COLUMN;
		O_FLUSH, O_SPEC, O_VALID: out std_logic_vector(2**N_LOG_ROB - 1 downto 0)
	);
end component;

component BRANCH is
	port(
		CLK: in std_logic;
		
		--Input operands from the Reservation Station
		I_VALID: in std_logic;
		I_OPR1: in std_logic_vector(31 downto 0);
		I_OPR2: in std_logic_vector(31 downto 0);
		I_OPR3: in std_logic_vector(31 downto 0);
		I_CTRL_BITS: in std_logic_vector(N_CTRL_BITS - 1 downto 0);
		I_PREDICTION: in std_logic; -- 1 if branch taken, 0 if not taken
		
		--Utility Inputs from the reservation station
		I_LOC: in std_logic_vector(N_LOG_ROB - 1 downto 0);
		I_BrTAG: in std_logic_vector(N_Br_TAG - 1 downto 0);
		I_HIST_IND: in std_logic_vector(N_Br_TAG - 1 downto 0);
		
		--Outputs as a proper execution unit
		O_OUT_PC: out std_logic_vector(31 downto 0);
		O_HIST_IND: out std_logic_vector(N_Br_TAG - 1 downto 0);
		O_VAL_EXEC: out std_logic;
		O_TAG_EXEC: out std_logic_vector(N_LOG_RR - 1 downto 0);
		O_LOC_EXEC: out std_logic_vector(N_LOG_ROB - 1 downto 0)
	);
end component;
	
component memory is
	generic (address_bit 	: integer := 32;
				data_bit 		: integer := 32;
				N_CTRL_BITS 	: integer := 27;
				N_LOG_RR 		: integer := 5;
				BUFFER_SIZE 	: INTEGER := 4;
				N_LOG_ROB 		: integer := 7;
				ram_size		: integer := 2**9 - 1);
port(
		clk 					: in std_logic;
		rst						: in std_logic;		-- Shubham
		
		SB_Enable				: in std_logic;		-- Shubham
		SB_mem_add				: in std_logic_vector(data_bit -1 downto 0);		-- Shubham
		SB_Data					: in std_logic_vector(address_bit - 1 downto 0);		-- Shubham
		
--		memread 				: in std_logic;
--		memwrite 				: in std_logic;

		DREG_CTRL 				: in std_logic_vector(N_CTRL_BITS-1 downto 0); 
		DREG_DEST 			  	: in std_logic_vector(N_LOG_RR-1 downto 0);
		DREG_ROB_LOC			: in std_logic_vector(N_LOG_ROB-1 downto 0);
		RS_OUTPUT_VALID      	: in std_logic;

		operand0 				: in std_logic_vector(address_bit - 1 downto 0);	-- Rt
		operand1 				: in std_logic_vector(address_bit - 1 downto 0);	-- Rs
		operand2 				: in std_logic_vector(address_bit - 1 downto 0);	-- Imm
		
		in_freeloc 				: in std_logic_vector(BUFFER_SIZE-1 downto 0);
		out_freeloc 			: out std_Logic_vector(BUFFER_SIZE-1 downto 0);

--		writedata 				: in std_logic_vector(data_bit - 1 downto 0);
--		readdata 				: out std_logic_vector(data_bit - 1 downto 0);
		
		Data 					: out std_logic_vector(data_bit - 1 downto 0);
		
		mem_address 			: out std_logic_vector(address_bit - 1 downto 0);
		valid 					: out std_logic;
		sw_valid 				: out std_logic;
		reg_dest 				: out std_logic_vector(N_LOG_RR-1 downto 0);
		reg_rob_loc				: out std_logic_vector(N_LOG_ROB-1 downto 0));
		
end component;

component StoreBuffer is 
	port(
		CLK: in std_Logic;
		RST: in std_logic;
		
		-- Inputs from the Memory Execution Unit
		I_DATA: in std_Logic_vector(OprSize - 1 downto 0);
		I_MemAddr: in std_Logic_vector(MemSize - 1 downto 0);
		I_LOC_EXEC_Buff: in std_logic_vector(BufferSize - 1 downto 0);
		I_VAL: in std_Logic;
		I_SW_VAL: in std_logic;
		
		-- Inputs from the ROB
		I_StoreCommit: in std_Logic;
		I_LOC_Buff: in std_logic_vector(BufferSize - 1 downto 0);
		
		-- Outputs from the Store Buffer to Memory
		O_DATA: out std_logic_vector(OprSize - 1 downto 0);
		O_MemAddr: out std_logic_vector(MemSize - 1 downto 0);
		O_WR: out std_logic;
		
		-- Outputs from the Store Buffer to the Memory Unit
		O_FREE_LOC: out std_logic_vector(BufferSize - 1 downto 0)
	);	
end component;
			 -- COMMON OUTPUTS -- 
signal			 O_I1 , O_I2 :  std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);			 
signal			 O_I1_CTRL, O_I2_CTRL :  std_logic_vector(N_CTRL_BITS - 1 downto 0);
signal			 O_I1_VALID, O_I2_VALID :  std_logic ;
signal			 O_I1_RNME_REG, O_I2_RNME_REG :  std_logic_vector(N_LOG_RR-1 downto 0);
signal			 O_I1_OPR1, O_I1_OPR2, O_I2_OPR1, O_I2_OPR2 :  std_logic_vector(31 downto 0);
signal			 O_I1_OPR1_VALID, O_I1_OPR2_VALID, O_I2_OPR1_VALID, O_I2_OPR2_VALID :  std_logic;

			 -- OUTPUTS TO RESERVATION STATION --	
signal			 O_I1_ROB_LOC, O_I2_ROB_LOC :  std_logic_vector( N_LOG_ROB - 1 downto 0) ;
			 
			 -- OUTPUTS TO REORDER BUFFER --
signal			 O_PC1, O_PC2 :  std_logic_vector( 31 downto 0 );
signal			 O_I1_ARCH_REG, O_I2_ARCH_REG :  std_logic_vector(N_LOG_AR-1 downto 0) ;
			 
			 -- OUTPUTS TO FETCH AND DECODE --
signal			 O_STALL :  std_logic   ;
signal 			 O_RR1_VAL, O_RR2_VAL : std_logic;

-- Outputs of Dispatch --
-- ALU Dispatch --
signal O_DS1_ALU_OPR1, O_DS1_ALU_OPR2 :  std_logic_vector(31 downto 0);
signal O_DS1_ALU_VAL, O_DS1_ALU_OPR1_VAL, O_DS1_ALU_OPR2_VAL :  std_logic ;
signal O_DS1_ALU_ROB_LOC   :  std_logic_vector(N_LOG_ROB-1 downto 0);
signal O_DS1_ALU_INSTR :  std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
signal O_DS1_ALU_CTRL  :  std_logic_vector(N_CTRL_BITS -1 downto 0);
signal O_DS1_ALU_RR    :  std_logic_vector(N_LOG_RR-1 downto 0);
			 
signal O_DS2_ALU_OPR1, O_DS2_ALU_OPR2 :  std_logic_vector(31 downto 0);
signal O_DS2_ALU_VAL, O_DS2_ALU_OPR1_VAL, O_DS2_ALU_OPR2_VAL :  std_logic ;
signal O_DS2_ALU_ROB_LOC   :  std_logic_vector(N_LOG_ROB-1 downto 0);
signal O_DS2_ALU_INSTR :  std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
signal O_DS2_ALU_CTRL  :  std_logic_vector(N_CTRL_BITS -1 downto 0);
signal O_DS2_ALU_RR    :  std_logic_vector(N_LOG_RR-1 downto 0);

-- FPU Dispatch --			 
signal O_DS1_FPU_OPR1, O_DS1_FPU_OPR2 :  std_logic_vector(31 downto 0);
signal O_DS1_FPU_VAL, O_DS1_FPU_OPR1_VAL, O_DS1_FPU_OPR2_VAL :  std_logic ;
signal O_DS1_FPU_ROB_LOC   :  std_logic_vector(N_LOG_ROB-1 downto 0);
signal O_DS1_FPU_INSTR :  std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
signal O_DS1_FPU_CTRL  :  std_logic_vector(N_CTRL_BITS-1 downto 0);
signal O_DS1_FPU_RR    :  std_logic_vector(N_LOG_RR-1 downto 0);
			 
signal O_DS2_FPU_OPR1, O_DS2_FPU_OPR2 :  std_logic_vector(31 downto 0);
signal O_DS2_FPU_VAL, O_DS2_FPU_OPR1_VAL, O_DS2_FPU_OPR2_VAL :  std_logic ;
signal O_DS2_FPU_ROB_LOC   :  std_logic_vector(N_LOG_ROB-1 downto 0) ;
signal O_DS2_FPU_INSTR :  std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
signal O_DS2_FPU_CTRL  :  std_logic_vector(N_CTRL_BITS-1 downto 0);
signal O_DS2_FPU_RR    :  std_logic_vector(N_LOG_RR-1 downto 0);

-- BRN Dispatch --			 
signal O_DS1_BRN_OPR1, O_DS1_BRN_OPR2 :  std_logic_vector(31 downto 0);
signal O_DS1_BRN_VAL, O_DS1_BRN_OPR1_VAL, O_DS1_BRN_OPR2_VAL :  std_logic ;
signal O_DS1_BRN_ROB_LOC   :  std_logic_vector(N_LOG_ROB-1 downto 0);
signal O_DS1_BRN_INSTR :  std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
signal O_DS1_BRN_CTRL  :  std_logic_vector(N_CTRL_BITS-1 downto 0);
signal O_DS1_BRN_RR    :  std_logic_vector(N_LOG_RR-1 downto 0);
			 
signal O_DS2_BRN_OPR1, O_DS2_BRN_OPR2 :  std_logic_vector(31 downto 0);
signal O_DS2_BRN_VAL, O_DS2_BRN_OPR1_VAL, O_DS2_BRN_OPR2_VAL :  std_logic ;
signal O_DS2_BRN_ROB_LOC   :  std_logic_vector(N_LOG_ROB-1 downto 0) ;
signal O_DS2_BRN_INSTR :  std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
signal O_DS2_BRN_CTRL  :  std_logic_vector(N_CTRL_BITS-1 downto 0);
signal O_DS2_BRN_RR    :  std_logic_vector(N_LOG_RR-1 downto 0);

-- MEM SIgnals --
signal O_DS1_MEM_OPR1, O_DS1_MEM_OPR2 :  std_logic_vector(31 downto 0);
signal O_DS1_MEM_VAL, O_DS1_MEM_OPR1_VAL, O_DS1_MEM_OPR2_VAL :  std_logic ;
signal O_DS1_MEM_ROB_LOC   :  std_logic_vector(N_LOG_ROB-1 downto 0);
signal O_DS1_MEM_INSTR :  std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
signal O_DS1_MEM_CTRL  :  std_logic_vector(N_CTRL_BITS-1 downto 0);
signal O_DS1_MEM_RR    :  std_logic_vector(N_LOG_RR-1 downto 0);
			 
signal O_DS2_MEM_OPR1, O_DS2_MEM_OPR2 :  std_logic_vector(31 downto 0);
signal O_DS2_MEM_VAL, O_DS2_MEM_OPR1_VAL, O_DS2_MEM_OPR2_VAL :  std_logic ;
signal O_DS2_MEM_ROB_LOC   :  std_logic_vector(N_LOG_ROB-1 downto 0) ;
signal O_DS2_MEM_INSTR :  std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
signal O_DS2_MEM_CTRL  :  std_logic_vector(N_CTRL_BITS-1 downto 0);
signal O_DS2_MEM_RR    :  std_logic_vector(N_LOG_RR-1 downto 0);


signal O_RNME_REG_BUSY, O_RNME_REG_VALID,O_ARCH_REG_LOCK : std_logic_vector(31 downto 0) ;
signal FWD_DATA_VAL : std_logic_vector(3 downto 0);
signal FWD_OPERAND : T_ARR4_SLV32 ;
signal FWD_TAG     : T_ARR4_SLV_TAG ;

-- FPU SIGNALS --
signal FPU_DS_VAL, ALU_DS_VAL, BRN_DS_VAL : std_logic_vector(2 downto 0);
signal FPU_RES_VAL : std_logic;
signal FPU_INSTR   : std_logic_vector(N_OPCODE_BITS + N_SHAMT_BITS + N_FUNC_BITS -1 downto 0);
signal FPU_OPR1, FPU_OPR2, FPU_RESULT : std_logic_vector(31 downto 0);
signal FPU_DEST_REG, FPU_DEST_REG_OUT : std_logic_vector(N_LOG_RR-1 downto 0);
signal FPU_CTRL : std_logic_vector(N_CTRL_BITS-1 downto 0);
signal FPU_INSTR_VALID : std_logic;
signal FPU_ROB_LOC_IN, FPU_ROB_LOC_OUT : std_logic_vector(N_LOG_ROB-1 downto 0);

-- ALU SIGNALS --
signal ALU_OPR1, ALU_OPR2, ALU_RESULT : std_logic_vector(31 downto 0);
signal ALU_INSTR   : std_logic_vector(N_OPCODE_BITS + N_SHAMT_BITS + N_FUNC_BITS -1 downto 0);
signal ALU_INSTR_VALID : std_logic; 
signal ADD_SUB : std_logic;
signal OVERFLOW_FLG, CARRY_FLAG, ZERO_FLAG : std_logic ; 
signal ALU_RES_VAL : std_logic;
signal ALU_ROB_LOC_IN, ALU_ROB_LOC_OUT : std_logic_vector(N_LOG_ROB-1 downto 0);
signal ALU_DEST_REG, ALU_DEST_REG_OUT : std_logic_vector(N_LOG_RR-1 downto 0);
signal ALU_CTRL : std_logic_vector(N_CTRL_BITS-1 downto 0);
								
signal DUMMY32 : std_logic_vector(31 downto 0);

signal TMP_N_INSTR_IN_STN : std_logic_vector(N_LOC_BITS downto 0);
signal TEMP_BUSY_BITS, TEMP_READY_BITS : std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0);
signal TEMP_RS1_N_INSTR_IN_STN, TEMP_RS2_N_INSTR_IN_STN : std_logic_vector(N_LOC_BITS downto 0);

signal TEMP_RS1_BUSY_BITS, TEMP_RS2_BUSY_BITS, TEMP_RS1_READY_BITS, TEMP_RS2_READY_BITS : std_logic_vector(N_ENTRIES_FPU_RS-1 downto 0); 
signal S_BR_BITS, O1_BR_BITS, O2_BR_BITS : std_logic_vector( N_BR_BITS_FOR_RS-1 downto 0 );

signal S_I1_SPEC, S_I2_SPEC : std_logic ;
signal S_I1_BrTag, S_I2_BrTag : std_logic_vector(3 downto 0);
signal S_ROB_TAG_IN : T_ARR4_SLV_TAG;
signal S_ROB_LOC_IN : T_ARR4_SLV_LOC;
signal S_ROB_VAL_IN : std_logic_vector(0 to 3);
signal S_ROB_OPR_IN : T_ARR4_SLV32;

signal S_PC1, S_PC2 : std_logic_vector(31 downto 0);
signal S_I1, S_I2   : std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
signal S_I1_CTRL, S_I2_CTRL : std_logic_vector(N_CTRL_BITS-1 downto 0);
signal S_I1_VALID, S_I2_VALID : std_logic;
signal S_I1_ARCH_REG, S_ROB_ARCH_REG1, S_I2_ARCH_REG, S_ROB_ARCH_REG2 : std_logic_vector(N_LOG_AR-1 downto 0);
signal S_I1_RNME_REG, S_ROB_RNME_REG1, S_I2_RNME_REG, S_ROB_RNME_REG2 : std_logic_vector(N_LOG_RR-1 downto 0);
signal S_ROB_FREE_LOC1, S_ROB_FREE_LOC2 : std_logic_vector(N_LOG_ROB-1 downto 0);

signal S_ROB_PC1, S_ROB_PC2 : std_logic_vector(31 downto 0);
signal S_ROB_I1, S_ROB_I2   : std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
signal S_ROB_I1_CTRL, S_ROB_I2_CTRL : std_logic_vector(N_CTRL_BITS-1 downto 0);
signal S_ROB_I1_VALID, S_ROB_I2_VALID : std_logic;
signal S_ROB_I1_ARCH_REG, S_ROB_I2_ARCH_REG : std_logic_vector(N_LOG_AR-1 downto 0);
signal S_ROB_I1_RNME_REG, S_ROB_I2_RNME_REG : std_logic_vector(N_LOG_RR-1 downto 0);
signal S_ROB_I1_BR_FIELD, S_ROB_I2_BR_FIELD : std_logic_vector( N_BR_BITS_FOR_RS-1 downto 0 );


signal S_ROB_REG_WR1, S_ROB_REG_WR2 : std_logic;
signal S_ROB_I1_BR_BITS, S_ROB_I2_BR_BITS : std_logic_vector( N_BR_BITS_FOR_RS-1 downto 0 );
signal DS_IMM_OPR1, DS_IMM_OPR2 : std_logic_vector(31 downto 0);
signal S_RR_BUSY : std_logic_vector( N_RNME_REG-1 downto 0 );

-- Branch Execution units --
signal BRN_OPR1, BRN_OPR2, BRN_OPR3 : std_logic_vector(31 downto 0);
signal BRN_CTRL : std_logic_vector(N_CTRL_BITS-1 downto 0);
signal BRN_EX_PRED, BRN_EX_OUT_VAL : std_logic;

signal BRN_ROB_LOC_IN, BRN_ROB_LOC_OUT : std_logic_vector( N_LOG_ROB-1 downto 0 );
signal BRN_EX_OUT_DEST_REG : std_logic_vector(N_LOG_RR-1 downto 0);
signal BRN_EX_BRTAG, BRN_EX_HIST_IND, BRN_EX_OUT_HIST_IND : std_logic_vector(3 downto 0);
signal BRN_EX_OUT_PC : std_logic_vector(31 downto 0);
signal BRN_INSTR_VALID :std_logic ;
signal BRN_EX_BR_FIELD : std_logic_vector( N_BR_BITS_FOR_RS-1 downto 0 );

-- Memory Execution unit --
signal MEM_DEST_REG , MEM_EX_OUT_DEST_REG: std_logic_vector( N_LOG_RR-1 downto 0);
signal MEM_CTRL : std_logic_vector(N_CTRL_BITS - 1 downto 0);
signal MEM_ROB_LOC_IN, MEM_ROB_LOC_OUT : std_logic_vector(N_LOG_ROB-1 downto 0);
signal MEM_INSTR_VALID : std_logic;
signal MEM_OPR1, MEM_OPR2, MEM_OPR3, MEM_RD_DATA, MEM_WR_ADDRESS : std_logic_vector(31 downto 0);
signal SB_LOC_IN, SB_LOC_OUT : std_logic_vector(3 downto 0);
signal MEM_OUT_VALID, MEM_SW_VALID : std_logic;
signal MEM_DS_VAL : std_logic_vector(2 downto 0);
signal MEM_EX_BR_FIELD	: std_logic_vector( N_BR_BITS_FOR_RS-1 downto 0 );

-- ROB UTILITY SIGNALS--
signal S_STORE_COMMIT: std_logic;
signal S_STORE_LOC_BUFF: std_logic_vector(Buffersize - 1 downto 0);
signal S_ROB_DEC_DIS_Br_RES, S_ROB_DEC_DIS_Br_VAL: std_Logic;
signal S_ROB_DEC_DIS_Br_TAG: std_logic_vector(N_Br_TAG - 1 downto 0);
signal S_ROB_FETCH_BR_PC, S_CDB_ROB_BR_PC: std_logic_vector(31 downto 0);
signal S_ROB_FETCH_HIST_IND, S_CDB_ROB_HIST_IND: std_logic_vector(N_Br_TAG - 1 downto 0);

-- FETCH SIGNALS --
signal S_DEC_FETCH_TAG_1, S_DEC_FETCH_TAG_2, S_DEC_FETCH_TAG_3: std_logic_vector(N_LOG_RR - 1 downto 0);
signal S_DEC_FETCH_VAL_1, S_DEC_FETCH_VAL_2, S_DEC_FETCH_VAL_3: std_logic;
signal S_DEC_FETCH_PC_1, S_DEC_FETCH_PC_2, S_DEC_FETCH_PC_3: std_logic_vector(31 downto 0);
signal S_DEC_FETCH_HIST_IND_1, S_DEC_FETCH_HIST_IND_2, S_DEC_FETCH_HIST_IND_3: std_Logic_vector(N_Br_TAG - 1 downto 0);
signal S_FETCH_DEC_PC1, S_FETCH_DEC_PC2: std_logic_vector(31 downto 0);
signal S_FETCH_DEC_HIST_IND1, S_FETCH_DEC_HIST_IND2: std_logic_vector(N_Br_TAG - 1 downto 0);
signal S_FETCH_DEC_INST1, S_FETCH_DEC_INST2: std_logic_vector(31 downto 0);
signal S_FETCH_DEC_PRED1, S_FETCH_DEC_PRED2: std_Logic;
signal S_FETCH_HIST_TABLE: TABLE;

-- DECODE SIGNALS --
signal S_DEC_DIS_PC1, S_DEC_DIS_PC2: std_logic_vector(31 downto 0);
signal S_OPCODE1, S_OPCODE2: std_logic_vector(N_OPCODE_BITS - 1 downto 0);
signal S_FUNC1, S_FUNC2: std_logic_vector(N_FUNC_BITS - 1 downto 0);
signal S_SHAMT1, S_SHAMT2: std_logic_vector(N_SHAMT_BITS - 1 downto 0);
signal S_I1_REG1, S_I1_REG2, S_I2_REG1, S_I2_REG2, S_I1_DEST, S_I2_DEST: std_logic_vector(N_LOG_AR - 1 downto 0);
signal S_CTRL1, S_CTRL2: std_Logic_vector(N_CTRL_BITS - 1 downto 0);
signal S_SPEC_I1, S_SPEC_I2, S_PRED_I1, S_PRED_I2: std_logic;
signal S_BRTAG_I1, S_BRTAG_I2: std_logic_vector(N_Br_TAG - 1 downto 0);
signal S_I1_IMM_OPR, S_I2_IMM_OPR: std_logic_vector(31 downto 0);
signal S_I1_HIST_IND, S_I2_HIST_IND: std_logic_vector(N_Br_TAG - 1 downto 0);
signal S_DEC_FETCH_J_VAL1, S_DEC_FETCH_J_VAL2, S_I1_VAL, S_I2_VAL: std_logic;
signal S_DEC_FETCH_J_ADDR1, S_DEC_FETCH_J_ADDR2: std_logic_vector(31 downto 0);
signal S_I1_DECODE_BR_BITS, S_I2_DECODE_BR_BITS: std_logic_vector(N_BR_BITS_FOR_RS - 1 downto 0);
signal S_I1_FETCH_DEC_HIST_IND, S_I2_FETCH_DEC_HIST_IND: std_logic_vector(N_Br_TAG - 1 downto 0);
signal S_I1_FETCH_DEC_PRED_BIT, S_I2_FETCH_DEC_PRED_BIT: std_logic;

-- STORE BUFFER SIGNALS --
signal S_STOREBUFF_ENABLE: std_logic;
signal S_STOREBUFF_ADDR, S_STOREBUFF_DATA: std_logic_vector(31 downto 0);

signal DUMMY128B, S_ROB_FLUSH, S_ROB_SPEC : std_logic_vector(127 downto 0);
signal S_ROB_REG_FLUSH1, S_ROB_REG_FLUSH2 : std_logic ;

begin
 
 iFETCH: FETCH port map(
			CLK => CLK, RST => RST,
			MEM => I_MEM,
			
			-- Inputs from the Decode Stage
			I_TAG_EXEC1 => S_DEC_FETCH_TAG_1, I_TAG_EXEC2 => S_DEC_FETCH_TAG_2,
			I_VAL_EXEC1 => S_DEC_FETCH_VAL_1, I_VAL_EXEC2 => S_DEC_FETCH_VAL_2,
			I_PC_EXEC1 => S_DEC_FETCH_PC_1, I_PC_EXEC2 => S_DEC_FETCH_PC_2,
			I_HIST_IND_EXEC1 => S_DEC_FETCH_HIST_IND_1, I_HIST_IND_EXEC2 => S_DEC_FETCH_HIST_IND_2,
			
			-- Inputs from the Branch Execution Unit
			I_TAG_EXEC3 => S_DEC_FETCH_TAG_3, 
			I_VAL_EXEC3 => S_DEC_FETCH_VAL_3, 
			I_PC_EXEC3 => S_DEC_FETCH_PC_3, 
			I_HIST_IND_EXEC3 => S_DEC_FETCH_HIST_IND_3, 
			
			-- Outputs to the Decode Buffer and itself
			O_NEXT_PC1 => S_FETCH_DEC_PC1, O_NEXT_PC2 => S_FETCH_DEC_PC2,
			O_I1_HIST_IND => S_FETCH_DEC_HIST_IND1, O_I2_HIST_IND => S_FETCH_DEC_HIST_IND2,
			O_INST1 => S_FETCH_DEC_INST1, O_INST2 => S_FETCH_DEC_INST2,
			O_PREDICTION1 => S_FETCH_DEC_PRED1, O_PREDICTION2 => S_FETCH_DEC_PRED2,
			
			--Debugging purpose
			O_HIST_TABLE => S_FETCH_HIST_TABLE
 );
 
O_NEXT_PC1 		<= S_FETCH_DEC_PC1; 
O_NEXT_PC2 		<= S_FETCH_DEC_PC2;
O_I1_HIST_IND 	<= S_FETCH_DEC_HIST_IND1;
O_I2_HIST_IND 	<= S_FETCH_DEC_HIST_IND2;
O_INST1 		<= S_FETCH_DEC_INST1;
O_INST2			<= S_FETCH_DEC_INST2;
O_PREDICTION1 	<= S_FETCH_DEC_PRED1;
O_PREDICTION2 	<= S_FETCH_DEC_PRED2;
 
 iDECODE: decode port map (
			CLK => CLK, RST => RST,
			I_PC1 => S_FETCH_DEC_PC1, I_PC2 => S_FETCH_DEC_PC2,
			I_I1_HIST_IND => S_FETCH_DEC_HIST_IND1, I_I2_HIST_IND => S_FETCH_DEC_HIST_IND2,
			INSTR1 => S_FETCH_DEC_INST1, INSTR2 => S_FETCH_DEC_INST2,
			I_pred_bit1 => S_FETCH_DEC_PRED1, I_pred_bit2 => S_FETCH_DEC_PRED2,
			I_Branch_Valid => S_ROB_DEC_DIS_Br_VAL,
			I_Branch_Result => S_ROB_DEC_DIS_Br_RES,
			I_Branch_tag => S_ROB_DEC_DIS_Br_TAG,
			O_PC1 => S_DEC_DIS_PC1, O_PC2 => S_DEC_DIS_PC2,
			O_OPCODE1 => S_OPCODE1, O_OPCODE2 => S_OPCODE2,
			O_FUNC1 => S_FUNC1, O_FUNC2 => S_FUNC2,
			O_SHAMT1 => S_SHAMT1, O_SHAMT2 => S_SHAMT2,
			O_I1_REG1 => S_I1_REG1, O_I1_REG2 => S_I1_REG2,
			O_I2_REG1 => S_I2_REG1, O_I2_REG2 => S_I2_REG2,
			O_I1_DEST => S_I1_DEST, O_I2_DEST => S_I2_DEST,
			O_I1_Valid => S_I1_VAL, O_I2_Valid => S_I2_VAL,
			O_CTRL1 => S_I1_CTRL, O_CTRL2 => S_I2_CTRL,
-- CTRL : ALU_instr FP_instr Mem_instr Br_instr R_type Imm_type RegWrite RegDst RegInSrc ALUSrc Add_sub Logic_ctrl alu_outp_control shift_control Fp_mul/add DataRead DataWrite BrType PCSrc 
--  27      1          1        1         1        1       1       1       2       2        1       1        2            3              2            1         1         1        2     2    
			speculative_bit1 => S_SPEC_I1, speculative_bit2 => S_SPEC_I2,
			O_pred_bit1 => S_PRED_I1, O_pred_bit2 => S_PRED_I2,
			branch_tag1 => S_BRTAG_I1, branch_tag2 => S_BRTAG_I2,
			O_IMM1 => S_I1_IMM_OPR, O_IMM2 => S_I2_IMM_OPR,
			O_I1_HIST_IND => S_I1_HIST_IND, O_I2_HIST_IND => S_I2_HIST_IND,
			O_I1_DEC_FETCH_HIST_IND => S_I1_FETCH_DEC_HIST_IND, O_I2_DEC_FETCH_HIST_IND => S_I2_FETCH_DEC_HIST_IND,
			O_FETCH_DEC_pred_bit1 => S_I1_FETCH_DEC_PRED_BIT, O_FETCH_DEC_pred_bit2 => S_I2_FETCH_DEC_PRED_BIT,
			jump_valid1 => S_DEC_FETCH_J_VAL1, jump_valid2 => S_DEC_FETCH_J_VAL2,
			jump_addr1 => S_DEC_FETCH_J_ADDR1, jump_addr2 => S_DEC_FETCH_J_ADDR2
);

O_OPCODE1 			<= S_OPCODE1;
O_OPCODE2 			<= S_OPCODE2;
O_FUNC1 			<= S_FUNC1;
O_FUNC2 			<= S_FUNC2;
O_SHAMT1 			<= S_SHAMT1;
O_SHAMT2 			<= S_SHAMT2;
O_I1_REG1 			<= S_I1_REG1;
O_I1_REG2 			<= S_I1_REG2;				
O_I2_REG1 			<= S_I2_REG1;
O_I2_REG2 			<= S_I2_REG2;
O_I1_DEST 			<= S_I1_DEST;
O_I2_DEST 			<= S_I2_DEST;
O_I1_DEC_Valid 		<= S_I1_VAL; 
O_I2_DEC_Valid 		<= S_I2_VAL;
O_DEC_CTRL1 		<= S_I1_CTRL;
O_DEC_CTRL2 		<= S_I2_CTRL;
speculative_bit1 	<= S_SPEC_I1;
speculative_bit2 	<= S_SPEC_I2;
O_IMM1 				<= S_I1_IMM_OPR;
O_IMM2 				<= S_I2_IMM_OPR;
jump_valid1 		<= S_DEC_FETCH_J_VAL1;
jump_valid2 		<= S_DEC_FETCH_J_VAL2;
jump_addr1 			<= S_DEC_FETCH_J_ADDR1;
jump_addr2 			<= S_DEC_FETCH_J_ADDR2;

-- Connections of decode unit to fetch unit --
S_DEC_FETCH_TAG_1 		<= S_BRTAG_I1 & S_PRED_I1; 
S_DEC_FETCH_TAG_2 		<= S_BRTAG_I2 & S_PRED_I2;
S_DEC_FETCH_VAL_1 		<= S_DEC_FETCH_J_VAL1; 
S_DEC_FETCH_VAL_2 		<= S_DEC_FETCH_J_VAL2;
S_DEC_FETCH_PC_1 		<= S_DEC_FETCH_J_ADDR1; 
S_DEC_FETCH_PC_2 		<= S_DEC_FETCH_J_ADDR2;
S_DEC_FETCH_HIST_IND_1 	<= S_I1_HIST_IND; 
S_DEC_FETCH_HIST_IND_2 	<= S_I2_HIST_IND;

-- Grouping the Branch bits from Decode unit to give to Dispatch Unit --
S_I1_DECODE_BR_BITS <= S_SPEC_I1 & S_I1_FETCH_DEC_PRED_BIT & S_BRTAG_I1 & S_I1_FETCH_DEC_HIST_IND;
S_I2_DECODE_BR_BITS <= S_SPEC_I2 & S_I2_FETCH_DEC_PRED_BIT & S_BRTAG_I2 & S_I2_FETCH_DEC_HIST_IND;

-- Grouping the data from the forwarded slots --
 FWD_DATA_VAL <= '0' & MEM_OUT_VALID & FPU_RES_VAL & ALU_RES_VAL ;

 FWD_TAG(0) <= ALU_DEST_REG_OUT ;
 FWD_TAG(1) <= FPU_DEST_REG_OUT ;
 FWD_TAG(2) <= MEM_EX_OUT_DEST_REG ;
 FWD_TAG(3) <= "00000" ; 

 FWD_OPERAND(0) <= ALU_RESULT ;
 FWD_OPERAND(1) <= FPU_RESULT ;
 FWD_OPERAND(2) <= MEM_RD_DATA ;
 FWD_OPERAND(3) <= X"00000000" ;
 
 DISP : DISPATCH_STAGE port map ( 
												 CLK => CLK, RST => RST, 
												 -- INPUTS FROM DECODE STAGE --
												 -- opcodes, shift and functional bits --
												 I_OPCODE1 => S_OPCODE1, I_OPCODE2 => S_OPCODE2,
												 I_FUNC1 => S_FUNC1, I_FUNC2	=> S_FUNC2 ,
												 I_SHAMT1 => S_SHAMT1 , I_SHAMT2 => S_SHAMT2 ,
												 -- control signals
												 I_CTRL1 => S_I1_CTRL, I_CTRL2 => S_I2_CTRL , 
												 -- valid bits
												 I_I1_VAL => S_I1_VAL, I_I2_VAL => S_I2_VAL, 
												 -- branch fields
												 I_I1_BR_FIELD => S_I1_DECODE_BR_BITS, I_I2_BR_FIELD => S_I2_DECODE_BR_BITS, 
												 -- program counter 
												 I_PC1 => S_DEC_DIS_PC1, I_PC2 => S_DEC_DIS_PC2 ,												 
												 
												 -- ARCHITECTURAL REGISTERS AND IMM OPR --
												 I_I1_REG1 => S_I1_REG1, I_I1_REG2 => S_I1_REG2 ,
												 I_I2_REG1 => S_I2_REG1, I_I2_REG2 => S_I2_REG2 ,
												 I_I1_DEST => S_I1_DEST, I_I2_DEST => S_I2_DEST ,
												 I_I1_IMM_OPR => S_I1_IMM_OPR, I_I2_IMM_OPR => S_I2_IMM_OPR, 
												 
												 -- FORWARDED INPUTS --
												 I_TAG_FWD_SLOT => FWD_TAG ,
												 I_FWD_SLOT_VAL => FWD_DATA_VAL ,
												 I_OPR_FWD_SLOT => FWD_OPERAND ,
												 
												 -- INPUTS FROM REORDER BUFFER --
												 -- 2 free locations in ROB
												 I_ROB_FREE_LOC1 	=> S_ROB_FREE_LOC1, 	I_ROB_FREE_LOC2 	=> S_ROB_FREE_LOC2,	
												 -- write enable signals for ARF
												 I_ROB_REG_WR1 	=> S_ROB_REG_WR1, 	I_ROB_REG_WR2 		=> S_ROB_REG_WR2, 
												 -- rename reg ids 
												 I_ROB_RNME_REG1 	=> S_ROB_RNME_REG1, 	I_ROB_RNME_REG2 	=> S_ROB_RNME_REG2,
												 -- arch reg ids 
												 I_ROB_ARCH_REG1 	=> S_ROB_ARCH_REG1, 	I_ROB_ARCH_REG2 	=> S_ROB_ARCH_REG2,
												 
												 -- Branch info from ROB
												 I_ROB_BR_VAL => S_ROB_DEC_DIS_Br_VAL, I_BR_RES => S_ROB_DEC_DIS_Br_RES,
												 I_ROB_BR_TAG => S_ROB_DEC_DIS_Br_TAG,
			 
												 I_ROB_FLUSH1 => S_ROB_REG_FLUSH1, I_ROB_FLUSH2 => S_ROB_REG_FLUSH2,
												 
												 -- COMMON OUTPUTS TO RESERVATION STATION --
												 O_DS_ALL_IMM_OPR1 => DS_IMM_OPR1, O_DS_ALL_IMM_OPR2 => DS_IMM_OPR2,
												 
												 -- OUTPUTS TO RESERVATION STATION --	
												 -- ALU --
												 O_DS1_ALU_OPR1 		=> O_DS1_ALU_OPR1, O_DS1_ALU_OPR2 => O_DS1_ALU_OPR2,
												 O_DS1_ALU_VAL 			=> O_DS1_ALU_VAL, 
												 O_DS1_ALU_OPR1_VAL 	=> O_DS1_ALU_OPR1_VAL, 
												 O_DS1_ALU_OPR2_VAL 	=> O_DS1_ALU_OPR2_VAL ,
												 O_DS1_ALU_ROB_LOC 		=> O_DS1_ALU_ROB_LOC ,
												 O_DS1_ALU_INSTR 		=> O_DS1_ALU_INSTR ,
												 O_DS1_ALU_CTRL  		=> O_DS1_ALU_CTRL ,
												 O_DS1_ALU_RR    		=> O_DS1_ALU_RR ,

												 O_DS2_ALU_OPR1 		=> O_DS2_ALU_OPR1, O_DS2_ALU_OPR2 => O_DS2_ALU_OPR2 ,
												 O_DS2_ALU_VAL 			=> O_DS2_ALU_VAL, O_DS2_ALU_OPR1_VAL => O_DS2_ALU_OPR1_VAL, 
												 O_DS2_ALU_OPR2_VAL 	=> O_DS2_ALU_OPR2_VAL ,
												 O_DS2_ALU_ROB_LOC 		=> O_DS2_ALU_ROB_LOC , 
												 O_DS2_ALU_INSTR 		=> O_DS2_ALU_INSTR ,
												 O_DS2_ALU_CTRL 		=> O_DS2_ALU_CTRL ,
												 O_DS2_ALU_RR 			=> O_DS2_ALU_RR ,
														
												 -- FPU --
												 O_DS1_FPU_OPR1 		=> O_DS1_FPU_OPR1, O_DS1_FPU_OPR2 => O_DS1_FPU_OPR2 ,
												 O_DS1_FPU_VAL			=> O_DS1_FPU_VAL, 
												 O_DS1_FPU_OPR1_VAL 	=> O_DS1_FPU_OPR1_VAL, 
												 O_DS1_FPU_OPR2_VAL 	=> O_DS1_FPU_OPR2_VAL ,
												 O_DS1_FPU_ROB_LOC  	=> O_DS1_FPU_ROB_LOC ,
												 O_DS1_FPU_INSTR 		=> O_DS1_FPU_INSTR ,
												 O_DS1_FPU_CTRL  		=> O_DS1_FPU_CTRL ,
												 O_DS1_FPU_RR    		=> O_DS1_FPU_RR ,
												 
												 O_DS2_FPU_OPR1 		=> O_DS2_FPU_OPR1, O_DS2_FPU_OPR2 => O_DS2_FPU_OPR2 ,
												 O_DS2_FPU_VAL 			=> O_DS2_FPU_VAL, O_DS2_FPU_OPR1_VAL=> O_DS2_FPU_OPR1_VAL, 
												 O_DS2_FPU_OPR2_VAL 	=> O_DS2_FPU_OPR2_VAL ,
												 O_DS2_FPU_ROB_LOC  	=> O_DS2_FPU_ROB_LOC ,
												 O_DS2_FPU_INSTR 		=> O_DS2_FPU_INSTR ,
												 O_DS2_FPU_CTRL  		=> O_DS2_FPU_CTRL ,
												 O_DS2_FPU_RR    		=> O_DS2_FPU_RR,


												 -- BRN --
												 O_DS1_BRN_OPR1 		=> O_DS1_BRN_OPR1, 		O_DS1_BRN_OPR2 => O_DS1_BRN_OPR2 ,
												 O_DS1_BRN_VAL			=> O_DS1_BRN_VAL, 
												 O_DS1_BRN_OPR1_VAL 	=> O_DS1_BRN_OPR1_VAL, 
												 O_DS1_BRN_OPR2_VAL 	=> O_DS1_BRN_OPR2_VAL ,
												 O_DS1_BRN_ROB_LOC  	=> O_DS1_BRN_ROB_LOC ,
												 O_DS1_BRN_INSTR 		=> O_DS1_BRN_INSTR ,
												 O_DS1_BRN_CTRL  		=> O_DS1_BRN_CTRL ,
												 O_DS1_BRN_RR    		=> O_DS1_BRN_RR ,
												 
												 O_DS2_BRN_OPR1 		=> O_DS2_BRN_OPR1, 		O_DS2_BRN_OPR2 => O_DS2_BRN_OPR2 ,
												 O_DS2_BRN_VAL 			=> O_DS2_BRN_VAL, 		
												 O_DS2_BRN_OPR1_VAL		=> O_DS2_BRN_OPR1_VAL, 
												 O_DS2_BRN_OPR2_VAL 	=> O_DS2_BRN_OPR2_VAL ,
												 O_DS2_BRN_ROB_LOC  	=> O_DS2_BRN_ROB_LOC ,
												 O_DS2_BRN_INSTR 		=> O_DS2_BRN_INSTR ,
												 O_DS2_BRN_CTRL  		=> O_DS2_BRN_CTRL ,
												 O_DS2_BRN_RR    		=> O_DS2_BRN_RR,
												 
												 -- MEM --
												 O_DS1_MEM_OPR1 		=> O_DS1_MEM_OPR1,  		O_DS1_MEM_OPR2 => O_DS1_MEM_OPR2,
												 O_DS1_MEM_VAL 			=> O_DS1_MEM_VAL, 
												 O_DS1_MEM_OPR1_VAL  	=> O_DS1_MEM_OPR1_VAL , 
												 O_DS1_MEM_OPR2_VAL  	=> O_DS1_MEM_OPR2_VAL , 
												 O_DS1_MEM_ROB_LOC   	=> O_DS1_MEM_ROB_LOC ,
												 O_DS1_MEM_INSTR 	   	=> O_DS1_MEM_INSTR ,
												 O_DS1_MEM_CTRL  		=> O_DS1_MEM_CTRL ,
												 O_DS1_MEM_RR    		=> O_DS1_MEM_RR ,
												 
												 O_DS2_MEM_OPR1			=> O_DS2_MEM_OPR1 , O_DS2_MEM_OPR2 => O_DS2_MEM_OPR2 ,
												 O_DS2_MEM_VAL			=> O_DS2_MEM_VAL , 
												 O_DS2_MEM_OPR1_VAL		=> O_DS2_MEM_OPR1_VAL ,
												 O_DS2_MEM_OPR2_VAL  	=> O_DS2_MEM_OPR2_VAL ,
												 O_DS2_MEM_ROB_LOC   	=> O_DS2_MEM_ROB_LOC ,
												 O_DS2_MEM_INSTR 	   	=> O_DS2_MEM_INSTR ,
												 O_DS2_MEM_CTRL  	   	=> O_DS2_MEM_CTRL ,
												 O_DS2_MEM_RR    		=> O_DS2_MEM_RR ,
												 
												 
												 -- Common outputs
												 O_I1_BR_FIELD => O1_BR_BITS, O_I2_BR_FIELD => O2_BR_BITS,
												 
												 
												 -- OUTPUTS TO REORDER BUFFER --
												 O_PC1 			=> S_PC1, 			O_PC2 			=> S_PC2,												 
												 O_I1 			=> S_I1, 			O_I2 				=> S_I2 ,
												 --O_I1_CTRL 		=> S_ROB_I1_CTRL, 		O_I2_CTRL 		=> S_ROB_I2_CTRL,
												 O_I1_VALID 	=> S_I1_VALID, 	O_I2_VALID 		=> S_I2_VALID ,
												 O_I1_ARCH_REG => S_I1_ARCH_REG, O_I2_ARCH_REG 	=> S_I2_ARCH_REG,												 
												 O_I1_RNME_REG => S_I1_RNME_REG, O_I2_RNME_REG 	=> S_I2_RNME_REG,
												 
												 -- OUTPUTS TO REORDER BUFFER --
												 O_ROB_PC1 				=> S_ROB_PC1, 				O_ROB_PC2 			=> S_ROB_PC2,
												 O_ROB_I1 				=> S_ROB_I1, 				O_ROB_I2 			=> S_ROB_I2,
												 O_ROB_I1_CTRL 		=> S_ROB_I1_CTRL, 		O_ROB_I2_CTRL 		=> S_ROB_I2_CTRL,			 
												 O_ROB_I1_VALID 		=> S_ROB_I1_VALID, 		O_ROB_I2_VALID 	=> S_ROB_I2_VALID ,
												 O_ROB_I1_ARCH_REG 	=> S_ROB_I1_ARCH_REG, 	O_ROB_I2_ARCH_REG => S_ROB_I2_ARCH_REG,
												 O_ROB_I1_RNME_REG 	=> S_ROB_I1_RNME_REG, 	O_ROB_I2_RNME_REG => S_ROB_I2_RNME_REG,
												 O_ROB_I1_BR_FIELD   => S_ROB_I1_BR_FIELD, 	O_ROB_I2_BR_FIELD   => S_ROB_I2_BR_FIELD,
												 

--						 
--												 -- OUTPUTS TO FETCH AND DECODE --
--												 O_STALL => O_STALL,  O_RR1_VAL => O_RR1_VAL, O_RR2_VAL => O_RR2_VAL ,
--												 O_RNME_REG_BUSY=> O_RNME_REG_BUSY, 
--												 O_RNME_REG_VALID => O_RNME_REG_VALID,
--												 O_ARCH_REG_LOCK  => O_ARCH_REG_LOCK 
												 O_ARF => O_ARF,
												 O_RRF => O_RRF,
												 O_ARF_TAG => O_ARF_TAG, O_RR_BUSY => O_RR_BUSY

													);

 
 O_I1_VAL <= S_I1_VALID ;
 O_I2_VAL <= S_I2_VALID ;
 
 O_O_DS2_FPU_OPR1 		<= O_DS2_FPU_OPR1 ;
 O_O_DS2_FPU_OPR2 		<= O_DS2_FPU_OPR2 ;
 O_O_DS2_FPU_VAL 			<= O_DS2_FPU_VAL;
 O_O_DS2_FPU_OPR1_VAL 	<= O_DS2_FPU_OPR1_VAL ;
 O_O_DS2_FPU_OPR2_VAL 	<= O_DS2_FPU_OPR2_VAL ;
 
 O_O_DS1_FPU_OPR1 		<= O_DS1_FPU_OPR1 ;
 O_O_DS1_FPU_OPR2 		<= O_DS1_FPU_OPR2 ;
 O_O_DS1_FPU_VAL 			<= O_DS1_FPU_VAL;
 O_O_DS1_FPU_OPR1_VAL 	<= O_DS1_FPU_OPR1_VAL ;
 O_O_DS1_FPU_OPR2_VAL 	<= O_DS1_FPU_OPR2_VAL ;
 
 O_O_DS2_ALU_OPR1 		<= O_DS2_ALU_OPR1 ;
 O_O_DS2_ALU_OPR2 		<= O_DS2_ALU_OPR2 ;
 O_O_DS2_ALU_VAL 			<= O_DS2_ALU_VAL;
 O_O_DS2_ALU_OPR1_VAL 	<= O_DS2_ALU_OPR1_VAL ;
 O_O_DS2_ALU_OPR2_VAL 	<= O_DS2_ALU_OPR2_VAL ;
 
 O_O_DS1_ALU_OPR1 		<= O_DS1_ALU_OPR1 ;
 O_O_DS1_ALU_OPR2 		<= O_DS1_ALU_OPR2 ;
 O_O_DS1_ALU_VAL 		<= O_DS1_ALU_VAL;
 O_O_DS1_ALU_OPR1_VAL 	<= O_DS1_ALU_OPR1_VAL ;
 O_O_DS1_ALU_OPR2_VAL 	<= O_DS1_ALU_OPR2_VAL ; 
 
 O_O_DS1_ALU_RR <= O_DS1_ALU_RR;
 O_O_DS2_ALU_RR <= O_DS2_ALU_RR;
 
 O_O_DS1_FPU_RR <= O_DS1_FPU_RR ;
 O_O_DS2_FPU_RR <= O_DS2_FPU_RR ;
 
 O_O_DS1_BR_RR <= O_DS1_BRN_RR;
 O_O_DS2_BR_RR <= O_DS2_BRN_RR;
 
 
 FPU_DS_VAL <= '0' & O_DS2_FPU_VAL & O_DS1_FPU_VAL ;
 
 DUMMY32   <= std_logic_vector(to_unsigned(0, 32));
 
 ------------------------------------------------------------------------------------------------
 ------------------------------  RESERVATION STATIONS -------------------------------------------
 ------------------------------------------------------------------------------------------------
 --------- 
 -- FPU --
 ---------
 RS_FPU: RESERVATION_STN port map 	(  	CLK => CLK, RST => RST , D_SLOT_VALID 	=> FPU_DS_VAL ,
														
														DS1_INSTR => O_DS1_FPU_INSTR, DS2_INSTR => O_DS2_FPU_INSTR, 
														DS3_INSTR => DUMMY32(N_OPCODE_BITS + N_SHAMT_BITS + N_FUNC_BITS-1 downto 0), 
														
														DS1_OPR1 => O_DS1_FPU_OPR1, DS1_OPR2 => O_DS1_FPU_OPR2, DS1_OPR3 => DS_IMM_OPR1,
														DS2_OPR1 => O_DS2_FPU_OPR1, DS2_OPR2 => O_DS2_FPU_OPR2, DS2_OPR3 => DS_IMM_OPR2,
														DS3_OPR1 => DUMMY32, DS3_OPR2 => DUMMY32, DS3_OPR3 => DUMMY32,
														
														DS1_OPR1_VAL => O_DS1_FPU_OPR1_VAL, DS1_OPR2_VAL => O_DS1_FPU_OPR2_VAL, 
														DS2_OPR1_VAL => O_DS2_FPU_OPR1_VAL, DS2_OPR2_VAL => O_DS2_FPU_OPR2_VAL, 
														DS3_OPR1_VAL => '0', DS3_OPR2_VAL => '0',
														
														DS1_DEST => O_DS1_FPU_RR, DS2_DEST => O_DS2_FPU_RR, 
														DS3_DEST => DUMMY32(N_LOG_RR-1 downto 0),
														
														DS1_CTRL => O_DS1_FPU_CTRL, DS2_CTRL => O_DS2_FPU_CTRL, 
														DS3_CTRL => DUMMY32(N_CTRL_BITS-1 downto 0) ,
														
														DS1_ROB_LOC => O_DS1_FPU_ROB_LOC,
														DS2_ROB_LOC => O_DS2_FPU_ROB_LOC, 
														DS3_ROB_LOC => DUMMY32(N_LOG_ROB-1 downto 0) ,
														
														DS1_SPEC_BrTAG_PRED => O1_BR_BITS, 
														DS2_SPEC_BrTAG_PRED => O2_BR_BITS, 
														DS3_SPEC_BrTAG_PRED => DUMMY32(N_BR_BITS_FOR_RS-1 downto 0) ,
														
														DATA_FWD_SLOT1 => ALU_RESULT, 
														DATA_FWD_SLOT2 => FPU_RESULT , 
														DATA_FWD_SLOT3 => MEM_RD_DATA, 
														DATA_FWD_SLOT4 => DUMMY32 ,
														
														TAG_FWD_SLOT1 => ALU_DEST_REG_OUT,
														TAG_FWD_SLOT2 => FPU_DEST_REG_OUT, 
														TAG_FWD_SLOT3 => MEM_EX_OUT_DEST_REG, 
														TAG_FWD_SLOT4 => DUMMY32(N_LOG_RR-1 downto 0) , 
														
														VAL_FWD_SLOTS => FWD_DATA_VAL,
														
														
														I_ROB_FLUSH => S_ROB_FLUSH, I_ROB_SPEC => S_ROB_SPEC,
--														TEMP_ISEQ3 => TEMP_ISEQ3, TEMP_ISEQ2 => TEMP_ISEQ2, 
--														TEMP_ISEQ1 => TEMP_ISEQ1, TEMP_ISEQ0 => TEMP_ISEQ0,
														
														DREG_INSTR => FPU_INSTR , DREG_DEST => FPU_DEST_REG ,
														DREG_ROB_LOC => FPU_ROB_LOC_IN ,
														
														DREG_OPR1 => FPU_OPR1, DREG_OPR2 => FPU_OPR2 , 
														DREG_CTRL => FPU_CTRL , 	

														RS_OUTPUT_VALID => FPU_INSTR_VALID ,

--														-- TEMP OUTPUTS --
														TEMP_N_INSTR_IN_STN => TEMP_RS1_N_INSTR_IN_STN , 														
--														TEMP_ALLOC_BITS => TEMP_ALLOC_BITS ,
														TEMP_BUSY_BITS => TEMP_RS1_BUSY_BITS , TEMP_READY_BITS => TEMP_RS1_READY_BITS );
--														TEMP_LOC1 => TEMP_RS1_LOC1, TEMP_LOC2 => TEMP_RS_LOC2, TEMP_RS_LOC3 => TEMP_LOC3 );
						

 O_N_INSTR_IN_STN 		<= TEMP_RS1_N_INSTR_IN_STN ;
 --O_FPU_INSTR_VALID      <= FPU_INSTR_VALID ;

 --------- 
 -- ALU --
 ---------
 
 ALU_DS_VAL <= '0' & O_DS2_ALU_VAL & O_DS1_ALU_VAL ;						
 
 RS_ALU: RESERVATION_STN port map 	(  	CLK => CLK, RST => RST , D_SLOT_VALID 	=> ALU_DS_VAL ,
														
														DS1_INSTR => O_DS1_ALU_INSTR, DS2_INSTR => O_DS2_ALU_INSTR, 
														DS3_INSTR => DUMMY32(N_OPCODE_BITS + N_SHAMT_BITS + N_FUNC_BITS-1 downto 0), 
														
														DS1_OPR1 => O_DS1_ALU_OPR1, DS1_OPR2 => O_DS1_ALU_OPR2, DS1_OPR3 => DS_IMM_OPR1,
														DS2_OPR1 => O_DS2_ALU_OPR1, DS2_OPR2 => O_DS2_ALU_OPR2, DS2_OPR3 => DS_IMM_OPR2,
														DS3_OPR1 => DUMMY32, DS3_OPR2 => DUMMY32, DS3_OPR3 => DUMMY32,
														
														DS1_OPR1_VAL => O_DS1_ALU_OPR1_VAL, DS1_OPR2_VAL => O_DS1_ALU_OPR2_VAL, 
														DS2_OPR1_VAL => O_DS2_ALU_OPR1_VAL, DS2_OPR2_VAL => O_DS2_ALU_OPR2_VAL, 
														DS3_OPR1_VAL => '0', DS3_OPR2_VAL => '0',
														
														DS1_DEST => O_DS1_ALU_RR, DS2_DEST => O_DS2_ALU_RR, 
														DS3_DEST => DUMMY32(N_LOG_RR-1 downto 0),
														
														DS1_CTRL => O_DS1_ALU_CTRL, DS2_CTRL => O_DS2_ALU_CTRL, 
														DS3_CTRL => DUMMY32(N_CTRL_BITS-1 downto 0) ,
														
														DS1_ROB_LOC => O_DS1_ALU_ROB_LOC,
														DS2_ROB_LOC => O_DS2_ALU_ROB_LOC, 
														DS3_ROB_LOC => DUMMY32(N_LOG_ROB-1 downto 0) ,

														DS1_SPEC_BrTAG_PRED => O1_BR_BITS, 
														DS2_SPEC_BrTAG_PRED => O2_BR_BITS, 
														DS3_SPEC_BrTAG_PRED => DUMMY32(N_BR_BITS_FOR_RS-1 downto 0) ,

														
														DATA_FWD_SLOT1 => ALU_RESULT, 
														DATA_FWD_SLOT2 => FPU_RESULT , 
														DATA_FWD_SLOT3 => MEM_RD_DATA, 
														DATA_FWD_SLOT4 => DUMMY32 ,
														
														TAG_FWD_SLOT1 => ALU_DEST_REG_OUT, 
														TAG_FWD_SLOT2 => FPU_DEST_REG_OUT, 
														TAG_FWD_SLOT3 => MEM_EX_OUT_DEST_REG, 
														TAG_FWD_SLOT4 => DUMMY32(N_LOG_RR-1 downto 0) , 
														
														VAL_FWD_SLOTS => FWD_DATA_VAL,
														
														I_ROB_FLUSH => S_ROB_FLUSH, I_ROB_SPEC => S_ROB_SPEC,
														
--														TEMP_ISEQ3 => TEMP_ISEQ3, TEMP_ISEQ2 => TEMP_ISEQ2, 
--														TEMP_ISEQ1 => TEMP_ISEQ1, TEMP_ISEQ0 => TEMP_ISEQ0,
														
														DREG_INSTR => ALU_INSTR , DREG_DEST => ALU_DEST_REG ,
														
														DREG_OPR1 => ALU_OPR1, DREG_OPR2 => ALU_OPR2 , 
														DREG_CTRL => ALU_CTRL , 	
														
														DREG_ROB_LOC => ALU_ROB_LOC_IN ,

														RS_OUTPUT_VALID => ALU_INSTR_VALID ,

--														-- TEMP OUTPUTS --
														TEMP_N_INSTR_IN_STN => TEMP_RS2_N_INSTR_IN_STN , 														
--														TEMP_ALLOC_BITS => TEMP_RS2_ALLOC_BITS ,
														TEMP_BUSY_BITS => TEMP_RS2_BUSY_BITS , TEMP_READY_BITS => TEMP_RS2_READY_BITS );
--														TEMP_LOC1 => TEMP_RS2_LOC1, TEMP_LOC2 => TEMP_RS2_LOC2, TEMP_LOC3 => TEMP_RS2_LOC3 );
	

	 
	 O_RS2_N_RS_ALU <= TEMP_RS2_N_INSTR_IN_STN ;
	 O_RS2_ALU_ROB_LOC_IN <= ALU_ROB_LOC_IN ;
	 O_RS2_ALU_DEST_REG <= ALU_DEST_REG ;
	 O_RS2_ALU_INSTR_VALID <= ALU_INSTR_VALID;
	 
	 
	 --------- 
	 -- BRN --
	 ---------
	BRN_DS_VAL <= '0' & O_DS2_BRN_VAL & O_DS1_BRN_VAL ;						
	DUMMY128B <= std_logic_vector(to_unsigned(0,128));
	
	RS_BRN: RESERVATION_STN port map 	(  	CLK => CLK, RST => RST , D_SLOT_VALID 	=> BRN_DS_VAL ,
														
															DS1_INSTR => O_DS1_BRN_INSTR, DS2_INSTR => O_DS2_BRN_INSTR, 
															DS3_INSTR => DUMMY32(N_OPCODE_BITS + N_SHAMT_BITS + N_FUNC_BITS-1 downto 0), 
														
															DS1_OPR1 => O_DS1_BRN_OPR1, DS1_OPR2 => O_DS1_BRN_OPR2, DS1_OPR3 => DS_IMM_OPR1,
															DS2_OPR1 => O_DS2_BRN_OPR1, DS2_OPR2 => O_DS2_BRN_OPR2, DS2_OPR3 => DS_IMM_OPR2,
															DS3_OPR1 => DUMMY32, DS3_OPR2 => DUMMY32, DS3_OPR3 => DUMMY32,
														
															DS1_OPR1_VAL => O_DS1_BRN_OPR1_VAL, DS1_OPR2_VAL => O_DS1_BRN_OPR2_VAL, 
															DS2_OPR1_VAL => O_DS2_BRN_OPR1_VAL, DS2_OPR2_VAL => O_DS2_BRN_OPR2_VAL, 
															DS3_OPR1_VAL => '0'					 , DS3_OPR2_VAL => '0',
														
															DS1_DEST => O_DS1_BRN_RR			 , DS2_DEST => O_DS2_BRN_RR, 
															DS3_DEST => DUMMY32(N_LOG_RR-1 downto 0),
														
															DS1_CTRL => O_DS1_BRN_CTRL, DS2_CTRL => O_DS2_BRN_CTRL, 
															DS3_CTRL => DUMMY32(N_CTRL_BITS-1 downto 0) ,
														
															DS1_ROB_LOC => O_DS1_BRN_ROB_LOC,
															DS2_ROB_LOC => O_DS2_BRN_ROB_LOC, 
															DS3_ROB_LOC => DUMMY32(N_LOG_ROB-1 downto 0) ,

															DS1_SPEC_BrTAG_PRED => O1_BR_BITS, 
															DS2_SPEC_BrTAG_PRED => O2_BR_BITS, 
															DS3_SPEC_BrTAG_PRED => DUMMY32(N_BR_BITS_FOR_RS-1 downto 0) ,

														
															DATA_FWD_SLOT1 => ALU_RESULT, 
															DATA_FWD_SLOT2 => FPU_RESULT , 
															DATA_FWD_SLOT3 => MEM_RD_DATA, 
															DATA_FWD_SLOT4 => DUMMY32 ,
														
															TAG_FWD_SLOT1 => ALU_DEST_REG_OUT, 
															TAG_FWD_SLOT2 => FPU_DEST_REG_OUT, 
															TAG_FWD_SLOT3 => MEM_EX_OUT_DEST_REG, 
															TAG_FWD_SLOT4 => DUMMY32(N_LOG_RR-1 downto 0) , 
														
															VAL_FWD_SLOTS => FWD_DATA_VAL,
														
															I_ROB_FLUSH => S_ROB_FLUSH, I_ROB_SPEC => DUMMY128B,
															
--															TEMP_ISEQ3 => TEMP_ISEQ3, TEMP_ISEQ2 => TEMP_ISEQ2, 
--															TEMP_ISEQ1 => TEMP_ISEQ1, TEMP_ISEQ0 => TEMP_ISEQ0,
														
															-- Outputs --
														
															DREG_OPR1  		=> BRN_OPR1, DREG_OPR2 => BRN_OPR2 , DREG_OPR3 => BRN_OPR3 ,
															DREG_CTRL  		=> BRN_CTRL , 	
															DREG_BR_FIELD 	=> BRN_EX_BR_FIELD , 
															DREG_ROB_LOC 	=> BRN_ROB_LOC_IN ,

															RS_OUTPUT_VALID => BRN_INSTR_VALID );

	--														-- TEMP OUTPUTS --
	--														TEMP_N_INSTR_IN_STN => TEMP_RS3_N_INSTR_IN_STN , 														
	--														TEMP_ALLOC_BITS => TEMP_RS3_ALLOC_BITS ,
	--														TEMP_BUSY_BITS => TEMP_RS3_BUSY_BITS , TEMP_READY_BITS => TEMP_RS3_READY_BITS );
	--														TEMP_LOC1 => TEMP_RS3_LOC1, TEMP_LOC2 => TEMP_RS3_LOC2, TEMP_LOC3 => TEMP_RS3_LOC3 );

 
	------------------------------------------------------------------------------------------------
	---------------------------------   EXECUTE STAGE ----------------------------------------------
	------------------------------------------------------------------------------------------------
	---------
	-- FPU --
	---------
	
	iFPU : FPU port map ( 
									CLK => CLK, RST => RST ,
									
									IN_CTRL  		=> FPU_CTRL, 
									IN_INSTR 	 	=> FPU_INSTR ,
									IN_DEST_REG  	=> FPU_DEST_REG ,
									IN_INSTR_VAL 	=> FPU_INSTR_VALID ,
									IN_ROB_LOC   	=> FPU_ROB_LOC_IN ,
									
									FPU_A => FPU_OPR1,  FPU_B  => FPU_OPR2 ,
									
									O_RESULT  	=> FPU_RESULT ,
									
									O_RES_VAL 	=> FPU_RES_VAL ,
									O_DEST_REG 	=> FPU_DEST_REG_OUT ,
									O_ROB_LOC  	=> FPU_ROB_LOC_OUT	
				
							);
	O_FPU_OPR1 			<= FPU_OPR1 ;
	O_FPU_OPR2 			<= FPU_OPR2 ;
	O_RS_FPU_DEST_REG 	<= FPU_DEST_REG ;	
	O_FPU_RESULT 		<= FPU_RESULT	   ;
	O_FPU_DEST_REG 		<= FPU_DEST_REG_OUT	;
	O_FPU_INSTR_VAL 	<= FPU_RES_VAL	;
	O_FPU_ROB_LOC_OUT 	<= FPU_ROB_LOC_OUT ;
	O_DREG_FPU_ROB_LOC  <= FPU_ROB_LOC_IN;
	
	---------
	-- ALU --
	---------	
	iALU : ALU port map (
									inp1 => ALU_OPR1, 
									inp2 => ALU_OPR2, 
									shift_amt => ALU_INSTR(10 downto 6),
									ALU_instr_control => ALU_INSTR_VALID, 
									logic_control => ALU_CTRL(13 downto 12),
									shift_control => ALU_CTRL(8 downto 7),
									alu_outp_control => ALU_CTRL(11 downto 9),
									add_sub => ALU_CTRL(14),
									outp => ALU_RESULT,
									ovfl => OVERFLOW_FLG,
									carr_ovfl => CARRY_FLAG,
									zero => ZERO_FLAG,
									Valid => ALU_RES_VAL,
									
									location_inp => ALU_ROB_LOC_IN,
									RR_inp => ALU_DEST_REG,
									location => ALU_ROB_LOC_OUT,
									RR => ALU_DEST_REG_OUT
								) ;
	O_ALU_OPR1 			<= ALU_OPR1 ;
	O_ALU_OPR2 			<= ALU_OPR2 ;
	O_RS_ALU_DEST_REG 	<= ALU_DEST_REG ;	
	O_ALU_RESULT 		<= ALU_RESULT	   ;
	O_ALU_DEST_REG 		<= ALU_DEST_REG_OUT	;
	O_ALU_INSTR_VAL 	<= ALU_RES_VAL	;
	O_ALU_ROB_LOC_OUT 	<= ALU_ROB_LOC_OUT ;
	O_DREG_ALU_ROB_LOC  <= ALU_ROB_LOC_IN;
	---------
	-- BRN --
	---------
	BRN_EX_PRED 		<= BRN_EX_BR_FIELD(8) ;
	BRN_EX_BRTAG 		<= BRN_EX_BR_FIELD(7 downto 4) ;
	BRN_EX_HIST_IND 	<= BRN_EX_BR_FIELD(3 downto 0) ;
	
--	O_BRN_EX_PRED  	<= BRN_EX_PRED ;
--	O_BRN_EX_BRTAG 	<= BRN_EX_BRTAG ;
--	O_BRN_EX_HIST_IND <= BRN_EX_HIST_IND ;
	
--	O_BRN_EX_PRED : out std_logic 
--	O_BRN_EX_BRTAG, O_BRN_EX_HIST_IND : out std_logic_vector(3 downto 0);

	iBRN :  BRANCH port map (
											CLK => CLK, 			
											
											--Input operands from the Reservation Station
											I_OPR1 			=> BRN_OPR1 ,
											I_OPR2 			=> BRN_OPR2 ,
											I_OPR3 			=> BRN_OPR3 ,
											I_CTRL_BITS 	=> BRN_CTRL ,
											I_PREDICTION    => BRN_EX_PRED , 
											I_VALID 		=> BRN_INSTR_VALID ,
											
											--Utility Inputs from the reservation station
											I_LOC 		=> BRN_ROB_LOC_IN ,
											I_BrTAG  	=> BRN_EX_BRTAG ,
											I_HIST_IND 	=> BRN_EX_HIST_IND ,
											
											--Outputs as a proper execution unit
											O_OUT_PC		=> S_CDB_ROB_BR_PC ,
											O_HIST_IND 	 	=> S_CDB_ROB_HIST_IND ,
											O_VAL_EXEC  	=> BRN_EX_OUT_VAL,
											O_TAG_EXEC  	=> BRN_EX_OUT_DEST_REG ,
											O_LOC_EXEC  	=> BRN_ROB_LOC_OUT
		);
	
	-- Mapping signals used for debugging
	O_BR_OPR1 				<= BRN_OPR1 ;
	O_BR_OPR2				<= BRN_OPR2 ;	
	O_BR_RESULT 			<= BRN_EX_OUT_PC;
	O_BR_DEST_REG 			<= BRN_EX_OUT_DEST_REG;
	O_BR_INSTR_VAL 			<= BRN_EX_OUT_VAL;
	O_BR_ROB_LOC_OUT 		<= BRN_ROB_LOC_OUT;
	O_DREG_BR_ROB_LOC    	<= BRN_ROB_LOC_IN;	
	
	--------------
	--- MEMORY ---
   --------------
	
	MEM_DS_VAL <= '0' & O_DS2_MEM_VAL & O_DS1_MEM_VAL ;						

	RS_MEM: RESERVATION_STN port map 	(  	CLK => CLK, RST => RST , D_SLOT_VALID 	=> MEM_DS_VAL ,
														
															DS1_INSTR => O_DS1_MEM_INSTR, DS2_INSTR => O_DS2_MEM_INSTR, 
															DS3_INSTR => DUMMY32(N_OPCODE_BITS + N_SHAMT_BITS + N_FUNC_BITS-1 downto 0), 
														
															DS1_OPR1 => O_DS1_MEM_OPR1, DS1_OPR2 => O_DS1_MEM_OPR2, DS1_OPR3 => DS_IMM_OPR1,
															DS2_OPR1 => O_DS2_MEM_OPR1, DS2_OPR2 => O_DS2_MEM_OPR2, DS2_OPR3 => DS_IMM_OPR2,
															DS3_OPR1 => DUMMY32, DS3_OPR2 => DUMMY32, DS3_OPR3 => DUMMY32,
														
															DS1_OPR1_VAL => O_DS1_MEM_OPR1_VAL, DS1_OPR2_VAL => O_DS1_MEM_OPR2_VAL, 
															DS2_OPR1_VAL => O_DS2_MEM_OPR1_VAL, DS2_OPR2_VAL => O_DS2_MEM_OPR2_VAL, 
															DS3_OPR1_VAL => '0'					 , DS3_OPR2_VAL => '0',
														
															DS1_DEST => O_DS1_MEM_RR			 , DS2_DEST => O_DS2_MEM_RR, 
															DS3_DEST => DUMMY32(N_LOG_RR-1 downto 0),
														
															DS1_CTRL => O_DS1_MEM_CTRL, DS2_CTRL => O_DS2_MEM_CTRL, 
															DS3_CTRL => DUMMY32(N_CTRL_BITS-1 downto 0) ,
														
															DS1_ROB_LOC => O_DS1_MEM_ROB_LOC,
															DS2_ROB_LOC => O_DS2_MEM_ROB_LOC, 
															DS3_ROB_LOC => DUMMY32(N_LOG_ROB-1 downto 0) ,

															DS1_SPEC_BrTAG_PRED => O1_BR_BITS, 
															DS2_SPEC_BrTAG_PRED => O2_BR_BITS, 
															DS3_SPEC_BrTAG_PRED => DUMMY32(N_BR_BITS_FOR_RS-1 downto 0) ,

														
															DATA_FWD_SLOT1 => ALU_RESULT, 
															DATA_FWD_SLOT2 => FPU_RESULT , 
															DATA_FWD_SLOT3 => MEM_RD_DATA, 
															DATA_FWD_SLOT4 => DUMMY32 ,
														
															TAG_FWD_SLOT1  => ALU_DEST_REG_OUT, 
															TAG_FWD_SLOT2  => FPU_DEST_REG_OUT, 
															TAG_FWD_SLOT3  => MEM_EX_OUT_DEST_REG, 
															TAG_FWD_SLOT4  => DUMMY32(N_LOG_RR-1 downto 0) , 
														
															VAL_FWD_SLOTS => FWD_DATA_VAL,
														
															I_ROB_FLUSH => S_ROB_FLUSH, I_ROB_SPEC => S_ROB_SPEC,
															
--															TEMP_ISEQ3 => TEMP_ISEQ3, TEMP_ISEQ2 => TEMP_ISEQ2, 
--															TEMP_ISEQ1 => TEMP_ISEQ1, TEMP_ISEQ0 => TEMP_ISEQ0,
														
															-- Outputs --
														
															DREG_OPR1  		=> MEM_OPR1, DREG_OPR2 => MEM_OPR2 , DREG_OPR3 => MEM_OPR3 ,
															DREG_CTRL  		=> MEM_CTRL , 	
															DREG_BR_FIELD 	=> MEM_EX_BR_FIELD , 
															DREG_ROB_LOC 	=> MEM_ROB_LOC_IN ,
															DREG_DEST       => MEM_DEST_REG ,
															RS_OUTPUT_VALID => MEM_INSTR_VALID );
	
		O_RS_MEM_VAL 	<= MEM_INSTR_VALID;
		O_RS_OPR1 		<= MEM_OPR1;
		O_RS_OPR2 		<= MEM_OPR2;
		O_RS_OPR3 		<= MEM_OPR3;
	
		iMEM : memory port map (
		clk => CLK,
		rst	=> RST,
		
		SB_Enable 	=> S_STOREBUFF_ENABLE,
		SB_mem_add 	=> S_STOREBUFF_ADDR,
		SB_Data		=> S_STOREBUFF_DATA,

		DREG_CTRL 			=> MEM_CTRL ,
		DREG_DEST 			=> MEM_DEST_REG ,
		DREG_ROB_LOC		=> MEM_ROB_LOC_IN ,
		RS_OUTPUT_VALID     => MEM_INSTR_VALID ,

		operand0 			=> MEM_OPR1 ,
		operand1 			=> MEM_OPR2 ,
		operand2 			=> MEM_OPR3 ,
											
		in_freeloc 			=> SB_LOC_IN ,
		out_freeloc 		=> SB_LOC_OUT ,


		Data 				=> MEM_RD_DATA ,
											
		mem_address 		=> MEM_WR_ADDRESS ,
		valid 				=> MEM_OUT_VALID ,
		sw_valid 			=> MEM_SW_VALID ,
		reg_dest 			=> MEM_EX_OUT_DEST_REG ,
		reg_rob_loc			=> MEM_ROB_LOC_OUT );
		
	-- Exposing the Memory Unit signals for Debugging --
	O_MEM_OPR1 			<= MEM_OPR1;
	O_MEM_OPR2 			<= MEM_OPR2;
	O_MEM_OPR3 			<= MEM_OPR3;
	O_MEM_INSTR_VAL 	<= MEM_OUT_VALID;
	O_MEM_DEST_REG 		<= MEM_EX_OUT_DEST_REG;
	O_MEM_ROB_LOC 		<= MEM_ROB_LOC_OUT;
	O_MEM_ADDR 			<= MEM_WR_ADDRESS;
	O_MEM_RESULT 		<= MEM_RD_DATA;
	O_IN_FREELOC 		<= SB_LOC_IN;
	O_OUT_FREELOC 		<= SB_LOC_OUT;
	
	-- Breaking up the Branch Bits before inserting into ROB --
	S_I1_SPEC 	<= S_ROB_I1_BR_FIELD(9);
	S_I1_BrTAG 	<= S_ROB_I1_BR_FIELD(7 downto 4);
	S_I2_SPEC 	<= S_ROB_I2_BR_FIELD(9);
	S_I2_BrTAG 	<= S_ROB_I2_BR_FIELD(7 downto 4);
	
	-- Grouping the Execution Unit Register Tags before feeding into ROB --
	S_ROB_TAG_IN(0) <= ALU_DEST_REG_OUT ;
	S_ROB_TAG_IN(1) <= FPU_DEST_REG_OUT ;
	S_ROB_TAG_IN(2) <= MEM_EX_OUT_DEST_REG;
	S_ROB_TAG_IN(3) <= BRN_EX_OUT_DEST_REG ;

	-- Grouping the Execution Unit ROB Locations before feeding into ROB --
	S_ROB_LOC_IN(0) <= ALU_ROB_LOC_OUT ;
	S_ROB_LOC_IN(1) <= FPU_ROB_LOC_OUT ;
	S_ROB_LOC_IN(2) <= MEM_ROB_LOC_OUT;
	S_ROB_LOC_IN(3) <= BRN_ROB_LOC_OUT ;
	
	-- Grouping the Execution Unit Execution Valid Bits before feeding into ROB --
	S_ROB_VAL_IN <= ALU_RES_VAL & FPU_RES_VAL & MEM_OUT_VALID & BRN_EX_OUT_VAL ;
	
	-- Grouping the Execution Unit Results before feeding into ROB --
	S_ROB_OPR_IN(0) <= ALU_RESULT;
	S_ROB_OPR_IN(1) <= FPU_RESULT;
	S_ROB_OPR_IN(2) <= MEM_RD_DATA;
	S_ROB_OPR_IN(3) <= BRN_EX_OUT_PC;
	
	iROB :  ROB port map (
										CLK => CLK, RST => RST,
										
										--Inputs from Dispatch stage
										I_PC1 			=> S_ROB_PC1, 				I_PC2 			=> S_ROB_PC2,
										I_I1 			=> S_ROB_I1, 				I_I2 			=> S_ROB_I2, 
										I_I1_CTRL 		=> S_ROB_I1_CTRL, 		    I_I2_CTRL 		=> S_ROB_I2_CTRL,
										I_I1_VALID		=> S_ROB_I1_VALID, 		    I_I2_VALID 		=> S_ROB_I2_VALID,
										I_I1_SPEC 		=> S_I1_SPEC, 				I_I2_SPEC 		=> S_I2_SPEC,
										I_I1_BrTAG 		=> S_I1_BrTAG, 			    I_I2_BrTAG 		=> S_I2_BrTAG,
										I_I1_ARCH_REG 	=> S_ROB_I1_ARCH_REG, 	    I_I2_ARCH_REG 	=> S_ROB_I2_ARCH_REG,
										I_I1_RNME_REG 	=> S_ROB_I1_RNME_REG, 	    I_I2_RNME_REG 	=> S_ROB_I2_RNME_REG,

										--Inputs from the Common Data Bus
										I_TAG_EXEC => S_ROB_TAG_IN,
										I_LOC_EXEC => S_ROB_LOC_IN,
										I_VAL_EXEC => S_ROB_VAL_IN,
										I_OPR_EXEC => S_ROB_OPR_IN,
										I_HIST_IND_EXEC => S_CDB_ROB_HIST_IND,
										I_BR_PC_EXEC => S_CDB_ROB_BR_PC,
										I_STORE_BUFF_IND => SB_LOC_OUT,
										I_SW_VALID => MEM_SW_VALID,
										
										--Outputs to dispatch stage
										O_ROB_FREE_LOC1 => S_ROB_FREE_LOC1, O_ROB_FREE_LOC2 	=> S_ROB_FREE_LOC2,
										O_ROB_REG_WR1   => S_ROB_REG_WR1, 	O_ROB_REG_WR2 		=> S_ROB_REG_WR2,
										O_ROB_REG_FLUSH1 => S_ROB_REG_FLUSH1, O_ROB_REG_FLUSH2 => S_ROB_REG_FLUSH2,
										O_ROB_RNME_REG1 => S_ROB_RNME_REG1, O_ROB_RNME_REG2 	=> S_ROB_RNME_REG2,
										O_ROB_ARCH_REG1 => S_ROB_ARCH_REG1, O_ROB_ARCH_REG2 	=> S_ROB_ARCH_REG2,
										
										--Outputs to Decode and Dispatch Unit
										O_ROB_HIST_IND_EXEC 	=> S_ROB_FETCH_HIST_IND,
										O_ROB_BR_PC_EXEC 		=> S_ROB_FETCH_BR_PC,
										O_ROB_DEC_VAL 			=> S_ROB_DEC_DIS_Br_VAL, O_ROB_DEC_BR_RES => S_ROB_DEC_DIS_Br_RES,
										O_ROB_DEC_TAG 			=> S_ROB_DEC_DIS_Br_TAG,
										
										--Outputs to store buffer
										O_STORE_COMMIT => S_STORE_COMMIT,
										O_LOC_BUFF => S_STORE_LOC_BUFF,
										
										--Maintenance Outputs
										O_FULL => O_ROB_FULL,

										--For debugging purposes
										O_head => O_ROB_HEAD,
										O_last => O_ROB_LAST,
										O_BRTAG => O_BRTAG, 
										O_FLUSH => S_ROB_FLUSH, 
										O_SPEC => S_ROB_SPEC,
										O_VALID => O_VALID

									);
							
		O_FLUSH <= S_ROB_FLUSH ;
		O_SPEC  <= S_ROB_SPEC  ;
		
		O_FLUSH1 <= S_ROB_REG_FLUSH1;
		O_FLUSH2 <= S_ROB_REG_FLUSH2;
		
		-- Connections of Branch Unit with Fetch Unit --
		S_DEC_FETCH_TAG_3 		<= S_ROB_DEC_DIS_Br_TAG & S_ROB_DEC_DIS_Br_RES;
		S_DEC_FETCH_VAL_3 		<= S_ROB_DEC_DIS_Br_VAL;
		S_DEC_FETCH_PC_3 		<= S_ROB_FETCH_BR_PC;
		S_DEC_FETCH_HIST_IND_3 	<= S_ROB_FETCH_HIST_IND;
		
		-- Exposing Outputs of ROB for Debugging --
		O_ROB_BR_VAL		<= S_ROB_DEC_DIS_Br_VAL;
		O_ROB_BR_RES		<= S_ROB_DEC_DIS_Br_RES;
		O_TEMP_ROB_L1 		<= S_ROB_FREE_LOC1 ;
		O_TEMP_ROB_L2 		<= S_ROB_FREE_LOC2 ;
		O_TEMP_ROB_WR1 		<= S_ROB_REG_WR1 ;
		O_TEMP_ROB_WR2 		<= S_ROB_REG_WR2 ;
		O_TEMP_ROB_RR1 		<= S_ROB_RNME_REG1;
		O_TEMP_ROB_RR2 		<= S_ROB_RNME_REG2;
		O_TEMP_ROB_AR1 		<= S_ROB_ARCH_REG1;
		O_TEMP_ROB_AR2 		<= S_ROB_ARCH_REG2;
		
		O_STORE_COMMIT 		<= S_STORE_COMMIT;
		O_STORE_LOC_BUFF	<= S_STORE_LOC_BUFF;
		
	iSTOREBUFF: StoreBuffer port map(
		CLK => CLK,
		RST => RST,
		
		I_DATA => MEM_RD_DATA,
		I_MemAddr => MEM_WR_ADDRESS,
		I_LOC_EXEC_Buff => SB_LOC_OUT,
		I_VAL => MEM_OUT_VALID,
		I_SW_VAL => MEM_SW_VALID,
		
		I_StoreCommit => S_STORE_COMMIT,
		I_LOC_Buff => S_STORE_LOC_BUFF,
		
		O_DATA => S_STOREBUFF_DATA,
		O_MemAddr => S_STOREBUFF_ADDR,
		O_WR => S_STOREBUFF_ENABLE,
		
		O_FREE_LOC => SB_LOC_IN
	);	
	
	-- Connections from Store Buffer to Memory Unit --
		
	O_STORE_DATA <= S_STOREBUFF_DATA;
	O_STORE_MEM_ADDR <= S_STOREBUFF_ADDR;
	O_STORE_WRITE <= S_STOREBUFF_ENABLE;		
	
end architecture;