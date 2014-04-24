library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpu_wrapper is
    Port (clk: in std_logic;
		  reset: in std_logic;
		  oaddr: out std_logic_vector(13 downto 0);
		  odata: out std_logic_vector(15 downto 0);
		  wr : out std_logic;
		  rd : out std_logic;
		  idata : in std_logic_vector(15 downto 0)
	);
end cpu_wrapper;
architecture cpu_wrapper of cpu_wrapper is

COMPONENT cpu
generic (
  CPU_NAME:string:="Global\\cpu_8";
  ADDR_WIDTH:natural:=256;
  DATA_WIDTH:natural:=256;
  TRN_WAIT:std_logic_vector(63 downto 0):=x"0000000000000010";
  WR_WAIT:std_logic_vector(63 downto 0):=x"0000000000000001";
  RD_WAIT:std_logic_vector(63 downto 0):=x"0000000000000001"
);
PORT(
	iclk : IN std_logic;
	irst : IN std_logic;
	idata : IN std_logic_vector(255 downto 0);          
	oaddr : OUT std_logic_vector(255 downto 0);
	odata : OUT std_logic_vector(255 downto 0);
	owr : OUT std_logic;
	ord : OUT std_logic
	);
END COMPONENT;

signal oaddrE,odataE,idataE:std_logic_vector(255 downto 0);

begin

oaddr<=oaddrE(oaddr'Length-1 downto 0);
odata<=odataE(odata'Length-1 downto 0);
idataE<=EXT(idata,idataE'Length);

cpu_inst: cpu 
generic map(
  CPU_NAME=>"Global\cpu_8",
  ADDR_WIDTH=>256,
  DATA_WIDTH=>256,
  TRN_WAIT=>x"0000000000000010",
  WR_WAIT=>x"0000000000000002",
  RD_WAIT=>x"0000000000000002"
)
port map(
	iclk => CLK,
	irst => reset,
	oaddr => oaddrE,
	odata => odataE,
	owr => wr,
	idata => idataE,
	ord => rd
);


end cpu_wrapper;

