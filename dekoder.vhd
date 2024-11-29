library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

entity dekoder is
Port (
      CLK         : in std_logic;
      start_bit_d : in std_logic_vector(15 downto 0); -- tu bedzie wartosc przzed kodowaniem 
      final_bit_d : out std_logic_vector(15 downto 0); --pozniej zmienic na 64, tu bedzie wychodzic zakodowana wartosc
      rx_dv       : in std_logic;
      reset       : in std_logic
      );
end dekoder;

architecture Behavioral of dekoder is
signal mamto                 : std_logic := '0';
type STANY is (Idle, D0, D1, D2, D3, D0_2, D3_2, koniec); --do nadawania bitow
signal state, next_state     : STANY := Idle;
signal previous_state        : STANY := Idle;
signal zakodowana_wiadomosc  : std_logic_vector(9 downto 0) := "0110101010";--"1000111100"; - to jest ciekaw przypadek   -- 0110101010   
signal odwrocona_wiadomosc   : std_logic_vector(9 downto 0) := (others => '0'); -- 0110011010   test
type t_matrix is array (0 to 1, 0 to 3) of integer;
signal outputs : t_matrix := (        --bylo constant wczesniej
                    (0, 3, 2, 1),   -- dla '0' , 1 kolumna
                    (1, 2, 3, 0));  -- dla '1' , 2 kolumna
type t_binary is array (0 to 3) of std_logic_vector(1 downto 0);
constant binary_values : t_binary := (
    "00",  -- 0
    "01",  -- 1
    "10",  -- 2
    "11"   -- 3
    );
signal matrix_value0 : integer := 0;
signal matrix_value1 : integer := 0;
signal binary_value0 : std_logic_vector(1 downto 0) := "00";
signal binary_value1 : std_logic_vector(1 downto 0) := "00";
signal xor_result_0  : std_logic_vector(1 downto 0) := "00";
signal xor_result_1  : std_logic_vector(1 downto 0) := "00";
signal counter0      : integer := 0;
signal counter1      : integer := 0;
signal zmienna       : std_logic := '0';
signal counter_all_0 : integer := 0;
signal counter_all_1 : integer := 0;
signal bit_index     : integer range 0 to 9 := 9;      
signal wiadomosc     : std_logic_vector(7 downto 0) := (others => '0');
signal odkodowana    : std_logic_vector(4 downto 0) := (others => '0');
signal zliczanie0    : integer := 0;
signal zliczanie1    : integer := 0;
signal liczba        : std_logic := '0';        --do odkodowania wartosci 
signal bit_index_updated : boolean := false;
signal first_D0      : boolean   := true;     -- sprawdza który raz pojawia siê D0, jeœli pierwszy to zostawia bit_index = 9, z kolei jeœli po raz kolejny to bit_index - 2;
signal another_D0    : boolean := false;    -- sprawdza czy po raz kolejny nie pojawia siê ten sam stan
signal final_output  : std_logic_vector(4 downto 0) := (others => '0');
-----
signal spraw         : std_logic_vector(1 downto 0) := "00";       --od 10 schodzê w dó³


begin 

--obracanie_bitow: process(CLK)
--begin
--    for a in 0 to 9 loop      -- bo nie moze byc 9 range to 0
--        odwrocona_wiadomosc(a) <= zakodowana_wiadomosc(9 - a);
--        odwrocona_wiadomosc2(a) <= zakodowana_wiadomosc(9 - a);
--    end loop;
--end process;

poczatek: process(CLK, reset)  
begin 
    if rising_edge(CLK) then
        if reset = '1' then
            state <= Idle;
        else
            state <= next_state;
        end if;
    end if;    
end process;

