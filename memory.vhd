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
use ieee.numeric_std.all;
--use work.PKG_COMMON.all;
use work.PKG_StoreBuf.all;

entity memory is
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
		
end entity;

architecture memory_arch of memory is

type mem_type is array(ram_size downto 0) of std_logic_vector(data_bit - 1 downto 0);	-- slv width = data_width
signal ram 								: mem_type := (others => (others => '0'));			-- array width = 2^address_width

signal Address , Address1				: std_logic_vector(address_bit - 1 downto 0);
signal load , r1_load					: std_logic;
signal store, prev_store, r1_store		: std_logic;

begin

-- 1st cycle : Address Calculation

Address <= std_logic_vector(unsigned(operand1) + unsigned(operand2));
load <= DREG_CTRL(24) and DREG_CTRL(5);
store <= DREG_CTRL(24) and DREG_CTRL(4);

process (clk)
begin

	if(rst = '1') then				-- Shubham
		ram(0) <= X"5C5C0000";
		ram(1) <= X"5C5C0001";
		ram(2) <= X"5C5C0002";
		ram(3) <= X"5C5C0003";
		ram(4) <= X"5C5C0004";
		ram(5) <= X"5C5C0005";
		ram(ram_size - 1 downto 6) <= (others => (others => '0'));
		
		
	elsif(rising_edge(clk)) then
		
		mem_address <= Address;
		
		-- Buffering Address and Load Store
		Address1 <= Address;
		
		r1_store <= store;
		r1_load  <= load;
		
		
		if (r1_load = '1') then
			
			sw_valid <= '0';
			Data <= ram(to_integer(unsigned(Address1)));
			valid <= RS_OUTPUT_VALID;
			reg_rob_loc <=dreg_rob_loc;
			reg_dest <= dreg_dest;
		
		elsif (r1_store = '1') then
			
			sw_valid <= '1';
			Data <= operand0;
			valid <= RS_OUTPUT_VALID;
			reg_rob_loc <=dreg_rob_loc;
			reg_dest <= dreg_dest;
			
			-- WRITE TO RAM DURING STORE IF SB_ENABLE
			if (SB_Enable = '1') then 
				ram(to_integer(unsigned(SB_mem_add))) <= SB_Data;
			end if;
			
			-- FREE LOC
			if (prev_store = '1') then
				out_freeloc <= std_Logic_vector(unsigned(in_freeloc) + 1);
			else
				out_freeloc <= in_freeloc;
			end if;
			
		end if;
		
		-- STORING PREV LOAD/STORE OPERATION		
		if (store = '1') then
			prev_store <= '1';
		
		else 
			prev_store <= '0';
		end if;
		
	end if;
end process;

-- 2nd clock  : 

--load <= DREG_CTRL(24) and DREG_CTRL(5);
--store <= DREG_CTRL(24) and DREG_CTRL(4);
--
--process(clk)
--begin
--
--	if(rising_edge(clk)) then
--		
--		if (r1_load = '1') then
--			
--			sw_valid <= '0';
--			Data <= ram(to_integer(unsigned(Address1)));
--			valid <= RS_OUTPUT_VALID;
--			reg_rob_loc <=dreg_rob_loc;
--			reg_dest <= dreg_dest;
--		
--		elsif (r1_store = '1') then
--			
--			sw_valid <= '1';
--			Data <= operand0;
--			valid <= RS_OUTPUT_VALID;
--			reg_rob_loc <=dreg_rob_loc;
--			reg_dest <= dreg_dest;
--
----			ram(to_integer(unsigned(Address1))) <= operand0;
--
--			if(prev_store = '1') then
--				out_freeloc <= std_Logic_vector(unsigned(in_freeloc) + 1);
--			else
--				out_freeloc <= in_freeloc;
--			end if;
--			
--		end if;
--	end if;
--end process;


--process(clk)
--begin
--	if(rising_edge(clk)) then
--		if (memread = '1') then
--			readdata <= ram(to_integer(unsigned(readaddress)));
--		--end if;
--		
--		elsif (memwrite = '1') then
--			ram(to_integer(unsigned(writeaddress))) <= writedata;
--		end if;
--		
--	end if;
--end process;

end architecture;