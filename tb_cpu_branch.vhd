library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG_COMMON.all;

entity tb is end entity;

architecture arch1 of tb is

component CPU is
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
			
			 -- Branch Bits
			 I_I1_DECODE_BR_BITS, I_I2_DECODE_BR_BITS: in std_logic_vector(N_BR_BITS_FOR_RS - 1 downto 0);

			 -- program counter 
			 I_PC1, I_PC2 : in std_logic_vector( 31 downto 0 );
			 
			 -- ARCHITECTURAL REGISTERS --
			 I_I1_REG1, I_I1_REG2 : in std_logic_vector(N_LOG_AR-1 downto 0 );
			 I_I2_REG1, I_I2_REG2 : in std_logic_vector(N_LOG_AR-1 downto 0 );
			 I_I1_DEST, I_I2_DEST : in std_logic_vector(N_LOG_AR-1 downto 0 );
			 I_I1_IMM_OPR, I_I2_IMM_OPR : in std_logic_vector(31 downto 0); 
			 
			-- -- OUTPUTS FROM DISPATCH --
			 O_O_DS1_FPU_OPR1, O_O_DS1_FPU_OPR2 : out std_logic_vector(31 downto 0);
			 O_O_DS1_FPU_VAL, O_O_DS1_FPU_OPR1_VAL, O_O_DS1_FPU_OPR2_VAL : out std_logic ;
			 O_O_DS2_FPU_OPR1, O_O_DS2_FPU_OPR2 : out std_logic_vector(31 downto 0);
			 O_O_DS2_FPU_VAL, O_O_DS2_FPU_OPR1_VAL, O_O_DS2_FPU_OPR2_VAL : out std_logic ;
			
			 -- -- OUTPUTS FROM RS --
			 O_FPU_OPR1, O_FPU_OPR2 :out std_logic_vector(31 downto 0) ;
			 O_RS_FPU_DEST_REG :out std_logic_vector(N_LOG_RR-1 downto 0) ;
			 O_N_INSTR_IN_STN : out std_logic_vector(3 downto 0);
			 
			 -- -- OUTPUTS FROM FPU--
			 O_FPU_RESULT    : out std_logic_vector(31 downto 0);
			 O_FPU_DEST_REG  : out std_logic_vector(N_LOG_RR-1 downto 0);
			 O_FPU_INSTR_VAL : out std_logic;
			 
			 -- OUTPUTS FROM BR --
			 O_BR_RESULT    : out std_logic_vector(31 downto 0);
			 O_BR_DEST_REG  : out std_logic_vector(N_LOG_RR-1 downto 0);
			 O_BR_INSTR_VAL : out std_logic;
			 			 
			 
			 -- TEMP OUTPUTS --
			 O_TEMP_RS1_BUSY_BITS, O_TEMP_RS1_READY_BITS : out std_logic_vector(7 downto 0);
			 O_TEMP_ROB_L1 , O_TEMP_ROB_L2 : out std_logic_vector( N_LOG_ROB-1 downto 0 ) ;
			 O_TEMP_ROB_WR1, O_TEMP_ROB_WR2 : out std_logic;
			 O_TEMP_ROB_RR1, O_TEMP_ROB_RR2 : out std_logic_vector(N_LOG_RR-1 downto 0);
			 O_TEMP_ROB_AR1, O_TEMP_ROB_AR2 : out std_logic_vector(N_LOG_AR-1 downto 0);

			 -- ROB --
			 O_ROB_HEAD : out std_logic_vector(N_LOG_ROB - 1 downto 0);
			 O_ROB_LAST : out std_logic_vector(N_LOG_ROB - 1 downto 0);
			 O_ROB_AR_COL : out ROB_TAG_COLUMN;
			 O_ROB_RR_COL : out ROB_TAG_COLUMN;
			 O_FLUSH: out std_logic_vector(0 to 2**N_LOG_ROB - 1);
			 
			 -- DISPATCH --
			 O_ARF 		:	out	T_ARCH_REGFILE ;
			 O_RRF 		:	out	T_RNME_REGFILE ;
			 O_ARF_TAG  : 	out	T_ARF_TAG ;
			 O_RR_BUSY  :  out std_logic_vector(N_RNME_REG-1 downto 0); 
			 
			 -- MISC OUTPUTS
			 O_FPU_ROB_LOC_OUT, O_DREG_ROB_LOC, O_TEMP_DS1_FPU_ROB_LOC,O_TEMP_DS2_FPU_ROB_LOC : out std_logic_vector(N_LOG_ROB-1 downto 0) ;
			 O_BR_ROB_LOC_OUT, O_BR_DREG_ROB_LOC, O_TEMP_DS1_BR_ROB_LOC,O_TEMP_DS2_BR_ROB_LOC : out std_logic_vector(N_LOG_ROB-1 downto 0) ;
			 O_I1_VAL , O_I2_VAL : out std_logic ;
			 O_O_DS1_FPU_RR , O_O_DS2_FPU_RR : out std_logic_vector(N_LOG_RR-1 downto 0);
			 O_O_DS1_BR_RR , O_O_DS2_BR_RR : out std_logic_vector(N_LOG_RR-1 downto 0)
		) ;

