library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.PKG_COMMON.all;

entity tb_fetch is
end entity;

architecture fetch_stim of tb_fetch is
	signal CLK: std_logic := '1';
	signal RST: std_logic;

	--Code Memory; Needs to be written in PKG_COMMON
	signal MEM: CODE_MEM;
	
	--Fetch will have input as a single program counter which 
	--helps in targeting the first of the 2 instructions to be fetched
	signal I_PC: std_logic_vector(31 downto 0);
	
	-- Inputs from the Common Data Bus
	signal I_TAG_EXEC: std_logic_vector(N_LOG_RR - 1 downto 0);
	signal I_VAL_EXEC: std_logic;
	signal I_PC_EXEC: std_logic_vector(31 downto 0); 
	signal I_HIST_IND_EXEC: std_logic_vector(N_Br_TAG - 1 downto 0);
	
	-- Outputs to the Decode Buffer and itself
	signal O_NEXT_PC: std_logic_vector(31 downto 0);
	signal O_I1_HIST_IND, O_I2_HIST_IND: std_logic_vector(N_Br_TAG - 1 downto 0);
	signal O_INST1, O_INST2: std_logic_vector(31 downto 0);
	
	--Debugging purpose
	signal hist_table: table;
	
begin
	DUT: entity work.FETCH(FETCH_ARCH) port map(
		CLK, RST,
		MEM,
		I_PC,
		I_TAG_EXEC, I_VAL_EXEC, I_PC_EXEC, I_HIST_IND_EXEC,
		O_NEXT_PC, O_I1_HIST_IND, O_I2_HIST_IND, O_INST1, O_INST2,
		hist_table
	);
	
	RST <= '1' after 10 ns, '0' after 70 ns;
	
	process
	begin
		CLK <= not CLK;
		wait for 20 ns;
	end process;
	
	process(CLK)
		variable i: integer := 0;
		variable j: integer := 0;
		file txt_file: text;
		variable txt_line: line;
		variable mem_size: integer := 7;
		type local_mem is array(0 to 6) of bit_vector(31 downto 0);
		variable memory: local_mem;
		variable codeMem: CODE_MEM;
	begin
		if rising_edge(CLK) then
			i := (i + 1);
			if(i = 1) then
				file_open(txt_file, "Codemem.txt", read_mode);
				j := 0;
				while not endfile(txt_file) loop
					readline(txt_file, txt_line);
					read(txt_line, memory(j));
					codeMem(j) := to_stdlogicvector(memory(j));
					j := (j + 1);
				end loop;
				file_close(txt_file);
				MEM <= codeMem;
			elsif(i = 2) then
				I_PC <= X"00000000";
				I_TAG_EXEC <= "00000";
				I_VAL_EXEC <= '0';
				I_PC_EXEC <= X"00000000";
				I_HIST_IND_EXEC <= "0000";
			elsif(i = 3) then
				I_PC <= X"00000002";
				I_TAG_EXEC <= "00000";
				I_VAL_EXEC <= '1';
				I_PC_EXEC <= X"33FFFFFF";
				I_HIST_IND_EXEC <= "0000";
			elsif(i = 4) then
				I_PC <= X"00000004";
				I_TAG_EXEC <= "00001";
				I_VAL_EXEC <= '0';
				I_PC_EXEC <= X"33FFFFFF";
				I_HIST_IND_EXEC <= "0001";
			end if;
		end if;
	end process;
	
end architecture fetch_stim;