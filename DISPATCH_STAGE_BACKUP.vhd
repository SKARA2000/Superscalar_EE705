library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ENCODER32x5 is
	port (	INPUT : in std_logic_vector(31 downto 0) ;
				VALID : out std_logic ;	
				OUTPUT : out std_logic_vector(4 downto 0) );
end entity;

architecture ARCH1 of ENCODER32x5 is

begin

	VALID <= '0' when INPUT = X"FFFFFFFF" else '1' ;
	
	process(INPUT)
	variable v_free_loc : std_logic_vector(4 downto 0) ;
	begin
		v_free_loc := "00000";
		for i in 31 downto 0 loop
			if (INPUT(i) = '0') then 
				v_free_loc := std_logic_vector(to_unsigned(i,5)); 
			end if;
		end loop;
		OUTPUT <= v_free_loc ;
	end process;

end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG_COMMON.all;

entity DISPATCH_STAGE is
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

end entity; 

architecture ARCH1 of DISPATCH_STAGE is 

signal ARCH_REG_FILE : T_ARCH_REGFILE ;
signal ARCH_REG_LOCK : std_logic_vector( N_ARCH_REG-1 downto 0 );
signal ARCH_REG_TAG : T_ARF_TAG;

signal RNME_REG_FILE : T_RNME_REGFILE ;
signal RNME_REG_BUSY, RNME_REG_VALID : std_logic_vector(N_RNME_REG-1 downto 0) := (others => '0');
signal RNME_REG_FREE_PTR : T_RNME_REG_PTR ;
signal RR_WR_EN : std_logic_vector( N_RNME_REG-1 downto 0 );

-- ARF SIGNALS --
signal REG_WRITE_I1, REG_WRITE_I2 : std_logic ;
signal I2_RAW_IMM1, I2_RAW_IMM2 : std_logic ;
signal OPR, OPR_RTYPE : T_ARR4_SLV32 ;
signal OPR_VAL : std_logic_vector(3 downto 0);
signal IS_STALL1 : std_logic ;

signal ARF_TAG1, ARF_TAG2 : std_logic_vector(N_LOG_RR-1 downto 0);
signal WR_ARF_DATA1, WR_ARF_DATA2 : std_logic_vector(31 downto 0);
signal WR_ARF_VAL1, WR_ARF_VAL2 : std_logic;
signal NO_PEND_WRITE1 , NO_PEND_WRITE2 : std_logic ;


signal IN_ENCODER : T_ARR4_SLV4 ;
signal TAG_MATCH_LOC : T_ARR4_SLV2 ;
signal TAG_MATCH_VAL : std_logic_vector(3 downto 0);

signal OPR1_NEXT, OPR2_NEXT, OPR3_NEXT, OPR4_NEXT : std_logic_vector(31 downto 0);
signal OPR1_VAL_NEXT, OPR2_VAL_NEXT, OPR3_VAL_NEXT, OPR4_VAL_NEXT : std_logic;


-- RRF SIGNALS --
signal WR_EN1_RR, WR_EN2_RR : std_logic ;
signal DSP_RD_REG1, DSP_RD_REG2, DSP_RD_REG3, DSP_RD_REG4 : std_logic_vector(N_LOG_RR-1 downto 0);
signal DSP_RD_DATA1_VALID, DSP_RD_DATA2_VALID, DSP_RD_DATA3_VALID, DSP_RD_DATA4_VALID : std_logic;
signal RNME_REG1 , RNME_REG2 : std_logic_vector(N_LOG_RR-1 downto 0);	
signal RR1_VAL, RR2_VAL : std_logic;
signal DSP_RD_DATA1, DSP_RD_DATA2, DSP_RD_DATA3, DSP_RD_DATA4 : std_logic_vector(31 downto 0);
signal FREE_REG1_VAL, FREE_REG2_VAL : std_logic ;
signal S_FREE_REG1, S_FREE_REG2 : std_logic_vector(N_LOG_RR-1 downto 0);
signal INPUT_ENC_L2 : T_ARR32_SLV32 ;
signal ENC_L2_VAL : std_logic_vector(31 downto 0);
signal S_FREE_REG_L2 : T_ARR32_SLV5 ;
signal FREE_RNME_REG1, FREE_RNME_REG2 : std_logic ;


