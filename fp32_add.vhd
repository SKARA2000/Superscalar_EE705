library ieee;
use ieee.std_logic_1164.all;

package PKG_EX_FPU is

constant N_ARCH_REG : integer := 32;
constant N_RNME_REG : integer := 32;
constant N_OPCODE_BITS : integer := 6;
constant N_SHAMT_BITS : integer := 5;
constant N_FUNC_BITS : integer := 6;
constant N_CTRL_BITS : integer := 27;

constant N_LOG_AR : integer := 5 ;
constant N_LOG_RR : integer := 5 ;
constant N_LOG_ROB : integer := 7;

constant IND_REGWR : integer:= 0;

constant OPCODE_ALU : std_logic_vector(5 downto 0) := "000000" ;
constant OPCODE_FPU : std_logic_vector(5 downto 0) := "000101" ;
constant OPCODE_MEM : std_logic_vector(5 downto 0) := "110011" ;
constant OPCODE_BRN : std_logic_vector(5 downto 0) := "001100" ;


type T_ARCH_REGFILE is array (0 to N_ARCH_REG-1) of std_logic_vector(31 downto 0);
type T_RNME_REGFILE is array (0 to N_RNME_REG-1) of std_logic_vector(31 downto 0);
type T_ARF_TAG is array (0 to N_ARCH_REG-1) of std_logic_vector(N_LOG_RR-1 downto 0);

type T_ARR4_SLV4 is array(0 to 3) of std_logic_vector(3 downto 0);
type T_ARR4_SLV2 is array(0 to 3) of std_logic_vector(1 downto 0);
type T_ARR4_SLV32 is array(0 to 3) of std_logic_vector(31 downto 0);
type T_ARR32_SLV32 is array(0 to 31) of std_logic_vector(31 downto 0);
type T_ARR4_SLV_TAG is array(0 to 3) of std_logic_vector(N_LOG_RR-1 downto 0);
type T_ARR32_SLV5 is array (0 to 31) of std_logic_vector(4 downto 0);
type T_RNME_REG_PTR is array (0 to 2) of std_logic_vector(N_LOG_RR - 1 downto 0);

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG_EX_FPU.all;

entity fp32_add is
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
	
end entity;	

architecture arch1 of fp32_add is 

component fp_get_operand is
	port ( 
				fp32_a : in std_logic_vector (31 downto 0);
				op_bin : out std_logic_vector(25 downto 0);
				a_Nan , a_Zero, a_Den, a_Inf : out std_logic );
end component;

constant NUM_BITS_OP : integer := 50;
signal reg12_op1_op, reg12_op2_op : std_logic_vector(NUM_BITS_OP-1 downto 0);
signal reg12_op1_sign, reg12_op2_sign : std_logic;
signal reg12_op1_exp, reg12_op2_exp : std_logic_vector(7 downto 0);
signal reg12_op1_NZDI, reg12_op2_NZDI : std_logic_vector(3 downto 0);
signal reg12_exp_diff : unsigned(8 downto 0);
signal reg12_osign_op : std_logic_vector(1 downto 0);
signal reg12_a_eq_b : std_logic;
signal reg12_rob_loc : std_logic_vector(N_LOG_ROB-1 downto 0);

signal reg12_instr_valid : std_logic;
signal reg12_dest_reg : std_logic_vector(N_LOG_RR-1 downto 0);

signal s_op1_sign, s_op2_sign : std_logic;
signal s_op1_exp, s_op2_exp : std_logic_vector(7 downto 0);
signal s_exp_a, s_exp_b : std_logic_vector(7 downto 0);
signal s_mnt_a, s_mnt_b : std_logic_vector(22 downto 0);
signal s_op1_bin, s_op2_bin :  std_logic_vector(NUM_BITS_OP-1 downto 0);
signal s_op_a_bin, s_op_b_bin :  std_logic_vector(NUM_BITS_OP-1 downto 0);
signal s_op1_NZDI , s_op2_NZDI : std_logic_vector(3 downto 0);
signal s_a_Nan , s_a_Zero, s_a_Den, s_a_Inf : std_logic;
signal s_b_Nan , s_b_Zero, s_b_Den, s_b_Inf : std_logic;
signal s_a_eq_b : std_logic;
signal s_exp_diff : unsigned(8 downto 0);
signal s_diff : std_logic_vector(8 downto 0);
signal s_fsign_op : std_logic_vector(1 downto 0);
signal s_op_a_bin_26b, s_op_b_bin_26b : std_logic_vector(25 downto 0);
signal s_opcode : std_logic_vector(N_OPCODE_BITS-1 downto 0);
signal s_func   : std_logic_vector(N_FUNC_BITS-1 downto 0);
signal s_instr_val_next : std_logic ;
--CYCLE 2 OF 3

