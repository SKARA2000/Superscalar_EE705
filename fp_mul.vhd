library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--- EDIT 1 : In clock 1, checked condition Ctrl(25) and Ctrl(6)
--- EDIT 2 : In clock 3, latch DREG_DEST and DREG_ROB_LOC
--- EDIT 3 : Valid_1, Valid_2

entity fp_mul is
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
			reg_instr_val 			: out std_logic;
	
			output 				: out std_logic_vector(31 downto 0));
end fp_mul;

architecture arch_fp_mul of fp_mul is

component Mul_24bit is
	port( 	A : in std_logic_vector(23 downto 0);
			B : in std_logic_vector(23 downto 0);
			Output : out std_logic_vector(47 downto 0));
end component;

component fp_operand is
port ( 
			fp32_a : in std_logic_vector (31 downto 0);
--			op_bin : out std_logic_vector(25 downto 0);
			a_exp : out std_logic_vector(7 downto 0);
			a_mant : out std_logic_vector(22 downto 0);
--			exp_zf, mnt_zf : out std_logic;
			a_sign, a_Nan , a_Zero, a_Den, a_Inf : out std_logic );
end component;		


--function Mul_24bit (	A : in std_logic_vector(23 downto 0);
--						B : in std_logic_vector(23 downto 0)) 


signal if1, if2 : std_logic;

signal a_exp, b_exp : std_logic_vector(7 downto 0);
signal a_mant, b_mant : std_logic_vector(22 downto 0);
signal a_mant_extend, b_mant_extend : std_logic_vector(23 downto 0);
signal mantissa_product_temp : std_logic_vector(47 downto 0);
signal mantissa_product : std_logic_vector(47 downto 0);
signal a_sign, a_Nan , a_Zero, a_Den, a_Inf : std_logic;
signal b_sign, b_Nan , b_Zero, b_Den, b_Inf : std_logic;
signal a_sign_temp, a_Nan_temp , a_Zero_temp, a_Den_temp, a_Inf_temp : std_logic;
signal b_sign_temp, b_Nan_temp , b_Zero_temp, b_Den_temp, b_Inf_temp : std_logic;
signal output_temp : std_logic_vector(31 downto 0);	

signal valid_1, valid_2 : std_logic;
signal fp_and_mul : std_logic;

signal r1_dest    : std_logic_vector(4 downto 0);
signal r1_rob_loc : std_logic_vector(6 downto 0);
signal r1_instr_val : std_logic ;

begin

-- CLOCK CYCLE 1 OF 3

opr1 : fp_operand port map (fp32_a => inp1, a_exp => a_exp , a_mant => a_mant , a_sign => a_sign_temp , a_Nan => a_Nan_temp , a_Zero => a_Zero_temp , a_Den => a_Den_temp, a_Inf => a_Inf_temp );
opr2 : fp_operand port map (fp32_a => inp2, a_exp => b_exp , a_mant => b_mant , a_sign => b_sign_temp , a_Nan => b_Nan_temp , a_Zero => b_Zero_temp , a_Den => b_Den_temp, a_Inf => b_Inf_temp );


--opr1 : fp_operand port map (fp32_a => inp1, a_exp => a_exp , a_mant => a_mant , a_sign => a_sign , a_Nan => a_Nan , a_Zero => a_Zero , a_Den => a_Den, a_Inf => a_Inf );
--opr2 : fp_operand port map (fp32_a => inp2, a_exp => b_exp , a_mant => b_mant , a_sign => b_sign , a_Nan => b_Nan , a_Zero => b_Zero , a_Den => b_Den, a_Inf => b_Inf );

a_mant_extend <= '1' & a_mant;			b_mant_extend <= '1' & b_mant;
Mul24 : Mul_24bit port map (A => a_mant_extend, B => b_mant_extend, Output => mantissa_product_temp);

fp_and_mul <= in_instr_val ;
 
