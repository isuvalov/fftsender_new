library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;
library work;
use work.regs_pack.all;

entity client_stimulus_cpu is
	generic (
		CUT_FRAMES:integer:=42
	);
	 port(
		 reset: in std_logic;
		 ce : in std_logic;
		 clk : in std_logic;
		 send_ask_radar_status: in std_logic;
		 send_ask_data: in std_logic;

		 dv_o: out std_logic;
		 data_o: out std_logic_vector(7 downto 0)
	     );
end client_stimulus_cpu;


architecture client_stimulus_cpu of client_stimulus_cpu is

type Tbig_sequense_array is array (0 to 100) of std_logic_vector(7 downto 0);


type Tstart_connection is array (0 to 44) of std_logic_vector(7 downto 0);
type Trequest_status is array (0 to 44) of std_logic_vector(7 downto 0);
type Trequest_data is array (0 to 44) of std_logic_vector(7 downto 0);
type Tread_porogi is array (0 to 44) of std_logic_vector(7 downto 0);
type Tmeasure_period is array (0 to 47) of std_logic_vector(7 downto 0);

constant start_connection01:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"ac", x"00", x"00", x"80", x"11", x"21", x"74", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"9c", x"5a", x"00", x"00");
constant start_connection02:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"ad", x"00", x"00", x"80", x"11", x"21", x"73", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"9b", x"5a", x"01", x"00");
constant start_connection03:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"ae", x"00", x"00", x"80", x"11", x"21", x"72", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"9a", x"5a", x"02", x"00");
constant start_connection04:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"af", x"00", x"00", x"80", x"11", x"21", x"71", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"99", x"5a", x"03", x"00");
constant start_connection05:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"b0", x"00", x"00", x"80", x"11", x"21", x"70", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"98", x"5a", x"04", x"00");
constant start_connection06:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"b1", x"00", x"00", x"80", x"11", x"21", x"6f", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"97", x"5a", x"05", x"00");
constant start_connection07:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"b2", x"00", x"00", x"80", x"11", x"21", x"6e", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"96", x"5a", x"06", x"00");
constant start_connection08:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"b3", x"00", x"00", x"80", x"11", x"21", x"6d", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"95", x"5a", x"07", x"00");
constant start_connection09:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"b5", x"00", x"00", x"80", x"11", x"21", x"6b", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"94", x"5a", x"08", x"00");
constant start_connection10:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"b6", x"00", x"00", x"80", x"11", x"21", x"6a", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"93", x"5a", x"09", x"00");
constant start_connection11:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"b7", x"00", x"00", x"80", x"11", x"21", x"69", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"92", x"5a", x"0a", x"00");
constant start_connection12:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"b8", x"00", x"00", x"80", x"11", x"21", x"68", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"91", x"5a", x"0b", x"00");
constant start_connection13:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"b9", x"00", x"00", x"80", x"11", x"21", x"67", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"90", x"5a", x"0c", x"00");
constant start_connection14:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"ba", x"00", x"00", x"80", x"11", x"21", x"66", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"8f", x"5a", x"0d", x"00");
constant start_connection15:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"bc", x"00", x"00", x"80", x"11", x"21", x"64", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"8e", x"5a", x"0e", x"00");
constant start_connection16:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"bd", x"00", x"00", x"80", x"11", x"21", x"63", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"8d", x"5a", x"0f", x"00");
constant start_connection17:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"be", x"00", x"00", x"80", x"11", x"21", x"62", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"8c", x"5a", x"10", x"00");
constant start_connection18:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"bf", x"00", x"00", x"80", x"11", x"21", x"61", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"8b", x"5a", x"11", x"00");
constant start_connection19:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"c0", x"00", x"00", x"80", x"11", x"21", x"60", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"8a", x"5a", x"12", x"00");


