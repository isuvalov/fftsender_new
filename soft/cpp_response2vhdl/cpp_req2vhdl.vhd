library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;

entity cpp_req2vhdl is
	 port(
		 reset: in std_logic;
		 ce : in std_logic;
		 clk : in std_logic;
		 can_go: in std_logic; --# see falling edge of recieved dv

		 dv_o: out std_logic;
		 data_o: out std_logic_vector(7 downto 0)
	     );
end cpp_req2vhdl;


architecture cpp_req2vhdl of cpp_req2vhdl is

signal delay_cnt:std_logic_vector(3 downto 0):=(others=>'1');
signal cnt:integer:=0;

type Tseq_array0 is array (0 to 42+3-1) of std_logic_vector(7 downto 0);
constant seq_array0:Tseq_array0:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"ac", x"00", x"00", x"80", x"11", x"21", x"74", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"9c",
x"5A", x"01", x"00");

type Tseq_array1 is array (0 to 42+6-1) of std_logic_vector(7 downto 0);
constant seq_array1:Tseq_array1:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"ac", x"00", x"00", x"80", x"11", x"21", x"74", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"9c",
x"5A", x"02", x"02", x"01", x"00", x"05");

type Tseq_array2 is array (0 to 42+3-1) of std_logic_vector(7 downto 0);
constant seq_array2:Tseq_array2:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"ac", x"00", x"00", x"80", x"11", x"21", x"74", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"9c",
x"5A", x"03", x"01");

type Tseq_array3 is array (0 to 42+6-1) of std_logic_vector(7 downto 0);
constant seq_array3:Tseq_array3:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"ac", x"00", x"00", x"80", x"11", x"21", x"74", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"9c",
x"5A", x"04", x"02", x"00", x"00", x"00");

type Tseq_array4 is array (0 to 42+3-1) of std_logic_vector(7 downto 0);
constant seq_array4:Tseq_array4:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"ac", x"00", x"00", x"80", x"11", x"21", x"74", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"9c",
x"5A", x"07", x"00");

constant RESP_NUM:natural:=5;
type Tsizes is array(0 to 5-1) of integer;
constant sizes:Tsizes:=(45, 48, 45, 48, 45);
type Tstm is (FINISH,TX_STATE0, TX_STATE1, TX_STATE2, TX_STATE3, TX_STATE4,WAIT_RESPONSE0, WAIT_RESPONSE1, WAIT_RESPONSE2, WAIT_RESPONSE3, WAIT_RESPONSE4,START_DELAY0, START_DELAY1, START_DELAY2, START_DELAY3, START_DELAY4);
signal stm:Tstm;

begin

process(clk)
begin
	if rising_edge(clk) then
		if reset='1' then
			stm<=WAIT_RESPONSE0;
			delay_cnt<=(others=>'1');
			dv_o<='0';
		elsif ce='1' then    --# reset
			case stm is
			when WAIT_RESPONSE0=>
				if can_go='1' then
					stm<=START_DELAY0;
				end if;
				delay_cnt<=(others=>'1');
				dv_o<='0';
			when START_DELAY0=>	
				if unsigned(delay_cnt)>0 then
					delay_cnt<=delay_cnt-1;
				else
					stm<=TX_STATE0;
				end if;
				cnt<=0;
				dv_o<='0';
			when TX_STATE0=>
				dv_o<='1';
				data_o<=seq_array0(cnt);
					if cnt<sizes(0)-1 then
						cnt<=cnt+1;
					else
						stm<=WAIT_RESPONSE1;
					end if;
			when WAIT_RESPONSE1=>
				if can_go='1' then
					stm<=START_DELAY1;
				end if;
				delay_cnt<=(others=>'1');
				dv_o<='0';
			when START_DELAY1=>	
				if unsigned(delay_cnt)>0 then
					delay_cnt<=delay_cnt-1;
				else
					stm<=TX_STATE1;
				end if;
				cnt<=0;
				dv_o<='0';
			when TX_STATE1=>
				dv_o<='1';
				data_o<=seq_array1(cnt);
					if cnt<sizes(1)-1 then
						cnt<=cnt+1;
					else
						stm<=WAIT_RESPONSE2;
					end if;
			when WAIT_RESPONSE2=>
				if can_go='1' then
					stm<=START_DELAY2;
				end if;
				delay_cnt<=(others=>'1');
				dv_o<='0';
			when START_DELAY2=>	
				if unsigned(delay_cnt)>0 then
					delay_cnt<=delay_cnt-1;
				else
					stm<=TX_STATE2;
				end if;
				cnt<=0;
				dv_o<='0';
			when TX_STATE2=>
				dv_o<='1';
				data_o<=seq_array2(cnt);
					if cnt<sizes(2)-1 then
						cnt<=cnt+1;
					else
						stm<=WAIT_RESPONSE3;
					end if;
			when WAIT_RESPONSE3=>
				if can_go='1' then
					stm<=START_DELAY3;
				end if;
				delay_cnt<=(others=>'1');
				dv_o<='0';
			when START_DELAY3=>	
				if unsigned(delay_cnt)>0 then
					delay_cnt<=delay_cnt-1;
				else
					stm<=TX_STATE3;
				end if;
				cnt<=0;
				dv_o<='0';
			when TX_STATE3=>
				dv_o<='1';
				data_o<=seq_array3(cnt);
					if cnt<sizes(3)-1 then
						cnt<=cnt+1;
					else
						stm<=WAIT_RESPONSE4;
					end if;
			when WAIT_RESPONSE4=>
				if can_go='1' then
					stm<=START_DELAY4;
				end if;
				delay_cnt<=(others=>'1');
				dv_o<='0';
			when START_DELAY4=>	
				if unsigned(delay_cnt)>0 then
					delay_cnt<=delay_cnt-1;
				else
					stm<=TX_STATE4;
				end if;
				cnt<=0;
				dv_o<='0';
			when TX_STATE4=>
				dv_o<='1';
				data_o<=seq_array4(cnt);
					if cnt<sizes(4)-1 then
						cnt<=cnt+1;
					else
					stm<=FINISH;
					end if;
			when FINISH=>
				 dv_o<='0';
				 data_o<=x"00";
			when others=>
			end case;
		end if; --# reset
	end if;
end process;

end cpp_req2vhdl;
