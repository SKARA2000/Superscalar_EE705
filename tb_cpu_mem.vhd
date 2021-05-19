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
			 O_BRTAG, O_BRTAGLOCAL: out ROB_BrTAG_COLUMN;
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

end component;

signal CLK, RST : std_logic;
signal I_MEM: in CODE_MEM;
			 
-- OUTPUTS --
signal O_O_DS1_FPU_OPR1, O_O_DS1_FPU_OPR2 :  std_logic_vector(31 downto 0);
signal O_O_DS1_FPU_VAL, O_O_DS1_FPU_OPR1_VAL, O_O_DS1_FPU_OPR2_VAL :  std_logic ;
signal O_O_DS2_FPU_OPR1, O_O_DS2_FPU_OPR2 :  std_logic_vector(31 downto 0);
signal O_O_DS2_FPU_VAL, O_O_DS2_FPU_OPR1_VAL, O_O_DS2_FPU_OPR2_VAL :  std_logic ;
signal O_O_DS1_FPU_RR , O_O_DS2_FPU_RR : std_logic_vector(N_LOG_RR-1 downto 0);

signal O_O_DS1_BR_RR , O_O_DS2_BR_RR : std_logic_vector(N_LOG_RR-1 downto 0);
signal O_BR_ROB_LOC_OUT, O_BR_DREG_ROB_LOC, O_TEMP_DS1_BR_ROB_LOC,O_TEMP_DS2_BR_ROB_LOC : std_logic_vector(N_LOG_ROB-1 downto 0) ;

signal  O_FPU_OPR1, O_FPU_OPR2 : std_logic_vector(31 downto 0) ;
signal  O_RS_FPU_DEST_REG : std_logic_vector(N_LOG_RR-1 downto 0) ;
signal  O_N_INSTR_IN_STN : std_logic_vector(3 downto 0);			 

signal  O_FPU_RESULT    : std_logic_vector(31 downto 0);
signal  O_FPU_DEST_REG  : std_logic_vector(N_LOG_RR-1 downto 0);
signal  O_FPU_INSTR_VAL : std_logic	;		 

signal O_BR_RESULT    : std_logic_vector(31 downto 0);
signal O_BR_DEST_REG  : std_logic_vector(N_LOG_RR-1 downto 0);
signal O_BR_INSTR_VAL : std_logic;

signal O_MEM_RESULT, O_MEM_OPR1, O_MEM_OPR2, O_MEM_OPR3   : std_logic_vector(31 downto 0);
signal O_MEM_ROB_LOC	 : std_logic_vector(N_LOG_ROB-1 downto 0);
signal O_MEM_ADDR		 : std_logic_vector(31 downto 0);
signal O_IN_FREELOC	 : std_logic_vector(Buffersize - 1 downto 0);
signal O_OUT_FREELOC	 : std_logic_vector(Buffersize - 1 downto 0);
signal O_MEM_DEST_REG  : std_logic_vector(N_LOG_RR-1 downto 0);
signal O_MEM_INSTR_VAL : std_logic;			 
			 
			 

signal O_TEMP_RS1_BUSY_BITS, O_TEMP_RS1_READY_BITS : std_logic_vector(7 downto 0);
signal O_TEMP_ROB_L1 , O_TEMP_ROB_L2 : std_logic_vector( N_LOG_ROB-1 downto 0 ) ;
signal O_TEMP_ROB_WR1, O_TEMP_ROB_WR2 : std_logic;
signal O_TEMP_ROB_RR1, O_TEMP_ROB_RR2 : std_logic_vector(N_LOG_RR-1 downto 0);
signal O_TEMP_ROB_AR1, O_TEMP_ROB_AR2 : std_logic_vector(N_LOG_AR-1 downto 0);

signal O_ROB_HEAD : std_logic_vector(N_LOG_ROB - 1 downto 0);
signal O_ROB_LAST : std_logic_vector(N_LOG_ROB - 1 downto 0);
signal O_BRTAG, O_BRTAGLOCAL: ROB_BrTAG_COLUMN;
signal O_FLUSH, O_SPEC, O_VALID: std_logic_vector(0 to 2**N_LOG_ROB - 1);
signal O_ROB_FULL, O_STORE_COMMIT: std_logic;
signal O_STORE_LOC_BUFF: std_logic_vector(Buffersize - 1 downto 0); 

