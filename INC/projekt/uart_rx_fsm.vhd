-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s):Radim Pokorný (xpokorr00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART_RX_FSM is
    port(
        CLK   : in std_logic;                     
        RST   : in std_logic;                    
        DIN   : in std_logic;                    
        CEN   : out std_logic;                   
        CNT   : in std_logic_vector(4 downto 0);  
        CNT2  : in std_logic_vector(3 downto 0); 
        DEN   : out std_logic;   
        DVAL  : out std_logic                                  
    );
end entity;

architecture behavioral of UART_RX_FSM is
    type fsm_states is (NEN, FIRST_W8, RCV, STOP_W8, DVLD);  
    signal crstate : fsm_states := NEN;  
begin
    CEN <= '0' when crstate = NEN or crstate = DVLD else '1'; 
    DVAL <= '1' when crstate = DVLD else '0'; 
    DEN <= '1' when crstate = RCV else '0'; 
    process(CLK) begin
        if RST = '1' then
            crstate <= NEN; 
        elsif rising_edge(CLK) then
            case crstate is
                when NEN => 
                    if DIN = '0' then 
                        crstate <= FIRST_W8; 
                    end if;
                when FIRST_W8 =>
                    if CNT= "10111" then 
                        crstate <= RCV; 
                    end if;
                when RCV =>
                    if CNT2 = "1000" then
                        crstate <= STOP_W8; 
                    end if;
                when STOP_W8 =>
                    if DIN = '1' then 
                        if CNT= "01111" then 
                            crstate <= DVLD;
                        end if;
                    end if;
                when DVLD =>
                    crstate <= NEN; 
                when others => null; 
            end case;
        end if;
    end process;
end architecture;
