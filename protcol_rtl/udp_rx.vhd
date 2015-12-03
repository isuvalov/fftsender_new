library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;
library work;
use work.regs_pack.all;

entity udp_rx is	 
	 port(
		 reset: in std_logic;
		 clk : in std_logic;
		 udp_IPaddr: in std_logic_vector(31 downto 0);
		 port_number: in std_logic_vector(15 downto 0);
		 i_dv : in std_logic; --# must be with i_ce 
		 i_ce : in std_logic;
		 i_data : in std_logic_vector(7 downto 0);

		 rx2tx: out Trx2tx_wires
	     );
end udp_rx;


architecture udp_rx of udp_rx is

constant PRMBLE_LEN		:integer:=8;  		--# Number of addition constant data in preamble
constant UDPHEADER_LEN		:integer:=42-12;  	--# Number of addition constant data in MAC frame
type Prmble_mem is array (0 to PRMBLE_LEN-1) of std_logic_vector(7 downto 0);
constant pre_mem:Prmble_mem:=  (x"55",x"55",x"55",x"55",x"55",x"55",x"55",x"D5");

FUNCTION log2roundup (data_value : integer)
		RETURN integer IS
		
		VARIABLE width       : integer := 0;
		VARIABLE cnt         : integer := 1;
		CONSTANT lower_limit : integer := 1;
		CONSTANT upper_limit : integer := 8;
		
	BEGIN
		IF (data_value <= 1) THEN
			width   := 0;
		ELSE
			WHILE (cnt < data_value) LOOP
				width := width + 1;
				cnt   := cnt *2;
			END LOOP;
		END IF;
		
		RETURN width;
	END log2roundup;


signal correct_prmb_cnt:std_logic_vector(log2roundup(PRMBLE_LEN)-1 downto 0);
signal correct_mac_cnt:std_logic_vector(2 downto 0);
signal udp_header_cnt:std_logic_vector(log2roundup(PRMBLE_LEN+UDPHEADER_LEN)-1 downto 0);
signal by_frame_cnt:std_logic_vector(15 downto 0);
signal port_number_reg:std_logic_vector(15 downto 0);
signal port_number_correct,port_error,not_request:std_logic;


type Tstm is (WAITING,GET_PREAMBULE,GETING_MAC1,GETING_MAC2,GETING_ETHER1,GETING_ETHER2,GETING_UDPHEADER,
	GET_REQ_PROPERTY,GET_REQ_NUMBER,GET_REG_TYPE
	);
signal stm:Tstm:=WAITING;
signal s_rx2tx:Trx2tx_wires;

begin

--# Request is srv->resp  and srv_t srv; 
--# resp have made by form_status_resp,form_status_temps, form_status_amperage, form_status_voltage

--# For form_status_resp:
--# typedef struct {
--#   base_resp_t base_resp;
--#   status_t status;
--#   unsigned char details;
--#   signed char t[3];
--#   unsigned char i[3];
--#   signed char u[4];
--# } status_resp_t;

--# typedef struct {
--#   unsigned char _;
--#   unsigned char no;
--#   unsigned char fn;
--#   unsigned char rv;
--# } base_resp_t;
--# 
--# typedef struct {
--#   unsigned char fault       : 1;
--#   unsigned char ready       : 1;
--#   unsigned char meas_mode   : 1;
--#   unsigned char last_unsucc : 1;
--#   unsigned char has_unread  : 1;
--# } status_t;
    
--# 36+PRMBLE_LEN - port start    

process(clk) is
begin
	if rising_edge(clk) then
		port_number_reg<=port_number;
	end if;
end process;

process(clk) is
begin
	if rising_edge(clk) then
		if reset='1' then
			stm<=WAITING;
			port_number_correct<='0';
			by_frame_cnt<=(others=>'0');
			port_error<='0';
			s_rx2tx.new_request_received<='0';
		else --# reset
			if i_ce='1' then
				by_frame_cnt<=by_frame_cnt+1;
				rx2tx<=s_rx2tx;
				case stm is
				when WAITING=>
					if i_dv='1' then
						if i_data=pre_mem(0) then
							stm<=GET_PREAMBULE;
							correct_prmb_cnt<=conv_std_logic_vector(1,correct_prmb_cnt'Length);
						end if;
					else
						by_frame_cnt<=(others=>'0');
					end if;
					correct_mac_cnt<=(others=>'0');
			        udp_header_cnt<=(others=>'0');
					port_number_correct<='0';
					port_error<='0';
					s_rx2tx.new_request_received<='0';					
					not_request<='0';
				when GET_PREAMBULE=>
					if i_data=pre_mem(conv_integer(correct_prmb_cnt)) then
						if correct_prmb_cnt<PRMBLE_LEN-1 then
							correct_prmb_cnt<=correct_prmb_cnt+1;
						else
							stm<=GETING_MAC1;
						end if;
					else
						stm<=WAITING;
					end if;
				when GETING_MAC1=>
					if unsigned(correct_mac_cnt)<6-1 then
						correct_mac_cnt<=correct_mac_cnt+1;
					else
						stm<=GETING_MAC2;
						correct_mac_cnt<=(others=>'0');
					end if;
				when GETING_MAC2=>
					if unsigned(correct_mac_cnt)<6-1 then
						correct_mac_cnt<=correct_mac_cnt+1;
					else
						stm<=GETING_ETHER1;
						correct_mac_cnt<=(others=>'0');
					end if;
				when GETING_ETHER1=>
					if i_data=x"08" then
						stm<=GETING_ETHER2;
					else
						stm<=WAITING;
					end if; 
				when GETING_ETHER2=>
					if i_data=x"00" then
						stm<=GETING_UDPHEADER;
					else
						stm<=WAITING;
					end if; 
				when GETING_UDPHEADER=>
--					if by_frame_cnt=37+PRMBLE_LEN then
					if by_frame_cnt=42 then
						if port_number_reg(15 downto 8)=i_data then
							port_number_correct<='1';
						else
							port_number_correct<='0';
						end if;
					end if;
					if by_frame_cnt=43 then
						if port_number_reg(7 downto 0)=i_data and port_number_correct='1' then
							port_error<='0';
						else
							port_error<='1';
						end if;
					end if;

					if port_error='1' then
						stm<=WAITING;
					else
						if by_frame_cnt=49 then
							stm<=GET_REQ_PROPERTY;
						end if;
--						if unsigned(udp_header_cnt)<PRMBLE_LEN+UDPHEADER_LEN-1 then
--						if unsigned(udp_header_cnt)<49 then
--							udp_header_cnt<=udp_header_cnt+1;
--						else
--							stm<=GET_REQ_PROPERTY;
--						end if;
					end if;
					s_rx2tx.new_request_received<='0';
				when GET_REQ_PROPERTY=>
					if i_data=x"5A" then
						stm<=GET_REQ_NUMBER;
					else
						stm<=WAITING;
						not_request<='1';
					end if;

				when GET_REQ_NUMBER=>
					s_rx2tx.request_number<=i_data;
					stm<=GET_REG_TYPE;
				
				when GET_REG_TYPE=>
					s_rx2tx.request_type<=i_data;
					s_rx2tx.new_request_received<='1';
					stm<=WAITING;
				when others=>
				end case;
			end if; --# ce
		end if;  --# reset
	end if;
end process;



end udp_rx;
