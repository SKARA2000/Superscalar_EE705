library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder_8 is
	port(
		input1: in std_logic_vector(7 downto 0);
		input2: in std_logic_vector(7 downto 0);
		carryin: in std_logic;
		output: out std_logic_vector(7 downto 0);
		ovfl: out std_logic
	);
end adder_8;

architecture kung of adder_8 is
	type g_p is array(0 to 7) of std_logic_vector(1 downto 0); -- stores (pi, gi)
	signal sig_g_p: g_p;
	signal carry_g_p: g_p;
	type carry_first_lvl is array(0 to 3) of std_logic_vector(1 downto 0);
	type carry_sec_lvl is array(0 to 1) of std_logic_vector(1 downto 0);
	type carry_third_lvl is array(0 to 1) of std_logic_vector(1 downto 0);
	type carry_fourth_lvl is array(0 to 2) of std_logic_vector(1 downto 0);
	signal carry_block_first_lvl: carry_first_lvl; -- stores first level (pi[2i,2i+1], gi[2i,2i+1])
	signal carry_block_sec_lvl: carry_sec_lvl; -- stores second level (pi[2i,2i+1], gi[2i,2i+1])
	signal carry_block_third_lvl: carry_third_lvl; -- stores third level (pi[2i,2i+1], gi[2i,2i+1])
	signal carry_block_fourth_lvl: carry_fourth_lvl; -- stores third level (pi[2i,2i+1], gi[2i,2i+1])
begin
	process(input1, input2)
	begin
		for i in 1 to 7 loop
			sig_g_p(i) <= (input1(i) xor input2(i)) & (input1(i) and input2(i));
		end loop;
		sig_g_p(0) <= (input1(0) xor input2(0)) & (((input1(0) xor input2(0)) and carryin) or (input1(0) and input2(0))); 
	end process;
	
	process(sig_g_p)
	begin
		for i in 0 to 3 loop
			carry_block_first_lvl(i) <= (sig_g_p(2*i)(1) and sig_g_p(2*i+1)(1)) & ((sig_g_p(2*i)(0) and sig_g_p(2*i+1)(1)) or sig_g_p(2*i+1)(0));
		end loop;
	end process;
	
	process(carry_block_first_lvl)
	begin
		for i in 0 to 1 loop
			carry_block_sec_lvl(i) <= (carry_block_first_lvl(2*i)(1) and carry_block_first_lvl(2*i+1)(1)) & ((carry_block_first_lvl(2*i)(0) and carry_block_first_lvl(2*i+1)(1)) or carry_block_first_lvl(2*i+1)(0));
		end loop;
	end process;
	
	process(carry_block_sec_lvl, carry_block_first_lvl)
	begin
		carry_block_third_lvl(0) <= (carry_block_sec_lvl(0)(1) and carry_block_first_lvl(2)(1)) & ((carry_block_sec_lvl(0)(0) and carry_block_first_lvl(2)(1)) or carry_block_first_lvl(2)(0));
		carry_block_third_lvl(1) <= (carry_block_sec_lvl(0)(1) and carry_block_sec_lvl(1)(1)) & ((carry_block_sec_lvl(0)(0) and carry_block_sec_lvl(1)(1)) or carry_block_sec_lvl(1)(0));
	end process;
	
	process(sig_g_p, carry_block_first_lvl, carry_block_sec_lvl, carry_block_third_lvl)
	begin
		carry_block_fourth_lvl(0) <= (carry_block_first_lvl(0)(1) and sig_g_p(2)(1)) & ((carry_block_first_lvl(0)(0) and sig_g_p(2)(1)) or sig_g_p(2)(0));
		carry_block_fourth_lvl(1) <= (carry_block_sec_lvl(0)(1) and sig_g_p(4)(1)) & ((carry_block_sec_lvl(0)(0) and sig_g_p(4)(1)) or sig_g_p(4)(0));
		carry_block_fourth_lvl(2) <= (carry_block_third_lvl(0)(1) and sig_g_p(6)(1)) & ((carry_block_third_lvl(0)(0) and sig_g_p(6)(1)) or sig_g_p(6)(0));
	end process;
	
	process(sig_g_p, carry_block_first_lvl, carry_block_sec_lvl, carry_block_third_lvl, carry_block_fourth_lvl)
	begin
		carry_g_p(7) <= carry_block_third_lvl(1);
		carry_g_p(6) <= carry_block_fourth_lvl(2);
		carry_g_p(5) <= carry_block_third_lvl(0); 
		carry_g_p(4) <= carry_block_fourth_lvl(1);
		carry_g_p(3) <= carry_block_sec_lvl(0);
		carry_g_p(2) <= carry_block_fourth_lvl(0);
		carry_g_p(1) <= carry_block_first_lvl(0); 
		carry_g_p(0) <= sig_g_p(0);
	end process;
	
	process(carry_g_p, sig_g_p, carryin)
	begin
		output(0) <= sig_g_p(0)(1) xor carryin;
		for i in 1 to 7 loop
			output(i) <= carry_g_p(i-1)(0) xor sig_g_p(i)(1);
		end loop;
		ovfl <= carry_g_p(7)(0);
	end process;