component shift_n_wrap is
	generic (NBITS_INP : integer := 50;
				NBITS_SHF : integer  := 6 );
	port ( inp : in std_logic_vector(NBITS_INP-1 downto 0);
			 shift_val : in unsigned(NBITS_SHF-1 downto 0);
			 outp : out std_logic_vector(NBITS_INP-1 downto 0) );
end component;		

signal reg23_op1_sign, reg23_op2_sign : std_logic;
signal reg23_SumorDiff : std_logic_vector(NUM_BITS_OP-1 downto 0);
signal reg23_op1_NZDI, reg23_op2_NZDI : std_logic_vector(3 downto 0);
signal reg23_osign_op : std_logic_vector(1 downto 0);
signal reg23_op1_exp , reg23_op2_exp : std_logic_vector(7 downto 0);	
signal reg23_instr_valid : std_logic;
signal reg23_dest_reg : std_logic_vector(N_LOG_RR-1 downto 0);
signal reg23_rob_loc : std_logic_vector(N_LOG_ROB-1 downto 0);

signal s_op2_shifted, s_SumorDiff, s_SumOrDiff_adder : std_logic_vector(NUM_BITS_OP-1 downto 0);



--CYCLE 3 OF 3 --
constant INF : integer := 0;
constant DEN : integer := 1;
constant ZER : integer := 2;
constant NAN : integer := 3;


signal s_Result : std_logic_vector(31 downto 0);

component get_mantissa is
	generic (NBITS_INP  : integer := 50; 
				NBITS_SEL : integer := 6 );
	port ( 
				mux_arr_in : in std_logic_vector(NBITS_INP-1 downto 0);
				sel        : in std_logic_vector(NBITS_SEL-1 downto 0);
				mantissa   : out std_logic_vector(22 downto 0) );
end component;

signal s_loc : std_logic_vector(7 downto 0);
signal s_mantissa : std_logic_vector(22 downto 0);

