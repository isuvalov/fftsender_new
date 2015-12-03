library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;
library work;
use work.assert_pack.all;
use work.regs_pack.all;

entity send_udp is
	generic(
		CUT_LEN:integer:=1024;
		DEBUG:integer:=1
	);
	 port(
		 reset: in std_logic;
		 clk_mac: in std_logic;

		 PayloadIsZERO: in std_logic; --# if it '1' make zero all data in MAC frame

		 udp_IPaddr: in std_logic_vector(31 downto 0);  --# UDP IP addr
		 udp_port_number : in std_logic_vector(15 downto 0);  --# UDP port number

		 rd_data: out std_logic;
		 fifo_empty: in std_logic;
		 read_count: in std_logic_vector(10 downto 0);

		 rd_direct: out std_logic;
		 i_direct: in std_logic;

		 i_data: in std_logic_vector(3 downto 0);
		 i_data_ce: in std_logic;

		 rd_exp: out std_logic;
		 i_data_exp: in std_logic_vector(7 downto 0);
		 i_data_exp_ce: in std_logic;

		 rx2tx: in Trx2tx_wires;

		 data_out: out std_logic_vector(3 downto 0);
		 dv : out std_logic
	     );
end send_udp;


architecture send_udp of send_udp is

constant PRMBLE_LEN		:integer:=8;  		--# Number of addition constant data in preamble
constant HEADER_LEN		:integer:=42;  	--# Number of addition constant data in MAC frame
constant DATAFRAME_LEN	:integer:=512; 	--# Length of data in MAC frame in bytes. Must be DATAFRAME_LEN*n=CUT_LEN

type Prmble_mem is array (0 to PRMBLE_LEN-1) of std_logic_vector(7 downto 0);
constant pre_mem:Prmble_mem:=  (x"55",x"55",x"55",x"55",x"55",x"55",x"55",x"D5");

type Tmac_mem is array (0 to HEADER_LEN-1) of std_logic_vector(7 downto 0);
constant mac_mem:Tmac_mem:=  (
x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"00",x"1E",x"68",x"AE",x"76",x"FF",x"08",x"00",x"45",x"00",
x"02",x"1E",x"00",x"00",x"00",x"00",x"40",x"11",x"E2",x"75",x"C0",x"A8",x"0A",x"0A",x"C0",x"A8",
x"0A",x"FF",x"00",x"3F",x"00",x"3F",x"02",x"0A",x"00",x"00");  --# Ethernet header


 function nextCRC32_D4 -- Calculate ETH CRC32
    (Data: std_logic_vector(3 downto 0);
     crc:  std_logic_vector(31 downto 0))
    return std_logic_vector is

    variable d:      std_logic_vector(3 downto 0);
    variable c:      std_logic_vector(31 downto 0);
    variable newcrc: std_logic_vector(31 downto 0);

  begin
    d := Data;
    c := crc;

    newcrc(0)  := d(0) xor c(28);
    newcrc(1)  := d(1) xor d(0) xor c(28) xor c(29);
    newcrc(2)  := d(2) xor d(1) xor d(0) xor c(28) xor c(29) xor c(30);
    newcrc(3)  := d(3) xor d(2) xor d(1) xor c(29) xor c(30) xor c(31);
    newcrc(4)  := d(3) xor d(2) xor d(0) xor c(0) xor c(28) xor c(30) xor c(31);
    newcrc(5)  := d(3) xor d(1) xor d(0) xor c(1) xor c(28) xor c(29) xor c(31);
    newcrc(6)  := d(2) xor d(1) xor c(2) xor c(29) xor c(30);
    newcrc(7)  := d(3) xor d(2) xor d(0) xor c(3) xor c(28) xor c(30) xor c(31);
    newcrc(8)  := d(3) xor d(1) xor d(0) xor c(4) xor c(28) xor c(29) xor c(31);
    newcrc(9)  := d(2) xor d(1) xor c(5) xor c(29) xor c(30);
    newcrc(10) := d(3) xor d(2) xor d(0) xor c(6) xor c(28) xor c(30) xor c(31);
    newcrc(11) := d(3) xor d(1) xor d(0) xor c(7) xor c(28) xor c(29) xor c(31);
    newcrc(12) := d(2) xor d(1) xor d(0) xor c(8) xor c(28) xor c(29) xor c(30);
    newcrc(13) := d(3) xor d(2) xor d(1) xor c(9) xor c(29) xor c(30) xor c(31);
    newcrc(14) := d(3) xor d(2) xor c(10) xor c(30) xor c(31);
    newcrc(15) := d(3) xor c(11) xor c(31);
    newcrc(16) := d(0) xor c(12) xor c(28);
    newcrc(17) := d(1) xor c(13) xor c(29);
    newcrc(18) := d(2) xor c(14) xor c(30);
    newcrc(19) := d(3) xor c(15) xor c(31);
    newcrc(20) := c(16);
    newcrc(21) := c(17);
    newcrc(22) := d(0) xor c(18) xor c(28);
    newcrc(23) := d(1) xor d(0) xor c(19) xor c(28) xor c(29);
    newcrc(24) := d(2) xor d(1) xor c(20) xor c(29) xor c(30);
    newcrc(25) := d(3) xor d(2) xor c(21) xor c(30) xor c(31);
    newcrc(26) := d(3) xor d(0) xor c(22) xor c(28) xor c(31);
    newcrc(27) := d(1) xor c(23) xor c(29);
    newcrc(28) := d(2) xor c(24) xor c(30);
    newcrc(29) := d(3) xor c(25) xor c(31);
    newcrc(30) := c(26);
    newcrc(31) := c(27);
    return newcrc;
  end nextCRC32_D4;

