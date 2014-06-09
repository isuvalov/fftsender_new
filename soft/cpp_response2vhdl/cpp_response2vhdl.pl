open(F,"../../protocol/rrw_server/bin/Debug/response.txt");
@lines=<F>;


print <<HTMLPRINT;
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;

entity cpu_correct_requset is
	 port(
		 reset: in std_logic;
		 ce : in std_logic;
		 clk : in std_logic;
		 can_go: in std_logic; --# see falling edge of recieved dv

		 dv_o: out std_logic;
		 data_o: out std_logic_vector(7 downto 0)
	     );
end cpu_correct_requset;


architecture cpu_correct_requset of cpu_correct_requset is

signal delay_cnt:std_logic_vector(3 downto 0):=(others=>'1');
signal cnt:integer:=0;

HTMLPRINT


$zz=0;
@sizes=();
foreach $txt (@lines)
{
  if ($txt =~ /resp:/)
  {
	@resp=split(' ',$txt);	
    $resp_len=(scalar @resp)-1;
	push(@sizes,$resp_len);
	print "type Tseq_array$zz is array (0 to 42+$resp_len-1) of std_logic_vector(7 downto 0);\n";
	print "constant seq_array$zz:Tseq_array$zz:=(";
	print 'x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"16", x"ea", x"ca", x"09", x"3a", x"08", x"00", x"45", x"00", x"00", x"1f", x"57", x"ac", x"00", x"00", x"80", x"11", x"21", x"74", x"c0", x"a8", x"01", x"06", x"ff", x"ff", x"ff", x"ff", x"e2", x"ce", x"ec", x"be", x"00", x"0b", x"14", x"9c",';
	print "\n";
	resp_print(@resp);
	print ");\n\n";
	$zz++;
  }
}


$sizes_len=scalar @sizes;
print "constant RESP_NUM:natural:=$sizes_len;\n";
print "type Tsizes is array(0 to $sizes_len-1) of integer;\n";
print "constant sizes:Tsizes:=(";
$z=0;
@tx_states=();
@wait_states=();
@delay_states=();
foreach $val (@sizes)
{
 if ($z<$sizes_len-1)
 {
	 print "$val, ";
	 push(@tx_states,"TX_STATE$z,");
	 push(@wait_states,"WAIT_RESPONSE$z,");
	 push(@delay_states,"START_DELAY$z,");
 } else
 {
	 print "$val";
	 push(@tx_states,"TX_STATE$z");
	 push(@wait_states,"WAIT_RESPONSE$z");
	 push(@delay_states,"START_DELAY$z");

 }
 $z++;
}
print ");\n";


print "type Tstm is (FINISH,@tx_states,@wait_states,@delay_states);\n";
print "signal stm:Tstm;\n";


print <<HTMLPRINT;

begin

process(clk)
begin
	if rising_edge(clk) then
		if reset='1' then
			stm<=WAIT_RESPONSE0;
			delay_cnt<=(others=>'1');
			dv_o<='0';
		else    --# reset
			case stm is
HTMLPRINT
$z=0;
$zz=$z+1;
foreach (@sizes)
{
print"			when WAIT_RESPONSE$z=>\n";
print"				if can_go='1' then\n";
print"					stm<=START_DELAY$z;\n";
print"				end if;\n";
print"				delay_cnt<=(others=>'1');\n";
print"				dv_o<='0';\n";
print"			when START_DELAY$z=>	\n";
print"				if unsigned(delay_cnt)>0 then\n";
print"					delay_cnt<=delay_cnt-1;\n";
print"				else\n";
print"					stm<=TX_STATE$z;\n";
print"				end if;\n";
print"				cnt<=0;\n";
print"				dv_o<='0';\n";
print"			when TX_STATE$z=>\n";
print"				dv_o<='1';\n";
print"				data_o<=seq_array$z(cnt);\n";
print"					if cnt<sizes($z)-1 then\n";
print"						cnt<=cnt+1;\n";
print"					else\n";
 if ($z<$sizes_len-1)
	{print"						stm<=WAIT_RESPONSE$zz;\n";}
 else
	{print "					stm<=FINISH;\n";}
print"					end if;\n";
$z++;
$zz=$z+1;
}
print <<HTMLPRINT;
			when FINISH=>
				 dv_o<='0';
				 data_o<=x"00";
			when others=>
			end case;
		end if; --# reset
	end if;
end process;

end cpu_correct_requset;
HTMLPRINT





sub resp_print
{
  my @val=@_;
  my $z=0;
  my $a=0;
  my $str='';
  my $resp_len=(scalar @resp)-1;
  foreach $str (@val)
  {
    if ($z>0) 
	{
		$a=dec2hex($str&0xFF);
		if ($z<$resp_len)
		{
			print "x\"$a\", ";
		} else
		{
			print "x\"$a\"";
		}
	}
  	$z++;
  }
}


# @values=split('\.',$line);

sub hex2dec
{
 return sprintf("%d",hex($_[0]))."";
}

sub hex2bin
{
 return sprintf("%.4b",hex($_[0]))."";
}
sub dec2hex
{
 return sprintf("%.2X",$_[0])."";
}
