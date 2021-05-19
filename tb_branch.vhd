library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG_COMMON.all;

entity tb_branch is
end entity;

architecture branch_stim of tb_branch is
	signal clk: std_logic := '0';
	--Input operands from the Reservation Station
	signal I_OPR1: std_logic_vector(31 downto 0);
	signal I_OPR2: std_logic_vector(31 downto 0);
	signal I_OPR3: std_logic_vector(31 downto 0);
	signal I_CTRL_BITS: std_logic_vector(N_CTRL_BITS - 1 downto 0);
	signal I_PREDICTION: std_logic; -- 1 if branch taken, 0 if not taken
	
	--Utility Inputs from the reservation station
	signal I_LOC: std_logic_vector(N_LOG_ROB - 1 downto 0);
	signal I_BrTAG: std_logic_vector(N_Br_TAG - 1 downto 0);
	signal I_HIST_IND: std_logic_vector(N_Br_TAG - 1 downto 0);
	
	--Outputs as a proper execution unit
	signal O_OUT_PC: std_logic_vector(31 downto 0);
	signal O_HIST_IND: std_logic_vector(N_Br_TAG - 1 downto 0);
	signal O_VAL_EXEC: std_logic;
	signal O_TAG_EXEC: std_logic_vector(N_LOG_RR - 1 downto 0);
	signal O_LOC_EXEC: std_logic_vector(N_LOG_ROB - 1 downto 0);
begin

	DUT: entity work.BRANCH(BR_ARCH) port map(
		clk,
		I_OPR1, I_OPR2, I_OPR3, I_CTRL_BITS, I_PREDICTION,
		I_TAG, I_LOC, I_HIST_IND,
		O_OUT_PC, O_HIST_IND, O_VAL_EXEC, O_TAG_EXEC, O_LOC_EXEC
	);
	
	process
	begin
		clk <= not clk;
		wait for 20 ns;
	end process;
	
	process
		variable i: integer := 0;
	begin
		for i in 0 to 3 loop \'
		;[waitde1qsrdyh2vvutebgcn w]
			if(i = 1) then
				I_CTRL_BITS <= "000110000000000000000000100";
				I_OPR1 <= X"42424242";
				I_OPR2 <= X"42424242";
				I_OPR3 <= X"33FFFF22";
				I_PREDICTION <= '0';
				I_BrTAG <= "0001";
			elsif(i = 2) then
				I_CTRL_BITS <= "000110000000000000000001100";
				I_OPR1 <= X"F2424242";
				I_OPR2 <= X"42424242";
				--I_OPR3 <= X"33FFFF22";
				I_PREDICTION <= '1';
				I_BrTAG <= "0010";
			elsif(i = 3) then
				I_CTRL_BITS <= "010110000000000000000001100";
				I_OPR1 <= X"F2424242";
				I_OPR2 <= X"42424242";
				--I_OPR3 <= X"33FFFF22";
				I_PREDICTION <= '1';
				I_BrTAG <= "0010";
			end if;
			wait for 40 ns;
		end loop;
	end process;
end architecture branch_stim;