end component;

signal CLK, RST : std_logic;

			 -- INPUTS FROM DECODE STAGE --
			 -- opcodes, shift and functional bits --

signal I_OPCODE1, I_OPCODE2 : std_logic_vector(N_OPCODE_BITS-1 downto 0);
signal I_FUNC1, I_FUNC2		 : std_logic_vector(N_FUNC_BITS-1 downto 0);
signal I_SHAMT1, I_SHAMT2   : std_logic_vector(N_SHAMT_BITS-1 downto 0);
			 
			 -- control signals
signal I_CTRL1, I_CTRL2     : std_logic_vector(N_CTRL_BITS-1 downto 0);
			 
			 -- valid bits
signal I_I1_VAL, I_I2_VAL   : std_logic;

			 -- program counter 
signal I_PC1  : std_logic_vector( 31 downto 0 ) := X"00000000" ;
signal I_PC2  : std_logic_vector( 31 downto 0 ) := X"00000001" ;	
	 
			 -- ARCHITECTURAL REGISTERS --
signal I_I1_REG1, I_I1_REG2 : std_logic_vector(N_LOG_AR-1 downto 0 );
signal I_I2_REG1, I_I2_REG2 : std_logic_vector(N_LOG_AR-1 downto 0 );
signal I_I1_DEST, I_I2_DEST : std_logic_vector(N_LOG_AR-1 downto 0 );

			 -- Branch Bits from Decode --
signal I_I1_DECODE_BR_BITS, I_I2_DECODE_BR_BITS: std_logic_vector(N_BR_BITS_FOR_RS - 1 downto 0);
			 
			 
--			 -- INPUTS FROM REORDER BUFFER --
--			 -- 2 free locations in ROB
--signal I_ROB_FREE_LOC1, I_ROB_FREE_LOC2 : std_logic_vector( N_LOG_ROB - 1 downto 0) ;	
--			 -- write enable signals for ARF
--signal I_ROB_REG_WR1, I_ROB_REG_WR2 : std_logic; 
--			 -- rename reg ids 
--signal I_ROB_RNME_REG1, I_ROB_RNME_REG2 : std_logic_vector( N_LOG_RR-1 downto 0 );
--			 -- arch reg ids 
--signal I_ROB_ARCH_REG1, I_ROB_ARCH_REG2 : std_logic_vector( N_LOG_AR-1 downto 0 );

			 
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
			 

signal O_TEMP_RS1_BUSY_BITS, O_TEMP_RS1_READY_BITS : std_logic_vector(7 downto 0);
signal O_TEMP_ROB_L1 , O_TEMP_ROB_L2 : std_logic_vector( N_LOG_ROB-1 downto 0 ) ;
signal O_TEMP_ROB_WR1, O_TEMP_ROB_WR2 : std_logic;
signal O_TEMP_ROB_RR1, O_TEMP_ROB_RR2 : std_logic_vector(N_LOG_RR-1 downto 0);
signal O_TEMP_ROB_AR1, O_TEMP_ROB_AR2 : std_logic_vector(N_LOG_AR-1 downto 0);

signal O_ROB_HEAD : std_logic_vector(N_LOG_ROB - 1 downto 0);
signal O_ROB_LAST : std_logic_vector(N_LOG_ROB - 1 downto 0);
signal O_ROB_AR_COL : ROB_TAG_COLUMN;
signal O_ROB_RR_COL : ROB_TAG_COLUMN;
signal O_FLUSH: std_logic_vector(0 to 2**N_LOG_ROB - 1);

signal O_ARF 		:		T_ARCH_REGFILE ;
signal O_RRF 		:		T_RNME_REGFILE ;
signal O_ARF_TAG  : 		T_ARF_TAG ;
signal O_FPU_ROB_LOC_OUT, O_DREG_ROB_LOC, O_TEMP_DS1_FPU_ROB_LOC,O_TEMP_DS2_FPU_ROB_LOC : std_logic_vector(N_LOG_ROB-1 downto 0) ;
signal O_I1_VAL , O_I2_VAL : std_logic ; 
signal O_RR_BUSY  :  std_logic_vector(N_RNME_REG-1 downto 0);
signal I_I1_IMM_OPR, I_I2_IMM_OPR : std_logic_vector(31 downto 0); 
 