maszynaStanu: process(zmienna, next_state, counter0, counter1, counter_all_0, counter_all_1)   -- maszyna stanow w zalznosci od przycisku
begin
    case state is
        when Idle => 
        if zmienna = '1' then   --rx_dv
            next_state <= D0;
        elsif zmienna = '0' then    
            next_state <= Idle;
        end if;
        
        when D0 => 
        if zmienna = '1' then 
            if counter0 < counter1 then   -- '0'      --wczesniej bylo if counter_all_0 < counter_all_1 then
                liczba <= '0';              -- do rejestru przesuwnego <- zdekodowanej informacji
                next_state <= D0_2;   --poczatkowo D0, pozniej D0_2;
                if bit_index = 1 then
                    next_state <= koniec;
                end if;
            elsif counter1 < counter0 then    -- '1'      --wczesniej bylo elsif counter_all_1 < counter_all_0 then
                liczba <= '1';
                next_state <= D2;
                if bit_index = 1 then
                    next_state <= koniec;
                end if;
            elsif counter0 = counter1 then
                if counter_all_0 < counter_all_1 then
                    liczba <= '0';
                    next_state <= D0_2; --poczatkowo D0, pozniej D0_2;
                    if bit_index = 1 then
                        next_state <= koniec;
                    end if;
                elsif counter_all_1 < counter_all_0 then
                    liczba <= '1';
                    next_state <= D2;
                    if bit_index = 1 then
                        next_state <= koniec;
                    end if;
                elsif counter_all_1 = counter_all_0 then
                    next_state <= D0;           -- w razie czego stoi na swoim stanie 
                end if;
            end if;
        elsif zmienna = '0' then
            next_state <= Idle;      
        end if;    
        
        when D0_2 =>
        if zmienna = '1' then
            if counter0 < counter1 then   -- '0'      --wczesniej bylo if counter_all_0 < counter_all_1 then
                liczba <= '0';              -- do rejestru przesuwnego <- zdekodowanej informacji
                next_state <= D0;
                if bit_index = 1 then
                    next_state <= koniec;
                end if;
            elsif counter1 < counter0 then    -- '1'      --wczesniej bylo elsif counter_all_1 < counter_all_0 then
                liczba <= '1';
                next_state <= D2;
                if bit_index = 1 then
                    next_state <= koniec;
                end if;
            elsif counter0 = counter1 then
                if counter_all_0 < counter_all_1 then
                    liczba <= '0';
                    next_state <= D0;
                    if bit_index = 1 then
                        next_state <= koniec;
                    end if;
                elsif counter_all_1 < counter_all_0 then
                    liczba <= '1';
                    next_state <= D2;
                    if bit_index = 1 then
                        next_state <= koniec;
                    end if;
                elsif counter_all_1 = counter_all_0 then
                    next_state <= D0_2;           -- w razie czego stoi na swoim stanie 
                end if;
            end if;
        elsif zmienna = '0' then
            next_state <= Idle;      --bylo next_state
        end if;                   
    
        when D1 => 
        if zmienna = '1' then
            if counter0 < counter1 then       -- '0'
                liczba <= '0'; 
                next_state <= D0;
                if bit_index = 1 then
                    next_state <= koniec;
                end if;
            elsif counter1 < counter0 then    --'1'
                liczba <= '1';
                next_state <= D2;
                if bit_index = 1 then
                    next_state <= koniec;
                end if;
            elsif counter0 = counter1 then
                if counter_all_0 < counter_all_1 then
                    liczba <= '0';
                    next_state <= D0;
                    if bit_index = 1 then
                        next_state <= koniec;
                    end if;
                elsif counter_all_1 < counter_all_0 then
                    liczba <= '1';
                    next_state <= D2; 
                    if bit_index = 1 then
                        next_state <= koniec;
                    end if;
                elsif counter_all_0 = counter_all_1 then
                    next_state <= D1;
                end if;
            end if;
        elsif zmienna = '0' then
            next_state <= Idle;   
        end if;
        
     when D2 => 
       if zmienna = '1' then 
           if counter0 < counter1 then        --'0'     
                liczba <= '0';
                next_state <= D1;
                if bit_index = 1 then
                    next_state <= koniec;
                end if;
           elsif counter1 < counter0 then     --'1'     
                liczba <= '1';
                next_state <= D3;
                if bit_index = 1 then
                    next_state <= koniec;
                end if;
           elsif counter0 = counter1 then
                if counter_all_0 < counter_all_1 then
                    liczba <= '0';
                    next_state <= D1;
                    if bit_index = 1 then
                        next_state <= koniec;
                    end if;
                elsif counter_all_1 < counter_all_0 then
                    liczba <= '1';
                    next_state <= D3;  
                    if bit_index = 1 then
                        next_state <= koniec;
                    end if; 
                elsif counter_all_0 = counter_all_1 then
                    next_state <= D2;       -- w razie czego zostaje na swoim stanie
                end if;           
            end if;
        elsif zmienna = '0' then
            next_state <= Idle;
        end if;   
       
       when D3 =>
       if zmienna = '1' then
           if counter0 < counter1 then        --'0'
                liczba <= '0';
                next_state <= D1;
                if bit_index = 1 then
                    next_state <= koniec;
                end if;
           elsif counter1 < counter0 then    --'1'
                liczba <= '1';
                next_state <= D3_2; --poczatkowod D3, pozniej D3_2;
                if bit_index = 1 then
                    next_state <= koniec;
                end if;
            elsif counter0 = counter1 then
                if counter_all_0 < counter_all_1 then
                    liczba <= '0';
                    next_state <= D1;
                    if bit_index = 1 then
                        next_state <= koniec;
                    end if;
                elsif counter_all_1 < counter_all_0 then
                    liczba <= '1';
                    next_state <= D3_2; -- poczatkowo D3, pozniej D3_2; 
                    if bit_index = 1 then
                        next_state <= koniec;
                    end if;
                end if;
            elsif counter_all_0 = counter_all_1 then
                next_state <= D3;
            end if;        
        elsif zmienna = '0' then
            next_state <= Idle;                  
        end if;
        
        when D3_2 =>
        if zmienna = '1' then
           if counter0 < counter1 then        --'0'
                liczba <= '0';
                next_state <= D1;
                if bit_index = 1 then
                    next_state <= koniec;
                end if;
           elsif counter1 < counter0 then    --'1'
                liczba <= '1';
                next_state <= D3;
                if bit_index = 1 then
                    next_state <= koniec;
                end if;
            elsif counter0 = counter1 then
                if counter_all_0 < counter_all_1 then
                    liczba <= '0';
                    next_state <= D1;
                    if bit_index = 1 then
                        next_state <= koniec;
                    end if;
                elsif counter_all_1 < counter_all_0 then
                    liczba <= '1';
                    next_state <= D3; 
                    if bit_index = 1 then
                        next_state <= koniec;
                    end if;
                end if;
            elsif counter_all_0 = counter_all_1 then
                next_state <= D3_2;
            end if;        
        elsif zmienna = '0' then
            next_state <= Idle;                  
        end if;
        
       when koniec =>
           next_state <= Idle;    --to bedzie w dalszym ciagu, na razie 

       when others =>
           next_state <= Idle;                        
       end case; 