process(clk) begin
	if (rising_edge(clk)) then 
		r1_dest     	<= DREG_DEST ;
		r1_rob_loc  	<= DREG_ROB_LOC ; 
		r1_instr_val 	<= fp_and_mul  ;
		
		if (fp_and_mul = '1') then			-- checked fp and mul
			
			mantissa_product <= mantissa_product_temp ;
			
			a_sign <= a_sign_temp;
			a_Nan <= a_Nan_temp;
			a_Zero <= a_Zero_temp;
			a_Inf <= a_Inf_temp;
			a_Den <= a_Den_temp;
			
			b_sign <= b_sign_temp;
			b_Nan <=b_Nan_temp;
			b_Zero <= b_Zero_temp;
			b_Inf <= b_Inf_temp;
			b_Den <= b_Den_temp;
			
			valid_1 <= '1';
			
		else valid_1 <= '0';
		end if;
	end if;
end process;

-- CLOCK CYCLE 2 OF 3

process(valid_1, a_exp, a_mant, a_sign, a_Nan , a_Zero, a_Den, a_Inf, b_exp, b_mant, b_sign, b_Nan , b_Zero, b_Den, b_Inf, mantissa_product)

--		variable mantissa_product : std_logic_vector(47 downto 0);
		variable exponent_out : std_logic_vector(7 downto 0);
		variable mantissa_out : std_logic_vector(22 downto 0);
		variable sign_out : std_logic;
	--	variable if1, if2 : std_logic;
		
	begin
	if (valid_1 = '1') then
		--00000000000000000000000000000000
--  	CAN'T PUT Compoennt inside process as component describes a h/w
	
--		MUL1 : Mul_24bit port map (A => mantissa1_ext , B => mantissa2_ext , Output => mantissa_product_temp );

		sign_out := a_sign xor b_sign;
		exponent_out := std_logic_vector(signed(a_exp) + signed(b_exp) - 127);
--		mantissa_product := std_logic_vector(unsigned('1' & a_mant) * unsigned('1' & b_mant));
		
		if(mantissa_product(47)='1') then
			exponent_out := std_logic_vector(unsigned(exponent_out) + 1);
			mantissa_out := mantissa_product(46 downto 24);
			if1 <= '1'; if2<='0';
		else
			exponent_out := exponent_out;
			mantissa_out := mantissa_product(45 downto 23);
			if2 <= '1'; if1<= '0';
		end if;
		
		
		
		if(((a_Zero and b_Inf) or (b_Zero and a_Inf)) = '1')then 		-- NaN
			output_temp <= sign_out & X"FF" & mantissa_out;
			valid_2 <= '1';
--		elsif(((a_Inf and b_Inf) or (a_Inf and (not b_Zero)) or (b_Inf and (not a_Zero))) = '1') then 		-- Infinity
		elsif((a_Inf and b_Inf) = '1') then
			output_temp <= sign_out & X"FF" & "00000000000000000000000";
			valid_2 <= '1';
--		elsif (((a_Zero and b_Zero) or (a_Zero and (not b_Zero)) or (b_Zero and (not a_Zero))) = '1') then	-- Zero
		elsif((a_Zero or b_Zero) = '1') then
			output_temp <= sign_out & "00000000" & "00000000000000000000000";
			valid_2 <= '1';		
		else
			output_temp <= sign_out & exponent_out & mantissa_out;
			valid_2 <= '1';
		end if;
	else 
		valid_2 <= '0';	
--		output_temp <= sign_out & exponent_out & mantissa_out;
	end if;
	
end process;
-- IF COND. always goes in else

process(clk) begin
	if(rising_edge(clk)) then

		reg_instr_val 	<= r1_instr_val ;

--		if valid_2 = '1' then	
			output <= output_temp;
			
			reg_dest    	<= r1_dest ;    
			reg_rob_loc 	<= r1_rob_loc ; 


		--else output <= (others => 'X');
		
		--end if;
	end if;
end process;

