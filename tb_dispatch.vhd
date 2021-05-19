library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG_DISPATCH_STG.all;

entity tb is end entity ;

architecture ARCH1 of tb is

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
			 -- status bits
			 I_I1_STS, I_I2_STS   : in std_logic_vector(2 downto 0);
			 -- program counter 
			 I_PC1, I_PC2 : in std_logic_vector( 31 downto 0 );
			 -- ARCHITECTURAL REGISTERS --
			 I_I1_REG1, I_I1_REG2 : in std_logic_vector(N_LOG_AR-1 downto 0 );
			 I_I2_REG1, I_I2_REG2 : in std_logic_vector(N_LOG_AR-1 downto 0 );
			 I_I1_DEST, I_I2_DEST : in std_logic_vector(N_LOG_AR-1 downto 0 );
			 
			 -- FORWARDED INPUTS --
			 I_TAG_FWD_SLOT : in T_ARR4_SLV_TAG ;
			 I_FWD_SLOT_VAL : in std_logic_vector(3 downto 0);
			 I_OPR_FWD_SLOT : in T_ARR4_SLV32 ;   
			 
			 -- INPUTS FROM REORDER BUFFER --
			 -- 2 free locations in ROB
			 I_ROB_FREE_LOC1, I_ROB_FREE_LOC2 : in std_logic_vector( N_LOG_ROB - 1 downto 0) ;	
			 -- write enable signals for ARF
			 I_ROB_REG_WR1, I_ROB_REG_WR2 : in std_logic; 
			 -- rename reg ids 
			 I_ROB_RNME_REG1, I_ROB_RNME_REG2 : in std_logic_vector( N_LOG_RR-1 downto 0 );
			 -- arch reg ids 
			 I_ROB_ARCH_REG1, I_ROB_ARCH_REG2 : in std_logic_vector( N_LOG_AR-1 downto 0 );
			 
		  
			 -- OUTPUTS TO RESERVATION STATION --	
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
			 
			 -- OUTPUTS TO REORDER BUFFER --
			 O_PC1, O_PC2 : out std_logic_vector( 31 downto 0 );
			 O_I1 , O_I2 : out std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);			 			 
			 O_I1_CTRL, O_I2_CTRL : out std_logic_vector(N_CTRL_BITS - 1 downto 0);			 
			 O_I1_VALID, O_I2_VALID : out std_logic ;			 
			 O_I1_STS, O_I2_STS : out std_logic_vector(2 downto  0);
			 O_I1_ARCH_REG, O_I2_ARCH_REG : out std_logic_vector(N_LOG_AR-1 downto 0) ;
			 O_I1_RNME_REG, O_I2_RNME_REG : out std_logic_vector(N_LOG_RR-1 downto 0);
			 
			 
			 -- OUTPUTS TO FETCH AND DECODE --
			 O_STALL : out std_logic ;
			 
			 -- TEMP OUTPUTS --
			 O_RR1_VAL, O_RR2_VAL : out std_logic ;
			 O_RNME_REG_BUSY, O_RNME_REG_VALID,O_ARCH_REG_LOCK : out std_logic_vector(31 downto 0) );

			 
end component; 

signal			 CLK, RST : std_logic;
			 -- INPUTS FROM DECODE STAGE --
			 -- opcodes, shift and functional bits --
signal			 I_OPCODE1, I_OPCODE2 :  std_logic_vector(N_OPCODE_BITS-1 downto 0);
signal			 I_FUNC1, I_FUNC2		 :  std_logic_vector(N_FUNC_BITS-1 downto 0);
signal			 I_SHAMT1, I_SHAMT2   :  std_logic_vector(N_SHAMT_BITS-1 downto 0);
			 
			 -- control signals
signal			 I_CTRL1, I_CTRL2     :  std_logic_vector(N_CTRL_BITS-1 downto 0);
			 
			 -- valid bits
signal			 I_I1_VAL, I_I2_VAL   :  std_logic;
			 -- status bits
signal			 I_I1_STS, I_I2_STS   :  std_logic_vector(2 downto 0);
			 -- program counter 
signal			 I_PC1, I_PC2 :  std_logic_vector( 31 downto 0 );
			 -- ARCHITECTURAL REGISTERS --
