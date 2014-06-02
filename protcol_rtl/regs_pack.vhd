library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package regs_pack is	

type Trx2tx_wires is record
	new_request_received: std_logic;
	number_of_req:std_logic_vector(7 downto 0);
	request_type:std_logic_vector(7 downto 0);
end record Trx2tx_wires;
							  


end regs_pack;
package body regs_pack is 
	


end package body regs_pack;

