library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

entity central is
Port (CLK_n   : in std_logic; 
      CLK_p   : in std_logic;
      RST     : in std_logic;   
      TX      : out std_logic_vector(15 downto 0);   --wczesniej tu gdzie 7 bylo wszyedzie 15
      RX      : in std_logic_vector(15 downto 0);
      GPIO    : in std_logic
      ); 
end central;

architecture Behavioral of central is
signal locked       : std_logic := '0';       --do resetu, locked znajduje sie w componencie zegara
signal RST_N        : std_logic;              
signal sys_clock    : std_logic;

signal c_TX_Byte    : std_logic_vector(15 downto 0);-- := (others => '0');      --bylo 15 downto
signal c_TX_DV      : std_logic := '0';
signal ACTIVE_TX    : std_logic;
signal SERIAL_TX    : std_logic;
signal DONE_TX      : std_logic;

signal c_RX_Byte    : std_logic_vector(15 downto 0) := (others => '0');
signal c_RX_DV      : std_logic := '0';
signal ACTIVE_RX    : std_logic := '0';
signal SERIAL_RX    : std_logic := '0';
signal DONE_RX      : std_logic;

signal TX_bufor     : std_logic_vector(15 downto 0);-- := (others => '0');--character range 48 to 57 := 48;
--signal RX_bufor     : std_logic_vector(7 downto 0) := (others => '0'); --narzaie 2 bajty
signal crk          : std_logic := '1';     --zeby skleic 16 bitow tx
signal n_TX_DV      : std_logic; --podroby c_TX_DV bo nie moge przypisac w dwoch procesach tego samego sygnalu 
signal n_RX_DV      : std_logic;
signal TX_signal    : std_logic_vector(15 downto 0) := (others => '0');

signal SW_0 : std_logic := '0';     --sygnaly odpowiadaj¹ce za przejscie
signal SW_1 : std_logic := '0';
signal WSW0 : std_logic := '0';
signal WSW1 : std_logic := '0';

type przejscia is (S0, S1, S2, S3); --do nadawania bitow
signal stateT, nstateT : przejscia := S0;
type skoki is (R0, R1, R2, R3);
signal stateR, nstateR : skoki := R0;

-- sygnaly do wysylania danych do pliku
constant  clock_period        : time        := 10 ns;
signal    loop_enable         : boolean     := true;
signal    bit_input_s         : bit;    --przechowuje pojedynczy bit danych
signal    bit_vector_input_s  : bit_vector(15 downto 0);   --przechowuje wielobitowe dane
signal    boolean_input_s     : boolean;    --przechowuje wartosc logiczna, uzywanado stanow binarnych
signal    char_input_s        : character;  --przechowuje pojednyczy znak, moze bedzie do obrobki tekstowej lub interfejsu uzytkownika
signal    int_input_s         : integer;    --przechowuje wartosc calkowita
signal    real_input_s        : real;   -- wartosc rzeczywista
signal    str_input_s         : string(15 downto 1);   --do wyswietlenia tekstu
signal    time_input_rx       : time        := 500ns;
signal    time_input_tx       : time        := 500ns;
signal    std_logic_input_s   : std_logic   := '0'; --przechowuje wartosc logiczna jako std
signal    std_ulogic_input_s  : std_ulogic  := '0';

-- do kodera
--signal ex_TX_Byte             : std_logic_vector(15 downto 0);-- := (others => '0');
signal FINAL_BIT_TO_TX         : std_logic_vector(15 downto 0);

-- do dekodera
signal final_bit_to_tx_64      : std_logic_vector(63 downto 0);

component clk_wiz_0 is        --zegar sys_clk
Port(
  clk_out1: out std_logic;
  reset: in std_logic;
  locked : out std_logic;
  clk_in1_p : in std_logic;
  clk_in1_n : in std_logic
 );
end component;

component UART_TX is    --wysyla
Port (CLK       : in std_logic;  
    reset       : in std_logic;
    i_TX_Byte   : in std_logic_vector(15 downto 0);    -- sygnal wejsciowy  
    i_TX_DV     : in std_logic;         --start wysylania bitow
    o_TX_Active : out std_logic;        --wskazanie aktywnosci lub gotowosci do transmisji
    o_TX_Serial : out std_logic;        --transmisja danych
    o_TX_Done   : out std_logic         -- wskazuje ze opracja wysylania sie skonczyla
);
end component;

