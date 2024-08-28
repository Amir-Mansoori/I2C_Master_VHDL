--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:59:43 05/15/2017
-- Design Name:   
-- Module Name:   D:/ISE_Projects/Fani_HerfeE/P43_I2C_Master/I2C_Master_tb.vhd
-- Project Name:  P43_I2C_Master
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: I2C_Master
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY I2C_Master_tb IS
END I2C_Master_tb;
 
ARCHITECTURE behavior OF I2C_Master_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT I2C_Master
    PORT(
         SDA : INOUT  std_logic;
         SCL : INOUT  std_logic;
         Data_i : IN  std_logic_vector(7 downto 0);
         Data_o : OUT  std_logic_vector(7 downto 0);
         en : IN  std_logic;
         busy : OUT  std_logic;
         Addr_in : IN  std_logic_vector(6 downto 0);
         R_Wn : IN  std_logic;
         Valid : OUT  std_logic;
         Ack : OUT  std_logic;
         clk : IN  std_logic;
         Start : IN  std_logic;
         Stop : IN  std_logic;
         Status : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Data_i : std_logic_vector(7 downto 0) := (others => '0');
   signal en : std_logic := '0';
   signal Addr_in : std_logic_vector(6 downto 0) := (others => '0');
   signal R_Wn : std_logic := '0';
   signal clk : std_logic := '0';
   signal Start : std_logic := '0';
   signal Stop : std_logic := '0';

	--BiDirs
   signal SDA : std_logic;
   signal SCL : std_logic;

 	--Outputs 
   signal Data_o : std_logic_vector(7 downto 0);
   signal busy : std_logic;
   signal Valid : std_logic;
   signal Ack : std_logic;
   signal Status : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: I2C_Master PORT MAP (
          SDA => SDA,
          SCL => SCL,
          Data_i => Data_i,
          Data_o => Data_o,
          en => en,
          busy => busy,
          Addr_in => Addr_in,
          R_Wn => R_Wn,
          Valid => Valid,
          Ack => Ack,
          clk => clk,
          Start => Start,
          Stop => Stop,
          Status => Status
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

Addr_in<="1111001";
en<='1';
R_Wn<='0';
Data_i<=x"55";
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.

      wait for 100 ns;	

      wait for clk_period*10;
		      -- insert stimul us here 
		
	   wait;
   end process;

END;