end architecture;


--fp_operand

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fp_operand is
port ( 
			fp32_a : in std_logic_vector (31 downto 0);
--			op_bin : out std_logic_vector(25 downto 0);
			a_exp : out std_logic_vector(7 downto 0);
			a_mant : out std_logic_vector(22 downto 0);
--			exp_zf, mnt_zf : out std_logic;
			a_sign, a_Nan , a_Zero, a_Den, a_Inf : out std_logic );
end entity;			

architecture arch1 of fp_operand is 

signal exp_a : std_logic_vector(7 downto 0);
signal mnt_a : std_logic_vector(22 downto 0);
signal exp_zf, mnt_zf : std_logic;				-- zero flag

begin

	a_exp <= fp32_a(30 downto 23);
	a_mant <= fp32_a(22 downto 0);
	a_sign <= fp32_a(31);
	
	mnt_a <= fp32_a(22 downto 0);
	exp_a <= fp32_a(30 downto 23);
	
	exp_zf <= '1' when (exp_a = X"00") else '0';
	mnt_zf <= '1' when (mnt_a = "00000000000000000000000") else '0';
	
	a_Zero <= '1' when (exp_zf = '1' and mnt_zf = '1') else '0' ;
	a_Inf  <= '1' when (exp_a = X"FF" and mnt_zf = '1') else '0' ;
	a_Nan  <= '1' when (exp_a = X"FF" and mnt_zf = '0') else '0' ;
	a_Den  <= '1' when (exp_zf = '1' and mnt_zf = '0') else '0';

--	op_bin <= '0' & (not exp_zf) & fp32_a(22 downto 0) & '0';

end architecture;


-- Mul 24 bit
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Mul_24bit is
port( A : in std_logic_vector(23 downto 0);
		B : in std_logic_vector(23 downto 0);
		Output : out std_logic_vector(47 downto 0));
end entity;

architecture arch_mul_24bit of Mul_24bit is
component Mul_12bit is
port(	A : in std_logic_vector(11 downto 0);
		B : in std_logic_vector(11 downto 0);
		Output : out std_logic_vector(23 downto 0));
end component;

component Ripple_Carry_25 is
   port(	input_vector_a: in std_logic_vector(24 downto 0);
			input_vector_b: in std_logic_vector(24 downto 0);
			input_c: in std_logic;
			output_vector_s: out std_logic_vector(24 downto 0);
			output_c : out std_logic);
end component;

signal Inter0, Inter1, Inter2, Inter3 : std_logic_vector(23 downto 0);
signal Inter00, Inter01, Inter02, Inter03, Inter04, Inter05, Inter06, Inter07 : std_logic_vector(24 downto 0);
signal sig_c : std_logic_vector(2 downto 0);
begin


mul1 : Mul_12bit port map (A=> A(11 downto 0), B=> B(11 downto 0), Output=> Inter0);
mul2 : Mul_12bit port map (A=> A(11 downto 0), B=> B(23 downto 12), Output=> Inter1);
mul3 : Mul_12bit port map (A=> A(23 downto 12), B=> B(11 downto 0), Output=> Inter2);
mul4 : Mul_12bit port map (A=> A(23 downto 12), B=> B(23 downto 12), Output=> Inter3);


Inter01 <= '0' & Inter1;
Inter02 <= '0' & Inter2;
Inter03 <= '0' & Inter3;

Output(11 downto 0) <= Inter0(11 downto 0);
Inter00 <= "0000000000000" & Inter0(23 downto 12);

R1 : Ripple_Carry_25 port map (input_vector_a => Inter01, input_vector_b => Inter02, input_c => '0', output_vector_s => Inter04, output_c => sig_c(0));
R2 : Ripple_Carry_25 port map (input_vector_a => Inter04, input_vector_b => Inter00, input_c => '0', output_vector_s => Inter05, output_c => sig_c(1));

Output(23 downto 12) <= Inter05(11 downto 0);

