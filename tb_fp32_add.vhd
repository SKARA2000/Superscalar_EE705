library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG_EX_FPU.all;

entity tb is end entity;

architecture rch1 of tb is 

component fp32_add is
	port ( 
				CLK : in std_logic;
				
				ctrl_sig  : in std_logic_vector(N_CTRL_BITS-1 downto 0);
				instr     : in std_logic_vector(N_OPCODE_BITS + N_SHAMT_BITS + N_FUNC_BITS - 1 downto 0);
				i_dest_reg  : in std_logic_vector(N_LOG_RR - 1 downto 0 );

				fp32_a , fp32_b : in std_logic_vector (31 downto 0);
				fp_sum : out std_logic_vector (31 downto 0); 
				instr_valid : out std_logic ;
				o_dest_reg : out std_logic_vector(N_LOG_RR-1 downto 0);
				
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

signal f32_a, f32_b, f32_out : std_logic_vector(31 downto 0);
signal clk : std_logic := '0';
signal add : std_logic := '0';
signal count : integer := 0;
signal ready : std_logic ;

signal temp_s_op1_sign, temp_s_op2_sign :  std_logic;
signal temp_s_op1_exp, temp_s_op2_exp :  std_logic_vector(7 downto 0);
signal temp_s_exp_diff  :  unsigned(8 downto 0);
signal temp_s_op1_bin, temp_s_op2_bin		:  std_logic_vector(49 downto 0);
signal temp_s_op1_NZDI, temp_s_op2_NZDI :  std_logic_vector(3 downto 0);

signal temp_op2_shifted, temp_SumorDiff : std_logic_vector(49 downto 0);
signal temp_loc : std_logic_vector(7 downto 0);
signal temp_mantissa : std_logic_vector(22 downto 0);
signal ctrl_sig : std_logic_vector(N_CTRL_BITS -1 downto 0);
signal instr     :  std_logic_vector(N_OPCODE_BITS + N_SHAMT_BITS + N_FUNC_BITS - 1 downto 0);
signal i_dest_reg  :  std_logic_vector(N_LOG_RR - 1 downto 0 );

signal instr_valid : std_logic ;
signal o_dest_reg : std_logic_vector(N_LOG_RR-1 downto 0) ;
--signal [2:0] state;
constant t_cycle : time := 20ns;

begin

	
	dut : fp32_add port map ( 	clk, ctrl_sig, instr , i_dest_reg,
												f32_a, f32_b, f32_out, instr_valid, o_dest_reg , 
												temp_s_op1_sign, temp_s_op2_sign, 
												temp_s_op1_exp, temp_s_op2_exp ,
												temp_s_exp_diff, temp_s_op1_bin ,
												temp_s_op2_bin	,
												temp_s_op1_NZDI, temp_s_op2_NZDI,
												temp_op2_shifted, temp_SumorDiff, temp_loc, temp_mantissa );	
	
	
	process 
	variable count : integer := 0;
	begin
	
		wait for t_cycle/2;
		clk <= not clk;
		wait for t_cycle/2;
		clk <= not clk;
		count := count + 1;
		
		if count = 63 then wait; end if;
	end process;
	
	process(clk) 
	begin
		if (clk = '1') then
			count <= count + 1;
		end if;	
	end process;
	
	process (count) 
	begin
		ctrl_sig <= (others => '0');
		
		if (count = 4) then
			instr <= OPCODE_FPU & "00000" & "000001" ;
			i_dest_reg <= "00001" ;
			f32_a <= X"0554AD2E";	--1e-35
			f32_b <= X"0554AD2E";	--1e-35
		end if;

		if (count = 5) then
			instr <= OPCODE_FPU & "00000" & "000001" ;
			i_dest_reg <= "00101" ;
		
			f32_a <= X"799A130C";	--1e35
			f32_b <= X"0554AD2E";	--1e-35
		end if;

		if (count = 6) then
			instr <= OPCODE_FPU & "00000" & "000101" ;
			i_dest_reg <= "00001" ;
		
			f32_a <= X"F99A130C";	--1e35
			f32_b <= X"0554AD2E";	--1e-35
		end if;
		
		if (count = 7) then
			instr <= OPCODE_FPU & "00000" & "000001" ;
			o_dest_reg <= "00001" ;
		
			f32_a <= X"42F06666";	--(120.2)
			f32_b <= X"BFC461AE";	--(-1.534231)
		end if;
		
		if (count = 8) then
			f32_a <= X"42F06666";	--(120.2)
			f32_b <= X"3FC461AE";	--1.534231
		end if;

		if (count = 9) then
			instr <= OPCODE_FPU & "00000" & "000001" ;
			o_dest_reg <= "00001" ;

			f32_a <= X"BF800000";	--(-1.0)
			f32_b <= X"3F800000";		--1.0
		end if;
	
		if (count = 10) then
			instr <= OPCODE_FPU & "00000" & "000001" ;
			o_dest_reg <= "00001" ;
		
			f32_a <= X"3F800000";	--1.0
			f32_b <= X"3F800000";		--1.0
		end if;
		
		--if (count == 11) add = 0;
		
		if (count = 11) then
			instr <= OPCODE_FPU & "00000" & "000001" ;
			o_dest_reg <= "00001" ;
		
			f32_a <= X"00000000";	--0.0
			f32_b <= X"00000000";	--0.0
			--add = 1;
		end if;
		
		--if (count == 21) add = 0;
		
		if (count = 12) then
			f32_a <= X"40000000";	--2.0
			f32_b <= X"3F800000";	--1.0
			--add = 1;
		end if;
		
		if (count = 13) then
			f32_a <= X"40000000";	--2.0
			f32_b <= X"BF800000";	--(-1.0)
			--add = 1;
		end if;

		if (count = 14) then
			f32_a <= X"02081CEA";	--1E-37
			f32_b <= X"006CE3EE";	--1E-38
			--add = 1;
		end if;

		if (count = 15) then
			f32_b <= X"02081CEA";	--1E-37
			f32_a <= X"006CE3EE";	--1E-38
			--add = 1;
		end if;

		if (count = 16) then
			f32_a <= X"806CE3EE";	--1E-38		
			f32_b <= X"02081CEA";	--1E-37
			--add = 1;
		end if;

		if (count = 17) then
			f32_a <= X"006CE3EE";	--1E-38
			f32_b <= X"82081CEA";	--1E-37			
			--add = 1;
		end if;

		if (count = 18) then
			f32_a <= X"000AE398";	--1E-39		
			f32_b <= X"006CE3EE";	--1E-38
			--add = 1;
		end if;
		
		--if (count ==31) add = 0;
	end process;	
	
end architecture;	
