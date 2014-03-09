----------------------------------------
-- Function    : Code Gray counter.
-- Coder       : Alex Claros F.
-- Date        : 15/May/2005.
-- Translator  : Alexander H Pham (VHDL)
----------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;
    
entity GrayCounter is
    generic (  
		mode: integer:=0;
        COUNTER_WIDTH :integer := 4
    );
    port (                                  --'Gray' code count output.
        GrayCount_out :out std_logic_vector (COUNTER_WIDTH-1 downto 0);  
        Enable_in     :in  std_logic;       -- Count enable.
        Clear_in      :in  std_logic;       -- Count reset.
        clk           :in  std_logic        -- Input clock
    );
end entity;

architecture rtl of GrayCounter is
	signal BinaryCount :std_logic_vector (COUNTER_WIDTH-1 downto 0):=conv_std_logic_vector(1, COUNTER_WIDTH);
begin
    process (clk) 
	variable vBinaryCount :std_logic_vector (COUNTER_WIDTH-1 downto 0);
	begin
		
        if (rising_edge(clk)) then
            if (Clear_in = '1') then
                --Gray count begins @ '1' with 
				if mode=0 then
					vBinaryCount := conv_std_logic_vector(1, COUNTER_WIDTH);                  
				else
					vBinaryCount := '1'&EXT("0",BinaryCount'Length-1);					
				end if;
				BinaryCount<=vBinaryCount;
                GrayCount_out <= (vBinaryCount(COUNTER_WIDTH-1) & 
                                  (vBinaryCount(COUNTER_WIDTH-2 downto 0) xor 
                                  vBinaryCount(COUNTER_WIDTH-1 downto 1)));
            -- first 'Enable_in'.
            elsif (Enable_in = '1') then
                BinaryCount   <= BinaryCount + 1;
                GrayCount_out <= (BinaryCount(COUNTER_WIDTH-1) & 
                                  (BinaryCount(COUNTER_WIDTH-2 downto 0) xor 
                                  BinaryCount(COUNTER_WIDTH-1 downto 1)));
            end if;
        end if;
    end process;
    
end architecture;