constant request_status01:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"5f", x"20", x"00", x"00", x"80", x"11", x"1a", x"00", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"12", x"c0", x"5a", x"c1", x"00");
constant request_status02:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"5f", x"26", x"00", x"00", x"80", x"11", x"19", x"fa", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"12", x"bf", x"5a", x"c2", x"00");
constant request_status03:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"5f", x"27", x"00", x"00", x"80", x"11", x"19", x"f9", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"12", x"be", x"5a", x"c3", x"00");
constant request_status04:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"5f", x"28", x"00", x"00", x"80", x"11", x"19", x"f8", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"12", x"bd", x"5a", x"c4", x"00");
constant request_status05:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"5f", x"29", x"00", x"00", x"80", x"11", x"19", x"f7", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"12", x"bc", x"5a", x"c5", x"00");
constant request_status06:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"5f", x"2d", x"00", x"00", x"80", x"11", x"19", x"f3", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"12", x"bb", x"5a", x"c6", x"00");
constant request_status07:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"5f", x"2f", x"00", x"00", x"80", x"11", x"19", x"f1", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"12", x"ba", x"5a", x"c7", x"00");
constant request_status08:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"5f", x"30", x"00", x"00", x"80", x"11", x"19", x"f0", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"12", x"b9", x"5a", x"c8", x"00");
constant request_status09:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"5f", x"31", x"00", x"00", x"80", x"11", x"19", x"ef", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"12", x"b8", x"5a", x"c9", x"00");
constant request_status10:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"5f", x"33", x"00", x"00", x"80", x"11", x"19", x"ed", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"12", x"b7", x"5a", x"ca", x"00");
constant request_status11:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"5f", x"34", x"00", x"00", x"80", x"11", x"19", x"ec", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"12", x"b6", x"5a", x"cb", x"00");


constant request_data01:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"62", x"45", x"00", x"00", x"80", x"11", x"16", x"db", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"11", x"a8", x"5a", x"d9", x"01");
constant request_data02:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"62", x"46", x"00", x"00", x"80", x"11", x"16", x"da", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"11", x"a7", x"5a", x"da", x"01");
constant request_data03:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"62", x"4a", x"00", x"00", x"80", x"11", x"16", x"d6", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"11", x"a6", x"5a", x"db", x"01");
constant request_data04:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"62", x"4b", x"00", x"00", x"80", x"11", x"16", x"d5", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"11", x"a5", x"5a", x"dc", x"01");


constant read_porogi01:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"5d", x"69", x"00", x"00", x"80", x"11", x"1b", x"b7", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"0f", x"c4", x"5a", x"bd", x"03");
constant read_porogi02:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"5d", x"6d", x"00", x"00", x"80", x"11", x"1b", x"b3", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"0f", x"c3", x"5a", x"be", x"03");
constant read_porogi03:Tstart_connection:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"5d", x"6e", x"00", x"00", x"80", x"11", x"1b", x"b2", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0b", x"0f", x"c2", x"5a", x"bf", x"03");


constant measure_300sec_01:Tmeasure_period:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"22", x"60", x"30", x"00", x"00", x"80", x"11", x"18", x"ed", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0e", x"0f", x"82", x"5a", x"cc", x"02", x"01", x"01", x"2c");
constant measure_300sec_02:Tmeasure_period:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"22", x"60", x"35", x"00", x"00", x"80", x"11", x"18", x"e8", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0e", x"10", x"ae", x"5a", x"cd", x"02", x"00", x"00", x"00");
constant measure_300sec_03:Tmeasure_period:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"22", x"60", x"38", x"00", x"00", x"80", x"11", x"18", x"e5", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0e", x"0f", x"80", x"5a", x"ce", x"02", x"01", x"01", x"2c");
constant measure_300sec_04:Tmeasure_period:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"22", x"60", x"3c", x"00", x"00", x"80", x"11", x"18", x"e1", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0e", x"10", x"ac", x"5a", x"cf", x"02", x"00", x"00", x"00");