-- Earlier ERROR was because of this
--Inter06 <= "0000000000000" & Inter05(23 downto 12);
Inter06 <= "00000000000" & sig_c(1) & Inter05(24 downto 12);

R3 : Ripple_Carry_25 port map (input_vector_a => Inter03, input_vector_b => Inter06, input_c => '0', output_vector_s => Inter07, output_c => sig_c(2));

Output(47 downto 24) <= Inter07(23 downto 0);

end architecture;

-- Mul 12 bit
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mul_12bit is
port(	A : in std_logic_vector(11 downto 0);
		B : in std_logic_vector(11 downto 0);
		Output : out std_logic_vector(23 downto 0));
end entity;

architecture arch_Mul_12 of Mul_12bit is
	component Mul_6bit is
		port(	A : in std_logic_vector(5 downto 0);
				B : in std_logic_vector(5 downto 0);
				Output : out std_logic_vector(11 downto 0));
	end component;
	
	component Ripple_Carry_14 is
		port( input_vector_a: in std_logic_vector(13 downto 0);
				input_vector_b: in std_logic_vector(13 downto 0);
				input_c: in std_logic;
				output_vector_s: out std_logic_vector(13 downto 0);
				output_c : out std_logic);
	end component;

signal Inter000, Inter0, Inter1, Inter2, Inter3 : std_logic_vector(11 downto 0);
signal Inter00, Inter01, Inter02, Inter03, Inter04, Inter05, Inter06, Inter07 : std_logic_vector(13 downto 0);
signal sig_c : std_logic_vector(2 downto 0);

begin

mul1 : Mul_6bit port map (A=> A(5 downto 0), B=> B(5 downto 0), Output=> Inter0);
mul2 : Mul_6bit port map (A=> A(5 downto 0), B=> B(11 downto 6), Output=> Inter1);
mul3 : Mul_6bit port map (A=> A(11 downto 6), B=> B(5 downto 0), Output=> Inter2);
mul4 : Mul_6bit port map (A=> A(11 downto 6), B=> B(11 downto 6), Output=> Inter3);

Inter01 <= "00" & Inter1;
Inter02 <= "00" & Inter2;
Inter03 <= "00" & Inter3;


Output(5 downto 0) <= Inter0(5 downto 0);
Inter00 <= "00000000" & Inter0(11 downto 6);


R1 : Ripple_Carry_14 port map (input_vector_a => Inter01, input_vector_b => Inter02, input_c => '0', output_vector_s => Inter04, output_c => sig_c(0));
R2 : Ripple_Carry_14 port map (input_vector_a => Inter04, input_vector_b => Inter00, input_c => '0', output_vector_s => Inter05, output_c => sig_c(1));

Output(11 downto 6) <= Inter05(5 downto 0);

--Inter06 <= "0000000" & sig_c(1) & Inter05(11 downto 6);
Inter06 <= "00000" & sig_c(1) & Inter05(13 downto 6);

R3 : Ripple_Carry_14 port map (input_vector_a => Inter03, input_vector_b => Inter06, input_c => '0', output_vector_s => Inter07, output_c => sig_c(2));

Output(23 downto 12) <= Inter07(11 downto 0);

end architecture;

-- Mul 6 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Mul_6bit is
port( A : in std_logic_vector(5 downto 0);
		B : in std_logic_vector(5 downto 0);
		Output : out std_logic_vector(11 downto 0));
end entity;

architecture arch_mul_6bit of Mul_6bit is
component Mul_3bit is
port(	A : in std_logic_vector(2 downto 0);
		B : in std_logic_vector(2 downto 0);
		Output : out std_logic_vector(5 downto 0));
end component;

component Ripple_Carry_8 is
   port( input_vector_a: in std_logic_vector(7 downto 0);
			input_vector_b: in std_logic_vector(7 downto 0);
			input_c: in std_logic;
       	output_vector_s: out std_logic_vector(7 downto 0);
			output_c : out std_logic);
