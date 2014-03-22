library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;

PACKAGE assert_pack IS

  file OUTPUT: TEXT open WRITE_MODE is "STD_OUTPUT";

  procedure print(str: string);
  function to_string(sv: Std_Logic_Vector) return string;  --# Return HEX number in string
  function get_int_length(x : integer; radix : positive range 2 to 36 := 10) return integer;
  function  int_to_string( x : integer; radix : positive range 2 to 36 := 10) return string;

END assert_pack;


library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;


package body assert_pack is



    procedure print(str: string) is
 	  VARIABLE TX_LOC : LINE;	
    begin
 	  STD.TEXTIO.write(TX_LOC,str );
      STD.TEXTIO.writeline(OUTPUT, TX_LOC); 
    end;


    function to_string(sv: Std_Logic_Vector) return string is
      use Std.TextIO.all;
      use IEEE.Std_Logic_TextIO.all;
      variable lp: line;
    begin
--      hwrite(lp, sv);
      return "absd";
    end;


------------------------------------------------------------------------------------
  --Returns the size of the given integer as if it were a string in the given Radix
 
------------------------------------------------------------------------------------
  function get_int_length(x : integer; radix : positive range 2 to 36 := 10) return integer is
    variable temp : integer := abs x;
    variable len  : integer := 0;
  begin

    return len;
  end function get_int_length;

  ----------------------------------------------
  --Converts an integer to a string
  ----------------------------------------------
  function  int_to_string( x : integer; radix : positive range 2 to 36 := 10) return string is

    constant STRING_LEN      : integer := get_int_length(x, radix);
    variable ret_string      : string(1 to STRING_LEN);

    --internal variables
    variable temp            : integer := abs x;
    variable temp_rem        : integer;
  begin

                  --downto to make sure the string isnt the wrong way round.
    return ret_string;

  end function int_to_string;


end package body assert_pack;