end process;

zmienna <= rx_dv;   --gdy pojawi sie sygnal ¿e nadchodz¹ bity to w³¹cza siê sygna³ zmienna

przejscia: process(state, next_state, bit_index_updated, previous_state, bit_index)--, counter_all_0, counter_all_1, xor_result_0, xor_result_1) -- maszyna stanow 
begin 
    if state /= previous_state then --sprawdzenie czy siê stan zmienil
        bit_index_updated <= false; --resetowanie flagi TYLKO przy zmianie stanu
    end if;
    previous_state <= state; 
     
    case state is        
        when Idle =>
            binary_value0 <= "00";
            binary_value1 <= "00";
            matrix_value0 <= 0;
            matrix_value1 <= 0;
            bit_index <= 9;
            bit_index_updated <= false; -- resetowanie flagi
            first_D0 <= true;   -- sprawdzenie czy D0 pojawia siê po raz pierwszy 
            
        --when D0 =>
--        if bit_index = 9 then   -- dodanie bit_index_updated = false czy first_D0 = true czy and previous_state = Idle
--                first_D0 <= false;  --ok
--                bit_index <= 9;     --ok
--            if state = D0 and first_D0 <= false then  -- za kolejnym
--                first_D0 <= true;   --ok
--                another_D0 <= true; 
--                    if not bit_index_updated then   --ok
--                        bit_index <= bit_index - 2; --ok
--                        bit_index_updated <= true;  --ok
--                        another_D0 <= false;
--                    end if;
--                end if;
--        elsif bit_index /= 9 then
--            first_D0 <= true;
--            if not bit_index_updated then   --if bit_index_updated = false then
--                bit_index <= bit_index - 2;
--                bit_index_updated <= true;
--            end if;
--        end if;
--        matrix_value0 <= outputs(0,0);    -- (wiersz, kolumna),     
--        binary_value0 <= binary_values(matrix_value0);
--        matrix_value1 <= outputs(1,0); 
--        binary_value1 <= binary_values(matrix_value1);  -- Pobierz odpowiadaj¹c¹ wartoœæ binarn¹

        when D0 =>    --to dziala
        if bit_index = 9 then
            first_D0 <= false;  -- flaga na false po pierwszym przejœciu
            bit_index <= 9;
        else
            first_D0 <= true;
            if bit_index_updated = false then
                bit_index <= bit_index - 2;
                bit_index_updated <= true;
            end if;
        end if;
        matrix_value0 <= outputs(0,0);    -- (wiersz, kolumna),     
        binary_value0 <= binary_values(matrix_value0);
        matrix_value1 <= outputs(1,0); 
        binary_value1 <= binary_values(matrix_value1);  -- Pobierz odpowiadaj¹c¹ wartoœæ binarn¹
        
        when D0_2 =>
        if not bit_index_updated then   --if bit_index_updated = false then
            bit_index <= bit_index - 2;
            bit_index_updated <= true;
        end if;
        matrix_value0 <= outputs(0,0);    -- (wiersz, kolumna),     
        binary_value0 <= binary_values(matrix_value0);
        matrix_value1 <= outputs(1,0); 
        binary_value1 <= binary_values(matrix_value1);  -- Pobierz odpowiadaj¹c¹ wartoœæ binarn¹
                
        when D1 =>     --powinno siê zmieni¹c bez wzgledu na nowy stan
        if not bit_index_updated then   -- bit_index_updated - zeby nie zwielokratnia³o siê zmniejszanie siê bit_index
            bit_index <= bit_index - 2;
            bit_index_updated <= true;
        end if;
        matrix_value0 <= outputs(0,1);    
        binary_value0 <= binary_values(matrix_value0);
        matrix_value1 <= outputs(1,1);
        binary_value1 <= binary_values(matrix_value1);
        
        when D2 =>
        if not bit_index_updated then
            bit_index <= bit_index - 2;
            bit_index_updated <= true;
        end if;
        matrix_value0 <= outputs(0,2);    
        binary_value0 <= binary_values(matrix_value0);
        matrix_value1 <= outputs(1,2); 
        binary_value1 <= binary_values(matrix_value1);
                           
        when D3 =>          
        if not bit_index_updated then
            bit_index <= bit_index - 2;
            bit_index_updated <= true;
        end if;
        matrix_value0 <= outputs(0,3);    
        binary_value0 <= binary_values(matrix_value0);
        matrix_value1 <= outputs(1,3); 
        binary_value1 <= binary_values(matrix_value1);
        
        when D3_2 =>
        if not bit_index_updated then   --if bit_index_updated = false then
            bit_index <= bit_index - 2;
            bit_index_updated <= true;
        end if;
        matrix_value0 <= outputs(0,0);    -- (wiersz, kolumna),     
        binary_value0 <= binary_values(matrix_value0);
        matrix_value1 <= outputs(1,0); 
        binary_value1 <= binary_values(matrix_value1);  -- Pobierz odpowiadaj¹c¹ wartoœæ binarn¹
        
        when koniec =>
            matrix_value0 <= 0;
            matrix_value1 <= 0;
            binary_value0 <= "00";
            binary_value1 <= "00";  
            bit_index <= 9; 
            bit_index_updated <= false;
                    
        when others =>
            matrix_value0 <= 0;
            matrix_value1 <= 0;
            binary_value0 <= "00";
            binary_value1 <= "00"; 
            bit_index <= 9;           
            bit_index_updated <= false;                    
        end case;
