library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;
library std;
use std.textio.all;
library work;
use work.assert_pack.all;



entity ethernet2hexfile is
	generic(
			SWAP_4BITS:integer:=1;			
			NameOfFile: string := "c:\noise.dat");
	 port(
		 clk : in STD_LOGIC;
		 dv : in STD_LOGIC;
		 DataToSave : in STD_LOGIC_VECTOR(3 downto 0)
	     );
end ethernet2hexfile;


architecture ethernet2hexfile of ethernet2hexfile is

constant BitLen:integer:=4;


FUNCTION rat( value : std_logic )
    RETURN std_logic IS
  BEGIN
    CASE value IS
      WHEN '0' | '1' => RETURN value;
      WHEN 'H' => RETURN '1';
      WHEN 'L' => RETURN '0';
      WHEN OTHERS => RETURN '0';
    END CASE;
END rat;

FUNCTION rats( value : std_logic_vector ) RETURN std_logic_vector IS
variable rtt:std_logic_vector(value'Range);
  BEGIN					   
    for i in value'Range loop		
		rtt(i):=rat(value(i));
	end loop;
	return rtt;
END rats;

function fliplr(A:std_logic_vector) return std_logic_vector is
variable R:std_logic_vector(A'Range);
begin
  for i in A'Low to A'High loop
	  R(A'High-(i-A'Low)):=A(i);
  end loop; 
  return R;
end function;


function ToHex( value: std_logic_vector) return string is
variable str:string(1 to BitLen/4);
variable a:character;
variable value_h:std_logic_vector(3 downto 0);
begin
	for z in 1 to BitLen/4 loop
	value_h:=fliplr(value(z*4-1 downto (z-1)*4));
	case value_h is
		when "0000" => a:='0';
		when "0001" => a:='1';
		when "0010" => a:='2';
		when "0011" => a:='3';		
		when "0100" => a:='4';
		when "0101" => a:='5';
		when "0110" => a:='6';
		when "0111" => a:='7';		
		when "1000" => a:='8';
		when "1001" => a:='9';
		when "1010" => a:='A';
		when "1011" => a:='B';		
		when "1100" => a:='C';
		when "1101" => a:='D';
		when "1110" => a:='E';
		when "1111" => a:='F';
		when "ZZZZ" => a:='Z';
		when OTHERS =>
			a:='X';
	end case;		
		
	str(z):=a;
	end loop;
 	return str;
end ToHex;

FILE results: TEXT OPEN WRITE_MODE IS NameOfFile;
signal cnt:integer:=0;
signal ccc:std_logic_vector(1 downto 0):=(others=>'0');
signal locDataToSave,DataToSave_reg,DataToSave_reg_1w,DataToSave_reg_2w:std_logic_vector(DataToSave'Length-1 downto 0):=(others=>'0');
signal cnti,framecnt:std_logic_vector(31 downto 0):=(others=>'0');

shared variable sTX_LOC : LINE:=NULL;	

signal locdv_1w,dv_1w,dv_2w,locdv:std_logic:='0';

--signal tessst:string(1 to (BitLen/4)*2+1);
begin
--tessst<=ToHex(fliplr(locDataToSave));


--sw01: if SWAP_4BITS=1 generate
--	process(clk) is
--	begin
--		if rising_edge(clk) then
--			dv_1w<=dv;
--			dv_2w<=dv_1w;
--			locdv<=dv_2w;
--			ccc<=ccc+1;
--			DataToSave_reg_1w<=DataToSave;
--			DataToSave_reg_2w<=DataToSave_reg_1w;
--
--			if ccc(0)='1' then
--				locDataToSave<=DataToSave_reg_2w;
--			else
--				locDataToSave<=DataToSave;
--			end if;	
--		end if;
--	end process;
--end generate;


locdv<=dv;
locDataToSave<=DataToSave;
	
wrFile: process (clk) is
VARIABLE TX_LOC : LINE:=NULL;	
variable dataint:Integer;
variable str1:string(1 to  20);
variable str2:string(1 to  1);
begin
str1:="-------------------/";
str2:=" ";
--	if rising_edge(clk) then
	if falling_edge(clk) then
        locdv_1w<=locdv;
		if locdv='0' then
			cnti<=(others=>'0');
			if unsigned(cnti)>0 then
				TX_LOC:=sTX_LOC;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.write(TX_LOC,str2);
				STD.TEXTIO.writeline(results, TX_LOC); 
				framecnt<=framecnt+1;
			end if;
		    TX_LOC:=NULL;
			sTX_LOC:=TX_LOC;
		elsif locdv='1' then
			if locdv_1w='0' then
		    	TX_LOC:=NULL;
				STD.TEXTIO.write(TX_LOC,"Frame number is "&int_to_string(conv_integer(unsigned(framecnt))));
	            STD.TEXTIO.writeline(results, TX_LOC); 
		    	TX_LOC:=NULL;
				sTX_LOC:=TX_LOC;
			end if;


			cnti<=cnti+1;
			TX_LOC:=sTX_LOC;
			STD.TEXTIO.write(TX_LOC,ToHex(fliplr(locDataToSave))(1 to 1));
			if cnti(0)='1' then
				STD.TEXTIO.write(TX_LOC,str2);
			end if;

			if cnti(4 downto 0)="11111" then
	            STD.TEXTIO.writeline(results, TX_LOC); 
		    	TX_LOC:=NULL;
				sTX_LOC:=TX_LOC;
			else
				sTX_LOC:=TX_LOC;
			end if;
		end if;

	end if;
end process;

end ethernet2hexfile;