begin

dut:  CPU port map (
			 CLK, RST,
			 -- INPUTS FROM DECODE STAGE --
			 -- opcodes, shift and functional bits --
			 I_OPCODE1, I_OPCODE2,
			 I_FUNC1, I_FUNC2, 
			 I_SHAMT1, I_SHAMT2, 
			 
			 -- control signals
			 I_CTRL1, I_CTRL2, 
			 
			 -- valid bits
			 I_I1_VAL, I_I2_VAL, 

			 -- Branch Bits
			 I_I1_DECODE_BR_BITS, I_I2_DECODE_BR_BITS,

			 -- program counter 
			 I_PC1, I_PC2,
			 
			 -- ARCHITECTURAL REGISTERS --
			 I_I1_REG1, I_I1_REG2,
			 I_I2_REG1, I_I2_REG2,
			 I_I1_DEST, I_I2_DEST,
			 I_I1_IMM_OPR, I_I2_IMM_OPR,
			 
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
			 			 
			 --Temp outputs
			 O_TEMP_RS1_BUSY_BITS, O_TEMP_RS1_READY_BITS,
			 O_TEMP_ROB_L1 , O_TEMP_ROB_L2,
			 O_TEMP_ROB_WR1, O_TEMP_ROB_WR2,
	         O_TEMP_ROB_RR1, O_TEMP_ROB_RR2,
			 O_TEMP_ROB_AR1, O_TEMP_ROB_AR2,
			
			--Rob
		 	 O_ROB_HEAD,
			 O_ROB_LAST,
			 O_ROB_AR_COL,
			 O_ROB_RR_COL,
			 O_FLUSH,
	
			--Dispatch
			 O_ARF, O_RRF, O_ARF_TAG, O_RR_BUSY,
			 
			 O_FPU_ROB_LOC_OUT, O_DREG_ROB_LOC, O_TEMP_DS1_FPU_ROB_LOC, O_TEMP_DS2_FPU_ROB_LOC,
			 O_BR_ROB_LOC_OUT, O_BR_DREG_ROB_LOC, O_TEMP_DS1_BR_ROB_LOC, O_TEMP_DS2_BR_ROB_LOC,
			 O_I1_VAL , O_I2_VAL,
			 O_O_DS1_FPU_RR , O_O_DS2_FPU_RR,
			 O_O_DS1_BR_RR, O_O_DS2_BR_RR
		) ;

	--I_I1_IMM_OPR <= X"41B00000";
	--I_I2_IMM_OPR <= X"41400000";
	
	process 
	variable v_count : integer := 0;
	begin
	
		for i in 0 to 49 loop
			CLK <= '0';
			
			wait for 1 ps;
			
			if (v_count < 2) then
				RST <= '1';
			else 
				RST <= '0';
			end if ;


			
			if (v_count < 2) then
				RST <= '1';
			else 
				RST <= '0';
			end if ;	
			
			if (v_count = 4) then
				I_OPCODE1  <= OPCODE_FPU ;
				I_SHAMT1   <= (others => '0');
				I_FUNC1    <= "000001";
				I_I1_VAL   <= '1';
				I_CTRL1   <= (IND_REG_WR => '1', IND_FPU_INSTR => '1', IND_REG_AM => '1', others => '0');
				I_I1_DECODE_BR_BITS <= '0' & '0' & "0000" & "0000";
				I_I1_REG1 <= std_logic_vector(to_unsigned(0,N_LOG_AR));
				I_I1_REG2 <= std_logic_vector(to_unsigned(9,N_LOG_AR));
				I_I1_DEST <= std_logic_vector(to_unsigned(10,N_LOG_AR));
				
				
				
				I_OPCODE2  <= OPCODE_FPU ;
				I_SHAMT2   <= (others => '0');
				I_FUNC2    <= "000001";
				I_I2_VAL <= '1' ;
				I_CTRL2   <= (IND_REG_WR => '1', IND_FPU_INSTR => '1', IND_REG_AM => '1', others => '0');
				I_I2_DECODE_BR_BITS <= '0' & '0' & "0000" & "0000";
				I_I2_REG1 <= std_logic_vector(to_unsigned(1,N_LOG_AR));
				I_I2_REG2 <= std_logic_vector(to_unsigned(10,N_LOG_AR));
				I_I2_DEST <= std_logic_vector(to_unsigned(1,N_LOG_AR));

				
			elsif (v_count = 5) then
			
				I_I1_VAL   <= '1';
				I_OPCODE1  <= OPCODE_BRN;
				I_CTRL1    <= "000110000000000000000001100";
				I_I1_DECODE_BR_BITS <= '1' & '1' & "0001" & "0010";
				I_I1_REG1       <= std_logic_vector(to_unsigned(9,N_LOG_AR));
				I_I1_REG2       <= std_logic_vector(to_unsigned(3,N_LOG_AR));
				I_I1_IMM_OPR 	<=  X"41400000";
				I_I1_DEST       <= std_logic_vector(to_unsigned(9,N_LOG_AR));
				
				I_I2_VAL <= '1' ;
				I_OPCODE2  <= OPCODE_BRN ;
				I_CTRL2 <= "000110000000000000000000100";
				I_I2_DECODE_BR_BITS <= '1' & '0' & "0010" & "0011";
				I_I2_REG1 <= std_logic_vector(to_unsigned(2,N_LOG_AR));
				I_I2_REG2 <= std_logic_vector(to_unsigned(3,N_LOG_AR));
				I_I2_IMM_OPR 	<=  X"40900000";
				I_I2_DEST <= (others => '0');
				
			elsif (v_count = 6) then
			
				I_OPCODE1  <= OPCODE_FPU ;
				I_SHAMT1   <= (others => '0');
				I_FUNC1    <= "000001";
				I_I1_VAL   <= '1';
				I_I1_DECODE_BR_BITS <= '1' & '0' & "0010" & "0011";
				I_I1_REG1       <= std_logic_vector(to_unsigned(4,N_LOG_AR));
				I_I1_REG2       <= std_logic_vector(to_unsigned(5,N_LOG_AR));
				I_I1_DEST       <= std_logic_vector(to_unsigned(12,N_LOG_AR));
				
				I_CTRL1         <= (IND_REG_WR => '1', IND_REG_AM => '1', IND_FPU_INSTR => '1', others => '0');
				
				I_I2_VAL <= '1' ;
				I_OPCODE2  <= OPCODE_FPU ;
				I_SHAMT2   <= (others => '0');
				I_FUNC2    <= "000001";
				I_CTRL2   <= (IND_REG_WR => '1', IND_REG_AM => '1', IND_FPU_INSTR => '1', others => '0');
				I_I2_DECODE_BR_BITS <= '1' & '0' & "0010" & "0011";
				I_I2_REG1 <= std_logic_vector(to_unsigned(6,N_LOG_AR));
				I_I2_REG2 <= std_logic_vector(to_unsigned(7,N_LOG_AR));
				I_I2_DEST <= std_logic_vector(to_unsigned(13,N_LOG_AR));
				
			elsif (v_count = 7) then
			
				I_OPCODE1  <= OPCODE_FPU ;
				I_SHAMT1   <= (others => '0');
				I_FUNC1    <= "000001";
				I_I1_VAL   <= '1';
				I_I1_DECODE_BR_BITS <= '0' & '0' & "0010" & "0011";
				I_I1_REG1       <= std_logic_vector(to_unsigned(10,N_LOG_AR));
				I_I1_REG2       <= std_logic_vector(to_unsigned(1,N_LOG_AR));
				I_I1_DEST       <= std_logic_vector(to_unsigned(2,N_LOG_AR));
				I_CTRL1         <= (IND_REG_WR => '1', IND_REG_AM => '1', IND_FPU_INSTR => '1', others => '0');
				
				I_I2_VAL <= '1' ;
				I_OPCODE2  <= OPCODE_FPU ;
				I_SHAMT2   <= (others => '0');
				I_FUNC2    <= "000001";
				I_CTRL2   <= (IND_REG_WR => '1', IND_REG_AM => '1', IND_FPU_INSTR => '1', others => '0');
				I_I2_DECODE_BR_BITS <= '0' & '0' & "0010" & "0011";
				I_I2_REG1 <= std_logic_vector(to_unsigned(2,N_LOG_AR));
				I_I2_REG2 <= std_logic_vector(to_unsigned(4,N_LOG_AR));
				I_I2_DEST <= std_logic_vector(to_unsigned(3,N_LOG_AR));
				
			elsif (v_count = 8) then
			
				I_OPCODE1  <= OPCODE_FPU ;
				I_SHAMT1   <= (others => '0');
				I_FUNC1    <= "000001";
				I_I1_VAL   <= '1';
				I_I1_DECODE_BR_BITS <= '0' & '0' & "0000" & "0011";
				I_I1_REG1       <= std_logic_vector(to_unsigned(3,N_LOG_AR));
				I_I1_REG2       <= std_logic_vector(to_unsigned(4,N_LOG_AR));
				I_I1_DEST       <= std_logic_vector(to_unsigned(5,N_LOG_AR));
				
				I_CTRL1         <= (IND_REG_WR => '1', IND_REG_AM => '1', IND_FPU_INSTR => '1', others => '0');
				
				I_I2_VAL <= '1' ;
				I_OPCODE2  <= OPCODE_FPU ;
				I_SHAMT2   <= (others => '0');
				I_FUNC2    <= "000001";
				I_CTRL2   <= (IND_REG_WR => '1', IND_REG_AM => '1', IND_FPU_INSTR => '1', others => '0');
				I_I2_DECODE_BR_BITS <= '0' & '0' & "0000" & "0011";
				I_I2_REG1 <= std_logic_vector(to_unsigned(6,N_LOG_AR));
				I_I2_REG2 <= std_logic_vector(to_unsigned(5,N_LOG_AR));
				I_I2_DEST <= std_logic_vector(to_unsigned(6,N_LOG_AR));

			elsif (v_count = 9) then
			
				I_OPCODE1  <= OPCODE_FPU ;
				I_SHAMT1   <= (others => '0');
				I_FUNC1    <= "000001";
				I_I1_VAL   <= '1';
				I_I1_REG1       <= std_logic_vector(to_unsigned(5,N_LOG_AR));
				I_I1_REG2       <= std_logic_vector(to_unsigned(6,N_LOG_AR));
				I_I1_DEST       <= std_logic_vector(to_unsigned(7,N_LOG_AR));
				I_I1_DECODE_BR_BITS <= '0' & '0' & "0000" & "0011";
				I_CTRL1         <= (IND_REG_WR => '1', IND_REG_AM => '1', IND_FPU_INSTR => '1', others => '0');
				
				I_I2_VAL <= '1' ;
				I_OPCODE2  <= OPCODE_FPU ;
				I_SHAMT2   <= (others => '0');
				I_FUNC2    <= "000001";
				I_CTRL2   <= (IND_REG_WR => '1', IND_REG_AM => '1', IND_FPU_INSTR => '1', others => '0');
				I_I2_DECODE_BR_BITS <= '0' & '0' & "0000" & "0011";
				I_I2_REG1 <= std_logic_vector(to_unsigned(7,N_LOG_AR));
				I_I2_REG2 <= std_logic_vector(to_unsigned(8,N_LOG_AR));
				I_I2_DEST <= std_logic_vector(to_unsigned(9,N_LOG_AR));

			elsif (v_count = 10) then
			
				I_OPCODE1  <= OPCODE_FPU ;
				I_SHAMT1   <= (others => '0');
				I_FUNC1    <= "000001";
				I_I1_VAL   <= '1';
				I_I2_DECODE_BR_BITS <= '0' & '0' & "0000" & "0011";
				I_I1_REG1       <= std_logic_vector(to_unsigned(1,N_LOG_AR));
				I_I1_REG2       <= std_logic_vector(to_unsigned(2,N_LOG_AR));
				I_I1_DEST       <= std_logic_vector(to_unsigned(7,N_LOG_AR));
				
				I_CTRL1         <= (IND_REG_WR => '1', IND_REG_AM => '1', IND_FPU_INSTR => '1', others => '0');
				
				I_I2_VAL <= '0' ;
				I_OPCODE2  <= OPCODE_FPU ;
				I_SHAMT2   <= (others => '0');
				I_FUNC2    <= "000001";
				I_CTRL2   <= (IND_REG_WR => '1', IND_REG_AM => '1', IND_FPU_INSTR => '1', others => '0');
				I_I2_DECODE_BR_BITS <= '0' & '0' & "0000" & "0011";
				I_I2_REG1 <= std_logic_vector(to_unsigned(7,N_LOG_AR));
				I_I2_REG2 <= std_logic_vector(to_unsigned(8,N_LOG_AR));
				I_I2_DEST <= std_logic_vector(to_unsigned(9,N_LOG_AR));
				
			else
				I_I1_VAL <= '0' ;
				I_I2_VAL <= '0' ;
			end if;
			
			if (I_I1_VAL = '1') then
				I_PC1 <= std_logic_vector(unsigned(I_PC1) + to_unsigned(2,32));
			end if;

			if (I_I2_VAL = '1') then
				I_PC2 <= std_logic_vector(unsigned(I_PC2) + to_unsigned(2,32));
			end if;
			
			wait for 10 ns;
			
			
			CLK <= '1';
			
			wait for 10 ns;
			
			v_count := v_count + 1;
		end loop;
		
		wait;

	end process;	
		
end architecture;