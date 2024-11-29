library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
 
entity uart_tb is
end uart_tb;
 
architecture Behavioral of uart_tb is

component central is
Port (
      CLK_n   : in std_logic; 
      CLK_p   : in std_logic;
      RST     : in std_logic; 
      TX      : out std_logic_vector;
      RX      : in std_logic_vector;
      GPIO    : in std_logic
      );
end component;
 
  component UART_TX is
    generic (
      g_CLKS_PER_BIT : integer := 1737
      );
    port (
      CLK         : in std_logic;     
      reset       : in std_logic;
      i_tx_byte   : in std_logic_vector(15 downto 0);
      i_tx_dv     : in std_logic;
      o_tx_active : out std_logic;
      o_tx_serial : out std_logic;
      o_tx_done   : out std_logic
      );
  end component;
 
  component UART_RX is
    generic (
      g_CLKS_PER_BIT : integer := 1737   
      );
    port (
      CLK         : in std_logic;     
      reset       : in std_logic;
      i_RX_Byte   : in std_logic_vector(15 downto 0);    -- sygnal wejsciowy  
      i_RX_dv     : in std_logic;
      o_RX_active : out std_logic;
      o_RX_serial : out std_logic;
      o_RX_done   : out std_logic
      );
  end component;
  
  component filtr
    port (CLK : in std_logic;
      Switch : in std_logic;
      odfiltrowany_przycisk: out std_logic
    );
    end component;
    
    component koder
    port (CLK : in std_logic;
    start_bit : in std_logic_vector(15 downto 0);
    final_bit : out std_logic_vector(63 downto 0);   
    put : in std_logic;
    reset : in std_logic
    );
    end component;
    
    component dekoder
    port (CLK : in std_logic;
    start_bit_d : in std_logic_vector(15 downto 0);
    final_bit_d : out std_logic_vector(15 downto 0);   
    rx_dv       : in std_logic;
    reset       : in std_logic
    );
    end component;
    
    component dekoder2
    port (CLK : in std_logic;
    start_bit_d : in std_logic_vector(63 downto 0);
    final_bit_d : out std_logic_vector(15 downto 0);   
    rx_dv       : in std_logic;
    reset       : in std_logic
    );
    end component;
 
  constant c_CLKS_PER_BIT : integer := 1737;
  constant c_BIT_PERIOD : time := 8680 ns;
  constant c_add_CLK      : integer := 1737;
   
  signal CLK_p       : std_logic;
  signal CLK_n       : std_logic;
  signal locked      : std_logic := '0';       --do resetu, locked znajduje sie w componencie zegara
  signal RST         : std_logic;
  signal RX          : std_logic_vector(15 downto 0) := (others => '0');
  signal TX          : std_logic_vector(15 downto 0) := (others => '0');
  signal GPIO        : std_logic := '0';
  signal r_TX_DV     : std_logic := '0';
  signal r_TX_BYTE   : std_logic_vector(15 downto 0) := (others => '0');
  signal r_TX_BYTE2   : std_logic_vector(15 downto 0) := (others => '0');
  signal ACTIVE_TX : std_logic := '1';
  signal SERIAL_TX : std_logic := '0';
  signal DONE_TX       : std_logic := '0';
--  signal w_RX_DV     : std_logic := '0';

  signal r_RX_DV     : std_logic := '0';
  signal r_RX_BYTE   : std_logic_vector(15 downto 0) := (others => '0');
  signal o_RX_BYTE   : std_logic_vector(15 downto 0) := (others => '0');
  signal SERIAL_RX   : std_logic := '0';
  signal ACTIVE_RX   : std_logic := '1';
  signal DONE_RX     : std_logic := '0';

  signal w_RX_BYTE   : std_logic_vector(15 downto 0) := (others => '0');
  signal r_RX_SERIAL : std_logic := '1';
  signal RX_bufor    : std_logic_vector(15 downto 0);-- := (others => '0');
  signal i_RX_Serial : std_logic := '0';
  signal RX_Byte     : std_logic_vector(15 downto 0) := (others => '0');     --wczesniej nie bylo wartosci
  signal r_RX_ACTIVE : std_logic := '1';

  constant TbPeriod : time := 5 ns;
  signal TbSimEnded : std_logic := '0';  
  
  signal FINAL_BIT_TO_TX : std_logic_vector(15 downto 0);-- := (others => '0');
  
  signal start_bit_d : std_logic_vector(15 downto 0);
  signal final_bit_d : std_logic_vector(15 downto 0);
  
  signal final_bit_to_tx_64 : std_logic_vector(63 downto 0);
  