begin


	-- CYCLE 1 OF 3 --
	process (CLK)
	begin
		if (rising_edge(CLK)) then
			reg12_op1_sign <= s_op1_sign;
         reg12_op2_sign <= s_op2_sign;
         reg12_op1_op 	<= s_op1_bin;
         reg12_op2_op   <= s_op2_bin;
         reg12_op1_exp  <= s_op1_exp;
         reg12_op2_exp  <= s_op2_exp;
			reg12_exp_diff <= s_exp_diff;
         reg12_op1_NZDI <= s_op1_NZDI;
         reg12_op2_NZDI <= s_op2_NZDI;
			reg12_osign_op <= s_fsign_op; 
			
			reg12_instr_valid <= s_instr_val_next ;
			reg12_dest_reg    <= i_dest_reg ;
			reg12_rob_loc     <= i_rob_loc ;
		end if;
	end process;
	

	s_opcode <= instr(N_OPCODE_BITS + N_SHAMT_BITS + N_FUNC_BITS - 1 downto N_OPCODE_BITS + N_SHAMT_BITS + N_FUNC_BITS - 6);
	s_func   <= instr(N_FUNC_BITS - 1 downto 0);
	s_instr_val_next <= '1' when ( s_opcode = OPCODE_FPU and s_func = "000001" and i_instr_valid = '1') else '0' ;  
	
	s_exp_a <= fp32_a(30 downto 23);
	s_exp_b <= fp32_b(30 downto 23);
	s_mnt_a <= fp32_a(22 downto 0);
	s_mnt_b <= fp32_b(22 downto 0);

	s_a_eq_b	<= '1' when (fp32_a = fp32_b) else '0';
	
	process(s_exp_a,s_exp_b,s_mnt_a,s_mnt_b,fp32_a, fp32_b, s_op_a_bin, s_op_b_bin, 
							s_a_Nan, s_a_Zero, s_a_Den, s_a_Inf,
							s_b_Nan, s_b_Zero, s_b_Den, s_b_Inf	)
	variable v_sign_a, v_sign_b, v_a_gt_b : std_logic;
	variable v_exp_diff : unsigned(8 downto 0);
	begin
		v_sign_a := fp32_a(31);
		v_sign_b := fp32_b(31);

		if (s_exp_a /= s_exp_b) then
			if (s_exp_a > s_exp_b) then
				s_op1_sign <= v_sign_a;
				s_op2_sign <= v_sign_b;
				s_op1_exp <= s_exp_a;
				s_op2_exp <= s_exp_b;


				v_exp_diff := unsigned('0' & fp32_a(30 downto 23)) - unsigned('0' & fp32_b(30 downto 23));	
				
				if (s_b_Den = '1') then
					v_exp_diff := v_exp_diff - unsigned((to_unsigned(0,8) & '1'));
				end if;
				
				s_exp_diff <= v_exp_diff;
				
				s_op1_bin <= s_op_a_bin;
				s_op2_bin <= s_op_b_bin;
				s_op1_NZDI <= s_a_Nan & s_a_Zero & s_a_Den & s_a_Inf;
				s_op2_NZDI <= s_b_Nan & s_b_Zero & s_b_Den & s_b_Inf;
				
				v_a_gt_b := '1';
			else
				s_op1_sign <= fp32_b(31);
				s_op2_sign <= fp32_a(31);
				s_op1_exp <= s_exp_b;
				s_op2_exp <= s_exp_a;
				
				v_exp_diff := unsigned('0' & fp32_b(30 downto 23)) - unsigned('0' & fp32_a(30 downto 23));	

				if (s_a_Den = '1') then
					v_exp_diff := v_exp_diff - unsigned((to_unsigned(0,8) & '1'));
				end if;
				
				s_exp_diff <= v_exp_diff;
				
				s_op1_bin <= s_op_b_bin;
				s_op2_bin <= s_op_a_bin;
				s_op1_NZDI <= s_b_Nan & s_b_Zero & s_b_Den & s_b_Inf;						
				s_op2_NZDI <= s_a_Nan & s_a_Zero & s_a_Den & s_a_Inf;
				
				v_a_gt_b := '0';
			end if;	
		else
			s_exp_diff <= (others => '0');
			if (s_mnt_a > s_mnt_b) then
				s_op1_sign <= fp32_a(31);
				s_op2_sign <= fp32_b(31);
				s_op1_exp <= s_exp_a;
				s_op2_exp <= s_exp_b;
				s_op1_bin <= s_op_a_bin;
				s_op2_bin <= s_op_b_bin;
				s_op1_NZDI <= s_a_Nan & s_a_Zero & s_a_Den & s_a_Inf;
				s_op2_NZDI <= s_b_Nan & s_b_Zero & s_b_Den & s_b_Inf;
	
				v_a_gt_b := '1';
			else
				s_op1_sign <= fp32_b(31);
				s_op2_sign <= fp32_a(31);		
				s_op1_exp <= s_exp_b;
				s_op2_exp <= s_exp_a;
				s_op1_bin <= s_op_b_bin;
				s_op2_bin <= s_op_a_bin;
				s_op1_NZDI <= s_b_Nan & s_b_Zero & s_b_Den & s_b_Inf;						
				s_op2_NZDI <= s_a_Nan & s_a_Zero & s_a_Den & s_a_Inf;
				
				v_a_gt_b := '0';
			end if;	
		end if;	
		
		--subtract with result having sign of a				 
		if (v_sign_a /= v_sign_b) then
			if (v_a_gt_b = '1') then 
				s_fsign_op <= v_sign_a & '1'; 
			else
				if (s_a_eq_b = '0') then 
					s_fsign_op <= v_sign_b & '1'; 
				else 
					s_fsign_op <= "01"; 
				end if; 
			end if;	
		else
			s_fsign_op <= v_sign_a & '0'; 
		end if; 
		
	end process;
	
	temp_s_op1_sign <=			s_op1_sign;
	temp_s_op2_sign <=			s_op2_sign;
	temp_s_op1_exp <=			s_op1_exp;
	temp_s_op2_exp <=			s_op2_exp;
	temp_s_exp_diff <=			s_exp_diff;	
	temp_s_op1_bin <=			s_op1_bin;
	temp_s_op2_bin <=			s_op2_bin;
