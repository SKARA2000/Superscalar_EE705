library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG_COMMON.all;

entity tb_ROB is
end entity;

architecture ROB_stim of tb_ROB is
	signal clk: std_logic := '0';
	signal rst: std_logic;
	signal t_PC1, t_PC2: std_logic_vector(31 downto 0);
	signal t_I1, t_I2: std_logic_vector(N_OPCODE_BITS+N_FUNC_BITS+N_SHAMT_BITS -1 downto 0);
	signal t_CTRL1, t_CTRL2: std_logic_vector(N_CTRL_BITS - 1 downto 0);
	signal t_VALID1, t_VALID2: std_logic;
	signal t_SPEC1, t_SPEC2: std_logic;
	signal t_BrTAG1, t_BrTAG2: std_logic_vector(N_Br_TAG -1 downto 0);
	signal t_STS1, t_STS2: std_logic_vector(2 downto 0);
	signal t_ARCH_REG1, t_ARCH_REG2: std_logic_vector(N_LOG_AR - 1 downto 0);
	signal t_RNME_REG1, t_RNME_REG2: std_logic_vector(N_LOG_RR - 1 downto 0);
	
	--Inputs from the Common Data Bus
	signal t_TAG_EXEC: T_ARR4_SLV_TAG;
	signal t_LOC_EXEC: T_ARR4_SLV_LOC;
	signal t_VAL_EXEC: std_logic_vector(0 to 3);
	signal t_OPR_EXEC: T_ARR4_SLV32;
		
	--Outputs to dispatch stage
	signal t_ROB_FREE_LOC1, t_ROB_FREE_LOC2: std_logic_vector(N_LOG_ROB - 1 downto 0);
	signal t_ROB_REG_WR1, t_ROB_REG_WR2: std_logic;
	signal t_ROB_RNME_REG1, t_ROB_RNME_REG2: std_logic_vector(N_LOG_RR - 1 downto 0);
	signal t_ROB_ARCH_REG1, t_ROB_ARCH_REG2: std_logic_vector(N_LOG_AR - 1 downto 0);
		
	--Maintenance Outputs
	signal t_FULL: std_logic;
	signal t_I1_MISSED: std_logic;
	signal t_I2_MISSED: std_logic;
	signal head, last: std_logic_vector(N_LOG_ROB - 1 downto 0);
	signal O_ARCH_REG, O_RNME_REG: ROB_TAG_COLUMN;
	
	--type tb1_inp is array(0 to 3) of std_logic_vector()
begin
	DUT: entity work.ROB(ROB_ARCH) port map(
		clk, rst, 
		t_PC1, t_PC2, 
		t_I1, t_I2,
		t_CTRL1, t_CTRL2,
		t_VALID1, t_VALID2,
		t_SPEC1, t_SPEC2,
		t_BrTAG1, t_BrTAG2,
		t_STS1, t_STS2,
		t_ARCH_REG1, t_ARCH_REG2,
		t_RNME_REG1, t_RNME_REG2,
		t_TAG_EXEC, t_LOC_EXEC, t_VAL_EXEC, t_OPR_EXEC,
		
		t_ROB_FREE_LOC1, t_ROB_FREE_LOC2,
		t_ROB_REG_WR1, t_ROB_REG_WR2,
		t_ROB_RNME_REG1, t_ROB_RNME_REG2,
		t_ROB_ARCH_REG1, t_ROB_ARCH_REG2, 
		t_FULL, t_I1_MISSED, t_I2_MISSED, 
		head, last, O_ARCH_REG, O_RNME_REG
	);
	
	process
	begin
		clk <= not clk;
		wait for 20 ns;
	end process;
	
	rst <= '1' after 30 ns, '0' after 90 ns;
	
	process(clk)
		variable i: integer := 0;
	begin
		if rising_edge(clk) then
			i := (i + 1);
			if(i = 3) then
				t_PC1 <= X"00000000"; t_PC2 <= X"00000001";
				--t_I1 <= X"00220020"; t_I2 <= X"00012020";
				t_VALID1 <= '0'; t_VALID2 <= '0';
				t_SPEC1 <= '0'; t_SPEC2 <= '0';
				t_BrTAG1 <= "0000"; t_BrTAG2 <= "0000";
				t_STS1 <= "001"; t_STS2 <= "001";
				t_ARCH_REG1 <= "00000"; t_ARCH_REG2 <= "00100";
				t_RNME_REG1 <= "10000"; t_RNME_REG2 <= "10001";
			elsif(i = 4) then
				t_PC1 <= X"00000002"; t_PC2 <= X"00000003";
				--t_I1 <= X"00430020"; t_I2 <= X"00222020";
				t_VALID1 <= '0'; t_VALID2 <= '0';
				t_SPEC1 <= '0'; t_SPEC2 <= '0';
				t_BrTAG1 <= "0000"; t_BrTAG2 <= "0000";
				t_STS1 <= "001"; t_STS2 <= "001";
				t_ARCH_REG1 <= "00000"; t_ARCH_REG2 <= "00100";
				t_RNME_REG1 <= "10010"; t_RNME_REG2 <= "10011";
				
				t_TAG_EXEC(0) <= "10000"; t_TAG_EXEC(1) <= "10001"; 
				t_LOC_EXEC(0) <= "0000000"; t_LOC_EXEC(1) <= "0000001";
				t_VAL_EXEC(0) <= '1'; t_VAL_EXEC(1) <= '0';
				t_OPR_EXEC(0) <= X"55080110"; t_OPR_EXEC(0) <= X"3FFFFFFF"; 
			elsif(i = 5) then
				t_TAG_EXEC(0) <= "10010"; t_TAG_EXEC(1) <= "10001"; 
				t_LOC_EXEC(0) <= "0000010"; t_LOC_EXEC(1) <= "0000001";
				t_VAL_EXEC(0) <= '0'; t_VAL_EXEC(1) <= '1';
				t_OPR_EXEC(0) <= X"3FFFFFFF"; t_OPR_EXEC(0) <= X"03080811"; 
			elsif(i = 6) then
				t_TAG_EXEC(0) <= "10010"; t_TAG_EXEC(1) <= "10011"; 
				t_LOC_EXEC(0) <= "0000010"; t_LOC_EXEC(1) <= "0000011";
				t_VAL_EXEC(0) <= '1'; t_VAL_EXEC(1) <= '1';
				t_OPR_EXEC(0) <= X"6FF31010"; t_OPR_EXEC(0) <= X"78787878"; 
			end if;
		end if;
	end process;
end architecture ROB_stim;