end process;

xorowanie: process(binary_value0, binary_value1, state, bit_index)
begin
    if (binary_value0 /= "00" or binary_value1 /= "00") or (state = D0_2 or state = D3_2 or state = D0 or state = D3) or bit_index /= 0 then -- operacja wykona sie tylko gdy ktorys z warunków wykarze aktywnosc
        xor_result_0 <= (binary_value0 xor zakodowana_wiadomosc(bit_index downto bit_index - 1)); --zakodowana_wiadomosc wskazuje poprawne wartosci
        xor_result_1 <= (binary_value1 xor zakodowana_wiadomosc(bit_index downto bit_index - 1));
    else
        xor_result_0 <= (others => '0');
        xor_result_1 <= (others => '0');
    end if;
end process;

counter: process(xor_result_0, xor_result_1)-- counter0, counter1)
begin
    -- dla xor_result_0
    if (xor_result_0 = "01" or xor_result_0 = "10") then    -- pojawi³ siê pojedynczy b³¹d
        counter0 <= 1;
    elsif xor_result_0 = "11" then                          -- wszystkie by³y b³êdne
        counter0 <= 2;
    elsif xor_result_0 = "00" then                          -- wszystkie siê zgadza³y
        counter0 <= 0;
    end if;
            
    -- dla xor_result_1
    if (xor_result_1 = "01" or xor_result_1 = "10") then    -- pojedynczy blad
        counter1 <= 1;
    elsif xor_result_1 = "11" then                          -- wszystkie bledne
        counter1 <= 2;
    elsif xor_result_1 = "00" then                          -- brak bledow 
        counter1 <= 0;    
    end if;  