end architecture kung;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity adder_32 is
	port(
		input1: in std_logic_vector(31 downto 0);
		input2: in std_logic_vector(31 downto 0);
		carryin: in std_logic;
		output: out std_logic_vector(31 downto 0);
		ovfl: out std_logic
	);
end entity adder_32;

architecture ripple_kung of adder_32 is
	signal carry_forward: std_logic_vector(3 downto 0) := "0000";
	signal ovfl_temp: std_logic;
begin
	adder0: entity work.adder_8(kung) port map(input1(7 downto 0), input2(7 downto 0), carryin, output(7 downto 0), carry_forward(0));
	adder1: entity work.adder_8(kung) port map(input1(15 downto 8), input2(15 downto 8), carry_forward(0), output(15 downto 8), carry_forward(1));
	adder2: entity work.adder_8(kung) port map(input1(23 downto 16), input2(23 downto 16), carry_forward(1), output(23 downto 16), carry_forward(2));
	adder3: entity work.adder_8(kung) port map(input1(31 downto 24), input2(31 downto 24), carry_forward(2), output(31 downto 24), ovfl);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity tb_adder32 is
end entity;

architecture stim of tb_adder32 is
	component adder_32 is
		port(
		input1: in std_logic_vector(31 downto 0);
		input2: in std_logic_vector(31 downto 0);
		carryin: in std_logic;
		output: out std_logic_vector(31 downto 0);
		ovfl: out std_logic
		);
	end component;
	signal input1, input2, output: std_logic_vector(31 downto 0);
	signal carryin, ovfl: std_logic;
begin
	dut: adder_32 port map(input1, input2, carryin, output, ovfl);
	input1 <= 	std_logic_vector(to_unsigned(1, input1'length)),  
				std_logic_vector(to_unsigned(2007, input1'length)) after 20 ns, 
				std_logic_vector(to_unsigned(13100, input1'length)) after 30 ns,
				std_logic_vector(to_unsigned(2147483647, input1'length)) after 40 ns;
	input2 <= 	std_logic_vector(to_unsigned(3, input1'length)),  
				std_logic_vector(to_unsigned(3101, input1'length)) after 20 ns, 
				std_logic_vector(to_unsigned(15043, input1'length)) after 30 ns,
				std_logic_vector(to_unsigned(2147480647, input1'length)) after 40 ns;
	carryin <= 	'0', 
				'1' after 20 ns,
				'0' after 30 ns,
				'1' after 40 ns;
end architecture;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
	port(
		inp1: in std_logic_vector(31 downto 0);
		inp2: in std_logic_vector(31 downto 0);
		shift_amt: in std_logic_vector(4 downto 0);
		logic_control: in std_logic_vector(1 downto 0);
		shift_control: in std_logic_vector(1 downto 0);
		alu_outp_control: in std_logic_vector(1 downto 0);
		add_sub: in std_logic;
		outp: out std_logic_vector(31 downto 0);
		ovfl: out std_logic;
		carr_ovfl: out std_logic;
		zero: out std_logic
	);
end entity ALU;

architecture dataflow of ALU is
	component adder_32 is
		port(
		input1: in std_logic_vector(31 downto 0);
		input2: in std_logic_vector(31 downto 0);
		carryin: in std_logic;
		output: out std_logic_vector(31 downto 0);
		ovfl: out std_logic
		);
	end component;
	signal add_inp2, add_outp, logic_outp, shift_outp, slt_outp: std_logic_vector(31 downto 0);
begin
	add_inp2 <= inp2 when (add_sub = '1') else (inp2 xor "11111111111111111111111111111111");	-- 2's complemetn for subtraction if necessary
	Adder: adder_32 port map(inp1, add_inp2, add_sub, add_outp, carr_ovfl);						-- Adder instantiation, Carry flag is set when adder has a global carry
	
	slt_outp <= std_logic_vector(to_unsigned(1, add_outp'length)) when (add_outp(31) = '1') else std_logic_vector(to_unsigned(0, add_outp'length));
	
	with logic_control select logic_outp <=
		inp1 and inp2 when "00", 		-- and logic
		inp1 or inp2 when "01",			-- or logic
		inp1 xor inp2 when "10",		-- xor logic
		(others => '0') when others;	-- default output
	
	with shift_control select shift_outp <= 
		inp2 when "00",																					-- no shift
		std_logic_vector(shift_right(signed(inp2), to_integer(unsigned(shift_amt)))) when "01", 		-- right shift arithmetic
		std_logic_vector(shift_left(unsigned(inp2), to_integer(unsigned(shift_amt)))) when "10", 		-- left shift 
		std_logic_vector(shift_right(unsigned(inp2), to_integer(unsigned(shift_amt)))) when "11", 		-- right shift logical
		(others => '0') when others;																	-- default output
	
	with alu_outp_control select outp <= 
		shift_outp when "00",			-- shift instruction
		slt_outp when "01",				-- slt instruction
		add_outp when "10",				-- add instruction
		logic_outp when "11",			-- logic instruction
		(others => '0') when others;	-- default output
		
	ovfl <= (inp1(31) and add_inp2(31) and (not add_outp(31))) or ((not inp1(31)) and (not add_inp2(31)) and add_outp(31));	-- Overflow Flag set when adder output is wrong
	zero <= '1' when (add_outp = "00000000000000000000000000000000") else '0';												-- Zero flag is set when adder output is zero
	
end architecture;