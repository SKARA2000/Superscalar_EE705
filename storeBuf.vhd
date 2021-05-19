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
use work.PKG_COMMON.all;
use work.PKG_StoreBuf.all;

entity StoreBuffer is
	port(
		CLK: in std_Logic;
		RST: in std_logic;
		
		-- Inputs from the Memory Execution Unit
		I_DATA: in std_Logic_vector(OprSize - 1 downto 0);
		I_MemAddr: in std_Logic_vector(MemSize - 1 downto 0);
		I_LOC_EXEC_Buff: in std_logic_vector(BufferSize - 1 downto 0);
		I_VAL: in std_Logic;
		I_SW_VAL: in std_logic;
		
		-- Inputs from the ROB
		I_StoreCommit: in std_Logic;
		I_LOC_Buff: in std_logic_vector(BufferSize - 1 downto 0);
		
		-- Outputs from the Store Buffer to Memory
		O_DATA: out std_logic_vector(OprSize - 1 downto 0);
		O_MemAddr: out std_logic_vector(MemSize - 1 downto 0);
		O_WR: out std_logic;
		
		-- Outputs from the Store Buffer to the Memory Unit
		O_FREE_LOC: out std_logic_vector(BufferSize - 1 downto 0)
	);
end entity StoreBuffer;

architecture StoreBuf_Arch of StoreBuffer is
begin
	process(CLK)
		variable WR, FULL: std_logic;
		variable StoreBuff: Buffer_COL; 
		variable index: unsigned(BufferSize - 1 downto 0);
		variable DATA: std_Logic_vector(OprSize - 1 downto 0);
		variable MemAddr: std_logic_vector(MemSize - 1 downto 0);
	begin
		if(RST = '1') then
			StoreBuff := (others => (others => '0'));
			index := (others => '0');
			O_DATA <= (others => '0');
			O_MemAddr <= (others => '0');
			O_WR <= '0';
			O_FREE_LOC <= (others => '0');

		elsif rising_edge(CLK) then
			-- Check the Common Data Bus for new store instructions
			if(I_VAL = '1') and (I_SW_VAL = '1') then
				StoreBuff(to_integer(unsigned(I_LOC_EXEC_Buff))) := I_DATA & I_MemAddr & '1';index := index + 1;
				for i in 0 to (2**BufferSize - 1) loop
					if(StoreBuff(to_integer(index))(0) = '1') then
						index := index + 1;
					else
						exit;
					end if;
				end loop;
			end if;
			
			-- Now check whether ROB needs any instruction to be committed or not
			if(I_StoreCommit = '1') then
				DATA := StoreBuff(to_integer(unsigned(I_LOC_Buff)))((MemSize + OprSize) downto (MemSize + 1));
				MemAddr := StoreBuff(to_integer(unsigned(I_LOC_Buff)))((MemSize) downto 1);
				WR := '1';
				-- New place in Store Buffer opened up; fill it asap
				index := unsigned(I_LOC_Buff);
			else
				DATA := (others => '0');
				MemAddr := (others => '0');
				WR := '0';
			end if;
			
			O_DATA <= DATA;
			O_MemAddr <= MemAddr;
			O_WR <= WR;
			O_FREE_LOC <= std_Logic_vector(index);
		end if;
	end process;
end architecture StoreBuf_Arch;