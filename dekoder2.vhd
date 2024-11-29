library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

entity dekoder2 is
Port (
      CLK         : in std_logic;
      start_bit_d : in std_logic_vector(63 downto 0); -- tu bedzie wartosc przed kodowaniem 
      final_bit_d : out std_logic_vector(15 downto 0); --pozniej zmienic na 64, tu bedzie wychodzic zakodowana wartosc
      rx_dv       : in std_logic;
      reset       : in std_logic
      );
end dekoder2;

architecture Behavioral of dekoder2 is
type STANY is (Idle, P0, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, P15, P16, P17, P18, P19, P20, 
               P21, P22, P23, P24, P25, P26, P27, P28, P29, P30, P31, P32, P33, P34, P35, P36, P37, P38, P39, P40,
               P41, P42, P43, P44, P45, P46, P47, P48, P49, P50, P51, P52, P53, P54, P55, P56, P57, P58, P59, P60, 
               P61, P62, P63, P0_2, P63_2, koniec); --do nadawania bitow
signal state, next_state : STANY := Idle;
signal previous_state    : STANY := Idle;
signal jakis_stan        : STANY := Idle;
type t_matrix is array (0 to 1, 0 to 63) of integer;
signal outputs : t_matrix := (        --bylo constant wczesniej
                    (0, 15, 10, 5, 9, 6, 3, 12, 12, 3, 6, 9, 5, 10, 15, 0,
                    14, 1, 4, 11, 7, 8, 13, 2, 2, 13, 8, 7, 11, 4, 1, 14,
                    8, 7, 2, 13, 1, 14, 11, 4, 4, 11, 14, 1, 13, 2, 7, 8,
                    6, 9, 12, 3, 15, 0, 5, 10, 10, 5, 0, 15, 3, 12, 9, 6),   -- dla '0' , 1 kolumna
                    (15, 0, 5, 10, 6, 11, 12, 3, 3, 12, 9, 6, 10, 5, 0, 15,
                    1, 14, 11, 4, 8, 7, 2, 13, 13, 2, 7, 8, 4, 11, 14, 1,
                    7, 8, 13, 2, 14, 1, 4, 11, 11, 4, 1, 14, 2, 13, 8, 7,
                    9, 6, 3, 12, 0, 15, 10, 5, 5, 10, 15, 0, 12, 3, 6, 9));  -- dla '1' , 2 kolumna
                    -- WA¯NE!!!!!!!!!!!!!!!!!!!!!!
                    -- jako ¿e wartoœci by³y zapisane ósemkowo i nie ma 9 i 8, to w constant binary_values s¹ u³o¿one bity po kolei i jest ich 15,
                    -- a nie 17 jak by³o pocz¹tkowo z matlaba
type t_binary is array (0 to 15) of std_logic_vector(3 downto 0);
constant binary_values : t_binary := (      --ósemkowo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    "0000",  -- 0
    "0001",  -- 1
    "0010",  -- 2
    "0011",  -- 3
    "0100",  -- 4 
    "0101",  -- 5
    "0110",  -- 6
    "0111",  -- 7
    "1000",  -- 8
    "1001",  -- 9
    "1010",  -- 10
    "1011",  -- 11
    "1100",  -- 12
    "1101",  -- 13
    "1110",  -- 14    
    "1111"   -- 15
    );
    
    --------
    --  0101110010100011
    --      0000111110000001101100000000010000000100010010110111011010011101
    --  1001100100100110
    --      1111100011100011111011001101101010111011110000010100110011101100
    --  1110110100111010
    --      1111011110011010010010001010100000101101011000010011010101000111
    --  1111000011110000
    --      1111011110010101001100010000110010101000100101010011000100001100
    --  0101010101010101
    --      0000111110000001010010001110011111100111111001111110011111100111
    --  1000000111110000
    --      1111100011101100100110101111111101111001010111001001111000001100
    --------
    
