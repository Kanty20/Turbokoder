library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity UART_RX is       -- odbieranie
generic (
g_CLKS_PER_BIT : integer := 1737       --liczba cykli zegara na 1 bit danych
);
Port (CLK       : in std_logic;  
    reset       : in std_logic;      
    i_RX_Byte   : in std_logic_vector(15 downto 0);    -- sygnal wejsciowy  
    i_RX_DV     : in std_logic;         --
    o_RX_Active : out std_logic;        --wskazanie aktywnosci lub gotowosci do transmisji
    o_RX_Serial : out std_logic;        --transmisja danych
    o_RX_Done   : out std_logic         -- wskazuje ze opracja wysylania sie skonczyla
    );
end UART_RX;

architecture Behavioral of UART_RX is
  type STANY_RX is (Idle_RX, RX_Start_Bit, RX_Data_Bits, RX_Stop_Bit, Cleanup_RX);
  signal rx_SM_Main: STANY_RX := Idle_RX;
  
  signal RX_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
  signal RX_Bit_Index : integer range 0 to 15 := 0;  
  signal RX_Data      : std_logic_vector(15 downto 0) := (others => '0');
  signal RX_Done      : std_logic := '0';
  signal o_RX_Shifted : std_logic_vector (15 downto 0) := (others => '0'); -- 2 bitowy do sprawdzenia okresla czy '1' czy 0
  
begin
 
p_UART_RX : process (CLK, reset)
begin
    if reset = '1' then
        rx_SM_Main <= Idle_RX;
        o_RX_Shifted <= (others => '0');
        RX_Done <= '0'; 
        --o_RX_Active <= '0';
        o_RX_Serial <= '1';
        RX_Clk_Count <= 0;
        RX_Bit_Index <= 0;
    end if;
    
    if rising_edge(CLK) then 
      case RX_SM_Main is
        when Idle_RX =>
          o_RX_Active <= '0';
          o_RX_Serial <= '1';         
          RX_Done <= '0';
          RX_Clk_Count <= 0;
          RX_Bit_Index <= 0;
 
          if i_RX_DV = '1' then
            RX_Data <= i_RX_Byte;
            RX_SM_Main <= RX_Start_Bit;
          else
            RX_SM_Main <= Idle_RX;
          end if;
 
        -- Start Bit
        when RX_Start_Bit =>
          o_RX_Active <= '1';
          o_RX_Serial <= '0';
 
          -- czekaj _CLKS_PER_BIT-1 na bit start
          if RX_Clk_Count < g_CLKS_PER_BIT-1 then
            RX_Clk_Count <= RX_Clk_Count + 1;
            RX_SM_Main   <= RX_Start_Bit;
          else
            RX_Clk_Count <= 0;
            RX_SM_Main   <= RX_Data_Bits;
          end if;
 
        -- czekaj g_CLKS_PER_BIT-1 na dane do skonczenia
        when RX_Data_Bits =>
          o_RX_Serial <= RX_Data(RX_Bit_Index);
           
          if RX_Clk_Count < g_CLKS_PER_BIT-1 then
            RX_Clk_Count <= RX_Clk_Count + 1;
            RX_SM_Main   <= RX_Data_Bits;
          else
            RX_Clk_Count <= 0;
             
            -- spr czy odebrano wszystkie bity            
            if RX_Bit_Index < 15 then     --1 bajt
              RX_Bit_Index <= RX_Bit_Index + 1; --zlicza od nowa
              RX_SM_Main   <= RX_Data_Bits;
            else
                    RX_Bit_Index <= 0;
                    RX_SM_Main   <= RX_Stop_Bit;
                    
--            if tx_Bit_Index > 7 then    --2 bajty
--                o_TX_Shifted <= o_TX_Shifted(7 downto 0) & i_TX_Byte;
            end if;
            end if;          
 
        -- Stop bit 
        when RX_Stop_Bit =>
          o_RX_Serial <= '1';
 
          -- czekaj g_CLKS_PER_BIT-1 na Stop bit
          if RX_Clk_Count < g_CLKS_PER_BIT-1 then
            RX_Clk_Count <= RX_Clk_Count + 1;
            RX_SM_Main   <= RX_Stop_Bit;
          else
            RX_Done   <= '1';
            RX_Clk_Count <= 0;
            RX_SM_Main   <= Cleanup_RX;
          end if;
         
        -- czekac na 1 clk
        when Cleanup_RX =>
          o_RX_Active <= '0';
          RX_Done   <= '1';
          RX_SM_Main   <= Idle_RX;
 
        when others =>
          RX_SM_Main <= Idle_RX;
      end case;
    end if;
  end process;
  
  o_RX_Done <= RX_Done;
 
end Behavioral;