signal ALU_FUNC : std_logic_vector(5 downto 0);
signal ALU_INSTR : std_logic_vector ( N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
signal ALU_DEST  : std_logic_vector(N_LOG_RR-1 downto 0);
signal ALU_ROB   : std_logic_vector(N_LOG_ROB-1 downto 0);

signal FPU_OPR1, FPU_OPR2 : std_logic_vector(31 downto 0);
signal FPU_OPR1_VAL, FPU_OPR2_VAL : std_logic ;
signal FPU_FUNC : std_logic_vector(5 downto 0);
signal FPU_INSTR : std_logic_vector ( N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
signal FPU_DEST  : std_logic_vector(N_LOG_RR-1 downto 0);
signal FPU_ROB   : std_logic_vector(N_LOG_ROB-1 downto 0);

signal DS1_ALU_VAL, DS2_ALU_VAL, DS1_FPU_VAL, DS2_FPU_VAL : std_logic ;
signal DS1_BRN_VAL, DS2_BRN_VAL, DS1_MEM_VAL, DS2_MEM_VAL : std_logic ;

--signal MEM_OPR1, MEM_OPR2 : std_logic_vector(31 downto 0);
--signal MEM_OPR1_VAL, MEM_OPR2_VAL : std_logic ;
--signal MEM_FUNC : std_logic_vector(5 downto 0);
--signal MEM_INSTR : std_logic_vector ( N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
--signal MEM_DEST  : std_logic_vector(N_LOG_RR-1 downto 0);
--signal MEM_ROB   : std_logic_vector(N_LOG_ROB-1 downto 0);
--
--signal BRN_OPR1, BRN_OPR2 : std_logic_vector(31 downto 0);
--signal BRN_OPR1_VAL, BRN_OPR2_VAL : std_logic ;
--signal BRN_FUNC : std_logic_vector(5 downto 0);
--signal BRN_INSTR : std_logic_vector ( N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
--signal BRN_DEST  : std_logic_vector(N_LOG_RR-1 downto 0);
--signal BRN_ROB   : std_logic_vector(N_LOG_ROB-1 downto 0);

signal S_INSTR1 , S_INSTR2 : std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);	
signal ROB_LOC1_CURR_CYCLE, ROB_LOC2_CURR_CYCLE	: 	std_logic_vector( N_LOG_ROB-1 downto 0 ); 

signal BR_TAG1_FROM_DISPATCH, BR_TAG2_FROM_DISPATCH : std_logic_vector(3 downto 0);
signal BR_TAG_I1, BR_TAG_I2 : std_logic_vector(3 downto 0);
signal I1_BR_FIELD_NEXT, I2_BR_FIELD_NEXT : std_logic_vector(N_BR_BITS_FOR_RS-1 downto 0);
signal I1_SPEC_BIT, I2_SPEC_BIT : std_logic ;
signal I1_VAL_NEXT, I2_VAL_NEXT : std_logic ;
		   
component ENCODER32x5 is
	port (	INPUT : in std_logic_vector(31 downto 0) ;
				VALID : out std_logic ;	
				OUTPUT : out std_logic_vector(4 downto 0) );
end component;


begin
	
		O_ARF 		<= ARCH_REG_FILE;
		O_RRF 		<= RNME_REG_FILE;
		O_ARF_TAG 	<= ARCH_REG_TAG;
		O_RR_BUSY 	<= RNME_REG_BUSY;
		
		O_STALL <= IS_STALL1 ;
		
		O_RR1_VAL <= RR1_VAL;
		O_RR2_VAL <= RR2_VAL;
		
		
		DS1_ALU_VAL <= I1_VAL_NEXT when I_CTRL1(IND_ALU_INSTR) = '1' else 
							'0' ;
		DS2_ALU_VAL <= I2_VAL_NEXT when I_CTRL2(IND_ALU_INSTR) = '1' else 
							'0' ;
		DS1_FPU_VAL <= I1_VAL_NEXT when I_CTRL1(IND_FPU_INSTR) = '1' else 
							'0' ;
		DS2_FPU_VAL <= I2_VAL_NEXT when I_CTRL2(IND_FPU_INSTR) = '1' else 
							'0' ;

		DS1_BRN_VAL <= I1_VAL_NEXT when I_CTRL1(IND_BRN_INSTR) = '1' else 
							'0' ;
		DS2_BRN_VAL <= I2_VAL_NEXT when I_CTRL2(IND_BRN_INSTR) = '1' else 
							'0' ;

		DS1_MEM_VAL <= I1_VAL_NEXT when I_CTRL1(IND_MEM_INSTR) = '1' else 
							'0' ;
		DS2_MEM_VAL <= I2_VAL_NEXT when I_CTRL2(IND_MEM_INSTR) = '1' else 
							'0' ;
							
		S_INSTR1 <= I_OPCODE1 & I_SHAMT1 & I_FUNC1 ;
		
		S_INSTR2 <= I_OPCODE2 & I_SHAMT2 & I_FUNC2 ;
		
		O_ROB_PC1 <= I_PC1;
		O_ROB_PC2 <= I_PC2;

		O_ROB_I1  <= S_INSTR1 ;
		O_ROB_I2  <= S_INSTR2 ;

		O_ROB_I1_CTRL <= I_CTRL1;
		O_ROB_I2_CTRL <= I_CTRL2;
				
		O_ROB_I1_VALID <= I1_VAL_NEXT ;
		O_ROB_I2_VALID <= I2_VAL_NEXT ;
				
		O_ROB_I1_ARCH_REG   <= I_I1_DEST ;
		O_ROB_I2_ARCH_REG   <= I_I2_DEST ;
				
		O_ROB_I1_RNME_REG  	<= RNME_REG1 ;
		O_ROB_I2_RNME_REG  	<= RNME_REG2 ;

		O_ROB_I1_BR_FIELD 	<= I1_BR_FIELD_NEXT;	
		O_ROB_I2_BR_FIELD 	<= I2_BR_FIELD_NEXT;	

		
		ROB_LOC1_CURR_CYCLE <= I_ROB_FREE_LOC1 ;
		ROB_LOC2_CURR_CYCLE <= I_ROB_FREE_LOC1 when I1_VAL_NEXT = '0' else I_ROB_FREE_LOC2;
		
		BR_TAG1_FROM_DISPATCH <=  I_I1_BR_FIELD(7 downto 4);
		BR_TAG2_FROM_DISPATCH <=  I_I2_BR_FIELD(7 downto 4);
		
		BR_TAG_I1 <= std_logic_vector(unsigned(BR_TAG1_FROM_DISPATCH) - to_unsigned(1,4)) when (I_ROB_BR_VAL = '1' and I_BR_RES = '1') else
						 BR_TAG1_FROM_DISPATCH ;
						 
		BR_TAG_I2 <= std_logic_vector(unsigned(BR_TAG2_FROM_DISPATCH) - to_unsigned(1,4)) when (I_ROB_BR_VAL = '1' and I_BR_RES = '1') else
						 BR_TAG2_FROM_DISPATCH ;
				
		I1_SPEC_BIT <=  '0' when (BR_TAG_I1 = "0000") else
							 I_I1_BR_FIELD(9) ;
							 
		I2_SPEC_BIT <=  '0' when (BR_TAG_I2 = "0000") else
							 I_I2_BR_FIELD(9) ;
		
		I1_BR_FIELD_NEXT <= I1_SPEC_BIT & I_I1_BR_FIELD(8) &  BR_TAG_I1 & I_I1_BR_FIELD(3 downto 0) ;
		I2_BR_FIELD_NEXT <= I2_SPEC_BIT & I_I2_BR_FIELD(8) &  BR_TAG_I2 & I_I2_BR_FIELD(3 downto 0) ;
		
		I1_VAL_NEXT <= '0' when (I_ROB_BR_VAL = '1' and I_BR_RES = '0') else	
							I_I1_VAL ;
							
		I2_VAL_NEXT <= '0' when (I_ROB_BR_VAL = '1' and I_BR_RES = '0') else	
							I_I2_VAL ;
		
		-- OUTPUTS --
		process (CLK)
		begin
			if (rising_edge(CLK)) then
				-- Common outputs To reorder buffer
				O_PC1 <= I_PC1;
				O_PC2 <= I_PC2;

				O_I1  <= S_INSTR1 ;
				O_I2  <= S_INSTR2 ;

				O_I1_CTRL <= I_CTRL1;
				O_I2_CTRL <= I_CTRL2;
				
				O_I1_VALID <= I1_VAL_NEXT ;
				O_I2_VALID <= I2_VAL_NEXT ;
				
			
				O_I1_ARCH_REG   <= I_I1_DEST ;
				O_I2_ARCH_REG   <= I_I2_DEST ;
				
				O_I1_RNME_REG  <= RNME_REG1 ;
				O_I2_RNME_REG  <= RNME_REG2 ;

				--O_I1_BR_FIELD 	  <= I_I1_BR_FIELD;	
				--O_I2_BR_FIELD 	  <= I_I2_BR_FIELD;	
				O_I1_BR_FIELD 		  <= I1_BR_FIELD_NEXT ;
				O_I2_BR_FIELD 		  <= I2_BR_FIELD_NEXT ;
				
				-- Common outputs to Reservation Station -
				O_DS_ALL_IMM_OPR1 <= I_I1_IMM_OPR ;
				O_DS_ALL_IMM_OPR2 <= I_I2_IMM_OPR ;
				
				-- Outputs to Reservation stations --
				O_DS1_ALU_VAL  <= DS1_ALU_VAL ;
				O_DS1_ALU_OPR1 <= OPR1_NEXT ;
				O_DS1_ALU_OPR2 <= OPR2_NEXT ;
				O_DS1_ALU_ROB_LOC  <= ROB_LOC1_CURR_CYCLE ;
				O_DS1_ALU_OPR1_VAL <= OPR1_VAL_NEXT ;
				O_DS1_ALU_OPR2_VAL <= OPR2_VAL_NEXT ;
				O_DS1_ALU_INSTR  <= I_OPCODE1 & I_SHAMT1 & I_FUNC1 ;
				O_DS1_ALU_CTRL   <= I_CTRL1;
				O_DS1_ALU_RR     <= RNME_REG1 ;			
				
				O_DS2_ALU_VAL  <= DS2_ALU_VAL;
				O_DS2_ALU_OPR1 <= OPR3_NEXT ;
				O_DS2_ALU_OPR2 <= OPR4_NEXT ;
				O_DS2_ALU_ROB_LOC  <= ROB_LOC2_CURR_CYCLE ;
				O_DS2_ALU_OPR1_VAL <= OPR3_VAL_NEXT ;
				O_DS2_ALU_OPR2_VAL <= OPR4_VAL_NEXT ;
				O_DS2_ALU_INSTR  	<= I_OPCODE2 & I_SHAMT2 & I_FUNC2 ;
				O_DS2_ALU_CTRL 	<= I_CTRL2;				
				O_DS2_ALU_RR     <= RNME_REG2 ;			
				
				--- FPU --
				O_DS1_FPU_VAL  <= DS1_FPU_VAL;
				O_DS1_FPU_OPR1 <= OPR1_NEXT ;
				O_DS1_FPU_OPR2 <= OPR2_NEXT ;
				O_DS1_FPU_ROB_LOC  <= ROB_LOC1_CURR_CYCLE ;
				O_DS1_FPU_OPR1_VAL <= OPR1_VAL_NEXT ;
				O_DS1_FPU_OPR2_VAL <= OPR2_VAL_NEXT ;
				O_DS1_FPU_INSTR  <= I_OPCODE1 & I_SHAMT1 & I_FUNC1 ;
				O_DS1_FPU_CTRL   <= I_CTRL1;
				O_DS1_FPU_RR     <= RNME_REG1 ;
				
				O_DS2_FPU_VAL  <= DS2_FPU_VAL ;
				O_DS2_FPU_OPR1 <= OPR3_NEXT ;
				O_DS2_FPU_OPR2 <= OPR4_NEXT ;
				O_DS2_FPU_ROB_LOC  <= ROB_LOC2_CURR_CYCLE ;
				O_DS2_FPU_OPR1_VAL <= OPR3_VAL_NEXT ;
				O_DS2_FPU_OPR2_VAL <= OPR4_VAL_NEXT ;
				O_DS2_FPU_INSTR  	<= I_OPCODE2 & I_SHAMT2 & I_FUNC2 ;
				O_DS2_FPU_CTRL 	<= I_CTRL2;				
				O_DS2_FPU_RR      <= RNME_REG2 ;
				----------------------------------------------------------------------
				--- BRN --
				O_DS1_BRN_VAL  		<= DS1_BRN_VAL;
				O_DS1_BRN_OPR1 		<= OPR1_NEXT ;
				O_DS1_BRN_OPR2 		<= OPR2_NEXT ;
				O_DS1_BRN_ROB_LOC  	<= ROB_LOC1_CURR_CYCLE ;
				O_DS1_BRN_OPR1_VAL 	<= OPR1_VAL_NEXT ;
				O_DS1_BRN_OPR2_VAL 	<= OPR2_VAL_NEXT ;
				O_DS1_BRN_INSTR  		<= I_OPCODE1 & I_SHAMT1 & I_FUNC1 ;
				O_DS1_BRN_CTRL   		<= I_CTRL1;
				O_DS1_BRN_RR     		<= RNME_REG1 ;
				
				O_DS2_BRN_VAL  		<= DS2_BRN_VAL ;
				O_DS2_BRN_OPR1 		<= OPR3_NEXT ;
				O_DS2_BRN_OPR2 		<= OPR4_NEXT ;
				O_DS2_BRN_ROB_LOC  	<= ROB_LOC2_CURR_CYCLE ;
				O_DS2_BRN_OPR1_VAL 	<= OPR3_VAL_NEXT ;
				O_DS2_BRN_OPR2_VAL 	<= OPR4_VAL_NEXT ;
				O_DS2_BRN_INSTR  		<= I_OPCODE2 & I_SHAMT2 & I_FUNC2 ;
				O_DS2_BRN_CTRL 		<= I_CTRL2;				
				O_DS2_BRN_RR      	<= RNME_REG2 ;
				-----------------------------------------------------------------------
				-- MEM --
				O_DS1_MEM_VAL  		<= DS1_MEM_VAL;
				O_DS1_MEM_OPR1 		<= OPR1_NEXT ;
				O_DS1_MEM_OPR2 		<= OPR2_NEXT ;
				O_DS1_MEM_ROB_LOC  	<= ROB_LOC1_CURR_CYCLE ;
				O_DS1_MEM_OPR1_VAL 	<= OPR1_VAL_NEXT ;
				O_DS1_MEM_OPR2_VAL 	<= OPR2_VAL_NEXT ;
				O_DS1_MEM_INSTR  		<= I_OPCODE1 & I_SHAMT1 & I_FUNC1 ;
				O_DS1_MEM_CTRL   		<= I_CTRL1;
				O_DS1_MEM_RR     		<= RNME_REG1 ;
				
				O_DS2_MEM_VAL  		<= DS2_MEM_VAL ;
				O_DS2_MEM_OPR1 		<= OPR3_NEXT ;
				O_DS2_MEM_OPR2 		<= OPR4_NEXT ;
				O_DS2_MEM_ROB_LOC  	<= ROB_LOC2_CURR_CYCLE ;
				O_DS2_MEM_OPR1_VAL 	<= OPR3_VAL_NEXT ;
				O_DS2_MEM_OPR2_VAL 	<= OPR4_VAL_NEXT ;
				O_DS2_MEM_INSTR  		<= I_OPCODE2 & I_SHAMT2 & I_FUNC2 ;
				O_DS2_MEM_CTRL 		<= I_CTRL2;				
				O_DS2_MEM_RR      	<= RNME_REG2 ;
			
		
		
			end if;
		end process ;
		
		-- DISPATCH  : WRITE SIGNAL --
		REG_WRITE_I1 <= I_CTRL1(IND_REG_WR);
		REG_WRITE_I2 <= I_CTRL2(IND_REG_WR);
		
		
		-- DISPATCH : DEPENDENCY OPERANDS --	
		I2_RAW_IMM1 <= '1' when ( I_I2_REG1 = I_I1_DEST and I1_VAL_NEXT = '1' and I2_VAL_NEXT = '1' and REG_WRITE_I1 = '1' ) else '0' ;
		I2_RAW_IMM2 <= '1' when ( I_I2_REG2 = I_I1_DEST and I1_VAL_NEXT = '1' and I2_VAL_NEXT = '1' and REG_WRITE_I1 = '1' ) else '0' ;
		
		
		OPR_RTYPE(0) <= ARCH_REG_FILE(to_integer(unsigned(I_I1_REG1))) when ARCH_REG_LOCK(to_integer(unsigned(I_I1_REG1))) = '0' else
							 DSP_RD_DATA1 when DSP_RD_DATA1_VALID = '1' else
							 ( std_logic_vector(to_unsigned(0, 32-N_LOG_RR)) & DSP_RD_REG1 ) ;
					
		OPR_RTYPE(1) <= ARCH_REG_FILE(to_integer(unsigned(I_I1_REG2))) when ARCH_REG_LOCK(to_integer(unsigned(I_I1_REG2))) = '0' else
							 DSP_RD_DATA2 when DSP_RD_DATA2_VALID = '1' else
							 ( std_logic_vector(to_unsigned(0, 32-N_LOG_RR)) & DSP_RD_REG2 ) ;
					
		OPR_RTYPE(2) <= (std_logic_vector(to_unsigned(0, 32-N_LOG_RR)) & RNME_REG1) when I2_RAW_IMM1 = '1' else
							 ARCH_REG_FILE(to_integer(unsigned(I_I2_REG1))) when ARCH_REG_LOCK(to_integer(unsigned(I_I2_REG1))) = '0' else
							 DSP_RD_DATA3 when DSP_RD_DATA3_VALID = '1' else
							 std_logic_vector(to_unsigned(0, 32-N_LOG_RR)) & DSP_RD_REG3 ;
					
		OPR_RTYPE(3) <= (std_logic_vector(to_unsigned(0, 32-N_LOG_RR)) & RNME_REG1) when I2_RAW_IMM2 = '1' else
							 ARCH_REG_FILE(to_integer(unsigned(I_I2_REG2))) when ARCH_REG_LOCK(to_integer(unsigned(I_I2_REG2))) = '0' else
							 DSP_RD_DATA4 when DSP_RD_DATA4_VALID = '1' else
							 ( std_logic_vector(to_unsigned(0, 32-N_LOG_RR)) & DSP_RD_REG4 ) ;

		
		OPR(0) <= OPR_RTYPE(0) ;
					
		OPR(1) <= OPR_RTYPE(1) when I_CTRL1(IND_REG_AM) = '1' else
					 I_I1_IMM_OPR ;
					
		OPR(2) <= OPR_RTYPE(2) ;
					
		OPR(3) <= OPR_RTYPE(3) when I_CTRL2(IND_REG_AM) = '1' else
					 I_I2_IMM_OPR ;
					
		OPR_VAL(0) <= '1' when ( ARCH_REG_LOCK(to_integer(unsigned(I_I1_REG1))) = '0') or 			
									  ( (ARCH_REG_LOCK(to_integer(unsigned(I_I1_REG1))) = '1') and DSP_RD_DATA1_VALID = '1' )  else
						  '0' ;
		
		OPR_VAL(1) <= '1' when ( I_CTRL1(IND_REG_AM) = '0' ) or ( ARCH_REG_LOCK(to_integer(unsigned(I_I1_REG2))) = '0') or 			
									  ( (ARCH_REG_LOCK(to_integer(unsigned(I_I1_REG2))) = '1') and	DSP_RD_DATA2_VALID = '1') else
						  '0';
							

		OPR_VAL(2) <= '1' when ( ( ARCH_REG_LOCK(to_integer(unsigned(I_I2_REG1))) = '0') or 			
									  ( ARCH_REG_LOCK(to_integer(unsigned(I_I2_REG1))) = '1' and	DSP_RD_DATA3_VALID = '1' ) )
									  and I2_RAW_IMM1 = '0' else
						  '0';
		
		OPR_VAL(3) <= '1' when ( I_CTRL2(IND_REG_AM) = '0' ) or (( ( ARCH_REG_LOCK(to_integer(unsigned(I_I2_REG2))) = '0') or 			
									  ( ARCH_REG_LOCK(to_integer(unsigned(I_I2_REG2))) = '1' and	DSP_RD_DATA4_VALID = '1') )
									  and I2_RAW_IMM2 = '0') else
						  '0';
							
		
		
		IS_STALL1 <= '1' when ((REG_WRITE_I1 = '1' or  REG_WRITE_I2 = '1') and RR1_VAL = '0') or 
									  (REG_WRITE_I1 = '1' and REG_WRITE_I2 = '1' and RR2_VAL = '0') else
						 '0' ;
			
			

	
		-- COMMIT : RENAME REG FILE READ --
		ARF_TAG1     <= ARCH_REG_TAG(to_integer(unsigned(I_ROB_ARCH_REG1))) ;
		ARF_TAG2     <= ARCH_REG_TAG(to_integer(unsigned(I_ROB_ARCH_REG2))) ;
		
		WR_ARF_DATA1 <= RNME_REG_FILE(to_integer(unsigned(I_ROB_RNME_REG1)));
		WR_ARF_DATA2 <= RNME_REG_FILE(to_integer(unsigned(I_ROB_RNME_REG2)));
		
		WR_ARF_VAL1  <= RNME_REG_VALID(to_integer(unsigned(I_ROB_RNME_REG1))) and I_ROB_REG_WR1;
		WR_ARF_VAL2  <= RNME_REG_VALID(to_integer(unsigned(I_ROB_RNME_REG2))) and I_ROB_REG_WR2;
		
		NO_PEND_WRITE1 <= '1' when I_ROB_RNME_REG1 = ARF_TAG1 else '0' ;
		NO_PEND_WRITE2 <= '1' when I_ROB_RNME_REG2 = ARF_TAG2 else '0' ;
		
		-- REG FILE UPDATE --
		process(CLK, RST)
		begin
			if (RST = '1') then
				ARCH_REG_FILE <= (others => (others => '0')) ;
				ARCH_REG_LOCK <= (others => '0');
				ARCH_REG_TAG  <= (others => (others => '0'));
				
				ARCH_REG_FILE(0) <=  X"00000000";	--0
			    ARCH_REG_FILE(1) <=  X"3F800000";	--1
			    ARCH_REG_FILE(2) <=  X"40000000";	--2 
			    ARCH_REG_FILE(3) <=  X"40400000";	--3
				ARCH_REG_FILE(4) <=  X"40800000";	--4
				ARCH_REG_FILE(5) <=  X"40A00000";	--5
				ARCH_REG_FILE(6) <=  X"40C00000";	--6
				ARCH_REG_FILE(7) <=  X"40E00000";	--7
				ARCH_REG_FILE(8) <=  X"41000000";	--8
			    ARCH_REG_FILE(9) <=  X"41100000";	--9

			elsif rising_edge(CLK) then
				if ( I1_VAL_NEXT = '1' and REG_WRITE_I1	= '1' and FREE_REG1_VAL = '1') then
					ARCH_REG_TAG(to_integer(unsigned(I_I1_DEST))) <= RNME_REG1 ;
					ARCH_REG_LOCK(to_integer(unsigned(I_I1_DEST))) <= '1' ;
				end if;

				if ( I2_VAL_NEXT = '1' and REG_WRITE_I2	= '1' and FREE_REG2_VAL = '1') then
					ARCH_REG_TAG(to_integer(unsigned(I_I2_DEST))) <= RNME_REG2 ;
					ARCH_REG_LOCK(to_integer(unsigned(I_I2_DEST))) <= '1' ;
				end if;
				
				if ( WR_ARF_VAL1 = '1' ) then
					ARCH_REG_FILE(to_integer(unsigned(I_ROB_ARCH_REG1))) <= WR_ARF_DATA1 ;
					if ( NO_PEND_WRITE1 = '1') then 
						ARCH_REG_LOCK(to_integer(unsigned(I_ROB_ARCH_REG1))) <= '0' ;
					end if;	
				end if;

				if ( WR_ARF_VAL2 = '1' ) then
					ARCH_REG_FILE(to_integer(unsigned(I_ROB_ARCH_REG2))) <= WR_ARF_DATA2 ;
					if ( NO_PEND_WRITE2 = '1') then 
						ARCH_REG_LOCK(to_integer(unsigned(I_ROB_ARCH_REG2))) <= '0' ;
					end if;	
				end if;
				
			end if;	
			
		end process;
		
		O_ARCH_REG_LOCK <= ARCH_REG_LOCK;
		
		-- DATA FORWARDING LOGIC --
		g4: for i in 0 to 3 generate 		-- loop over operands
			g5: for j in 0 to 3 generate 	-- loop over forwarding slots
				IN_ENCODER(i)(j) <= '1' when (I_TAG_FWD_SLOT(j) = OPR(i)(N_LOG_RR-1 downto 0) and I_FWD_SLOT_VAL(j) = '1' and OPR_VAL(i) = '0') else
										  '0' ;	
			end generate ;	

			TAG_MATCH_LOC(i) <= "00" when IN_ENCODER(i)(0) = '1' else
									  "01" when IN_ENCODER(i)(1) = '1' else
									  "10" when IN_ENCODER(i)(2) = '1' else
									  "11" when IN_ENCODER(i)(3) = '1' else
									  "00" ;
			TAG_MATCH_VAL(i) <= '0' when IN_ENCODER(i) = "0000" else '1' ;
		end generate;
		
		OPR1_NEXT <= OPR(0) when TAG_MATCH_VAL(0) = '0' else I_OPR_FWD_SLOT(to_integer(unsigned(TAG_MATCH_LOC(0))));
		OPR2_NEXT <= OPR(1) when TAG_MATCH_VAL(1) = '0' else I_OPR_FWD_SLOT(to_integer(unsigned(TAG_MATCH_LOC(1))));
		OPR3_NEXT <= OPR(2) when TAG_MATCH_VAL(2) = '0' else I_OPR_FWD_SLOT(to_integer(unsigned(TAG_MATCH_LOC(2))));
		OPR4_NEXT <= OPR(3) when TAG_MATCH_VAL(3) = '0' else I_OPR_FWD_SLOT(to_integer(unsigned(TAG_MATCH_LOC(3))));
		
		OPR1_VAL_NEXT <= '1' when TAG_MATCH_VAL(0) = '1' else OPR_VAL(0) ;
		OPR2_VAL_NEXT <= '1' when TAG_MATCH_VAL(1) = '1' else OPR_VAL(1) ;
		OPR3_VAL_NEXT <= '1' when TAG_MATCH_VAL(2) = '1' else OPR_VAL(2) ;
		OPR4_VAL_NEXT <= '1' when TAG_MATCH_VAL(3) = '1' else OPR_VAL(3) ;
		
		
		-- INPUTS TO RENAME REGISTER FILE --
		WR_EN1_RR <= REG_WRITE_I1 and I1_VAL_NEXT and FREE_REG1_VAL;
		WR_EN2_RR <= REG_WRITE_I2 and I2_VAL_NEXT and FREE_REG2_VAL;
		
		DSP_RD_REG1 <= ARCH_REG_TAG(to_integer(unsigned(I_I1_REG1))) ;
		DSP_RD_REG2 <= ARCH_REG_TAG(to_integer(unsigned(I_I1_REG2))) ;	
		DSP_RD_REG3 <= ARCH_REG_TAG(to_integer(unsigned(I_I2_REG1))) ;
		DSP_RD_REG4 <= ARCH_REG_TAG(to_integer(unsigned(I_I2_REG2))) ;	
		
		
		-- OUTPUTS OF RENAME REGISTER FILE --
		DSP_RD_DATA1_VALID <= RNME_REG_VALID(to_integer(unsigned(DSP_RD_REG1))) ;
		DSP_RD_DATA2_VALID <= RNME_REG_VALID(to_integer(unsigned(DSP_RD_REG2))) ;
		DSP_RD_DATA3_VALID <= RNME_REG_VALID(to_integer(unsigned(DSP_RD_REG3))) ;
		DSP_RD_DATA4_VALID <= RNME_REG_VALID(to_integer(unsigned(DSP_RD_REG4))) ;
		
		RNME_REG1 <= S_FREE_REG1 ;
		RNME_REG2 <= S_FREE_REG2 when ( REG_WRITE_I1 = '1' and I1_VAL_NEXT = '1' ) else S_FREE_REG1;
		
		RR1_VAL <= FREE_REG1_VAL ;
		RR2_VAL <= FREE_REG2_VAL ;

		-- RENAME REGISTER FILE OPERATIONS --		
		DSP_RD_DATA1 <= RNME_REG_FILE(to_integer(unsigned(DSP_RD_REG1))) ;
		DSP_RD_DATA2 <= RNME_REG_FILE(to_integer(unsigned(DSP_RD_REG2))) ;
		DSP_RD_DATA3 <= RNME_REG_FILE(to_integer(unsigned(DSP_RD_REG3))) ;
		DSP_RD_DATA4 <= RNME_REG_FILE(to_integer(unsigned(DSP_RD_REG4))) ;
		
		ENC1 : ENCODER32x5 port map (INPUT => RNME_REG_BUSY, VALID => FREE_REG1_VAL, OUTPUT => S_FREE_REG1 );


		g1: for i in 0 to 31 generate
			g2: for j in 0 to 31 generate
				INPUT_ENC_L2(i)(j) <= FREE_REG1_VAL when j = i else RNME_REG_BUSY(j) ;
			end generate;		
			
			g3 : ENCODER32x5 port map (INPUT => INPUT_ENC_L2(i), VALID => ENC_L2_VAL(i), OUTPUT => S_FREE_REG_L2(i) );
		end generate;
		
		S_FREE_REG2   <= S_FREE_REG_L2(to_integer(unsigned(S_FREE_REG1)));
		FREE_REG2_VAL <= '0' when FREE_REG1_VAL = '0' else ENC_L2_VAL(to_integer(unsigned(S_FREE_REG1)));
		
		FREE_RNME_REG1 <= I_ROB_REG_WR1 and RNME_REG_VALID(to_integer(unsigned(I_ROB_RNME_REG1)));
		FREE_RNME_REG2 <= I_ROB_REG_WR2 and RNME_REG_VALID(to_integer(unsigned(I_ROB_RNME_REG2)));
		

		process(CLK,RST)
		begin
			if (RST = '1') then
				RNME_REG_BUSY  <= (others => '0');
				RNME_REG_VALID <= (others => '0');
			elsif rising_edge(clk) then
				if ( WR_EN1_RR = '1') then
					RNME_REG_BUSY(to_integer(unsigned(RNME_REG1))) <= '1';
					RNME_REG_VALID(to_integer(unsigned(RNME_REG1)))	 <= '0';
				end if;
				
				if ( WR_EN2_RR = '1') then
					RNME_REG_BUSY(to_integer(unsigned(RNME_REG2))) <= '1';
					RNME_REG_VALID(to_integer(unsigned(RNME_REG2))) <= '0';
				end if;
				
				if ( I_FWD_SLOT_VAL(0) = '1') then
					RNME_REG_FILE(to_integer(unsigned(I_TAG_FWD_SLOT(0)))) <= I_OPR_FWD_SLOT(0);
					RNME_REG_BUSY(to_integer(unsigned(I_TAG_FWD_SLOT(0)))) <= '1';
					RNME_REG_VALID(to_integer(unsigned(I_TAG_FWD_SLOT(0)))) <= '1';
				end if;
				
				if ( I_FWD_SLOT_VAL(1) = '1') then
					RNME_REG_FILE(to_integer(unsigned(I_TAG_FWD_SLOT(1)))) <= I_OPR_FWD_SLOT(1);
					RNME_REG_BUSY(to_integer(unsigned(I_TAG_FWD_SLOT(1)))) <= '1';
					RNME_REG_VALID(to_integer(unsigned(I_TAG_FWD_SLOT(1)))) <= '1';
				end if;

				if (I_FWD_SLOT_VAL(2) = '1') then
					RNME_REG_FILE(to_integer(unsigned(I_TAG_FWD_SLOT(2)))) <= I_OPR_FWD_SLOT(2);
					RNME_REG_BUSY(to_integer(unsigned(I_TAG_FWD_SLOT(2)))) <= '1';
					RNME_REG_VALID(to_integer(unsigned(I_TAG_FWD_SLOT(2)))) <= '1';
				end if;

				if (I_FWD_SLOT_VAL(3) = '1') then
					RNME_REG_FILE(to_integer(unsigned(I_TAG_FWD_SLOT(3)))) <= I_OPR_FWD_SLOT(3);
					RNME_REG_BUSY(to_integer(unsigned(I_TAG_FWD_SLOT(3)))) <= '1';
					RNME_REG_VALID(to_integer(unsigned(I_TAG_FWD_SLOT(3)))) <= '1';
				end if;
				
				if (FREE_RNME_REG1 = '1') then
					RNME_REG_BUSY(to_integer(unsigned(I_ROB_RNME_REG1))) <= '0';
					RNME_REG_VALID(to_integer(unsigned(I_ROB_RNME_REG1))) <= '0';
				end if;
				
				if (FREE_RNME_REG2 = '1') then
					RNME_REG_BUSY(to_integer(unsigned(I_ROB_RNME_REG2))) <= '0';
					RNME_REG_VALID(to_integer(unsigned(I_ROB_RNME_REG2))) <= '0';
				end if;
				
			end if;
			
		
		end process;
			
		O_RNME_REG_BUSY <= RNME_REG_BUSY ;
		O_RNME_REG_VALID <= RNME_REG_VALID ;
			
end architecture;