--	temp_s_op1_NZDI <= 			s_op1_NZDI;
--	temp_s_op2_NZDI <=			s_op2_NZDI;	
	temp_s_op1_NZDI <= 	s_op1_NZDI;						
	temp_s_op2_NZDI <= 	s_op2_NZDI;
	
	get_op_a : fp_get_operand port map (fp32_a, s_op_a_bin_26b, s_a_Nan , s_a_Zero, s_a_Den, s_a_Inf);
	get_op_b : fp_get_operand port map (fp32_b, s_op_b_bin_26b, s_b_Nan , s_b_Zero, s_b_Den, s_b_Inf);

	s_op_a_bin <=  s_op_a_bin_26b & std_logic_vector(to_unsigned(0,NUM_BITS_OP-26));
	s_op_b_bin <=  s_op_b_bin_26b & std_logic_vector(to_unsigned(0,NUM_BITS_OP-26));
	
	-- CYCLE 2 OF 3 --

	shifter: shift_n_wrap port map (reg12_op2_op, reg12_exp_diff(5 downto 0), s_op2_shifted);
	--adder  : adder_block port map (reg12_op1_op, s_op2_shifted , '0', s_SumOrDiff_adder);
	
	process(reg12_exp_diff, reg12_op1_op, reg12_op2_op, reg12_osign_op, s_op2_shifted)
	variable v_op2_shifted, v_op1, v_op2, v_SumorDiff : std_logic_vector(NUM_BITS_OP-1 downto 0);
	begin
		v_op1 := reg12_op1_op;
		v_op2 := reg12_op2_op;
		if (reg12_exp_diff > to_unsigned(47,8)) then
			v_SumorDiff := v_op1;
		else
			v_op2_shifted := s_op2_shifted;
			if (reg12_osign_op(0) = '0') then --add
				v_SumorDiff := std_logic_vector(unsigned(v_op1) + unsigned(v_op2_shifted));
			else
				v_SumorDiff := std_logic_vector(unsigned(v_op1) - unsigned(v_op2_shifted));
			end if;	
		end if;
		s_SumorDiff <= v_SumorDiff;	
	end process;

	--Temporary outputs
	temp_op2_shifted <= s_op2_shifted;
	temp_SumorDiff <= s_SumorDiff;
	
	process (CLK)
	begin
		if (rising_edge(CLK)) then
			reg23_op1_sign <= reg12_op1_sign;
         reg23_op2_sign <= reg12_op2_sign;
         --reg12_op1_op 	<= s_op1_bin;
         --reg12_op2_op   <= s_op2_bin;
			reg23_SumorDiff <= s_SumorDiff; 
         reg23_op1_exp  <= reg12_op1_exp;
         reg23_op2_exp  <= reg12_op2_exp;
			--reg12_exp_diff <= s_exp_diff;
         reg23_op1_NZDI <= reg12_op1_NZDI;
         reg23_op2_NZDI <= reg12_op2_NZDI;
			reg23_osign_op <= reg12_osign_op; 
			
			reg23_instr_valid <= reg12_instr_valid ;
			reg23_dest_reg    <= reg12_dest_reg ;
			reg23_rob_loc     <= reg12_rob_loc ;
			o_instr_valid 		<= reg12_instr_valid ;			
		end if;

	end process;	
	
	-- CYCLE 3 OF 3 --
	-- Both operands are zero => Result = 0
	-- Any operand is NaN => Result = Nan
	-- Both operands are INF and operation is ADD => Result = +/- INF
	-- Both operands are INF and operation is SUB => Result = NaN
	
	gen_mnt : get_mantissa 
			generic map (NBITS_INP  => NUM_BITS_OP, 
							 NBITS_SEL  =>  6 )
			port map( 
							mux_arr_in => reg23_SumorDiff,
							sel        => s_loc(5 downto 0),
							mantissa   => s_mantissa );

	temp_loc <= s_loc;
	temp_mantissa <= s_mantissa;
	ploc: process(reg23_SumorDiff )
	variable v_flag_stop : std_logic := '0';
	variable v_loc : std_logic_vector(7 downto 0);
	begin
		for i in (NUM_BITS_OP-1) downto 0 loop
			if (reg23_SumorDiff(i) = '1') and (v_flag_stop = '0') then
				v_loc := std_logic_vector(to_unsigned(i,8));
				v_flag_stop := '1';
			end if;	
		end loop;
		
		s_loc <= v_loc;
		v_flag_stop := '0';
		
	end process;
	
	process (reg23_op1_NZDI, reg23_op2_NZDI, reg23_SumorDiff, reg23_osign_op, reg23_op1_exp,
				reg23_op1_sign , reg23_op2_sign, s_mantissa, s_loc )
	variable v_mnt : std_logic_vector(22 downto 0);
	variable v_exp : std_logic_vector(7 downto 0);
	variable v_sign : std_logic;
	variable v_iloc_1 : integer;
	variable v_sloc_1 : signed(8 downto 0);
	variable f_loc_1 : std_logic:= '0';
	variable v_exp_signed : signed(8 downto 0);
	variable v_exp1 , v_exp2,v_exp_9b : unsigned(8 downto 0);
	begin
		if (reg23_op1_NZDI(ZER) = '1') and (reg23_op2_NZDI(ZER) = '1') then
			v_mnt := (others => '0');					--Zero
			v_exp := (others => '0');					--Zero
			v_sign := '0';
		elsif (reg23_op1_NZDI(NAN) = '1') or (reg23_op2_NZDI(NAN) = '1') then
			v_mnt := (22=>'1', others =>'0');		--Nan
			v_exp := X"FF";
			v_sign := reg23_osign_op(1);	
		elsif (reg23_op1_NZDI(INF) = '1') and (reg23_op2_NZDI(INF) = '1') then
			if (reg23_op1_sign /= reg23_op2_sign) then
				v_mnt := (22=>'1', others =>'0');	--Nan
				v_exp := X"FF";
				v_sign := '0';
			else
				v_mnt := (others => '0');	--Infinity
				v_exp := X"FF";
				v_sign := reg23_osign_op(1);	
			end if;	
		else 
			-- If one is normalised
			if (reg23_op1_NZDI(DEN) = '0') then
				v_mnt := s_mantissa;
				v_exp1 := unsigned('0'& reg23_op1_exp) + unsigned('0' & s_loc);
				v_exp2 := to_unsigned((NUM_BITS_OP - 2),9) ;
				
				if (v_exp1 > v_exp2) then
					v_exp_9b := v_exp1 - v_exp2;
					v_exp := std_logic_vector(v_exp_9b(7 downto 0));
				else
					v_exp := (others => '0');
					v_mnt := (others => '0');
				end if;
				
				if (reg23_SumorDiff = std_logic_vector(to_unsigned(0,NUM_BITS_OP))) then				
					v_mnt := (others => '0');					--Zero
					v_exp := (others => '0');					--Zero
				end if;
			else
			--Both numbers are denormalised
					v_mnt := reg23_SumorDiff((NUM_BITS_OP-3) downto (NUM_BITS_OP-25)) ;
					v_exp := reg23_op1_exp;
			end if;
			v_sign := reg23_osign_op(1);	
		
		end if;

		s_Result <= v_sign & v_exp & v_mnt;
	end process;
	
	fp_sum <= s_Result;
	o_dest_reg <= reg23_dest_reg ;