end component;

signal Inter0, Inter1, Inter2, Inter3 : std_logic_vector(5 downto 0);
signal Inter00, Inter01, Inter02, Inter03, Inter04, Inter05, Inter06, Inter07 : std_logic_vector(7 downto 0);
signal sig_c : std_logic_vector(2 downto 0);
begin


mul1 : Mul_3bit port map (A=> A(2 downto 0), B=> B(2 downto 0), Output=> Inter0);
mul2 : Mul_3bit port map (A=> A(2 downto 0), B=> B(5 downto 3), Output=> Inter1);
mul3 : Mul_3bit port map (A=> A(5 downto 3), B=> B(2 downto 0), Output=> Inter2);
mul4 : Mul_3bit port map (A=> A(5 downto 3), B=> B(5 downto 3), Output=> Inter3);


Inter01 <= "00" & Inter1;
Inter02 <= "00" & Inter2;
Inter03 <= "00" & Inter3;

Output(2 downto 0) <= Inter0(2 downto 0);
Inter00 <= "00000" & Inter0(5 downto 3);

R1 : Ripple_Carry_8 port map (input_vector_a => Inter01, input_vector_b => Inter02, input_c => '0', output_vector_s => Inter04, output_c => sig_c(0));
R2 : Ripple_Carry_8 port map (input_vector_a => Inter04, input_vector_b => Inter00, input_c => '0', output_vector_s => Inter05, output_c => sig_c(1));

Output(5 downto 3) <= Inter05(2 downto 0);
Inter06 <= "000" & Inter05(7 downto 3);

R3 : Ripple_Carry_8 port map (input_vector_a => Inter03, input_vector_b => Inter06, input_c => '0', output_vector_s => Inter07, output_c => sig_c(2));

Output(11 downto 6) <= Inter07(5 downto 0);

end architecture;

-- Mul 3
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mul_3bit is
port(A : in std_logic_vector(2 downto 0);
		B : in std_logic_vector(2 downto 0);
		Output : out std_logic_vector(5 downto 0));
end entity;

architecture arch_mul3 of Mul_3bit is
component Full_Adder_FPM  is
  port (A, B, Cin: in std_logic; S, Cout: out std_logic);
end component;

component Half_Adder  is
  port (A, B: in std_logic; S, C: out std_logic);
end component;

signal O : std_logic_vector(5 downto 0) := (others => '0');
signal A0B0, A1B0, A2B0, A0B1, A1B1, A2B1, A0B2, A1B2, A2B2 : std_logic := '0';
signal C : std_logic_vector(4 downto 0) := (others => '0');
signal Inter : std_logic_vector(1 downto 0) := (others => '0');

begin

A1B0 <= (A(1) and B(0));
A2B0 <= (A(2) and B(0));
A0B1 <= (A(0) and B(1));
A1B1 <= (A(1) and B(1));
A2B1 <= (A(2) and B(1));
A0B2 <= (A(0) and B(2));
A1B2 <= (A(1) and B(2));
A2B2 <= (A(2) and B(2));


O(0) <= A(0) and B(0);
ha1 : Half_Adder port map (A=> A1B0, B=> A0B1, S=> O(1), C=> C(0) );
fa1 : Full_Adder_FPM port map (A=> A2B0, B=> A1B1, Cin=> C(0), S=> Inter(0), Cout=> C(1));
ha2 : Half_Adder port map (A=> Inter(0), B=> A0B2, S=> O(2), C=> C(2) );
fa2 : Full_Adder_FPM port map (A=> A2B1, B=> A1B2, Cin=> C(1), S=> Inter(1), Cout=> C(3));
ha3 : Half_Adder port map (A=> Inter(1), B=> C(2), S=> O(3), C=> C(4) );
fa3 : Full_Adder_FPM port map (A=>A2B2 , B=> C(3), Cin=> C(4) , S=> O(4), Cout=> O(5));