constant measure_100sec_01:Tmeasure_period:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"22", x"60", x"d4", x"00", x"00", x"80", x"11", x"18", x"49", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0e", x"10", x"a6", x"5a", x"d5", x"02", x"00", x"00", x"00");
constant measure_100sec_02:Tmeasure_period:=(x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"22", x"60", x"d6", x"00", x"00", x"80", x"11", x"18", x"47", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e3", x"e9", x"ec", x"be", x"00", x"0e", x"10", x"40", x"5a", x"d6", x"02", x"01", x"00", x"64");


type Task_radar_status_mem is array (0 to 3-1) of std_logic_vector(7 downto 0);
--constant ask_radar_status_mem:Task_radar_status_mem:=  ( x"55",x"55",x"55",x"55",x"55",x"55",x"55",x"D5",
--x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"00",x"1E",x"68",x"AE",x"76",x"FF",x"08",x"00",x"45",x"00",
--x"02",x"1E",x"00",x"00",x"00",x"00",x"40",x"11",x"E2",x"75",x"C0",x"A8",x"0A",x"0A",x"C0",x"A8",
--x"0A",x"FF",x"00",x"3F",x"00",x"3F",x"02",x"0A",x"00",x"00");  --# Ethernet header


constant ask_radar_status_mem:Task_radar_status_mem:=  (  
      x"5A",  x"00",  x"00"  );  --# Послать запрос состояния радара (3 байта): 0x5A (признак), номер запроса, 0x00 (состояние радара).



constant ask_data_mem:Task_radar_status_mem:=  ( 
      x"5A",  x"00",  x"01"  );  --# запрос данных (3 байта): 0x5A (признак), номер запроса, 0x01 (получить данные).
								 --# Высылается если флаг have_unread_measurement=1 высланный по запросу ask_radar_status_mem

function copy_45(inn: Tstart_connection; len:integer) return Tbig_sequense_array is
variable seq_array:Tbig_sequense_array;
begin
	for i in 0 to len-1 loop
		seq_array(i):=inn(i);
	end loop;
	return seq_array;
end;


function copy_47(inn: Tmeasure_period; len:integer) return Tbig_sequense_array is
variable seq_array:Tbig_sequense_array;
begin
	for i in 0 to len-1 loop
		seq_array(i):=inn(i);
	end loop;
	return seq_array;
end;


type Tstm is (WAITING,SEND_01,SEND_CRC);
signal stm:Tstm:=WAITING;

signal big_sequense_array:Tbig_sequense_array;

--type T_sequence is (PREP_START_CON01,PREP_START_CON02,PREP_START_CON03,PREP_REQ_STATUS01,PREP_REQ_STATUS02);
--signal sequence:T_sequence;
type T_gap_pauses is array(0 to 11-1) of integer;
type T_frame_lens is array(0 to 11-1) of integer;
constant gap_pauses:T_gap_pauses:=(1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000);
constant frame_lens:T_frame_lens:=(45,45,45,45,45,45,45,47,47,45,45);

signal short_seq:Tstart_connection;

type Tbig_stm is (START_DELAY,WAITING,SEND_55_01,SEND_55_02,SEND_55_03,SEND_55_04,SEND_55_05,SEND_55_06,SEND_55_07,SEND_D5,
		PREP_START_CON01,PREP_REQ_STATUS01,SEND_ARRAY,MAKE_GAP,MAKE_GAP_PAUSE,CHOOSE_NEXT);
signal big_stm:Tbig_stm;
signal current_len,current_frame,current_pos,cntgap:integer;

signal delay_cnt:integer;

signal s_dv:std_logic;
signal s_data:std_logic_vector(7 downto 0);
signal cnt:std_logic_vector(7 downto 0);

begin


process(clk)
begin
	if rising_edge(clk) then
		if reset='1' then
			big_stm<=START_DELAY;--CHOOSE_NEXT;
			current_frame<=0;
			current_pos<=0;
			s_dv<='0';
			delay_cnt<=500;
		else    --#reset
			if ce='1' then
			case big_stm is
			when START_DELAY=>
				if delay_cnt>0 then
					delay_cnt<=delay_cnt-1;
				else
					big_stm<=CHOOSE_NEXT;
				end if;
			when SEND_55_01=>
				s_data<=x"55";
			    s_dv<='1';
				big_stm<=SEND_55_02;
			when SEND_55_02=>
				s_data<=x"55";
			    s_dv<='1';
				big_stm<=SEND_55_03;
			when SEND_55_03=>
				s_data<=x"55";
			    s_dv<='1';
				big_stm<=SEND_55_04;
			when SEND_55_04=>
				s_data<=x"55";
			    s_dv<='1';
				big_stm<=SEND_55_05;
			when SEND_55_05=>
				s_data<=x"55";
			    s_dv<='1';
				big_stm<=SEND_55_06;
			when SEND_55_06=>
				s_data<=x"55";
			    s_dv<='1';
				big_stm<=SEND_55_07;
			when SEND_55_07=>
				s_data<=x"55";
			    s_dv<='1';
				big_stm<=SEND_D5;
			when SEND_D5=>
				s_data<=x"D5";
			    s_dv<='1';
				big_stm<=SEND_ARRAY;

			when SEND_ARRAY=>
				if current_len>0 then
					current_len<=current_len-1;					
					s_data<=big_sequense_array(current_pos+CUT_FRAMES);
			    	s_dv<='1';
				else
					big_stm<=MAKE_GAP;
					s_data<=x"00";
				    s_dv<='0';
				end if;
				current_pos<=current_pos+1;
			when MAKE_GAP=>
				s_dv<='0';
				s_data<=x"00";
				cntgap<=gap_pauses(current_frame);
				big_stm<=MAKE_GAP_PAUSE;
			when MAKE_GAP_PAUSE =>
				if cntgap>0 then
					cntgap<=cntgap-1;
				else
					current_frame<=current_frame+1;
--					big_stm<=sequence(current_frame+1);
					big_stm<=CHOOSE_NEXT;
				end if;
			when CHOOSE_NEXT=>
				current_pos<=0;
				case current_frame is 
				when 0=>
					current_len<=frame_lens(current_frame)-CUT_FRAMES;
					big_sequense_array<=copy_45(start_connection01,frame_lens(current_frame));
				when 1=>
					current_len<=frame_lens(current_frame)-CUT_FRAMES;
					big_sequense_array<=copy_45(start_connection02,frame_lens(current_frame));
				when 2=>
					current_len<=frame_lens(current_frame)-CUT_FRAMES;
					big_sequense_array<=copy_45(start_connection03,frame_lens(current_frame));


				when 3=>
					current_len<=frame_lens(current_frame)-CUT_FRAMES;
					big_sequense_array<=copy_45(request_status01,frame_lens(current_frame));
				when 4=>
					current_len<=frame_lens(current_frame)-CUT_FRAMES;
					big_sequense_array<=copy_45(request_status02,frame_lens(current_frame));


				when 5=>
					current_len<=frame_lens(current_frame)-CUT_FRAMES;
					big_sequense_array<=copy_45(read_porogi01,frame_lens(current_frame));
				when 6=>
					current_len<=frame_lens(current_frame)-CUT_FRAMES;
					big_sequense_array<=copy_45(read_porogi02,frame_lens(current_frame));


				when 7=>
					current_len<=frame_lens(current_frame)-CUT_FRAMES;
					big_sequense_array<=copy_47(measure_300sec_01,frame_lens(current_frame));
				when 8=>
					current_len<=frame_lens(current_frame)-CUT_FRAMES;
					big_sequense_array<=copy_47(measure_300sec_02,frame_lens(current_frame));

				when 9=>
					current_len<=frame_lens(current_frame)-CUT_FRAMES;
					big_sequense_array<=copy_45(request_data01,frame_lens(current_frame));
				when 10=>
					current_len<=frame_lens(current_frame)-CUT_FRAMES;
					big_sequense_array<=copy_45(request_data02,frame_lens(current_frame));



				when others=>
					current_frame<=0;
					current_len<=frame_lens(0)-CUT_FRAMES;
					big_sequense_array<=copy_45(start_connection01,frame_lens(0));
				end case;
				if CUT_FRAMES=0 then
					big_stm<=SEND_55_01;
				else
					big_stm<=SEND_ARRAY;
				end if;
			when others=>
			end case;
				data_o<=s_data;
				dv_o<=s_dv;

		end if; --#ce
		end if; --#reset

	end if; --# clk
end process;

--process(clk)
--begin
--	if rising_edge(clk) then
--		if reset='1' then
--			stm<=WAITING;
--		else
--			if ce='1' then
--				case stm is
--				when WAITING=>
--					if send_ask_radar_status='1' then
--						stm<=SEND_01;
--					end if;	
--					s_data<=x"00";
--					s_dv<='0';
--					cnt<=x"00";
--				when SEND_01=>
--					if unsigned(cnt)<3-1 then
--						cnt<=cnt+1;
--					else
--						stm<=WAITING;--SEND_CRC;
--						cnt<=x"00";
--					end if;
--					s_data<=ask_radar_status_mem(conv_integer(cnt));
--                    s_dv<='1';
--				when SEND_CRC=>
--					s_data<=x"FF";
--					s_dv<='1';
--					if unsigned(cnt)<4-1 then
--						cnt<=cnt+1;
--					else
--						stm<=WAITING;
--					end if;
--        
--				when others=>
--				end case;
--				data_o<=s_data;
--				dv_o<=s_dv;
--			end if; --# ce		
--		end if;
--	end if;
--end process;
--


end client_stimulus_cpu;


