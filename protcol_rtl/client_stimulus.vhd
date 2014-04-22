library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;
library work;
use work.regs_pack.all;

entity client_stimulus is
	 port(
		 reset: in std_logic;
		 ce : in std_logic;
		 clk : in std_logic;
		 send_ask_radar_status: in std_logic;
		 send_ask_data: in std_logic;

		 dv_o: out std_logic;
		 data_o: out std_logic_vector(7 downto 0)
	     );
end client_stimulus;


architecture client_stimulus of client_stimulus is

type Task_radar_status_mem is array (0 to 50-1+3) of std_logic_vector(7 downto 0);
--constant ask_radar_status_mem:Task_radar_status_mem:=  ( x"55",x"55",x"55",x"55",x"55",x"55",x"55",x"D5",
--x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"00",x"1E",x"68",x"AE",x"76",x"FF",x"08",x"00",x"45",x"00",
--x"02",x"1E",x"00",x"00",x"00",x"00",x"40",x"11",x"E2",x"75",x"C0",x"A8",x"0A",x"0A",x"C0",x"A8",
--x"0A",x"FF",x"00",x"3F",x"00",x"3F",x"02",x"0A",x"00",x"00");  --# Ethernet header


constant ask_radar_status_mem:Task_radar_status_mem:=  ( x"55",x"55",x"55",x"55",x"55",x"55",x"55",x"D5",
x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"00",x"1E",x"68",x"AE",x"76",x"FF",x"08",x"00",x"45",x"00",
x"02",x"1E",x"00",x"00",x"00",x"00",x"40",x"11",x"E2",x"75",x"C0",x"A8",x"0A",x"0A",x"C0",x"A8",
x"0A",x"FF",x"00",x"3F",x"00",x"3F",x"02",x"0A",x"00",x"00",  
      x"5A",  x"33",  x"00"  );  --# Послать запрос состояния радара (3 байта): 0x5A (признак), номер запроса, 0x00 (состояние радара).



constant ask_data_mem:Task_radar_status_mem:=  ( x"55",x"55",x"55",x"55",x"55",x"55",x"55",x"D5",
x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"00",x"1E",x"68",x"AE",x"76",x"FF",x"08",x"00",x"45",x"00",
x"02",x"1E",x"00",x"00",x"00",x"00",x"40",x"11",x"E2",x"75",x"C0",x"A8",x"0A",x"0A",x"C0",x"A8",
x"0A",x"FF",x"00",x"3F",x"00",x"3F",x"02",x"0A",x"00",x"00",  
      x"5A",  x"33",  x"01"  );  --# запрос данных (3 байта): 0x5A (признак), номер запроса, 0x01 (получить данные).
								 --# Высылается если флаг have_unread_measurement=1 высланный по запросу ask_radar_status_mem


type Tstm is (WAITING,SEND_01,SEND_CRC);
signal stm:Tstm:=WAITING;

signal s_dv:std_logic;
signal s_data:std_logic_vector(7 downto 0);
signal cnt:std_logic_vector(7 downto 0);

begin

process(clk)
begin
	if rising_edge(clk) then
		if reset='1' then
			stm<=WAITING;
		else
			if ce='1' then
				case stm is
				when WAITING=>
					if send_ask_radar_status='1' then
						stm<=SEND_01;
					end if;	
					s_data<=x"00";
					s_dv<='0';
					cnt<=x"00";
				when SEND_01=>
					if unsigned(cnt)<50-1 then
						cnt<=cnt+1;
					else
						stm<=SEND_CRC;
						cnt<=x"00";
					end if;
					s_data<=ask_radar_status_mem(conv_integer(cnt));
                    s_dv<='1';
				when SEND_CRC=>
					s_data<=x"FF";
					s_dv<='1';
					if unsigned(cnt)<4-1 then
						cnt<=cnt+1;
					else
						stm<=WAITING;
					end if;
        
				when others=>
				end case;
				data_o<=s_data;
				dv_o<=s_dv;
			end if; --# ce		
		end if;
	end if;
end process;



end client_stimulus;