signal bit_index               : integer range 0 to 64 := 64;  
signal ascii                   : string(1 to 64) := "Mauris tristique risus ac augue viverra posuere. Donec accumsan.";    
signal zakodowana_wiadomosc    : std_logic_vector(63 downto 0) := (others => '0');  
signal zakodowana_wiadomosc2   : std_logic_vector(63 downto 0) := "1111100011101100100101011000100110100100011111010001011111101000";  
------ dla 4800 bitów 
signal zmienna                 : std_logic := '0';
signal counter0                : integer := 0;
signal counter1                : integer := 0;
signal liczba                  : std_logic := '0';        --do odkodowania wartosci 
signal bit_index_updated       : boolean := false;
signal matrix_value0           : integer := 0;
signal matrix_value1           : integer := 0;
signal binary_value0           : std_logic_vector(3 downto 0) := "0000";    -- wczesniej bylo 4 downto 0
signal binary_value1           : std_logic_vector(3 downto 0) := "0000";
signal first_D0                : boolean   := true;     -- sprawdza który raz pojawia siê D0, jeœli pierwszy to zostawia bit_index = 9, z kolei jeœli po raz kolejny to bit_index - 2;
signal xor_result_0            : std_logic_vector(3 downto 0) := "0000";
signal xor_result_1            : std_logic_vector(3 downto 0) := "0000";
signal zliczanie0              : integer := 0;
signal zliczanie1              : integer := 0;
signal odkodowana              : std_logic_vector(15 downto 0) := (others => '0');
signal final_output            : std_logic_vector(15 downto 0) := (others => '0');
signal pomocnicza              : std_logic_vector(3 downto 0) := (others => '0');

--do sprawdzenia
signal d1                      : integer := 0;
signal d2                      : integer := 0;
signal d3                      : integer := 0;
signal j_spr                   : integer := 0;
signal spr_syg                 : boolean;

function get_state_index(s : STANY) return natural is  
begin
    case s is                            -- funkcja która odpowiada za odpowiednie przypisanie wartoœci do outputsów
        when P0 | P0_2 | Idle | koniec => return 0;     --nie da siê niestety bardziej uproœciæ
        when P1 => return 1;
        when P2 => return 2;
        when P3 => return 3;
        when P4 => return 4;
        when P5 => return 5;
        when P6 => return 6;
        when P7 => return 7;
        when P8 => return 8;
        when P9 => return 9;
        when P10 => return 10;
        when P11 => return 11;
        when P12 => return 12;
        when P13 => return 13;
        when P14 => return 14;
        when P15 => return 15;
        when P16 => return 16;
        when P17 => return 17;
        when P18 => return 18;
        when P19 => return 19;
        when P20 => return 20;
        when P21 => return 21;
        when P22 => return 22;
        when P23 => return 23;
        when P24 => return 24;
        when P25 => return 25;
        when P26 => return 26;
        when P27 => return 27;
        when P28 => return 28;
        when P29 => return 29;
        when P30 => return 30;
        when P31 => return 31;
        when P32 => return 32;
        when P33 => return 33;
        when P34 => return 34;
        when P35 => return 35;
        when P36 => return 36;
        when P37 => return 37;
        when P38 => return 38;
        when P39 => return 39;
        when P40 => return 40;
        when P41 => return 41;
        when P42 => return 42;
        when P43 => return 43;
        when P44 => return 44;
        when P45 => return 45;
        when P46 => return 46;
        when P47 => return 47;
        when P48 => return 48;
        when P49 => return 49;
        when P50 => return 50;
        when P51 => return 51;
        when P52 => return 52;
        when P53 => return 53;
        when P54 => return 54;
        when P55 => return 55;
        when P56 => return 56;
        when P57 => return 57;
        when P58 => return 58;
        when P59 => return 59;
        when P60 => return 60;
        when P61 => return 61;
        when P62 => return 62;
        when P63 | P63_2 => return 63;
        when others => return 0; -- dla stanów bez przypisanego indeksu, czy mo¿e powinno byc 0
    end case;
    return 0;   -- na wszelki wypadek jak nic nie zadziala
end function;

-- przejscie z integera do state 
function get_state_index2(s : natural; b : integer := 0; z : std_logic := '0') return STANY is