Output <= O;
end architecture;

-- Ripple 8
-- A Ripple

library ieee;
use ieee.std_logic_1164.all;
entity Ripple_Carry_8 is
   port( input_vector_a: in std_logic_vector(7 downto 0);
			input_vector_b: in std_logic_vector(7 downto 0);
			input_c: in std_logic;
       	output_vector_s: out std_logic_vector(7 downto 0);
			output_c : out std_logic);
end entity;

architecture arch_Ripple_8 of Ripple_Carry_8 is
   component Full_Adder_FPM is
     port(A,B,Cin: in std_logic;
         	S,Cout: out std_logic);
   end component;
	
	signal sig_c : std_logic_vector(6 downto 0);
	
	
begin

   -- input/output vector element ordering is critical,
   -- and must match the ordering in the trace file!
   FA1: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(0),
					B   => input_vector_b(0),
					Cin => input_c,
					-- order of outputs S Cout
					S => output_vector_s(0),
					Cout => sig_c(0));
					
	FA2: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(1),
					B   => input_vector_b(1),
					Cin => sig_c(0),
					-- order of outputs S Cout
					S => output_vector_s(1),
					Cout => sig_c(1));
					
    FA3: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(2),
					B   => input_vector_b(2),
					Cin => sig_c(1),
					-- order of outputs S Cout
					S => output_vector_s(2),
					Cout => sig_c(2));
					
	FA4: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(3),
					B   => input_vector_b(3),
					Cin => sig_c(2),
					-- order of outputs S Cout
					S => output_vector_s(3),
					Cout => sig_c(3));

	FA5: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(4),
					B   => input_vector_b(4),
					Cin => sig_c(3),
					-- order of outputs S Cout
					S => output_vector_s(4),
					Cout => sig_c(4));
					
	FA6: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(5),
					B   => input_vector_b(5),
					Cin => sig_c(4),
					-- order of outputs S Cout
					S => output_vector_s(5),
					Cout => sig_c(5));

	FA7: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(6),
					B   => input_vector_b(6),
					Cin => sig_c(5),
					-- order of outputs S Cout
					S => output_vector_s(6),
					Cout => sig_c(6));

	FA8: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(7),
					B   => input_vector_b(7),
					Cin => sig_c(6),
					-- order of outputs S Cout
					S => output_vector_s(7),
					Cout => output_c);

					
					
end arch_Ripple_8;




-- Ripple 14

library ieee;
use ieee.std_logic_1164.all;
entity Ripple_Carry_14 is
   port( input_vector_a: in std_logic_vector(13 downto 0);
			input_vector_b: in std_logic_vector(13 downto 0);
			input_c: in std_logic;
       	output_vector_s: out std_logic_vector(13 downto 0);
			output_c : out std_logic);
end entity;

architecture arch_Ripple_14 of Ripple_Carry_14 is
   component Full_Adder_FPM is
     port(A,B,Cin: in std_logic;
         	S,Cout: out std_logic);
   end component;
	
	signal sig_c : std_logic_vector(12 downto 0);
	
	