--	o_instr_valid <= reg23_instr_valid ;
	o_rob_loc     <= reg23_rob_loc ;
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fp_get_operand is
port ( 
			fp32_a : in std_logic_vector (31 downto 0);
			op_bin : out std_logic_vector(25 downto 0);
			a_Nan , a_Zero, a_Den, a_Inf : out std_logic );
end entity;			

architecture arch1 of fp_get_operand is 

signal exp_a : std_logic_vector(7 downto 0);
signal mnt_a : std_logic_vector(22 downto 0);
signal exp_zf, mnt_zf : std_logic;

begin

	exp_a <= fp32_a(30 downto 23);
	mnt_a <= fp32_a(22 downto 0);
	

	exp_zf <= '1' when (exp_a = X"00") else '0';
	mnt_zf <= '1' when (mnt_a = "00000000000000000000000") else '0';
	
	a_Zero <= '1' when (exp_zf = '1' and mnt_zf = '1') else '0' ;
	a_Inf  <= '1' when (exp_a = X"FF" and mnt_zf = '1') else '0' ;
	a_Nan  <= '1' when (exp_a = X"FF" and mnt_zf = '0') else '0' ;
	a_Den  <= '1' when (exp_zf = '1' and mnt_zf = '0') else '0';

	op_bin <= '0' & (not exp_zf) & fp32_a(22 downto 0) & '0';

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_n_wrap is
	generic (NBITS_INP : integer := 50;
				NBITS_SHF : integer  := 6 );
	port ( inp : in std_logic_vector(NBITS_INP-1 downto 0);
			 shift_val : in unsigned(NBITS_SHF-1 downto 0);
			 outp : out std_logic_vector(NBITS_INP-1 downto 0) );