signal O_ARF 		:		T_ARCH_REGFILE ;
signal O_RRF 		:		T_RNME_REGFILE ;
signal O_ARF_TAG  : 		T_ARF_TAG ;
signal O_FPU_ROB_LOC_OUT, O_DREG_ROB_LOC, O_TEMP_DS1_FPU_ROB_LOC,O_TEMP_DS2_FPU_ROB_LOC : std_logic_vector(N_LOG_ROB-1 downto 0) ;
signal O_I1_VAL , O_I2_VAL : std_logic ; 
signal O_RR_BUSY  :  std_logic_vector(N_RNME_REG-1 downto 0);
signal I_I1_IMM_OPR, I_I2_IMM_OPR : std_logic_vector(31 downto 0); 
 

signal O_STORE_WRITE: std_logic;
signal O_STORE_DATA: std_logic_vector(31 downto 0);
signal O_STORE_MEM_ADDR: std_logic_vector(31 downto 0);
signal O_STOREBUFF_FREE_LOC: std_logic_vector(Buffersize - 1 downto 0);
 
 
begin

dut:  CPU port map (
			 CLK, RST,
			 I_MEM,
			 
			 -- -- OUTPUTS FROM DISPATCH --
			 O_O_DS1_FPU_OPR1, O_O_DS1_FPU_OPR2,
			 O_O_DS1_FPU_VAL, O_O_DS1_FPU_OPR1_VAL, O_O_DS1_FPU_OPR2_VAL,
			 O_O_DS2_FPU_OPR1, O_O_DS2_FPU_OPR2,
			 O_O_DS2_FPU_VAL, O_O_DS2_FPU_OPR1_VAL, O_O_DS2_FPU_OPR2_VAL,

			 -- OUTPUTS FROM RS --			 
			 O_FPU_OPR1, O_FPU_OPR2 ,
			 O_RS_FPU_DEST_REG ,
			 O_N_INSTR_IN_STN ,

			 -- -- OUTPUTS FROM FPU--
			 O_FPU_RESULT,
			 O_FPU_DEST_REG,
			 O_FPU_INSTR_VAL,
			 
			 -- OUTPUTS FROM BR --
			 O_BR_RESULT, 
			 O_BR_DEST_REG,   
			 O_BR_INSTR_VAL, 
			 
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
			 			 
			 --Temp outputs
			 O_TEMP_RS1_BUSY_BITS, O_TEMP_RS1_READY_BITS,
			 O_TEMP_ROB_L1 , O_TEMP_ROB_L2,
			 O_TEMP_ROB_WR1, O_TEMP_ROB_WR2,
	         O_TEMP_ROB_RR1, O_TEMP_ROB_RR2,
			 O_TEMP_ROB_AR1, O_TEMP_ROB_AR2,
			
			--Rob
		 	 O_ROB_HEAD,
			 O_ROB_LAST,
			 O_BRTAG,
			 O_BRTAGLOCAL,
			 O_ROB_FULL, O_STORE_COMMIT,
			 O_STORE_LOC_BUFF,
			 O_FLUSH, 
			 O_SPEC,
			 O_VALID,
			 
			--Dispatch
			 O_ARF, O_RRF, O_ARF_TAG, O_RR_BUSY,
			 
			-- STORE BUFFER OUTPUTS --
			 O_STORE_WRITE,
			 O_STORE_DATA,
			 O_STORE_MEM_ADDR,
			 O_STOREBUFF_FREE_LOC,
			 
			 O_FPU_ROB_LOC_OUT, O_DREG_ROB_LOC, O_TEMP_DS1_FPU_ROB_LOC, O_TEMP_DS2_FPU_ROB_LOC,
			 O_BR_ROB_LOC_OUT, O_BR_DREG_ROB_LOC, O_TEMP_DS1_BR_ROB_LOC, O_TEMP_DS2_BR_ROB_LOC,
			 O_I1_VAL , O_I2_VAL,
			 O_O_DS1_FPU_RR , O_O_DS2_FPU_RR,
			 O_O_DS1_BR_RR, O_O_DS2_BR_RR
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