begin

   -- input/output vector element ordering is critical,
   -- and must match the ordering in the trace file!
   FA1: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(0),
					B   => input_vector_b(0),
					Cin => input_c,
					-- order of outputs S Cout
					S => output_vector_s(0),
					Cout => sig_c(0));
					
	FA2: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(1),
					B   => input_vector_b(1),
					Cin => sig_c(0),
					-- order of outputs S Cout
					S => output_vector_s(1),
					Cout => sig_c(1));
					
    FA3: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(2),
					B   => input_vector_b(2),
					Cin => sig_c(1),
					-- order of outputs S Cout
					S => output_vector_s(2),
					Cout => sig_c(2));
					
	FA4: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(3),
					B   => input_vector_b(3),
					Cin => sig_c(2),
					-- order of outputs S Cout
					S => output_vector_s(3),
					Cout => sig_c(3));

	FA5: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(4),
					B   => input_vector_b(4),
					Cin => sig_c(3),
					-- order of outputs S Cout
					S => output_vector_s(4),
					Cout => sig_c(4));
					
	FA6: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(5),
					B   => input_vector_b(5),
					Cin => sig_c(4),
					-- order of outputs S Cout
					S => output_vector_s(5),
					Cout => sig_c(5));

	FA7: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(6),
					B   => input_vector_b(6),
					Cin => sig_c(5),
					-- order of outputs S Cout
					S => output_vector_s(6),
					Cout => sig_c(6));

	FA8: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(7),
					B   => input_vector_b(7),
					Cin => sig_c(6),
					-- order of outputs S Cout
					S => output_vector_s(7),
					Cout => sig_c(7));

	FA9: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(8),
					B   => input_vector_b(8),
					Cin => sig_c(7),
					-- order of outputs S Cout
					S => output_vector_s(8),
					Cout => sig_c(8));
					
	FA10: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(9),
					B   => input_vector_b(9),
					Cin => sig_c(8),
					-- order of outputs S Cout
					S => output_vector_s(9),
					Cout => sig_c(9));
					
    FA11: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(10),
					B   => input_vector_b(10),
					Cin => sig_c(9),
					-- order of outputs S Cout
					S => output_vector_s(10),
					Cout => sig_c(10));
					
	FA12: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(11),
					B   => input_vector_b(11),
					Cin => sig_c(10),
					-- order of outputs S Cout
					S => output_vector_s(11),
					Cout => sig_c(11));

	FA13: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(12),
					B   => input_vector_b(12),
					Cin => sig_c(11),
					-- order of outputs S Cout
					S => output_vector_s(12),
					Cout => sig_c(12));
					
	FA14: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(13),
					B   => input_vector_b(13),
					Cin => sig_c(12),
					-- order of outputs S Cout
					S => output_vector_s(13),
					Cout => output_c);
				
					
end architecture;





-- Ripple 25

library ieee;
use ieee.std_logic_1164.all;
entity Ripple_Carry_25 is
   port(	input_vector_a: in std_logic_vector(24 downto 0);
			input_vector_b: in std_logic_vector(24 downto 0);
			input_c: in std_logic;
			output_vector_s: out std_logic_vector(24 downto 0);
			output_c : out std_logic);
end entity;

architecture arch_Ripple_25 of Ripple_Carry_25 is
component Ripple_Carry_12 is
   port( 	input_vector_a: in std_logic_vector(11 downto 0);
			input_vector_b: in std_logic_vector(11 downto 0);
			input_c: in std_logic;
			output_vector_s: out std_logic_vector(11 downto 0);
			output_c : out std_logic);
end component;

component Full_Adder_FPM  is
  port (A, B, Cin: in std_logic; S, Cout: out std_logic);
end component;

	signal sig_c : std_logic;
	signal sig_c1 : std_logic;
	
begin

   -- input/output vector element ordering is critical,
   -- and must match the ordering in the trace file!
    RC1: Ripple_Carry_12 port map (
					-- order of inputs Cin B A
					input_vector_a   => input_vector_a(11 downto 0),
					input_vector_b   => input_vector_b(11 downto 0),
					input_c => input_c,
					-- order of outputs S Cout
					output_vector_s => output_vector_s(11 downto 0),
					output_c => sig_c);
					
	RC2: Ripple_Carry_12 port map (
					-- order of inputs Cin B A
					input_vector_a   => input_vector_a(23 downto 12),
					input_vector_b   => input_vector_b(23 downto 12),
					input_c => sig_c,
					-- order of outputs S Cout
					output_vector_s => output_vector_s(23 downto 12),
					output_c => sig_c1);
					
	FA1: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(24),
					B   => input_vector_b(24),
					Cin => sig_c1,
					-- order of outputs S Cout
					S => output_vector_s(24),
					Cout => output_c);					
