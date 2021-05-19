
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG_COMMON.all;

entity FPU is
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
	
end entity;	

architecture ARCH of FPU is

component fp32_add is
	port ( 
				CLK : in std_logic;
				
				ctrl_sig  : in std_logic_vector(N_CTRL_BITS-1 downto 0);
				
				instr     : in std_logic_vector(N_OPCODE_BITS + N_SHAMT_BITS + N_FUNC_BITS - 1 downto 0);
				i_dest_reg  : in std_logic_vector(N_LOG_RR - 1 downto 0 );
				i_instr_valid : in std_logic;
				i_rob_loc     : in std_logic_vector(N_LOG_ROB-1 downto 0);
				
				fp32_a , fp32_b : in std_logic_vector (31 downto 0);
				
				fp_sum : out std_logic_vector (31 downto 0); 
				
				o_instr_valid 	: out std_logic ;
				o_dest_reg 		: out std_logic_vector(N_LOG_RR-1 downto 0);
				o_rob_loc  		: out std_logic_vector(N_LOG_ROB-1 downto 0);
				
				temp_s_op1_sign, temp_s_op2_sign : out std_logic;
				temp_s_op1_exp, temp_s_op2_exp : out std_logic_vector(7 downto 0);
				temp_s_exp_diff  : out unsigned(8 downto 0);
				temp_s_op1_bin, temp_s_op2_bin		 : out std_logic_vector(49 downto 0);
				temp_s_op1_NZDI, temp_s_op2_NZDI : out std_logic_vector(3 downto 0) 	;
				temp_op2_shifted, temp_SumorDiff  : out std_logic_vector(49 downto 0); 
				temp_loc : out std_logic_vector(7 downto 0);
				temp_mantissa : out std_logic_vector(22 downto 0)
				);
	
end component;	

component fp_mul is
	generic (	N_CTRL_BITS 	: integer := 27;
			N_LOG_RR 		: integer := 5;
			N_LOG_ROB 		: integer := 7);

	port(		inp1 				: in std_logic_vector(31 downto 0);
				inp2 				: in std_logic_vector(31 downto 0);
				clk 				: in std_logic;
				in_instr_val			: in std_logic;
		
				DREG_CTRL 			: in std_logic_vector(N_CTRL_BITS-1 downto 0); 
				DREG_DEST 			: in std_logic_vector(N_LOG_RR-1 downto 0);
				DREG_ROB_LOC		: in std_logic_vector(N_LOG_ROB-1 downto 0);
				
				reg_dest 			: out std_logic_vector(N_LOG_RR-1 downto 0);
				reg_rob_loc			: out std_logic_vector(N_LOG_ROB-1 downto 0);
				reg_instr_val 		: out std_logic;
		
				output 				: out std_logic_vector(31 downto 0) 
			);
end component;

signal ADD_IVAL, MUL_IVAL, SUM_VAL, PRO_VAL : std_logic ;
signal DEST_REG_OUT_1, DEST_REG_OUT_2 : std_logic_vector(N_LOG_RR-1 downto 0);
signal ROB_LOC_OUT_1, ROB_LOC_OUT_2   : std_logic_vector(N_LOG_ROB-1 downto 0);
signal SUM, PRODUCT : std_logic_vector(31 downto 0);
begin

		ADD_IVAL <= '1' when ( IN_CTRL(IND_FPU_AM) = '0' and  IN_INSTR_VAL = '1' ) else '0' ;
		MUL_IVAL <= '1' when ( IN_CTRL(IND_FPU_AM) = '1' and  IN_INSTR_VAL = '1' ) else '0' ;
		
		FPADD : fp32_add port map ( 	CLK => CLK,
				
												CTRL_SIG 		=> IN_CTRL, 
												INSTR 			=> IN_INSTR ,
												I_DEST_REG  	=> IN_DEST_REG, 
												I_INSTR_VALID 	=> ADD_IVAL,
												I_ROB_LOC 		=> IN_ROB_LOC,
												
												FP32_A 			=> FPU_A, FP32_B => FPU_B,
												
												FP_SUM 			=> SUM,
												
												O_DEST_REG 		=> DEST_REG_OUT_1,
												O_INSTR_VALID 	=> SUM_VAL ,
												
												O_ROB_LOC      => ROB_LOC_OUT_1
--												temp_s_op1_sign, temp_s_op2_sign : out std_logic;
--												temp_s_op1_exp, temp_s_op2_exp : out std_logic_vector(7 downto 0);
--												temp_s_exp_diff  : out unsigned(8 downto 0);
--												temp_s_op1_bin, temp_s_op2_bin		 : out std_logic_vector(49 downto 0);
--												temp_s_op1_NZDI, temp_s_op2_NZDI : out std_logic_vector(3 downto 0) 	;
--												temp_op2_shifted, temp_SumorDiff  : out std_logic_vector(49 downto 0); 
--												temp_loc : out std_logic_vector(7 downto 0);
--												temp_mantissa : out std_logic_vector(22 downto 0) \
												);												


		FPMUL:	fp_mul port map (	clk 				=> CLK ,
		
											inp1 				=> FPU_A ,
											inp2 				=> FPU_B ,

											in_instr_val	=> MUL_IVAL ,
									
											DREG_CTRL 		=> IN_CTRL ,
											DREG_DEST 		=> IN_DEST_REG ,
											DREG_ROB_LOC	=> IN_ROB_LOC ,
											
											reg_dest 		=> DEST_REG_OUT_2 ,
											reg_rob_loc		=> ROB_LOC_OUT_2 ,
											reg_instr_val 	=> PRO_VAL ,
									
											output 			=> PRODUCT ) ;
											
											
						  
		O_RES_VAL 	<= SUM_VAL or PRO_VAL ;				  
	
		O_RESULT  	<= SUM	when SUM_VAL = '1' else
							PRODUCT ;
						 
		O_DEST_REG  <= DEST_REG_OUT_1	when SUM_VAL = '1' else
							DEST_REG_OUT_2 ;
						 
		O_ROB_LOC  	<= ROB_LOC_OUT_1	when SUM_VAL = '1' else
							ROB_LOC_OUT_2 ;

			
end architecture;