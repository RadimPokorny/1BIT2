-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s):Radim Pokorný (xpokorr00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART_RX_FSM is
    port(
       CLK   : in std_logic;                     -- signal clock
       RST   : in std_logic;                     -- reset clock
       DIN   : in std_logic;                     -- input bit
       CNT    : in std_logic_vector(4 downto 0);  -- clock cycle counter (0 - 24)
       CEN   : out std_logic;                    -- check if 'clock cycle counter' is active (if we are at WAIT_FOR_RIST_BIT or RCV state)
       CNT2   : in std_logic_vector(3 downto 0);  -- bit counter (reading 8 bits in total)
       DEN   : out std_logic;                    -- check if 'reading data' is active (if we are at RCV state)  
       DVAL  : out std_logic                     -- check if 'validating data' is active (if we are at DVLD state)
    );
end entity;

architecture behavioral of UART_RX_FSM is
    type fsm_states is (NEN, FIRST_W8, RCV, STOP_W8, DVLD);  -- define all the FSM states
    signal current_state : fsm_states := NEN;  -- set current_state to NEN ('default' state)

begin

    -- ACTIVATING PORTS
    CEN <= '0' when current_state = NEN or current_state = DVLD else '1'; -- counting clock cycles only in FIRST_W8, RCV and STOP_W8 states
    DVAL <= '1' when current_state = DVLD else '0'; -- becomes 1 when we start validating data (after we recieve 'stop-bit')
    DEN <= '1' when current_state = RCV else '0'; -- becomes 1 when we start reading bits (after we recieve 'first-bit')

    -- PROCESS
    process(CLK) begin

        -- RESET
        if RST = '1' then
            current_state <= NEN; -- reset to 'default' state
            
        -- RISING EDGE
        elsif rising_edge(CLK) then

            -- HANDLE STATES
            case current_state is
                when NEN => 
                    if DIN = '0' then -- 0 is a start bit
                        current_state <= FIRST_W8; -- change to next state
                    end if;
                when FIRST_W8 =>
                    if CNT= "10111" then -- wait 23 clock cycles (to sample mid-bit)
                        current_state <= RCV; -- change to next state
                    end if;
                when RCV =>
                    if CNT2 = "1000" then -- read 8 bits of data
                        current_state <= STOP_W8; -- change to next state 
                    end if;
                when STOP_W8 =>
                    if DIN = '1' then -- 1 is a stop bit
                        if CNT= "01111" then -- validate data mid-stopbit
                            current_state <= DVLD; -- change to next state
                        end if;
                    end if;
                when DVLD =>
                    current_state <= NEN; -- go back to 'default' state
                when others => null; -- invalid option (should not happen)
            end case;

        end if;
    end process;
end architecture;
