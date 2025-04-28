-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Radim Pokorný (xpokorr00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
  port (
    CLK      : in std_logic;
    RST      : in std_logic;
    DIN      : in std_logic;
    DOUT     : out std_logic_vector(7 downto 0);
    DOUT_VLD : out std_logic
  );
end entity;

-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
  signal cnt        : std_logic_vector(4 downto 0) := "00001";
  signal COUNT_EN   : std_logic                    := '0';
  signal cnt2       : std_logic_vector(3 downto 0) := "0000";
  signal data_en    : std_logic                    := '0';
  signal data_valid : std_logic                    := '0';

begin
  fsm : entity work.UART_RX_FSM
    port map
    (
      CLK        => CLK,
      RST        => RST,
      DIN        => DIN,
      CNT        => cnt,
      COUNT_EN   => COUNT_EN,
      CNT2       => cnt2,
      DATA_EN    => data_en,
      DATA_VALID => data_valid
    );
  process (CLK) begin
    if RST = '1' then
      DOUT_VLD <= '0';
      cnt      <= "00001";
      cnt2     <= "0000";
      DOUT     <= (others => '0');
    elsif rising_edge(CLK) then
      if COUNT_EN = '0' then
        cnt <= "00001";
      else
        cnt <= cnt + 1;
      end if;
      DOUT_VLD <= '0';
      if cnt2 = "1000" and data_valid = '1' then
        DOUT_VLD <= '1';
        cnt2     <= "0000";
      end if;
      if data_en = '1' then
        if cnt >= "10000" then
          cnt <= "00001";
          case cnt2 is
            when "0000" =>
              DOUT(0) <= DIN;
              cnt2    <= "0001";
            when "0001" =>
              DOUT(1) <= DIN;
              cnt2    <= "0010";
            when "0010" =>
              DOUT(2) <= DIN;
              cnt2    <= "0011";
            when "0011" =>
              DOUT(3) <= DIN;
              cnt2    <= "0100";
            when "0100" =>
              DOUT(4) <= DIN;
              cnt2    <= "0101";
            when "0101" =>
              DOUT(5) <= DIN;
              cnt2    <= "0110";
            when "0110" =>
              DOUT(6) <= DIN;
              cnt2    <= "0111";
            when "0111" =>
              DOUT(7) <= DIN;
              cnt2    <= "1000";
            when others => null;
          end case;
        end if;
      end if;
    end if;
  end process;
end architecture;