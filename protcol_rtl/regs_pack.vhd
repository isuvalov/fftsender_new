library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package regs_pack is	

type Trx2tx_wires is record
	new_request_received: std_logic;
end record Trx2tx_wires;
							  
type Tregs_from_host is record	
	start_work: std_logic;
end record Tregs_from_host;

constant DEFAULT_FROMHOST_REGS:Tregs_from_host:=(
	start_work=>'0'
);



end regs_pack;
package body regs_pack is 
	


end package body regs_pack;