component UART_RX is    -- odbiera 
Port (CLK       : in std_logic;  
    reset       : in std_logic;
    i_RX_Byte   : in std_logic_vector(15 downto 0);   
    i_RX_DV     : in std_logic;         --start wysylania bitow
    o_RX_Active : out std_logic;        --wskazanie aktywnosci lub gotowosci do transmisji
    o_RX_Serial : out std_logic;        --transmisja danych
    o_RX_Done   : out std_logic         -- wskazuje ze opracja wysylania sie skonczyla
    );
end component;

component filtr is  
Port (
      CLK : in std_logic;
      Switch : in std_logic;
      odfiltrowany_przycisk0: out std_logic;
      odfiltrowany_przycisk1 : out std_logic
      );
end component;

component koder is
Port (
    CLK : in std_logic;
    start_bit : in std_logic_vector(15 downto 0);
    final_bit : out std_logic_vector(63 downto 0);   --pozniej zmienic na 64
    put       : in std_logic;
    reset     : in std_logic
);
end component;

component dekoder is
Port (
    CLK         : in std_logic;
    start_bit_d : in std_logic_vector(15 downto 0);
    final_bit_d : out std_logic_vector(15 downto 0);
    rx_dv       : in std_logic;
    reset       : in std_logic
);
end component;

component dekoder2 is
Port (
    CLK         : in std_logic;
    start_bit_d : in std_logic_vector(63 downto 0);
    final_bit_d : out std_logic_vector(15 downto 0);    --trzeba bedzie tu zmienic wartosc
    rx_dv       : in std_logic;
    reset       : in std_logic
);
end component;
 
begin

CLK0: clk_wiz_0
Port map(
  clk_out1 => sys_clock,
  reset => RST,
  locked => locked,     
  clk_in1_p => CLK_p,
  clk_in1_n => CLK_n
 );
 
 --locked_n <= not locked; --DS
 
UARTowanieTX: UART_TX
Port map (
    CLK => sys_clock,
    reset => RST,
    --reset => locked_n,--ds 
    i_TX_Byte => c_TX_Byte,
    i_TX_DV => c_TX_DV,
    o_TX_Active => ACTIVE_TX,
    o_TX_Serial => SERIAL_TX,
    o_TX_Done => DONE_TX --=> c_TX_Done
); 

UARTownie_RX: UART_RX
Port map (CLK => sys_clock,
    reset => RST,--ds, locked_N
    i_RX_Byte => c_RX_Byte,
    i_RX_DV => c_RX_DV,
    o_RX_Active => ACTIVE_RX,
    o_RX_Serial => SERIAL_RX,
    o_RX_Done => DONE_RX
);

filtrowanie: filtr    
Port map(
    CLK => sys_clock,
    Switch => GPIO,
    odfiltrowany_przycisk0 => SW_0,
    odfiltrowany_przycisk1 => SW_1
);

kodowanie: koder
Port map(
    CLK => sys_clock,
    start_bit => c_TX_Byte,--ex_TX_Byte,
    final_bit => final_bit_to_tx_64,
    put => GPIO,
    reset => RST
);

dekodowanie: dekoder
Port map(
    CLK => sys_clock,
    start_bit_d => FINAL_BIT_TO_TX,     --trzeba bedzie odpowiednio podlaczyc
    final_bit_d => c_TX_Byte,           -- trzeba bedzie odpowiednio podlaczyc
    rx_dv => c_RX_DV,
    reset => RST
);

dekodowanie2: dekoder2
Port map(
    CLK => sys_clock,
    start_bit_d => final_bit_to_tx_64,     --trzeba bedzie odpowiednio podlaczyc
    final_bit_d => c_TX_Byte,           -- trzeba bedzie odpowiednio podlaczyc
    rx_dv => c_RX_DV,
    reset => RST
);

reset_down : process (RST_N, sys_clock) --gdy stan nieustalony (na samym poczatku programu)
begin
    if falling_edge(sys_clock) then
        if locked = '0' then
            RST_N <= '1'; 
        elsif locked = '1' then
            RST_N <= '0';
        end if;
     end if;
end process;

--RST_N <= RST;

