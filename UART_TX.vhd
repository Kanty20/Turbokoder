library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity UART_TX is
  generic (
    g_CLKS_PER_BIT : integer := 1737     --  CLK/ baudrate = 200MHz/115200 = 1736,11
    );
  port (
    CLK         : in std_logic;  
    reset       : in std_logic := '0';      --SW8.3  CPU_RESET
    i_TX_Byte   : in std_logic_vector(15 downto 0);-- := (others => '0');    -- sygnal wejsciowy  
    i_TX_DV     : in std_logic;         --
    o_TX_Active : out std_logic;        --wskazanie aktywnosci lub gotowosci do transmisji
    o_TX_Serial : out std_logic;        --transmisja danych
    o_TX_Done   : out std_logic         -- wskazuje ze opracja wysylania sie skonczyla
    );
end UART_TX;
 
architecture Behavioral of UART_TX is
  
  type t_SM_Main is (Idle, TX_Start_Bit, TX_Data_Bits, TX_Stop_Bit, Cleanup);
  signal tx_SM_Main : t_SM_Main := Idle;
 
  signal tx_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
  signal tx_Bit_Index : integer range 0 to 15 := 0;  
  signal TX_Data      : std_logic_vector(15 downto 0) := (others => '0');
  signal TX_Done      : std_logic := '0';
  
begin
   
  p_UART_TX : process (CLK)   --logika przejsc miedzy stanami
  begin
--    if reset = '1' then
--        tx_SM_Main <= Idle;
--        o_TX_Shifted <= (others => '0');
--        TX_Done <= '0'; --nowo dodane
--        o_TX_Active <= '0';
--        o_TX_Serial <= '1';
--        tx_Clk_Count <= 0;
--        tx_Bit_Index <= 0;
--    end if;
    
    if rising_edge(CLK) then 
      case tx_SM_Main is
        when Idle =>
          o_TX_Active <= '0';
          o_TX_Serial <= '1';         
          TX_Done   <= '0';
          tx_Clk_Count <= 0;
          tx_Bit_Index <= 0;
 
          if i_TX_DV = '1' then
            TX_Data <= i_TX_Byte;
            tx_SM_Main <= TX_Start_Bit;
          else
            tx_SM_Main <= Idle;
          end if;
 
        -- Start Bit
        when TX_Start_Bit =>
          o_TX_Active <= '1';
          o_TX_Serial <= '0';
 
          -- czekaj _CLKS_PER_BIT-1 na bit start
          if tx_Clk_Count < g_CLKS_PER_BIT-1 then
            tx_Clk_Count <= tx_Clk_Count + 1;
            tx_SM_Main   <= TX_Start_Bit;
          else
            tx_Clk_Count <= 0;
            tx_SM_Main   <= TX_Data_Bits;
          end if;
 
        -- czekaj g_CLKS_PER_BIT-1 na dane do skonczenia
        when TX_Data_Bits =>
          o_TX_Serial <= TX_Data(tx_Bit_Index);
           
          if tx_Clk_Count < g_CLKS_PER_BIT-1 then
            tx_Clk_Count <= tx_Clk_Count + 1;
            tx_SM_Main   <= TX_Data_Bits;
          else
            tx_Clk_Count <= 0;
             
            -- spr czy wyslano wszystkie bity
            --czy to tez bedzie dzialac jak bedzie wiecej niz 16 bitow?
            
            if tx_Bit_Index < 15 then     --1 bajt
              tx_Bit_Index <= tx_Bit_Index + 1; --zlicza od nowa
              tx_SM_Main   <= TX_Data_Bits;
            else
                    tx_Bit_Index <= 0;
                    tx_SM_Main   <= TX_Stop_Bit;
     
            end if;
            end if;          
 
        -- Stop bit 
        when TX_Stop_Bit =>
          o_TX_Serial <= '1';
 
          -- czekaj g_CLKS_PER_BIT-1 na Stop bit
          if tx_Clk_Count < g_CLKS_PER_BIT-1 then
            tx_Clk_Count <= tx_Clk_Count + 1;
            tx_SM_Main   <= TX_Stop_Bit;
          else
            TX_Done   <= '1';
            tx_Clk_Count <= 0;
            tx_SM_Main   <= Cleanup;
          end if;
         
        -- czekac na 1 clk
        when Cleanup =>
          o_TX_Active <= '0';
          TX_Done   <= '1';
          tx_SM_Main   <= Idle;
 
        when others =>
          tx_SM_Main <= Idle;
      end case;
    end if;
  end process p_UART_TX;
  
  o_TX_Done <= TX_Done;
   
end Behavioral;