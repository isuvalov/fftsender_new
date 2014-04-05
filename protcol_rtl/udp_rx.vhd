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
		 i_start : in std_logic; --# must be with i_ce 
		 i_ce : in std_logic;
		 i_stop : in std_logic;
		 i_data : in std_logic_vector(7 downto 0);

		 rx2tx: out Trx2tx_wires;
		 o_regs: out Tregs_from_host
	     );
end udp_rx;


architecture udp_rx of udp_rx is

constant PRMBLE_LEN		:integer:=8;  		--# Number of addition constant data in preamble
type Prmble_mem is array (0 to PRMBLE_LEN-1) of std_logic_vector(7 downto 0);
constant pre_mem:Prmble_mem:=  (x"55",x"55",x"55",x"55",x"55",x"55",x"55",x"D5");

signal correct

type Tstm is (GET_PREAMBULE);
signal stm:Tstm;

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
    
    


process(clk) is
begin
	if rising_edge(clk) then
		if i_start='1' and i_ce='1' then
			if i_data=pre_mem(0) then
				stm<=GET_PREAMBULE;
			end if;
		else
			case stm is
			when GET_PREAMBULE=>
			when others=>
			end case;
		end if;
	end if;
end process;



end udp_rx;
