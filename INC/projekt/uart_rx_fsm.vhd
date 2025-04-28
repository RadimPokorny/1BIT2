-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s):Radim Pokorný (xpokorr00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART_RX_FSM is
  port (
    CLK        : in std_logic;
    RST        : in std_logic;
    DIN        : in std_logic;
    COUNT_EN   : out std_logic;
    CNT        : in std_logic_vector(4 downto 0);
    CNT2       : in std_logic_vector(3 downto 0);
    DATA_EN    : out std_logic;
    DATA_VALID : out std_logic
  );
end entity;

architecture behavioral of UART_RX_FSM is
  type fsm_states is (RECEIVE_DATA, FIRST_WAIT_BIT, NOT_ENABLED, STOP_WAIT_BIT, DATA_VLD);
  signal state : fsm_states := NOT_ENABLED;
begin
  COUNT_EN <= '0' when state = NOT_ENABLED or state = DATA_VLD else
    '1';
  DATA_VALID <= '1' when state = DATA_VLD else
    '0';
  DATA_EN <= '1' when state = RECEIVE_DATA else
    '0';
  process (CLK) begin
    if RST = '1' then
      state <= NOT_ENABLED;
    elsif rising_edge(CLK) then
      case state is
        when DATA_VLD =>
          state <= NOT_ENABLED;
        when NOT_ENABLED =>
          if DIN = '0' then
            state <= FIRST_WAIT_BIT;
          end if;
        when RECEIVE_DATA =>
          if CNT2 = "1000" then
            state <= STOP_WAIT_BIT;
          end if;
        when STOP_WAIT_BIT =>
          if DIN = '1' then
            if CNT = "01111" then
              state <= DATA_VLD;
            end if;
          end if;
        when FIRST_WAIT_BIT =>
          if CNT = "10111" then
            state <= RECEIVE_DATA;
          end if;
        when others => null;
      end case;
    end if;
  end process;
end architecture;