signal			 I_I1_REG1, I_I1_REG2 :  std_logic_vector(N_LOG_AR-1 downto 0 );
signal			 I_I2_REG1, I_I2_REG2 :  std_logic_vector(N_LOG_AR-1 downto 0 );
signal			 I_I1_DEST, I_I2_DEST :  std_logic_vector(N_LOG_AR-1 downto 0 );
			 
			 -- FORWARDED INPUTS --
signal			 I_TAG_FWD_SLOT :  T_ARR4_SLV_TAG ;
signal			 I_FWD_SLOT_VAL :  std_logic_vector(3 downto 0);
signal			 I_OPR_FWD_SLOT :  T_ARR4_SLV32 ;   
			 
			 -- INPUTS FROM REORDER BUFFER --
			 -- 2 free locations in ROB
signal			 I_ROB_FREE_LOC1, I_ROB_FREE_LOC2 :  std_logic_vector( N_LOG_ROB - 1 downto 0) ;	
			 -- write enable signals for ARF
signal			 I_ROB_REG_WR1, I_ROB_REG_WR2 :  std_logic; 
			 -- rename reg ids 
signal			 I_ROB_RNME_REG1, I_ROB_RNME_REG2 :  std_logic_vector( N_LOG_RR-1 downto 0 );
			 -- arch reg ids 
signal			 I_ROB_ARCH_REG1, I_ROB_ARCH_REG2 :  std_logic_vector( N_LOG_AR-1 downto 0 );
			 
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
signal			 O_I1_STS, O_I2_STS :  std_logic_vector(2 downto  0);
signal			 O_I1_ARCH_REG, O_I2_ARCH_REG :  std_logic_vector(N_LOG_AR-1 downto 0) ;
			 
			 -- OUTPUTS TO FETCH AND DECODE --
signal			 O_STALL :  std_logic   ;
signal 			 O_RR1_VAL, O_RR2_VAL : std_logic;

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
signal O_RNME_REG_BUSY, O_RNME_REG_VALID,O_ARCH_REG_LOCK : std_logic_vector(31 downto 0) ;
begin

I_FUNC1 <= (others => '0');
I_FUNC2 <= (others => '0');
I_SHAMT1 <= (others => '0');
I_SHAMT2 <= (others => '0');
I_I1_STS <= (others => '0');
I_I2_STS <= (others => '0');