end arch_Ripple_25;


-- Ripple 12

library ieee;
use ieee.std_logic_1164.all;
entity Ripple_Carry_12 is
   port( input_vector_a: in std_logic_vector(11 downto 0);
			input_vector_b: in std_logic_vector(11 downto 0);
			input_c: in std_logic;
       	output_vector_s: out std_logic_vector(11 downto 0);
			output_c : out std_logic);
end entity;

architecture arch_Ripple_12 of Ripple_Carry_12 is
   component Full_Adder_FPM is
     port(A,B,Cin: in std_logic;
         	S,Cout: out std_logic);
   end component;
	
	signal sig_c : std_logic_vector(10 downto 0);
	
	
begin

   -- input/output vector element ordering is critical,
   -- and must match the ordering in the trace file!
   FA1: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(0),
					B   => input_vector_b(0),
					Cin => input_c,
					-- order of outputs S Cout
					S => output_vector_s(0),
					Cout => sig_c(0));
					
	FA2: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(1),
					B   => input_vector_b(1),
					Cin => sig_c(0),
					-- order of outputs S Cout
					S => output_vector_s(1),
					Cout => sig_c(1));
					
    FA3: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(2),
					B   => input_vector_b(2),
					Cin => sig_c(1),
					-- order of outputs S Cout
					S => output_vector_s(2),
					Cout => sig_c(2));
					
	FA4: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(3),
					B   => input_vector_b(3),
					Cin => sig_c(2),
					-- order of outputs S Cout
					S => output_vector_s(3),
					Cout => sig_c(3));

	FA5: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(4),
					B   => input_vector_b(4),
					Cin => sig_c(3),
					-- order of outputs S Cout
					S => output_vector_s(4),
					Cout => sig_c(4));
					
	FA6: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(5),
					B   => input_vector_b(5),
					Cin => sig_c(4),
					-- order of outputs S Cout
					S => output_vector_s(5),
					Cout => sig_c(5));

	FA7: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(6),
					B   => input_vector_b(6),
					Cin => sig_c(5),
					-- order of outputs S Cout
					S => output_vector_s(6),
					Cout => sig_c(6));

	FA8: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(7),
					B   => input_vector_b(7),
					Cin => sig_c(6),
					-- order of outputs S Cout
					S => output_vector_s(7),
					Cout => sig_c(7));

	FA9: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(8),
					B   => input_vector_b(8),
					Cin => sig_c(7),
					-- order of outputs S Cout
					S => output_vector_s(8),
					Cout => sig_c(8));
					
	FA10: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(9),
					B   => input_vector_b(9),
					Cin => sig_c(8),
					-- order of outputs S Cout
					S => output_vector_s(9),
					Cout => sig_c(9));
					
    FA11: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(10),
					B   => input_vector_b(10),
					Cin => sig_c(9),
					-- order of outputs S Cout
					S => output_vector_s(10),
					Cout => sig_c(10));
					
	FA12: Full_Adder_FPM port map (
					-- order of inputs Cin B A
					A   => input_vector_a(11),
					B   => input_vector_b(11),
					Cin => sig_c(10),
					-- order of outputs S Cout
					S => output_vector_s(11),
					Cout => output_c);
				
					
end architecture;

-- FA 

library ieee;
use ieee.std_logic_1164.all;

entity Full_Adder_FPM  is
  port (A, B, Cin: in std_logic; S, Cout: out std_logic);
end entity Full_Adder_FPM;

architecture Struct of Full_Adder_FPM is
begin

S<= A xor B xor Cin;
Cout <= ((A xor B) and Cin) or (A and B);

end Struct;

-- HA
library ieee;
use ieee.std_logic_1164.all;
entity Half_Adder is
   port (A, B: in std_logic; S, C: out std_logic);
end entity Half_Adder;

architecture Equations of Half_Adder is
begin
   S <= (A xor B);
   C <= (A and B);
end Equations;