end entity;			 

architecture arch1 of shift_n_wrap is 

constant s_z_64 : std_logic_vector(63 downto 0) := (others => '0');
begin
	process(inp, shift_val)
	variable v_int : std_logic_vector(NBITS_INP-1 downto 0);	
	begin
		v_int := inp;
		for i in (NBITS_SHF-1) downto 0 loop
			if (shift_val(i) = '1') then
				v_int := s_z_64((2**i -1) downto 0) & v_int((NBITS_INP-1) downto (NBITS_INP-(NBITS_INP - 2**i)));
			end if;	
		end loop;
		outp <= v_int;
	end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder_block is
	port (in1 , in2 : in std_logic_vector(25 downto 0); 
			add0_sub1 : in std_logic;
			SumOrDiff : out std_logic_vector(25 downto 0));
end entity;

architecture arch1 of adder_block is

component full_adder is
	port (a,b,cin : in std_logic; s, cout : out std_logic );
end component;
signal c_out : std_logic_vector(26 downto 0);
--signal s_out : 
begin
	c_out(0) <= '0';
	g1: for i in 0 to 25 generate
		g2: full_adder port map (in1(i), in2(i), c_out(i), SumOrDiff(i) , c_out(i+1));
	end generate;	
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder is
	port (a,b,cin : in std_logic; s, cout : out std_logic );
end entity;

architecture arch1 of full_adder is
begin
	s <= a xor b xor cin;
	cout <= (a and b) or (b and cin) or (a and cin);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux64x1 is
port ( mux_in : in std_logic_vector(63 downto 0);
		 sel    : in std_logic_vector(5 downto 0);
		 mux_out: out std_logic );
end entity;

architecture arch1 of mux64x1 is
begin
	mux_out <= mux_in(to_integer(unsigned(sel))) ;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity get_mantissa is
	generic (NBITS_INP  : integer := 50; 
				NBITS_SEL : integer := 6 );
	port ( 
				mux_arr_in : in std_logic_vector(NBITS_INP-1 downto 0);
				sel        : in std_logic_vector(NBITS_SEL-1 downto 0);
				mantissa : out std_logic_vector(22 downto 0) );
end entity;

architecture arch1 of get_mantissa is

type t_arr23_inp is array (1 to 23) of std_logic_vector(63 downto 0);
signal mux_arr_inp : t_arr23_inp;

component mux64x1 is
port ( mux_in : in std_logic_vector(63 downto 0);
		 sel    : in std_logic_vector(5 downto 0);
		 mux_out: out std_logic );
end component;

begin
		
		g1:for i in 1 to 23 generate
			mux_arr_inp(i)(63 downto NBITS_INP)  <= std_logic_vector(to_unsigned(0, 63-NBITS_INP+1));
			mux_arr_inp(i)(NBITS_INP-1 downto i) <= mux_arr_in(NBITS_INP-1-i downto 0);
			mux_arr_inp(i)(i-1 downto 0) <= std_logic_vector(to_unsigned(0, i));
			g2:  mux64x1 port map(mux_arr_inp(i), sel, mantissa(23-i));
		end generate;
end architecture;