DUT : DISPATCH_STAGE	port map ( 
												 CLK => CLK, RST => RST, 
												 
												 -- INPUTS FROM DECODE STAGE --
												 -- opcodes, shift and functional bits --
												 I_OPCODE1 => I_OPCODE1, I_OPCODE2 => I_OPCODE2,
												 I_FUNC1 => I_FUNC1, I_FUNC2	=> I_FUNC2 ,
												 I_SHAMT1 => I_SHAMT1 , I_SHAMT2 => I_SHAMT2 ,
												 
												 -- control signals
												 I_CTRL1 => I_CTRL1, I_CTRL2 => I_CTRL2 , 
												 
												 -- valid bits
												 I_I1_VAL => I_I1_VAL, I_I2_VAL => I_I2_VAL, 
												 
												 -- status bits
												 I_I1_STS => I_I1_STS, I_I2_STS => I_I2_STS ,
												 
												 -- program counter 
												 I_PC1 => I_PC1, I_PC2 => I_PC2 ,												 
												 
												 -- ARCHITECTURAL REGISTERS --
												 I_I1_REG1 => I_I1_REG1, I_I1_REG2 => I_I1_REG2 ,
												 I_I2_REG1 => I_I2_REG1, I_I2_REG2 => I_I2_REG2 ,
												 I_I1_DEST => I_I1_DEST, I_I2_DEST => I_I2_DEST ,
												 
												 -- FORWARDED INPUTS --
												 I_TAG_FWD_SLOT => I_TAG_FWD_SLOT ,
												 I_FWD_SLOT_VAL => I_FWD_SLOT_VAL ,
												 I_OPR_FWD_SLOT => I_OPR_FWD_SLOT ,
												 
												 -- INPUTS FROM REORDER BUFFER --
												 -- 2 free locations in ROB
												 I_ROB_FREE_LOC1 => I_ROB_FREE_LOC1, I_ROB_FREE_LOC2 => I_ROB_FREE_LOC2,	
												 -- write enable signals for ARF
												 I_ROB_REG_WR1 => I_ROB_REG_WR1, I_ROB_REG_WR2 => I_ROB_REG_WR2, 
												 -- rename reg ids 
												 I_ROB_RNME_REG1 => I_ROB_RNME_REG1, I_ROB_RNME_REG2 => I_ROB_RNME_REG2,
												 -- arch reg ids 
												 I_ROB_ARCH_REG1 => I_ROB_ARCH_REG1, I_ROB_ARCH_REG2 => I_ROB_ARCH_REG2,
												 
												 -- COMMON OUTPUTS -- 

												 -- OUTPUTS TO RESERVATION STATION --	
												 O_DS1_ALU_OPR1 => O_DS1_ALU_OPR1, O_DS1_ALU_OPR2 => O_DS1_ALU_OPR2,
												 O_DS1_ALU_VAL => O_DS1_ALU_VAL, 
												 O_DS1_ALU_OPR1_VAL => O_DS1_ALU_OPR1_VAL, 
												 O_DS1_ALU_OPR2_VAL => O_DS1_ALU_OPR2_VAL ,
												 O_DS1_ALU_ROB_LOC => O_DS1_ALU_ROB_LOC ,
												 O_DS1_ALU_INSTR => O_DS1_ALU_INSTR ,
												 O_DS1_ALU_CTRL  => O_DS1_ALU_CTRL ,
												 O_DS1_ALU_RR    => O_DS1_ALU_RR ,
												 
												 O_DS2_ALU_OPR1 => O_DS2_ALU_OPR1, O_DS2_ALU_OPR2 => O_DS2_ALU_OPR2 ,
												 O_DS2_ALU_VAL => O_DS2_ALU_VAL, O_DS2_ALU_OPR1_VAL => O_DS2_ALU_OPR1_VAL, 
												 O_DS2_ALU_OPR2_VAL => O_DS2_ALU_OPR2_VAL ,
												 O_DS2_ALU_ROB_LOC => O_DS2_ALU_ROB_LOC , 
												 O_DS2_ALU_INSTR => O_DS2_ALU_INSTR ,
												 O_DS2_ALU_CTRL => O_DS2_ALU_CTRL ,
												 O_DS2_ALU_RR => O_DS2_ALU_RR ,
												 
												 O_DS1_FPU_OPR1 => O_DS1_FPU_OPR1, O_DS1_FPU_OPR2 => O_DS1_FPU_OPR2 ,
												 O_DS1_FPU_VAL=> O_DS1_FPU_VAL, 
												 O_DS1_FPU_OPR1_VAL => O_DS1_FPU_OPR1_VAL, 
												 O_DS1_FPU_OPR2_VAL => O_DS1_FPU_OPR2_VAL ,
												 O_DS1_FPU_ROB_LOC  => O_DS1_FPU_ROB_LOC ,
												 O_DS1_FPU_INSTR => O_DS1_FPU_INSTR ,
												 O_DS1_FPU_CTRL  => O_DS1_FPU_CTRL ,
												 O_DS1_FPU_RR    => O_DS1_FPU_RR ,
												 
												 O_DS2_FPU_OPR1 => O_DS2_FPU_OPR1, O_DS2_FPU_OPR2 => O_DS2_FPU_OPR2 ,
												 O_DS2_FPU_VAL => O_DS2_FPU_VAL, O_DS2_FPU_OPR1_VAL=> O_DS2_FPU_OPR1_VAL, 
												 O_DS2_FPU_OPR2_VAL => O_DS2_FPU_OPR2_VAL ,
												 O_DS2_FPU_ROB_LOC  => O_DS2_FPU_ROB_LOC ,
												 O_DS2_FPU_INSTR => O_DS2_FPU_INSTR ,
												 O_DS2_FPU_CTRL  => O_DS2_FPU_CTRL ,
												 O_DS2_FPU_RR    => O_DS2_FPU_RR ,
												 
												 -- OUTPUTS TO REORDER BUFFER --
												 O_PC1 => O_PC1, O_PC2 => O_PC2,												 
												 O_I1 => O_I1, O_I2 => O_I2 ,
												 O_I1_CTRL => O_I1_CTRL, O_I2_CTRL => O_I2_CTRL,
												 O_I1_VALID => O_I1_VALID, O_I2_VALID => O_I2_VALID ,
												 O_I1_STS => O_I1_STS, O_I2_STS => O_I2_STS,												 
												 O_I1_ARCH_REG => O_I1_ARCH_REG, O_I2_ARCH_REG => O_I2_ARCH_REG,												 
												 O_I1_RNME_REG => O_I1_RNME_REG, O_I2_RNME_REG => O_I2_RNME_REG ,
						 
												 -- OUTPUTS TO FETCH AND DECODE --
												 O_STALL => O_STALL,  O_RR1_VAL => O_RR1_VAL, O_RR2_VAL => O_RR2_VAL ,
												 O_RNME_REG_BUSY=> O_RNME_REG_BUSY, 
												 O_RNME_REG_VALID => O_RNME_REG_VALID,
												 O_ARCH_REG_LOCK  => O_ARCH_REG_LOCK );	

	process
	variable v_count : integer := 0;
	begin
		for i in 0 to 63 loop
			CLK <= '0';
			
			wait for 1ps;
			
			if (v_count < 2) then
				RST <= '1';
			else 
				RST <= '0';
			end if ;
			
			if (v_count = 3) then
					I_OPCODE1 <= OPCODE_ALU ;
					I_OPCODE2 <= OPCODE_FPU ;
					I_FUNC1 <= "000101" ;
					I_FUNC2 <= "011101" ;
					I_SHAMT1 <= "00111" ;
					I_SHAMT2 <= "11111" ;
					
					I_CTRL1 <= (0 => '1' , others => '0');
					I_CTRL2 <= (0 => '1' , others => '0');
					I_I1_VAL <= '1';
					I_I2_VAL <= '1';
					I_PC1 <= std_logic_vector(to_unsigned(1,32));
					I_PC2 <= std_logic_vector(to_unsigned(5,32));
					I_I1_REG1 <= "00001" ;
					I_I1_REG2 <= "00010" ;
					I_I2_REG1 <= "00101" ;
					I_I2_REG2 <= "00110" ;
					I_I1_DEST <= "00011" ;
					I_I2_DEST <= "01110" ;
					I_ROB_FREE_LOC1 <= std_logic_vector(to_unsigned(10, N_LOG_ROB));
					I_ROB_FREE_LOC2 <= std_logic_vector(to_unsigned(11, N_LOG_ROB));
					I_ROB_REG_WR1 <= '0';
					I_ROB_REG_WR2 <= '0';
					I_ROB_RNME_REG1 <= "00001";
					I_ROB_RNME_REG2 <= "00001";
			elsif (v_count = 7) then
			
					I_TAG_FWD_SLOT(0) <= "00111" ;
					I_TAG_FWD_SLOT(2) <= "00011" ;
					I_FWD_SLOT_VAL <= "0101";
					I_OPR_FWD_SLOT(0) <= X"0F0F0F0F" ;   
					I_OPR_FWD_SLOT(2) <= X"01010101" ;   
					
			elsif (v_count = 8) then
					I_FWD_SLOT_VAL <= "0000";					
			elsif (v_count = 10) then
					I_ROB_REG_WR1 <= '1';
					I_ROB_REG_WR2 <= '1';
					I_ROB_RNME_REG1 <= "00111";
					I_ROB_RNME_REG2 <= "00101";
					I_ROB_ARCH_REG1 <= "00001";
					I_ROB_ARCH_REG2 <= "01001";
					
			elsif (v_count = 11) then
					I_ROB_REG_WR1 <= '1';
					I_ROB_REG_WR2 <= '1';
					I_ROB_RNME_REG1 <= "00000";
					I_ROB_RNME_REG2 <= "00011";
					I_ROB_ARCH_REG1 <= "00001";
					I_ROB_ARCH_REG2 <= "01001";
					
			end if;
			
			
			wait for 10ns;
			
			
			CLK <= '1';
			
			wait for 10ns;
			
			v_count := v_count + 1;
		end loop;
	wait;
	end process;
												 

end architecture;

