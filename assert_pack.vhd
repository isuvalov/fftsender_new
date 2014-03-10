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
      hwrite(lp, sv);
      return lp.all;
    end;


------------------------------------------------------------------------------------
  --Returns the size of the given integer as if it were a string in the given Radix
 
------------------------------------------------------------------------------------
  function get_int_length(x : integer; radix : positive range 2 to 36 := 10) return integer is
    variable temp : integer := abs x;
    variable len  : integer := 0;
  begin

    if x = 0 then
      len := 1;
    end if;

    while temp > 0 loop
      temp := temp / radix;

      len  := len + 1;
    end loop;

    if x < 0 then
      len := len + 1;   --add extra character for -ve sign
    end if;

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
    for i in STRING_LEN downto 1 loop

      --add -ve sign
      if i = 1 and x < 0 then
        ret_string(i)         := '-';
      else
        temp_rem              := temp rem radix;

        case temp_rem is
          when 0      => ret_string(i) := '0';
          when 1      => ret_string(i) := '1';
          when 2      => ret_string(i) := '2';
          when 3      => ret_string(i) := '3';
          when 4      => ret_string(i) := '4';
          when 5      => ret_string(i) := '5';
          when 6      => ret_string(i) := '6';
          when 7      => ret_string(i) := '7';
          when 8      => ret_string(i) := '8';
          when 9      => ret_string(i) := '9';
          when 10     => ret_string(i) := 'A';
          when 11     => ret_string(i) := 'B';
          when 12     => ret_string(i) := 'C';
          when 13     => ret_string(i) := 'D';
          when 14     => ret_string(i) := 'E';
          when 15     => ret_string(i) := 'F';
          when 16     => ret_string(i) := 'G';
          when 17     => ret_string(i) := 'H';
          when 18     => ret_string(i) := 'I';
          when 19     => ret_string(i) := 'J';
          when 20     => ret_string(i) := 'K';
          when 21     => ret_string(i) := 'L';
          when 22     => ret_string(i) := 'M';
          when 23     => ret_string(i) := 'N';
          when 24     => ret_string(i) := 'O';
          when 25     => ret_string(i) := 'P';
          when 26     => ret_string(i) := 'Q';
          when 27     => ret_string(i) := 'R';
          when 28     => ret_string(i) := 'S';
          when 29     => ret_string(i) := 'T';
          when 30     => ret_string(i) := 'U';
          when 31     => ret_string(i) := 'V';
          when 32     => ret_string(i) := 'W';
          when 33     => ret_string(i) := 'X';
          when 34     => ret_string(i) := 'Y';
          when 35     => ret_string(i) := 'Z';

          --something has gone very wrong. Kill simulation
          when others => report "Illegal option chosen in converting integer to string" severity failure;
        end case;

        temp := temp / radix;
      end if;
    end loop;

    return ret_string;

  end function int_to_string;


end package body assert_pack;