--   Low-level byte-write
--  procedure UART_WRITE_BYTE (
--    i_data_in       : in  std_logic_vector(7 downto 0);
--    signal o_serial : out std_logic) is
--  begin
 
--    -- Send Start Bit
--    o_serial <= '0';
--    wait for c_BIT_PERIOD;
 
--    -- Send Data Byte
--    for ii in 0 to 7 loop
--      o_serial <= i_data_in(ii);
--      wait for c_BIT_PERIOD;
--    end loop;  -- ii
 
--    -- Send Stop Bit
--    o_serial <= '1';
--    wait for c_BIT_PERIOD;
--    end UART_WRITE_BYTE;
 
begin

mainn  : central
port map (CLK_n   => CLK_n, 
      CLK_p   => CLK_p,
      RST     => RST,
      TX      => TX,
      RX      => RX,
      GPIO    => GPIO
);

UART_TX_INST : UART_TX 
  generic map (
    g_CLKS_PER_BIT => c_CLKS_PER_BIT
      )
    port map (
      CLK         => CLK_p,
      reset       => RST,
      i_tx_dv     => r_TX_DV,
      i_tx_byte   => r_TX_BYTE,
      o_tx_active => ACTIVE_TX,
      o_tx_serial => SERIAL_TX,
      o_tx_done   => DONE_TX
      );
 
-- locked_n <= not locked;
 
  UART_RX_INST : UART_RX
    generic map (
      g_CLKS_PER_BIT => c_CLKS_PER_BIT
      )
    port map (
      CLK         => CLK_p,
      reset       => RST,
      i_RX_dv     => r_RX_DV,
      i_RX_byte   => r_RX_BYTE,
      o_RX_active => ACTIVE_RX,
      o_RX_serial => SERIAL_RX,
      o_RX_done   => DONE_RX
      );
      
  kodowanie : koder
      port map (
      CLK       => CLK_p,
      start_bit => r_TX_BYTE2,       --sprawdzic pozniej czy to na pewno dobrze
      final_bit => final_bit_to_tx_64,
      put       => GPIO,
      reset     => RST
      );
      
  dekodowanie : dekoder
    port map (
    CLK         => CLK_p,
    start_bit_d => FINAL_BIT_TO_TX, -- do sprawdzenia 
    final_bit_d => r_TX_BYTE2,
    rx_dv       => r_RX_DV,
    reset       => RST
    );

  dekodowanie2 : dekoder2
    port map(
    CLK         => CLK_p,
    start_bit_d => final_bit_to_tx_64, -- do sprawdzenia 
    final_bit_d => r_TX_BYTE2,
    rx_dv       => r_RX_DV,
    reset       => RST
    );
    
CLK_generation : process
        begin
            CLK_p <= '0';
            wait for TbPeriod/2;
            CLK_p <= '1';
            wait for TbPeriod/2;
    end process;
   
    CLK_n <= not CLK_p;      
    
    stimuli : process
    begin
        RST <= '1';
        wait for 100 ns;
        RST <= '0';
        wait for 100 ns;    
        wait for 100 * TbPeriod;
        TbSimEnded <= '1';
        wait;
    end process;    
    
    r_TX_BYTE <= r_TX_BYTE2;
    TX <=FINAL_BIT_TO_TX;
       
    ----do sprawdzenia uarta
    process is 
        begin
--        -- do dzialania TX
       r_TX_DV   <= '1';   --musi byc do TX
--        r_TX_BYTE <= X"66";
--       wait for 88ns;
--       r_TX_DV <= '0';
--       wait for 88 ns;
        
        -- do sprawdzenia RX
----        r_RX_DV   <= '1';
------        r_RX_BYTE <= X"AB";
------        wait for 20ns;
------        r_RX_BYTE <= X"12";
------        wait for 20ns;
------        r_RX_BYTE <= X"34";
------        wait for 20ns;
--        r_RX_DV <= '1';     -- musi byc do RX
--        WAIT FOR 50 NS;
--        RX <= x"5454";      --do sprawdzenia RX 
--        wait for 100ns;
--        RX <= X"5555";
--        wait for 100ns;
----        RX <= X"33";
----        wait for 88ns;
----        RX <= X"44";
----        wait for 88ns;
        
        -- do sprawdzenia przyscisku
        GPIO <= '0';
        wait for 300ns;
        GPIO <= '1';
        wait for 100ns;
--        GPIO <= '0';
--        wait for 200ns;
        
--        GPIO <= '1';
--        wait for 30 ns;
--        GPIO <= '0'; 
--        wait for 200 ns;
        
        -- do sprawdzenia dekodera
        r_RX_DV <= '0';
        wait for 25 ns;
        r_RX_DV <= '1';
        wait;
        
    end process;

end Behavioral;