begin 
    -- b - bit_index
    -- z - zmienna 
    
    case s is 
        when 0 => --return P0; --P0_2, Idle, koniec; 
        if b = 63 then
            if z = '0' then
                return Idle;    
            elsif z = '1' then    
                return P0;
            elsif z = '1' and b < 63 then
                return P0_2;
            else 
                return Idle;
            end if;
        end if;        
        when 1 => return P1;
        when 2 => return P2;
        when 3 => return P3;
        when 4 => return P4;
        when 5 => return P5;
        when 6 => return P6;
        when 7 => return P7;
        when 8 => return P8;
        when 9 => return P9;
        when 10 => return P10;
        when 11 => return P11;
        when 12 => return P12;
        when 13 => return P13;
        when 14 => return P14;
        when 15 => return P15;
        when 16 => return P16;     
        when 17 => return P17;
        when 18 => return P18;
        when 19 => return P19;
        when 20 => return P20;
        when 21 => return P21;
        when 22 => return P22;
        when 23 => return P23;
        when 24 => return P24;
        when 25 => return P25;
        when 26 => return P26;
        when 27 => return P27;
        when 28 => return P28;
        when 29 => return P29;
        when 30 => return P30;
        when 31 => return P31;
        when 32 => return P32;  
        when 33 => return P33;
        when 34 => return P34;
        when 35 => return P35;
        when 36 => return P36;
        when 37 => return P37;
        when 38 => return P38;
        when 39 => return P39;     
        when 40 => return P40;
        when 41 => return P41;
        when 42 => return P42;
        when 43 => return P43;
        when 44 => return P44;
        when 45 => return P45;
        when 46 => return P46;
        when 47 => return P47;
        when 48 => return P48;
        when 49 => return P49;
        when 50 => return P50;
        when 51 => return P51;
        when 52 => return P52;
        when 53 => return P53;
        when 54 => return P54;
        when 55 => return P55;    
        when 56 => return P56;
        when 57 => return P57;
        when 58 => return P58;
        when 59 => return P59;
        when 60 => return P60;
        when 61 => return P61;
        when 62 => return P62;
        when 63 => --return P63; --P63_2;--, P63_2;
            if b < 63 and b > 0 then
                return P63;            
            else
                return P63_2;
            end if;
            
        when others => return Idle;
    end case;
    return Idle; -- gdy przypadki zwion¹, w sumie nie potrzebne ale na wszleki w
end function;

begin

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