function fliplr(A:std_logic_vector) return std_logic_vector is
variable R:std_logic_vector(A'Range);
begin
  for i in A'Low to A'High loop
	  R(A'High-(i-A'Low)):=A(i);
  end loop; 
  return R;
end function;


signal frame_num:std_logic_vector(3 downto 0);

function get_numframes(some:integer) return std_logic_vector is
variable calc:std_logic_vector(15 downto 0);
variable fr:std_logic_vector(frame_num'Length-1 downto 0);
begin
	calc:=conv_std_logic_vector(CUT_LEN/DATAFRAME_LEN,calc'Length);
	fr:=calc(fr'Length-1 downto 0);
	return fr;
end function;


type Tstm_read is (  WAITING_REQUEST, SEND_RADAR_STATE0, SEND_RADAR_STATE1, SEND_RADAR_PREAMBLE0,SEND_RADAR_PREAMBLE1, SEND_RADAR_STATE_NUM0, SEND_RADAR_STATE_NUM1,  
SEND_RADAR_STATE_ZEROS,
STARTING,DELAYING,WAITING,PREAMBLE1,PREAMBLE2,DESCR_MAC1,DESCR_MAC2,
DESCR_POS1,DESCR_POS2,DESCR_POS3,DESCR_POS4,READ_DATA,PUSHCRC1,PUSHCRC2,PUSHCRC3,PUSHCRC4,PUSHCRC5,PUSHCRC6,PUSHCRC7,PUSHCRC8);
signal stm_read:Tstm_read;

constant RADAR_STATUS_LEN:integer:=43;
type Tradar_status is array (0 to 42) of std_logic_vector(7 downto 0);

constant radar_status:Tradar_status:=(x"54", x"04", x"a6", x"c3", x"98", x"77", x"3c", x"97", x"0e", x"91", x"a7", x"93", x"08", x"00", x"45", x"00",
x"00", x"2c", x"67", x"dd", x"00", x"00", x"80", x"11", x"3d", x"7e", x"c0", x"a8", x"0a", x"0a", x"c0", x"a8",
x"0a", x"0b", x"ec", x"bf", x"d2", x"95", x"00", x"18", x"05", x"10", x"a5");

signal outrd_cnt:std_logic_vector(7 downto 0);

signal fifo_empty_1w, exp_first_read, signal_direct_reg:std_logic;

signal cnt_mac:std_logic_vector(7 downto 0);
signal crc32:std_logic_vector(31 downto 0);
signal C_calc:std_logic_vector(31 downto 0);
signal s_data_out: std_logic_vector(3 downto 0);
signal s_dv : std_logic;		
signal read_cnt: std_logic_vector(15 downto 0);
signal sig_dir:std_logic_vector(3 downto 0);
signal exp_fifosE:std_logic_vector(7 downto 0);
signal delay_cnt:std_logic_vector(4 downto 0);

signal rx2tx_reg: Trx2tx_wires;

begin

C_calc <= not (crc32(28)& crc32(29)& crc32(30)& crc32(31)& crc32(24)& crc32(25)& crc32(26)& crc32(27)&
					crc32(20)& crc32(21)& crc32(22)& crc32(23)& crc32(16)& crc32(17)& crc32(18)& crc32(19)&
					crc32(12)& crc32(13)& crc32(14)& crc32(15)& crc32(8) & crc32(9) & crc32(10)& crc32(11)&
					crc32(4) & crc32(5) & crc32(6) & crc32(7) & crc32(0) & crc32(1) & crc32(2) & crc32(3));



process (clk_mac) is
begin
 if rising_edge(clk_mac) then

	fifo_empty_1w<=fifo_empty;
	signal_direct_reg<=i_direct;
	exp_fifosE<=i_data_exp;

	if reset='1' then
		stm_read<=WAITING_REQUEST;--STARTING;--WAITING;
		rd_data<='0';
		s_dv<='0';
		frame_num<=(others=>'0');
		rd_exp<='0';
		exp_first_read<='0';
	else --# reset
		case stm_read is

		when WAITING_REQUEST=>
			if rx2tx.new_request_received='1' then
				rx2tx_reg<=rx2tx;
				case rx2tx.request_type is
				when x"00" => stm_read<=SEND_RADAR_PREAMBLE0;
				when x"01" => stm_read<=STARTING;
				when others=>
				end case;
			end if;
			outrd_cnt<=(others=>'0');
			cnt_mac<=(others=>'0');
            rd_data<='0';
		 	rd_exp<='0';
			rd_direct<='0';
			s_dv<='0';
--------------------------------------------------------------------------------
----------------------------Отсылка состояния радара--------------------------
--------------------------------------------------------------------------------
		when SEND_RADAR_PREAMBLE0=>
			 stm_read<=SEND_RADAR_PREAMBLE1;
			 s_dv<='1';
			 s_data_out<=pre_mem(conv_integer(cnt_mac))(3 downto 0);
		when SEND_RADAR_PREAMBLE1=>
			 if unsigned(cnt_mac)<((PRMBLE_LEN)-1) then
			 	cnt_mac<=cnt_mac+1;
				stm_read<=SEND_RADAR_PREAMBLE0;
			 else
				cnt_mac<=(others=>'0');
				stm_read<=SEND_RADAR_STATE0;
			 end if;
			 s_dv<='1';
			 s_data_out<=pre_mem(conv_integer(cnt_mac))(7 downto 4);

		when SEND_RADAR_STATE0=>
			 stm_read<=SEND_RADAR_STATE1;
			 s_dv<='1';
			 s_data_out<=radar_status(conv_integer(outrd_cnt))(3 downto 0);

		when SEND_RADAR_STATE1=>
			 s_dv<='1';
			 s_data_out<=radar_status(conv_integer(outrd_cnt))(7 downto 4);
			 if unsigned(outrd_cnt)<((1+RADAR_STATUS_LEN-1)-1) then
			 	outrd_cnt<=outrd_cnt+1;
				stm_read<=SEND_RADAR_STATE0;
			 else
				outrd_cnt<=(others=>'0');
				stm_read<=SEND_RADAR_STATE_NUM0;
			 end if;

		when SEND_RADAR_STATE_NUM0=>
			 s_dv<='1';
		     s_data_out<=rx2tx_reg.request_number(3 downto 0);
             stm_read<=SEND_RADAR_STATE_NUM1;

		when SEND_RADAR_STATE_NUM1=>
			 s_dv<='1';
		     s_data_out<=rx2tx_reg.request_number(7 downto 4);
             stm_read<=SEND_RADAR_STATE_ZEROS;

		when SEND_RADAR_STATE_ZEROS=>
			s_dv<='1';
            s_data_out<=x"0";
			if unsigned(outrd_cnt)<((16*2)-1) then
				outrd_cnt<=outrd_cnt+1;
			else
				outrd_cnt<=(others=>'0');
				stm_read<=WAITING_REQUEST;			
			end if;


--------------------------------------------------------------------------------
----------------------------Данные измерения------------------------------------
--------------------------------------------------------------------------------
		when STARTING=>		
			if (unsigned(read_count)>=(DATAFRAME_LEN*2) and fifo_empty_1w='0') then			
				stm_read<=PREAMBLE1;
			    if DEBUG=1 then
				  print(">>> Start frame sequense "&int_to_string(conv_integer(frame_num)));
			    end if;
				rd_exp<='1';
				rd_direct<='1';
			else
				rd_exp<='0';
				rd_direct<='0';
			end if;
			rd_data<='0';
			s_dv<='0';
			s_data_out<=(others=>'0');	
			read_cnt<=(others=>'0');
			cnt_mac<=(others=>'0');
			crc32<=(others=>'1');
			frame_num<=(others=>'0');
			
			exp_first_read<='0';
		when WAITING =>
			if (fifo_empty_1w='0') and unsigned(read_count)>=(DATAFRAME_LEN*2) then			
				stm_read<=PREAMBLE1;
			    if DEBUG=1 then
				  print("Start frame "&int_to_string(conv_integer(frame_num)));
			    end if;

			end if;
			rd_direct<='0';
			rd_data<='0';
			s_dv<='0';
			s_data_out<=(others=>'0');	
			read_cnt<=(others=>'0');
			cnt_mac<=(others=>'0');
			crc32<=(others=>'1');
			rd_exp<='0';

		when PREAMBLE1 =>
			 --cnt_mac<=cnt_mac;
			 stm_read<=PREAMBLE2;
			 s_dv<='1';
			 s_data_out<=pre_mem(conv_integer(cnt_mac))(3 downto 0);
			 rd_data<='0';
			 rd_exp<='0';
             rd_direct<='0';
		when PREAMBLE2 =>
			 if unsigned(cnt_mac)<((PRMBLE_LEN)-1) then
			 	cnt_mac<=cnt_mac+1;
				stm_read<=PREAMBLE1;
				rd_direct<='0';
			 else
				cnt_mac<=(others=>'0');
				stm_read<=DESCR_MAC1;
				rd_direct<='0';
			 end if;
			 s_dv<='1';
			 s_data_out<=pre_mem(conv_integer(cnt_mac))(7 downto 4);
			 rd_data<='0';

		when DESCR_MAC1 =>
			 stm_read<=DESCR_MAC2;
			 rd_direct<='0';
			 s_dv<='1';
          	 s_data_out<=mac_mem(conv_integer(cnt_mac))(3 downto 0);
          	 crc32<=nextCRC32_D4(fliplr(mac_mem(conv_integer(cnt_mac))(3 downto 0)),crc32);
			 		 
		when DESCR_MAC2 =>
			 if unsigned(cnt_mac)<((HEADER_LEN)-1) then
			 	cnt_mac<=cnt_mac+1;
				stm_read<=DESCR_MAC1;
			 else
				cnt_mac<=(others=>'0');
				stm_read<=DESCR_POS1;
				rd_data<='1';
				if exp_first_read='1' then
					rd_exp<='0';
				else
					rd_exp<='0';
				end if;
				exp_first_read<='1';
			if signal_direct_reg='1' then 
			   sig_dir<=x"C";
			   if DEBUG=1 then
				 print(" Direction 1");
			   end if;
			else
			   sig_dir<=x"F";
			   if DEBUG=1 then
				 print(" Direction 0");
			   end if;
			end if;



			 end if;
			 s_dv<='1';
          s_data_out<=mac_mem(conv_integer(cnt_mac))(7 downto 4);
			 crc32<=nextCRC32_D4(fliplr(mac_mem(conv_integer(cnt_mac))(7 downto 4)),crc32);
			 	  
	      when DESCR_POS1 =>
			s_dv<='1';
			s_data_out<=sig_dir;
			crc32<=nextCRC32_D4(fliplr(sig_dir),crc32);
			stm_read<=DESCR_POS2;
			rd_data<='0';
			rd_exp<='0';
			
		when DESCR_POS2 =>
			rd_exp<='0';
			s_dv<='1';
			s_data_out<=frame_num;
			crc32<=nextCRC32_D4(fliplr(frame_num),crc32);
			stm_read<=DESCR_POS3;
			rd_data<='0';
			
		when DESCR_POS3 =>
			s_dv<='1';
			s_data_out<=exp_fifosE(3 downto 0);
			crc32<=nextCRC32_D4(fliplr(exp_fifosE(3 downto 0)),crc32);
			stm_read<=DESCR_POS4;
			rd_data<='0';	
			frame_num<=frame_num+1;
   
		when DESCR_POS4 =>
			s_dv<='1';
			s_data_out<=exp_fifosE(7 downto 4);
			crc32<=nextCRC32_D4(fliplr(exp_fifosE(7 downto 4)),crc32);
			stm_read<=READ_DATA;
			rd_data<='1';
            if DEBUG=1 then
			  print("< Read EXP "&to_string(exp_fifosE));
			end if;

		when READ_DATA => 
			read_cnt<=read_cnt+1;
			if PayloadIsZERO='1' then								
				s_data_out<=x"0";				
				crc32<=nextCRC32_D4(x"0",crc32);					
			else																
				s_data_out<=i_data;
				crc32<=nextCRC32_D4(fliplr(i_data),crc32);
			end if;															

			if read_cnt<(DATAFRAME_LEN)*2-2 then
				rd_data<='1';
			else															
				rd_data<='0';
			end if;															
			
			if unsigned(read_cnt)<(DATAFRAME_LEN)*2-1 then
				stm_read<=READ_DATA; 
			else
				stm_read<=PUSHCRC8;
			end if;
			
		when PUSHCRC1 =>
			s_dv<='1';
			s_data_out<=C_calc(3 downto 0);
--			if frame_num=get_numframes(0) then
			if frame_num=4 then
				stm_read<=STARTING;
				if DEBUG=1 then
			   		print("End of secuence");
				end if;
			else
				stm_read<=DELAYING;--WAITING;
				if DEBUG=1 then
			   		print("End of frame");
				end if;
			end if;
			delay_cnt<=(others=>'1');

			
		when PUSHCRC2 =>
			s_dv<='1';
			s_data_out<=C_calc(7 downto 4);  				--#Petrov  x"7"
			stm_read<=PUSHCRC1;

		when PUSHCRC3 =>
			s_dv<='1';
			s_data_out<=C_calc(11 downto 8); 				--#Petrov  x"C"
			stm_read<=PUSHCRC2;

		when PUSHCRC4 =>
			s_dv<='1';
			s_data_out<=C_calc(15 downto 12);  				--#Petrov  x"4"
			stm_read<=PUSHCRC3;

		when PUSHCRC5 =>
			s_dv<='1';
			s_data_out<=C_calc(19 downto 16);  				--#Petrov  x"4"
			stm_read<=PUSHCRC4;

		when PUSHCRC6 =>
			s_dv<='1';
			s_data_out<=C_calc(23 downto 20);  				--#Petrov  x"D"
			stm_read<=PUSHCRC5;

		when PUSHCRC7 =>
			s_dv<='1';
			s_data_out<=C_calc(27 downto 24);  				--#Petrov  x"C"
			stm_read<=PUSHCRC6;

		when PUSHCRC8 =>
			rd_data<='0';
			s_dv<='1';
			s_data_out<=C_calc(31 downto 28);  				--#Petrov  x"6"
			stm_read<=PUSHCRC7;           

		when DELAYING=>
			if unsigned(delay_cnt)>0 then
				delay_cnt<=delay_cnt-1;
			else
				stm_read<=WAITING;
			end if;
		    s_dv<='0';
		when others =>
			stm_read<=WAITING;
		end case;

	end if; --# reset	

 end if;
end process;

output_p: process (clk_mac) is
begin
     if falling_edge (clk_mac) then
	     data_out<=s_data_out;
        dv<=s_dv;
	  end if;
end process;

end send_udp;