end process;
        
-- musi byc w osobnym procesie, bo inaczej nie dzia³a
koncoweZliczanie : process(xor_result_0, xor_result_1)
begin
-- na wypadek gdyby counter nie zadzialal
    if xor_result_0 /= "00" or xor_result_1 /= "00" then
        zliczanie0 <= counter_all_0;
        counter_all_0 <= counter0 + zliczanie0; 
        zliczanie1 <= counter_all_1;  
        counter_all_1 <= counter1 + zliczanie1;
    end if;
end process;

zdekodowana: process(next_state)
begin
    if next_state /= Idle and next_state /= koniec then --or state /= koniec then   
        odkodowana(4 downto 1) <= odkodowana(3 downto 0);   -- przesuwanie bitów w lewo
        odkodowana(0) <= liczba;            -- dodawanie nowego bitu na pozycji 0
    elsif next_state = koniec then
        final_output <= odkodowana;  -- Przyk³adowe przypisanie do wyjœcia
    elsif next_state = Idle then
        odkodowana <= (others => '0');  -- Resetowanie w stanie Idle
    end if;
end process;

--process(state)
--begin
-- if state = koniec then
--        final_output <= odkodowana;
--    end if;
--end process;

dopliku: process(CLK)   --  zapisanie do pliku
file        output_file            : text is out "C:\Users\ps-1\Desktop\moje\Zadanie 2\pliki\dekoder.txt";   --zapisane w konkretnej œcie¿ce      
variable    output_line            : line;  --tymczasowe przechowywanie danych przed ich zapisaniem
variable    good_v                 : boolean;
variable    char_input_v           : character;
variable    time_input_v           : time;

begin
    if rising_edge(CLK) then
       output_line := null;
       
       read(output_line, char_input_v, good_v);
       read(output_line, time_input_v, good_v);
    
        if mamto = '1' then
            write(output_line, string'(" "), left, 0);   --spacja stworzona ¿eby dopisaæ drugi bajt, mozna w sumie ja usunac
            write(output_line, odkodowana); 
            writeline(output_file, output_line);
        end if;
        
        if (good_v) then 
              assert (true) report "wyslano poprawnie!" severity failure;
        end if;
    end if;
end process;

end Behavioral;