state_machine: process (RST, RST_N, sys_clock, SW_0, SW_1)     --mechanika nacisniecia przycisku,  RST_N,
begin
     
     if RST = '1' or RST_N = '1' then       --gdy zwykly lub wczesniejszy reset
        stateT <= S0;      
     elsif rising_edge(sys_clock) then
        if (SW_0 = '1' and SW_1 = '0') then     --odfiltrowane przyciski tworza zale¿noœæ i od nich zalezy jaki stan wejdzie
            WSW0 <= '1';      
            WSW1 <= '0';
        elsif (SW_0 = '0' and SW_1 = '1') then
            WSW1 <= '1';
            WSW0 <= '0';
        end if;
        if (WSW1 = '1' xor WSW0 = '1') then    --gdy któryœ z tych sygna³ów bêdzie '1'                                      
            stateT <= nstateT;    --nastepny stan            
        end if;
        end if;
end process;

p1: process(sys_clock, WSW1, WSW0, stateT)     --implementacja dwuprocesowa
begin        
     case stateT is       
        when S0 =>  
        if WSW1 = '1' then      --editt c_TX_Done, U¯YC JAK BEDZIE DZIALAC => and c_TX_Done = '1'
            nstateT <= S1;
        elsif WSW1 /= '1' then            
            nstateT <= S0;
        end if;

        when S1 =>      
        if WSW0 = '1' then
            nstateT <= S2;
        elsif WSW0 /= '1' then
            nstateT <= S1;
        end if;
           
        when S2 =>                
        if WSW1 = '1' then      
            nstateT <= S3;
        elsif WSW1 /= '1' then
            nstateT <= S2;
        end if;

       when S3 =>      
       if WSW0 = '1' then
            nstateT <= S0;
        elsif WSW0 /= '1' then
            nstateT <= S3;
            end if;
            
        when others =>
            nstateT <= S0;
    end case;
end process;

przejscia_uarta_TX: process(sys_clock)
begin
    if rising_edge(sys_clock) then
        case stateT is
        when S0 => 
            crk <= '1'; -- crk jest wykorzystywany do zapisywania do pliku 
            TX_bufor <= x"0000"; 
            c_TX_Byte <= TX_bufor;      
            c_TX_DV <= '1';
--               
                   
            when S1 =>     -- GPIO = '1'
                crk <= '0'; 
                TX_bufor <= x"eaea"; 
                c_TX_Byte <= TX_bufor;      
                c_TX_DV <= '1';
--                    
             
             when S2 =>     
                crk <= '1'; 
                TX_bufor <= x"0000"; 
                c_TX_Byte <= TX_bufor;                
                 c_TX_DV <= '1';
        
            when S3 =>      --GPIO = '1'
                crk <= '0'; -- crk jest wykorzystywany do zapisywania do pliku 
                TX_bufor <= x"bbbb"; 
                c_TX_Byte <= TX_bufor;      
                c_TX_DV <= '1'; --wczesniej wszystkie c_TX_DV byly zakomentowane              
            
end case;
end if;
end process;

--przejscia_uarta_RX: process(sys_clock, RST, locked)
--begin

----    if RST = '1' or locked = '0' then
----        nstateR <= R0;
----        --RX_bufor <= x"00";
        
--    if rising_edge(sys_clock) then
--        case stateR is
--        when R0 => 
--            if ACTIVE_RX = '0' then
--            --if (SERIAL_RX = '1' and ACTIVE_RX = '0') then --done = 0 
--                c_RX_Byte <= RX; 
--                --RX_bufor <= RX;
--                --c_RX_Byte <= RX_bufor;     
--                c_RX_DV <= '1';
--                nstateR <= R1;
--            else
--            --elsif (SERIAL_RX = '0' and ACTIVE_RX = '1') then 
--                nstateR <= R0;
--            end if;
            
----            when R1 =>      
----                if DONE_RX = '1' then
----                   nstateR <= R2;
----                   --c_RX_DV <= '1';
----                else 
----                   nstateR <= R1;
----               end if;
                   
--            when R1 =>     
--                --if ACTIVE_RX = '0' then
--                if (ACTIVE_RX = '0' and DONE_RX = '1') then --najlepsze rozwiazanie 
--                    c_RX_Byte <= RX; 
--                    --RX_bufor <= RX; 
--                    --c_RX_Byte <= RX_bufor;      
--                    c_RX_DV <= '1';
--                    nstateR <= R0;
--                else 
--                    nstateR <= R1;
--                end if;
        
