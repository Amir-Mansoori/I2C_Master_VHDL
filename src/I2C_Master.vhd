----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:19:47 05/02/2017 
-- Design Name: 
-- Module Name:    I2C_Master - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity I2C_Master is
    Port ( SDA : inout  STD_LOGIC;
           SCL : inout  STD_LOGIC;
			  Data_i : in  STD_LOGIC_VECTOR(7 downto 0);
			  Data_o : out  STD_LOGIC_VECTOR(7 downto 0);
           en : in  STD_LOGIC;
           busy : out  STD_LOGIC;
           Addr_in : in  STD_LOGIC_VECTOR (6 downto 0);
           R_Wn : in  STD_LOGIC;
           Valid : out  STD_LOGIC;
           Ack : out  STD_LOGIC;
           clk : in  STD_LOGIC;
           Start : in  STD_LOGIC;
           Stop : in  STD_LOGIC;
           Status : out  STD_LOGIC_Vector(7 downto 0));
end I2C_Master;

architecture Behavioral of I2C_Master is

type state_machine is (idle, Gen_start, address, wait_en, Send_Data,Receive_Data, Gen_Stop);
signal state: state_machine:= idle;
signal cnt_start: integer range 0 to 200:=0;
signal cnt_addr: integer range 0 to 50:=0;
signal cnt_Data: integer range 0 to 50:=0;
signal cnt_SDA: integer range 0 to 50:=0;
signal cnt_SCL: integer range 0 to 50:=0;
signal i: integer range 0 to 8:=0;
signal n: integer range 0 to 1:=0;
signal sig_address: STD_LOGIC_VECTOR(8 downto 0);
signal sig_Data: STD_LOGIC_VECTOR(8 downto 0);
signal sig_Data_out: STD_LOGIC_VECTOR(7 downto 0);
signal sig_RWn: STD_LOGIC;
signal flag: STD_LOGIC;

begin

	process(clk)
	begin
		if(rising_edge(clk)) then
			case state is
				when idle =>
					Ack<='0';
					valid<='0';
					busy<='0';
					status<=x"00";
					if(start='1') then
						busy<='1';
						state<=Gen_start;
					end if;
-----------------------------------------------------------------				
				when Gen_start =>
			------------------------------------	
					if(SDA='1' and SCL='1') then
						cnt_start<=cnt_start+1;
						if(cnt_start=199) then
							cnt_start<=0;
							SDA<='0';
							flag<='1';							----- wait 200 clk when SDA & SCL = 1
						elsif(SDA='0' or SCL='0') then
							cnt_start<=0;
							state<=Gen_Start;
						end if;
					end if;
			--------------------------------------   
						if(flag='1') then
							cnt_SDA<=cnt_SDA+1;
							if(cnt_SDA=49) then
								cnt_SDA<=0;
								SCL<='0';
								n<=n+1;
								if(n=1) then				------   after 200 clk of SDA & SCL ='1' ==> SCL<='0' then SDA<='0'
									n<=0;
									state<=address;
									sig_address(8 downto 2)<=Addr_in;
									sig_address(1)<=R_Wn;
									sig_address(0)<='Z';
									status<=x"08";
									busy<='1';
									flag<='0';
								end if;
							end if;
						end if;
	----------------------------------------------------------------------------------------			
				
				when address =>
					SDA<=sig_address(8);
					cnt_addr<=cnt_addr+1;
					if(cnt_addr=16) then ---340 ns SCL=0
						SCL<='1';
					end if;
					if(cnt_addr=31) then	---- 300 ns SCL=1
						SCL<='0';
					end if;
					if(cnt_addr=49) then	----360 ns SCL=0
						sig_address<=sig_address(7 downto 0)&'0';
						cnt_addr<=0;
						i<=i+1;
						if(i=7) then	---RWn
							sig_RWn<=SDA;
						end if;
						if(i=8) then
							i<=0;
							if(SDA='0') then ---Ack='0'
								status<=x"18";
								state<=Wait_en;
							elsif(SDA='1') then ---Ack='1'
								status<=x"20";
								state<=Gen_Stop;
							end if;
						end if;
					end if;
						
					
				
				
				when wait_en =>
					busy<='0';
					if(Stop='1') then
						state<=Gen_Stop;
					elsif(en='1') then
						if(sig_RWn='0') then
							state<=Send_Data;
							sig_Data(8 downto 1)<=Data_i;
							sig_Data(0)<='Z';
						elsif(sig_RWn='1') then
							state<=Receive_Data;
							sig_Data(8 downto 1) <= "ZZZZZZZZ";
							sig_Data(0) <= '0'; --- Ack<='0';
						end if;
						
					else
						state<=wait_en;
					end if;				
				
				when Send_Data =>
					busy<='1';
					----------------------------------------------------------
					SDA<=sig_Data(8);
					cnt_Data<=cnt_Data+1;
					if(cnt_Data=16) then
						SCL<='1';
					end if;
					if(cnt_Data=31) then
						SCL<='0';
					end if;
					if(cnt_Data=49) then
						sig_Data<=sig_Data(7 downto 0)&'0';
						cnt_Data<=0;
						i<=i+1;
						if(i=8) then
							i<=0;
							if(SDA='0') then ---Ack='0'
								status<=x"28";
								state<=Wait_en;
							elsif(SDA='1') then ---Ack='1'
								status<=x"30";
								state<=Gen_Stop;
							end if;
						end if;
					end if;
						
					
					
					
					----------------------------------------------------------
				when Receive_Data =>
					busy<='1';
					----------------------------------------------------------
					SDA<=sig_Data(8);
					cnt_Data<=cnt_Data+1;
					if(cnt_Data=16) then
						SCL<='1';
						sig_Data_out<=sig_Data_out(6 downto 0) & SDA;
					end if;
					if(cnt_Data=31) then
						SCL<='0';
					end if;
					if(cnt_Data=49) then
						sig_Data<=sig_Data(8 downto 1)&'0';
						cnt_Data<=0;
						i<=i+1;
						if(i=8) then
							i<=0;
							Ack<='1';
							Data_o<=sig_Data_out;
							valid<='1';
							if(Stop='1') then
								SDA<='1';
								state<=Gen_Stop;
							else
								SDA<='0';
								state<=wait_en;
							end if;
						end if;
					end if;
						
					
					
					
					---------------------------------------------------------
				
				
				when Gen_Stop =>
					SCL<='1';
					cnt_SCL<=cnt_SCL+1;
					if(cnt_SCL=49) then
						cnt_SCL<=0;
						SDA<='1';
						n<=n+1;
						if(n=1) then
							n<=0;
							state<=idle;
						end if;
					end if;
				
				
				
			end case;
			
			
		end if;
		
	end process;

end Behavioral;

