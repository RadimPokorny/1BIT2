-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Radim Pokorný (xpokorr00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;                        -- signal clock
        RST      : in std_logic;                        -- reset clock
        DIN      : in std_logic;                        -- input bit
        DOUT     : out std_logic_vector(7 downto 0);    -- output (8 bits)
        DOUT_VLD : out std_logic                        -- data validation
    );
end entity;

-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
    signal cnt   : std_logic_vector(4 downto 0) := "00001";   
    signal cen  : std_logic := '0';                          
    signal cnt2  : std_logic_vector(3 downto 0) := "0000";   
    signal den  : std_logic := '0';                          
    signal dval : std_logic := '0';                         

begin
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        DIN => DIN,
        CNT => cnt,
        CEN => cen,
        CNT2 => cnt2,
        DEN => den,
        DVAL => dval
    );

    process (CLK) begin
        if RST = '1' then
            DOUT_VLD <= '0';          
            DOUT <= (others => '0');  
            cnt <= "00001"; 
            cnt2 <= "0000";        
        elsif rising_edge(CLK) then

            if cen = '0' then 
                cnt <= "00001";
            else 
                cnt <= cnt + 1;
            end if;

            DOUT_VLD <= '0';

            if cnt2 = "1000" then
                if dval = '1' then
                    cnt2 <= "0000";
                    DOUT_VLD <= '1'; 
                end if;
            end if;

            if den = '1' then 
                if cnt >= "10000" then 
                    cnt <= "00001"; 

                    -- LOAD BITS
                    case cnt2 is
                        when "0000" => 
                            DOUT(0) <= DIN;
                            cnt2 <= "0001";
                        when "0001" => 
                            DOUT(1) <= DIN; 
                            cnt2 <= "0010"; 
                        when "0010" => 
                            DOUT(2) <= DIN; 
                            cnt2 <= "0011";
                        when "0011" => 
                            DOUT(3) <= DIN;
                            cnt2 <= "0100";
                        when "0100" => 
                            DOUT(4) <= DIN;  
                            cnt2 <= "0101";
                        when "0101" => 
                            DOUT(5) <= DIN; 
                            cnt2 <= "0110"; 
                        when "0110" => 
                            DOUT(6) <= DIN;  
                            cnt2 <= "0111"; 
                        when "0111" => 
                            DOUT(7) <= DIN;   
                            cnt2 <= "1000"; 
                        when others => null;   
                    end case;

                end if;
            end if;
        end if;
    end process; 
end architecture;