--            when R3 =>      
--                if DONE_RX = '1' then
--                   nstateR <= R0;
--                   c_RX_DV <= '0';  --¿eby zostawic 'puste' zeby w razie czego mogl wskoczyc tx (wczesniej = '1');
--                else 
--                   nstateR <= R3;
--                   end if;        
           
--        when others =>
--            nstateR <= R0; 
--    end case;
--end if;
--end process;

c_RX_Byte <= RX; 

----do wysylania i odbierania uarta
----     trzeba poprawic tx, bo cos srednio chce dzialac
--kto_kiedy_co: process(sys_clock, GPIO, c_TX_Byte, c_RX_Byte) --w przypadku gdy chce skorzystac jednego portu w roznych miejscach
--begin
--    if WSW1 = '1' then  --WCZESNIEJ WSW1
--        TX <= c_TX_Byte;
--    else
----    elsif WSW0 = '0' then
--        TX <= c_RX_Byte;
--       end if;
--end process;

FINAL_BIT_TO_TX <= c_TX_Byte;       
TX <= FINAL_BIT_TO_TX;

--niestety wysylanie do pliku dziala tylko gdy robi sie symulacje 
do_pliku_TX: process(sys_clock)
file        output_file_TX         : text is out "C:\Users\ps-1\Desktop\moje\Zadanie 2\pliki\wysylanie.txt";   --zapisane w konkretnej œcie¿ce      
-- file        output_file         : text is out "C:\Users\ps-1\Desktop\moje\Zadanie 2\pliki\wysylanie.ptp";   -- rozszerzenie docklight     
variable    output_line_TX         : line;  --tymczasowe przechowywanie danych przed ich zapisaniem
variable    good_v                 : boolean;
variable    char_input_v           : character;
variable    time_input_v           : time;

begin
    if rising_edge(sys_clock) then
       output_line_TX := null;
       
       read(output_line_TX, char_input_v, good_v);
       read(output_line_TX, time_input_v, good_v);
    
        if crk = '1' then
            write(output_line_TX, string'(" "), left, 0);   --spacja stworzona ¿eby dopisaæ drugi bajt, mozna w sumie ja usunac
            write(output_line_TX, TX_bufor);  --zapisane binarnie, odnosi sie do faktycznego sygnalu z central
            writeline(output_file_TX, output_line_TX);
        end if;
        
        if (good_v) then 
              assert (true) report "wyslano poprawnie!" severity failure;
        end if;
    end if;
end process;

do_pliku_RX: process(sys_clock)
file        output_file_RX         : text is out "C:\Users\ps-1\Desktop\moje\Zadanie 2\pliki\odbieranie.txt";   --zapisane w konkretnej œcie¿ce      
-- file        output_file         : text is out "C:\Users\ps-1\Desktop\moje\Zadanie 2\pliki\wysylanie.ptp";   -- rozszerzenie docklight     
variable    output_line_RX         : line;  --tymczasowe przechowywanie danych przed ich zapisaniem
variable    good_v                 : boolean;
variable    input_line             : line; 
variable    char_input_v           : character;
variable    time_input_v           : time;

begin
    if rising_edge(sys_clock) then
       output_line_RX := null;
       
       read(input_line, char_input_v, good_v);
       read(input_line, time_input_v, good_v);
    
        if c_RX_DV = '1' then
        --napisa cos ze jesli jest 0 to zeby wpisac tylko jednen nowy biat a nie milion
            write(output_line_RX, string'(" "), left, 0);   --spacja stworzona ¿eby dopisaæ drugi bajt, mozna w sumie ja usunac
            --write(output_line, bit_vector_input_s, left);
            
            write(output_line_RX, c_RX_Byte);  --zapisane binarnie, odnosi sie do faktycznego sygnalu z central
            --write(output_line_RX, RX_bufor);  --zapisane binarnie, odnosi sie do faktycznego sygnalu z central
            writeline(output_file_RX, output_line_RX);
            --write(output_line_RX, now , left, 10);                  -- zapisanie czasu
        end if;        
        if (good_v) then 
              assert (true) report "wyslano poprawnie!" severity failure;
        end if;
    end if;
end process;



end Behavioral;