kodowanie_64: process(ascii) -- obracanie bitow
variable temp_byte : std_logic_vector(7 downto 0);  --podzielenie na 8 bitow
begin
    for a in 1 to 8 loop      -- 150 znakow ktore beda 8 bitowe, od 1 do 150 poniewa¿ dla wartoœci typu string uzywa sie indeksowania od 1
        temp_byte := std_logic_vector(to_unsigned(character'pos(ascii(a)), 8)); --wektor przechodzacy do unsigned, a nastepnie character zeby zapisac z ascii na 8 bitow   
   ----------
   -- 'pos - zwraca pozycje danej wartosci typu wyliczeniowgo, w tym przypadku character
   -- to_unsigned(...,8) - konwertuje liczbe na postac binarna
   ----------
        zakodowana_wiadomosc((8-a)*8+7 downto (8-a)*8) <= temp_byte;   --odwrócenie kolejnosci wektora, (150-a) znak "L" trafi na najnizsze bity, a ostatni znak na najwyzsze
        --bits_data(a*8-1 downto (a-1)*8) <= temp_byte;      -- Przypisanie 8-bitowego kodu binarnego do odpowiedniej czêœci wyjœcia bits_output, jak bylo z rejestrem przesuwnym
        --powyzsza linijka jest poprawna, ale zapisuje "od koñca wartosci"
    end loop;
end process;

---- maszyna stanów tylko w przypadku dla funkji get_state_index
--maszynaStanu: process(zmienna, state, counter0, counter1, zliczanie0, zliczanie1)   
--variable j : integer;   -- indeks bie¿¹cego stanu
--begin
    
--    j := get_state_index(state); -- pobiera indeks bie¿¹cego stanu
    
--    j_spr <= j;

--    case state is
--        when Idle =>
--            if zmienna = '1' then
--                next_state <= P0;
--            else
--                next_state <= Idle;
--            end if;
        
--        when koniec =>
--            next_state <= Idle;
--            liczba <= '0';
            
        
--        when others =>
--            if zmienna = '1' then
--                if j = 0 or j = 1 then --dla P0, P0_2, P1
--                    if counter0 < counter1 then
--                        liczba <= '0';
--                        if state = P0 then 
--                            next_state <= P0_2;
--                        elsif state = P0_2 or state = P1 then
--                            next_state <= P0;
--                        end if; 
--                    elsif counter1 < counter0 then
--                        liczba <= '1';
--                        next_state <= P32;
--                    elsif counter0 = counter1 then
--                        if zliczanie0 < zliczanie1 then
--                            liczba <= '0';
--                            if state = P0 then 
--                                next_state <= P0_2;
--                            elsif state = P0_2 or state = P1 then
--                                next_state <= P0;
--                            end if; 
--                        elsif zliczanie1 < zliczanie0 then
--                            liczba <= '1';
--                            next_state <= P32;
----                        elsif zliczanie0 = zliczanie1 then
--                            --state <= error;
--                        end if;    
--                    end if;
                        
--                elsif j = 62 or j = 63 then --dla P62, P63_2, P63
--                    if counter0 < counter1 then
--                        liczba <= '0';
--                        next_state <= P31;
--                    elsif counter1 < counter0 then
--                        liczba <= '1';
--                        if state = P63 then
--                            next_state <= P63_2;
--                        elsif state = P63_2 or state = P62 then
--                            next_state <= P63;
--                        end if; 
--                    elsif counter0 = counter1 then
--                        if zliczanie0 < zliczanie1 then
--                            liczba <= '0';
--                            next_state <= P31;
--                        elsif zliczanie1 < zliczanie0 then
--                            liczba <= '1';
--                            if state = P63 then
--                                next_state <= P63_2;
--                            elsif state = P63_2 or state = P62 then
--                                next_state <= P63;
--                            end if;
----                        elsif zliczanie1 = zliczanie0 then
--                            --state <= error;    
--                        end if;
--                    end if;
                    
--                    ------------ jak dziala
--                    -- np. z P6 (return = 6), mo¿liwe stany : P3 lub P35   <- stan w zale¿noœci od countera
--                    -- 6/2 = 3, 6/2+32 = 35
--                    -- np. z P20 (return = 20), mo¿liwe stany : P10 lub P42
--                    -- 20/2 = 10, 20/2+32 = 42
--                    --
--                    -- np. z P9 (return = 9), mo¿liwe stany : P4 lub P36
--                    -- 9/2 = 4, 9/2+31 = 36
--                    -- np z P59 (return = 59), mo¿liwe stany : 
--                    -- 59/2 = 29 ,59/2+31 = 61
                    
--                    -- dodaje '+ 1', bo przypisa³am do ka¿dego stanu jakiœ indeks ¿eby by³o mi ³atwiej, a chdl i tak robi po swojemu
--                    ------------
                    
                
--                elsif (j >= 2) and (j <= 61) then          -- <2,61> gdzie tutaj ju¿ nie ma wyj¹tków
--                    if counter0 < counter1 then
--                        liczba <= '0';
--                        if j mod 2 = 0 then     -- liczba parzysta 
--                            next_state <= STANY'val((j/2)+1);
--                            --get_state_index2((j/2)+1) <= STANY'val((j/2)+1);                     -- dla pierwszej 'dwójki' która ma te same 'nastepne stany', wczesniej bylo next_state
--                            --next_state <= get_state_index2((j/2)+1);   
----                            next_state <= get_state_index2(((j / 2) + 1), bit_index, zmienna);
                  
--                        elsif j mod 2 = 1 then  -- liczba nieparzysta
--                            next_state <= STANY'val((j/2)+1); --musi byc -0.5, ale zaokr¹gli w dó³
----                            next_state <= STANY'val((j/2)+1); --musi byc -0.5, ale zaokr¹gli w dó³
----                            next_state <= get_state_index2((j/2)+1);
----                            next_state <= get_state_index2(((j / 2) + 1), bit_index, zmienna);

--                        end if;
--                    elsif counter1 < counter0 then
--                        liczba <= '1';
--                        if j mod 2 = 0 then     -- liczba parzysta  
--                            next_state <= STANY'val((j/2) + 32 + 1);  
--                            --next_state <= get_state_index2((j/2) + 32 + 1);  
----                            get_state_index2((j/2)+1) <= STANY'val((j/2) + 32 + 1);  
----                            next_state <= get_state_index2((j/2) + 32 + 1);  
----                            next_state <= get_state_index2(((j / 2) + 32 + 1), bit_index, zmienna);
--                        elsif j mod 2 = 1 then  -- liczba nieparzysta
--                            next_state <= STANY'val((j/2) + 31 + 1); 
--                            --next_state <= get_state_index2((j/2) + 31 + 1);
----                            get_state_index2((j/2)+1) <= STANY'val((j/2) + 31 + 1); 
----                            next_state <= get_state_index2((j/2) + 31 + 1);
----                            next_state <= get_state_index2(((j / 2) + 31 + 1), bit_index, zmienna);
--                        end if;
--                    elsif counter0 = counter1 then
--                        if zliczanie0 < zliczanie1 then
--                            liczba <= '0';
--                            if j mod 2 = 0 then     
--                                next_state <= STANY'val((j/2) + 1);  --liczba parzysta
--                                --next_state <= get_state_index2((j/2) + 1);  
----                                get_state_index2((j/2)+1) <= STANY'val((j/2) + 1);  --liczba parzysta
----                                next_state <= get_state_index2((j/2) + 1);  
----                                next_state <= get_state_index2(((j / 2) + 1), bit_index, zmienna);
--                            elsif j mod 2 = 1 then 
--                                --next_state <= STANY'val((j/2) + 1);  -- liczba nieparzysta
--                                --next_state <= get_state_index2((j/2) + 1);  
----                                get_state_index2((j/2)+1) <= STANY'val((j/2) + 1);  -- liczba nieparzysta
----                                next_state <= get_state_index2((j/2) + 1); 
--                                next_state <= get_state_index2(((j / 2) + 1), bit_index, zmienna);
--                            end if;
--                        elsif zliczanie1 < zliczanie0 then
--                            liczba <= '1';
--                            if j mod 2 = 0 then      
--                                next_state <= STANY'val((j/2) + 32 + 1);  --liczba parzysta
--                                --next_state <= get_state_index2((j/2) + 32 + 1);
----                                get_state_index2((j/2)+1) <= STANY'val((j/2) + 32 + 1);  --liczba parzysta
----                                next_state <= get_state_index2((j/2) + 32 + 1);
----                                next_state <= get_state_index2(((j / 2) + 32 + 1), bit_index, zmienna);
--                            elsif j mod 2 = 1 then  
--                                next_state <= STANY'val((j/2) + 31 + 1); --liczba nieparzysta
--                                --next_state <= get_state_index2((j/2) + 31 + 1);
----                                get_state_index2((j/2)+1) <= STANY'val((j/2) + 31 + 1); --liczba nieparzysta
----                                next_state <= get_state_index2((j/2) + 31 + 1);
----                                next_state <= get_state_index2(((j / 2) + 31 + 1), bit_index, zmienna);
--                            end if;
----                        elsif zliczanie0 = zliczanie1 then
----                            state <= error;
--                        end if;
--                    end if;
--                end if;
--                if bit_index = 3 then
--                    next_state <= koniec;
--                end if;
--            end if;
--    end case;
--end process;

-- maszyna stanów dla funkcji get_state_index2
maszynaStanu: process(zmienna, state, counter0, counter1, zliczanie0, zliczanie1)  
    variable j : integer;   -- indeks bie¿¹cego stanu
    variable next_j : integer; -- indeks nastêpnego stanu
begin
    j := get_state_index(state); -- pobiera indeks bie¿¹cego stanu
    
    j_spr <= j;

    case state is
        when Idle =>
            if zmienna = '1' then
                next_state <= P0;
            else
                next_state <= Idle;
            end if;
        
        when koniec =>
            next_state <= Idle;
            liczba <= '0';
            
        when others =>
            if zmienna = '1' then
                if j = 0 or j = 1 then -- dla P0, P0_2, P1
                    if counter0 < counter1 then
                        liczba <= '0';
                        if state = P0 then 
                            next_state <= P0_2;
                        elsif state = P0_2 or state = P1 then
                            next_state <= P0;
                        end if; 
                    elsif counter1 < counter0 then
                        liczba <= '1';
                        next_state <= P32;
                    elsif counter0 = counter1 then
                        if zliczanie0 < zliczanie1 then
                            liczba <= '0';
                            if state = P0 then 
                                next_state <= P0_2;
                            elsif state = P0_2 or state = P1 then
                                next_state <= P0;
                            end if; 
                        elsif zliczanie1 < zliczanie0 then
                            liczba <= '1';
                            next_state <= P32;
                        else
                            -- Obs³u¿ sytuacjê, gdy zliczanie0 = zliczanie1, jeœli to konieczne
                        end if;    
                    end if;
                        
                elsif j = 62 or j = 63 then -- dla P62, P63_2, P63
                    if counter0 < counter1 then
                        liczba <= '0';
                        next_state <= P31;
                    elsif counter1 < counter0 then
                        liczba <= '1';
                        if state = P63 then
                            next_state <= P63_2;
                        elsif state = P63_2 or state = P62 then
                            next_state <= P63;
                        end if; 
                    elsif counter0 = counter1 then
                        if zliczanie0 < zliczanie1 then
                            liczba <= '0';
                            next_state <= P31;
                        elsif zliczanie1 < zliczanie0 then
                            liczba <= '1';
                            if state = P63 then
                                next_state <= P63_2;
                            elsif state = P63_2 or state = P62 then
                                next_state <= P63;
                            end if;
--                        elsif zliczanie1 = zliczanie0 then
--                            state <= error;                        
                        end if;
                    end if;
                    
                elsif (j >= 2) and (j <= 61) then -- stany od 2 do 61
                    if counter0 < counter1 then
                        liczba <= '0';
                        next_j := j/2; --next_j := (j / 2) + 1;     -- parzysta i nieparzysta
                        next_state <= get_state_index2(next_j, bit_index, zmienna);
                    elsif counter1 < counter0 then
                        liczba <= '1';
                        if (j mod 2) = 0 then                       -- parzysta
                            next_j := (j/2) + 32;   --next_j := (j / 2) + 32 + 1;
                        else                                        -- nieparzysta
                            next_j := (j/2) + 32;   --next_j := (j / 2) + 31 + 1;
                        end if;
                        next_state <= get_state_index2(next_j, bit_index, zmienna);
                    elsif counter0 = counter1 then
                        if zliczanie0 < zliczanie1 then
                            liczba <= '0';                          --dla parzystego jak i nieparzystego
                            next_j := j/2; --((j/2)+1);
                            next_state <= get_state_index2(next_j, bit_index, zmienna);
                        elsif zliczanie1 < zliczanie0 then
                            liczba <= '1';
                            if (j mod 2) = 0 then                       -- parzysta
                                next_j := (j/2) + 33; --next_j := (j / 2) + 32 + 1;
                            else                                        -- nieparzysta
                                next_j := (j/2) + 32; --next_j := (j / 2) + 31 + 1;
                            end if;
                            next_state <= get_state_index2(next_j, bit_index, zmienna);
                        end if;
                    end if;
                end if;
                if bit_index = 3 then
                    next_state <= koniec;
                end if;
            end if;
    end case;
end process;



d1 <= 19/2+31 + 1;
d2 <= 36/2;
d3 <= 19/2+31;

zmienna <= rx_dv;   


przejscia: process(state, next_state, previous_state)   
variable n : integer;                   --wartoœci z outputsów
variable local_bit_index : integer;     --bit index
variable local_bit_index_updated : boolean; -- sprawdza czy bit index sie zmienia 
variable local_first_D0 : boolean := false; -- odnosi siê do rozpoczynaj¹cego P0

begin
    local_bit_index := bit_index;
    local_bit_index_updated := bit_index_updated;
    local_first_D0 := first_D0;

    if state /= previous_state then
        local_bit_index_updated := false;
    end if;
    previous_state <= state;
        
        if state = Idle then   
            binary_value0 <= "0000";
            binary_value1 <= "0000";
            matrix_value0 <= 0;
            matrix_value1 <= 0;
            local_bit_index := 63;
            local_bit_index_updated := false;
            local_first_D0 := true;
    
        elsif state = koniec then
            matrix_value0 <= 0;
            matrix_value1 <= 0;
            binary_value0 <= "0000";
            binary_value1 <= "0000";
            local_bit_index := 63;
            local_bit_index_updated := false;

-- state = P0, bit_index = 63
        else
            if local_bit_index_updated = false then
                if state = P0 then
                    if local_first_D0 = false and local_bit_index = 63 then --local_first_D0 = true and local_bit_index = 63 then
                        local_first_D0 := true;
                    elsif local_first_D0 = true and local_bit_index < 63 then
                        local_bit_index := local_bit_index - 4;
                        local_bit_index_updated := true;
                    end if;
                else
                    local_bit_index := local_bit_index - 4; --dla pozostalych
                    local_bit_index_updated := true;
                end if;
            end if;

--state = P0, bit_index = 59
--        else
--            if local_bit_index_updated = false then
--                if state = P0 then
--                    if local_first_D0 = true and local_bit_index = 63 then
--                        local_first_D0 := false;
--                    else
--                        local_bit_index := local_bit_index - 4;
--                        local_bit_index_updated := true;
--                    end if;
--                else
--                    local_bit_index := local_bit_index - 4; --dla pozostalych
--                    local_bit_index_updated := true;
--                end if;
--            end if;
    
            n := get_state_index(state);
    
            if n >= 0 then
                matrix_value0 <= outputs(0, n);
                binary_value0 <= binary_values(matrix_value0);
                matrix_value1 <= outputs(1, n);
                binary_value1 <= binary_values(matrix_value1);
            else
                matrix_value0 <= 0;
                matrix_value1 <= 0;
                binary_value0 <= "0000";
                binary_value1 <= "0000";
                local_bit_index := 63;
                local_bit_index_updated := false;
            end if;
        end if;

    bit_index <= local_bit_index;
    bit_index_updated <= local_bit_index_updated;
    first_D0 <= local_first_D0;
end process;

xorowanie: process(state, bit_index, binary_value0, binary_value1)    --binary_value0, binary_value1
begin
    --if (binary_value0 /= "0000" or binary_value1 /= "0000") then --or (state = P0_2 or state = P63_2 or state = P0 or state = P3) or bit_index /= 0 then -- operacja wykona sie tylko gdy ktorys z warunków wykarze aktywnosc
        if state /= Idle then
            xor_result_0 <= (binary_value0 xor zakodowana_wiadomosc2(bit_index downto bit_index - 3)); --zakodowana_wiadomosc wskazuje poprawne wartosci
            xor_result_1 <= (binary_value1 xor zakodowana_wiadomosc2(bit_index downto bit_index - 3));
            pomocnicza <= zakodowana_wiadomosc2(bit_index downto bit_index - 3);
        elsif state = Idle then
            xor_result_0 <= (others => '0');
            xor_result_1 <= (others => '0');
        end if;
end process;

counterIzliczanie: process(xor_result_0, xor_result_1)    --zliczanie '1'
variable one_count_0 : integer := 0;    --do zliczania counterow
variable one_count_1 : integer := 0;

begin
    one_count_0 := 0;
    for i in xor_result_0'range loop    --pêtla przechodzi przez ka¿dy bit wektora xor_result_0 (przez ca³y zakres)
        if xor_result_0(i) = '1' then   --gdy gdzies pojawi sie '1' 
            one_count_0 := one_count_0 + 1; --zwiêksza siê wartoœæ one_count_0 o 1;
        end if;
    end loop;
        
    if one_count_0 = 0 then                                 -- gdy 0 b³êdów
        counter0 <= 0;
    elsif one_count_0 = 1 then                              -- 1 b³¹d
        counter0 <= 1;  
    elsif one_count_0 = 2 then                              -- 2 b³êdy
        counter0 <= 2;  
    elsif one_count_0 = 3 then                              -- 3 b³êdy
        counter0 <= 3;  
    elsif one_count_0 = 4 then                              -- 4 b³êdy
        counter0 <= 4;
    end if;  
    
    one_count_1 := 0;
    for i in xor_result_1'range loop
        if xor_result_1(i) = '1' then
            one_count_1 := one_count_1 + 1;
        end if;
    end loop;
    
    if one_count_1 = 0 then                                 -- gdy 0 b³êdów
        counter1 <= 0;
    elsif one_count_1 = 1 then                              -- gdy 1 b³¹d
        counter1 <= 1;  
    elsif one_count_1 = 2 then                              -- gdy 2 b³êdy
        counter1 <= 2;  
    elsif one_count_1 = 3 then                              -- gdy 3 b³êdy
        counter1 <= 3;
    elsif one_count_1 = 4 then                              -- gdy 4 b³êdy
        counter1 <= 4;  
    end if;
    
    if state = koniec or state = Idle then  --wyzerowanie na koniec liczników
        counter0 <= 0;
        counter1 <= 0;
    end if;
end process;


koncoweZliczanie : process(bit_index, counter1, counter0)
variable sumowanie0 : integer := 0;
variable sumowanie1 : integer := 0;
variable poprzedni_bit : integer := 0; -- zmienna pomocnicza do sprawdzania zmiany bit_index
begin
    if bit_index /= poprzedni_bit then  --jesli nie jest taki jak by³ poprzednio
        sumowanie0 := sumowanie0 + counter0;
        sumowanie1 := sumowanie1 + counter1;
    end if;
    
    poprzedni_bit := bit_index; --aktualizacja zmienej, sprawdza czy bit index jest inny od poprzedniego
    
    zliczanie0 <= sumowanie0;
    zliczanie1 <= sumowanie1;
    
    if state = koniec or state = Idle then  
        sumowanie0 := 0;
        sumowanie1 := 0;
        zliczanie0 <= 0;
        zliczanie1 <= 0;
    end if;
end process;

zdekodowana: process(CLK, reset)    -- rejestr przesuwny z odkodowan¹ wiadomoœci¹ 
begin
    if rising_edge(CLK) then
        if reset = '1' then
            odkodowana <= (others => '0');
            final_output <= (others => '0');
        elsif state /= Idle and state /= koniec then
            odkodowana(15 downto 1) <= odkodowana(14 downto 0);
            odkodowana(0) <= liczba;        -- dodawanie nowego bitu na pozycji 0
            final_output <= (others => '0');
        elsif state = koniec then
            final_output <= odkodowana;
        elsif state = Idle then
            odkodowana <= (others => '0');
            final_output <= (others => '0');
        end if;
    end if;
end process;

final_bit_d <= odkodowana;

dopliku: process(CLK)   
file        output_file            : text is out "C:\Users\ps-1\Desktop\moje\Zadanie 2\pliki\64_bity_wiadomosci.txt";   --zapisane w konkretnej œcie¿ce      
-- file        output_file         : text is out "C:\Users\ps-1\Desktop\moje\Zadanie 2\pliki\wysylanie.ptp";   -- rozszerzenie docklight     
variable    output_line            : line;  --tymczasowe przechowywanie danych przed ich zapisaniem
variable    good_v                 : boolean;
variable    char_input_v           : character;
variable    time_input_v           : time;

begin
    if rising_edge(CLK) then
       output_line := null;
       
       read(output_line, char_input_v, good_v);
       read(output_line, time_input_v, good_v);
    
        --if mamto = '1' then
            write(output_line, string'(" "), left, 0);   --spacja stworzona ¿eby dopisaæ drugi bajt, mozna w sumie ja usunac
--            write(output_line, MSG); 
            write(output_line, zakodowana_wiadomosc2); 
            writeline(output_file, output_line);
        --end if;
        
        if (good_v) then 
              assert (true) report "wyslano poprawnie!" severity failure;
        end if;
    end if;
end process;

dopliku_final: process(CLK)   
file        output_file            : text is out "C:\Users\ps-1\Desktop\moje\Zadanie 2\pliki\odkodowana_z_64b_do_16b.txt";   --zapisane w konkretnej œcie¿ce      
-- file        output_file         : text is out "C:\Users\ps-1\Desktop\moje\Zadanie 2\pliki\wysylanie.ptp";   -- rozszerzenie docklight     
variable    output_line            : line;  --tymczasowe przechowywanie danych przed ich zapisaniem
variable    good_v                 : boolean;
variable    char_input_v           : character;
variable    time_input_v           : time;

begin
    if rising_edge(CLK) then
       output_line := null;
       
       read(output_line, char_input_v, good_v);
       read(output_line, time_input_v, good_v);
    
        --if mamto = '1' then
            write(output_line, string'(" "), left, 0);   --spacja stworzona ¿eby dopisaæ drugi bajt, mozna w sumie ja usunac
--            write(output_line, MSG); 
            write(output_line, odkodowana); 
            writeline(output_file, output_line);
        --end if;
        
        if (good_v) then 
              assert (true) report "wyslano poprawnie!" severity failure;
        end if;
    end if;
end process;


end Behavioral;

