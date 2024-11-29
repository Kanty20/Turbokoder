library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

entity koder is
Port (
      CLK : in std_logic;
      start_bit : in std_logic_vector(15 downto 0); -- tu bedzie wartosc przzed kodowaniem 
      final_bit : out std_logic_vector(63 downto 0); --pozniej zmienic na 64, tu bedzie wychodzic zakodowana wartosc
      put : in std_logic;       --button
      reset : in std_logic
      );
end koder;

architecture Behavioral of koder is

type STANY is (E0, E1); --do nadawania bitow
signal state, estate : STANY := E0;

signal g0 : std_logic_vector(6 downto 0) := "1111111";
signal g1 : std_logic_vector(6 downto 0) := "1011001";
signal g2 : std_logic_vector(6 downto 0) := "1010011";
signal g3 : std_logic_vector(6 downto 0) := "1000101";
signal bits : std_logic_vector (15 downto 0) := "1100100100111010"; --DO ZMIANY, zanim bêde podawaæ wartoœci z start_bit
signal MSG : std_logic_vector(63 downto 0) := (others => '0'); --others dodane pozniej
signal msg0 : std_logic_vector(6 downto 0) := "0000000";
signal msg1 : std_logic_vector(6 downto 0) := "0000000";
signal msg2 : std_logic_vector(6 downto 0) := "0000000";
signal msg3 : std_logic_vector(6 downto 0) := "0000000";
signal result_g0 : std_logic_vector(15 downto 0) := (others => '0');
signal result_g1 : std_logic_vector(15 downto 0) := (others => '0');
signal result_g2 : std_logic_vector(15 downto 0) := (others => '0');
signal result_g3 : std_logic_vector(15 downto 0) := (others => '0');
signal modulo : std_logic := '0';
signal modulo1 : std_logic := '0';
signal modulo2 : std_logic := '0';
signal modulo3 : std_logic := '0';
signal oki  : std_logic_vector(15 downto 0) := (others => '0');
signal oki1 : std_logic_vector(15 downto 0) := (others => '0');
signal oki2 : std_logic_vector(15 downto 0) := (others => '0');
signal oki3 : std_logic_vector(15 downto 0) := (others => '0');
signal i            : integer range 0 to 15 := 15;
signal step_counter : integer range 0 to 20 := 20;
signal process_done : boolean := false;
signal full         : boolean := false;
signal mamto        : std_logic := '0';

-- dane na 1200 bitow
signal bits_data : std_logic_vector(1199 downto 0) := (others => '0'); -- wieksza ilosc 
signal bits_ascii : string(1 to 150) := "Vivamus tincidunt porta urna at commodo. Donec ut nisl iaculis, condimentum arcu et, ullamcorper augue. Aliquam vitae arcu laoreet, aliquet tellus eu.";
signal result_g0_12 : std_logic_vector(1199 downto 0) := (others => '0');
signal result_g1_12 : std_logic_vector(1199 downto 0) := (others => '0');
signal result_g2_12 : std_logic_vector(1199 downto 0) := (others => '0');
signal result_g3_12 : std_logic_vector(1199 downto 0) := (others => '0');
signal MSG_12 : std_logic_vector(4799 downto 0) := (others => '0');    
signal oki_12  : std_logic_vector(1199 downto 0) := (others => '0');
signal oki1_12 : std_logic_vector(1199 downto 0) := (others => '0');
signal oki2_12 : std_logic_vector(1199 downto 0) := (others => '0');
signal oki3_12 : std_logic_vector(1199 downto 0) := (others => '0');
signal msg0_12 : std_logic_vector(6 downto 0) := "0000000";
signal msg1_12 : std_logic_vector(6 downto 0) := "0000000";
signal msg2_12 : std_logic_vector(6 downto 0) := "0000000";
signal msg3_12 : std_logic_vector(6 downto 0) := "0000000";
signal matlab : std_logic_vector(4799 downto 0) := "000011111000000101001000000100001000010101000011001011011101011011101011010000000000101110001010011101010100001111010101001110100111000110111111011111010101100000100010111011110000101101111101000101110001111100000100000010110011110110101011101100111001101011111111011110011010010001110010100110011101100111011101110101101110101101001111011111011010111101000000101100111101010111000010100111010010010110000010110101101110101101001111100001011011101100110110110101101010010001111101000101110001000001111101101011110100000010111100010101000111001010010110010101111110110010011010111111110111100110101011111111000101000001110110110100101010000011001110011101011111010000000100101111001110001101010100011100101001100111011001001001010011101001111110001100010100001110011010111111110111100110100100011111010001011100011111000001000000010010111100111011000010001010101111010000001011001111010101001110100111111000110001010000111001101011111111011101100010010100111010011100011011000000001011011100101001011001010111111011001001101011111111011101100010010111000010100111010010010110001101101000001100111001111010100011010101100000100010111000000111110101011000001000101110000001111101101000001100111001111010011101011011101100110110110110011101001010100000110000011111010001000100000000000100111100111101000111001001101011111111100011101100011000100001110001101101100111010010101000001100111001111010100011011010111101000000101100111101101010110100101110000001000010001010110000101001001010101011101100111001101011111111011110011010010001111101000101110001111100001011011100101001011001010111111011001001101011111111011101101101001010101111010000001011001100101101110101101110101101000000000001000000101100110010001001011000110101010111101000111010011111101100100110101111111101110110110111011101011011101011010011111000101000111010011100011011111110001010110000101001110100101010111110110111110100010111000100000111110101010111101011000010100111011101110101101110101101000000000001000000101100111101101010110100010011111000101000111010011111101100100110101111111101110110001001011100001010011101001001011000110110100000110011100111101010001101101011110100000010110011110110101011101100110110110110011101110111010110111010110100111101111101010110000010001011100000100001011011010010111000000100000111110110101111010000001011110001010100011100101001100111010110101001000111110100010111000100000111110101011000001011010110111001000011100110101111111101110110001001010011101001110001101100000000010000000100101111001110110011010101110000101001110100101010111110110111110100011000100111100100001110011010111111110111011000101010101101001011100000011111000010110111001010010110010101110001101111111000101000111010011111101100100110101111111101111001101001000111110100010111000100000111110101010111101011000010100111010010010101111010110000101001001001010011101001110001101111110111110101011000001000101110000010001010110000101001110100100101100011011010000011001110011101011111010000000100101111001110001101011011111111000101000001110110001010101011010010111000000111110000010000000100101100110110001000011100100110101111111101110110001001010011101001110001101100000000101101111101000101110001000010000101010011000101010010000101111110110111110100010111000100001000010110110100101101111001111010110100000000000100111100111101000111001001101011111111100011101100100110100000100000011011111101111101010101111010110000101001110111011101011011101011010000000000010011110011110111101011000000001011011111010001011100010000100010100011101001110001101111110111110101011000001011010110111001000011100110101111111101111001101001001000101001110101010000110010110111010110111010110100000000001011011100101001100111011001001001010011101001110001101111111000010110110100101101111001111001000011100110101111111101110110001001010011101001110001101100000000010000000100101111001110110011010101110000101001110100101010111110110111110100011000100111100100001110011010111111110111011011010010010101111010110000101001001001010011101001110001101111110111110110100000110011100111010111110100000001001011110011101100110110101011010010111000000100001000010110110100101110000001111100001011011100101001011001010111000110111111100010100011101001111110110010011010111111110111011000100101001110100111000110111111011111010101011110101100001010011101110111010110111010110100000000000100111100111101111010110000000010110111110100010111000100001000010110110100101110000001111100001011011100101001011001010111111011001001101011111111011110011010010001110010100110011101100100101010101101001011100000010000011111010101011110101100001010011101001001010111101011000010011010100100011111010001011100011111000001000000101100111101101010111011001110011010111111110111011000101010101101001011100000011111000010110111110100011000100111101011010000000000";
signal zgadzasie : std_logic := '0';

begin

------------------------------------------------------------------------------------------- 16 bitów

--bits <= start_bit;

--resetowanie dla 16 bitow
resetowanie: process(CLK, reset)    
begin
    if reset = '1' then
        result_g0 <= (others => '0');
        result_g1 <= (others => '0');
        result_g2 <= (others => '0');
        result_g3 <= (others => '0');
    elsif rising_edge(CLK) then
        if i >= 0 then  --od 15, przesuniecie bitowe, dla ka¿dej z macierzy
            result_g0 <= result_g0(14 downto 0) & bits(i);
            result_g1 <= result_g1(14 downto 0) & bits(i);
            result_g2 <= result_g2(14 downto 0) & bits(i);
            result_g3 <= result_g3(14 downto 0) & bits(i);
            process_done <= true;
        end if;
    end if;
end process;

encoder: process(CLK, state, put)   -- maszyna stanow w zalznosci od przycisku
begin  
    if rising_edge(CLK) then
        case state is       
            when E0 =>  
            if put = '1' then
                estate <= E1;
            else 
                estate <= E0;
            end if;
    
           when E1 =>  
            if put = '0' then
                estate <= E0;
            else 
                estate <= E1;
            end if;
            
            when others =>
                estate <= E0; 
        end case;
            state <= estate;
   end if;     
end process;

petla_16_bitowa: process(CLK, reset) 
begin
    if reset = '1' then
        MSG <= (others => '0');
        i <= 15;
        modulo <= '0';
        modulo1 <= '0';
        modulo2 <= '0';
        modulo3 <= '0';
        msg0 <= (others => '0');
        
    elsif rising_edge(CLK) then 
     case state is
        when E0 =>
            MSG <= (others => '0');
            i <= 15;       --z prawej strony jest najstarszy bit
            modulo <= '0';
            modulo1 <= '0';
            modulo2 <= '0';
            modulo3 <= '0';
            msg0 <= (others => '0');
            msg1 <= (others => '0');
            msg2 <= (others => '0');
            msg3 <= (others => '0');
                                    
        when E1 =>
        --if i <= 15 then       --w odwrotna strone bity
        --if i >= 0 then          --poprawne
        if process_done = true then
            msg0(6) <= result_g0(0) and g0(6);
            msg0(5) <= result_g0(1) and g0(5);
            msg0(4) <= result_g0(2) and g0(4);
            msg0(3) <= result_g0(3) and g0(3);
            msg0(2) <= result_g0(4) and g0(2);
            msg0(1) <= result_g0(5) and g0(1);
            msg0(0) <= result_g0(6) and g0(0);
            modulo <= msg0(6) xor msg0(5) xor msg0(4) xor msg0(3) xor msg0(2) xor msg0(1) xor msg0(0);  --mod2
            --oki(15 downto 0) <= oki(14 downto 0) & modulo;       --rejestr przesuwny
                    
--            result_g1 <= result_g1(14 downto 0) & bits(i);
----                msg1 <= result_g1(15 downto 9) and g1;
            msg1(6) <= result_g1(0) and g1(6);
            msg1(5) <= result_g1(1) and g1(5);
            msg1(4) <= result_g1(2) and g1(4);
            msg1(3) <= result_g1(3) and g1(3);
            msg1(2) <= result_g1(4) and g1(2);
            msg1(1) <= result_g1(5) and g1(1);
            msg1(0) <= result_g1(6) and g1(0);
            modulo1 <= msg1(6) xor msg1(5) xor msg1(4) xor msg1(3) xor msg1(2) xor msg1(1) xor msg1(0);
            --oki1 <= oki1(14 downto 0) & modulo1;
        
--            result_g2 <= result_g2(14 downto 0) & bits(i);
----                msg2 <= result_g2(15 downto 9) and g2;
            msg2(6) <= result_g2(0) and g2(6);
            msg2(5) <= result_g2(1) and g2(5);
            msg2(4) <= result_g2(2) and g2(4);
            msg2(3) <= result_g2(3) and g2(3);
            msg2(2) <= result_g2(4) and g2(2);
            msg2(1) <= result_g2(5) and g2(1);
            msg2(0) <= result_g2(6) and g2(0);
            modulo2 <= msg2(6) xor msg2(5) xor msg2(4) xor msg2(3) xor msg2(2) xor msg2(1) xor msg2(0);
            --oki2 <= oki2(14 downto 0) & modulo2;
            
--            result_g3 <= result_g3(14 downto 0) & bits(i);
----                msg3 <= result_g3(15 downto 9) and g3;
            msg3(6) <= result_g3(0) and g3(6);
            msg3(5) <= result_g3(1) and g3(5);
            msg3(4) <= result_g3(2) and g3(4);
            msg3(3) <= result_g3(3) and g3(3);
            msg3(2) <= result_g3(4) and g3(2);
            msg3(1) <= result_g3(5) and g3(1);
            msg3(0) <= result_g3(6) and g3(0);
            modulo3 <= msg3(6) xor msg3(5) xor msg3(4) xor msg3(3) xor msg3(2) xor msg3(1) xor msg3(0);
            --oki3 <= oki3(14 downto 0) & modulo3;
--         --i <= i + 1;  -- w odwrotna strone bity

            if not full then    -- zeby nie przelatywalo cale przesuniecie bitowe, tylko gdy zapelni sie 16 bitami zeby stanelo 
                oki(15 downto 0) <= oki(14 downto 0) & modulo; -- Dodawanie do rejestru przesuwnego
                oki1(15 downto 0) <= oki1(14 downto 0) & modulo1;
                oki2(15 downto 0) <= oki2(14 downto 0) & modulo2;
                oki3(15 downto 0) <= oki3(14 downto 0) & modulo3;
                
                -- Sprawdzanie, czy `oki` jest pe³ne
                if oki(13) = '1' then   --zatrzymanie, gdy ramka 16 bitow
                    full <= true;
                end if;
                
                if oki1(13) = '1' then
                    full <= true;
                end if;
                
                if oki2(13) = '1' then
                    full <= true;
                end if;
                
                if oki3(13) = '1' then
                    full <= true;
                end if;
            end if;
            
            if full then
                modulo <= '0'; -- Resetowanie `modulo` po osi¹gniêciu 16 bitów
                modulo1 <= '0';
                modulo2 <= '0';
                modulo3 <= '0';
            end if;

            for p in 0 to 15 loop   
                MSG(p*4+3 downto p*4) <= oki(p) & oki1(p) & oki2(p) & oki3(p);
                mamto <= '1';        
                -----------------
                -- gdy p = 0, zakres to 3 downto 0, czyli bity 3,2,1,0
                -- gdy p = 1, zakres to 7 downto 4, czyli bity 7,6,5,4
                -- gdy p = 2, zakres to 11 downto 8, czyli bity 11,10,9,8
                -----------------        
            end loop;
                
        i <= i - 1; --poprawne
            end if;
        end case;
    end if;
end process;

final_bit <= MSG;

------------------------------------------------------------------------------------------- 1200 bitów

--kodowanie_1200: process(bits_ascii) -- obracanie bitow
--variable temp_byte : std_logic_vector(7 downto 0);  --podzielenie na 8 bitow
--begin
--    for a in 1 to 150 loop      -- 150 znakow ktore beda 8 bitowe, od 1 do 150 poniewa¿ dla wartoœci typu string uzywa sie indeksowania od 1
--        temp_byte := std_logic_vector(to_unsigned(character'pos(bits_ascii(a)), 8)); --wektor przechodzacy do unsigned, a nastepnie character zeby zapisac z ascii na 8 bitow   
--   ----------
--   -- 'pos - zwraca pozycje danej wartosci typu wyliczeniowgo, w tym przypadku character
--   -- to_unsigned(...,8) - konwertuje liczbe na postac binarna
--   ----------
--        bits_data((150-a)*8+7 downto (150-a)*8) <= temp_byte;   --odwrócenie kolejnosci wektora, (150-a) znak "L" trafi na najnizsze bity, a ostatni znak na najwyzsze
--        --bits_data(a*8-1 downto (a-1)*8) <= temp_byte;      -- Przypisanie 8-bitowego kodu binarnego do odpowiedniej czêœci wyjœcia bits_output, jak bylo z rejestrem przesuwnym
--        --powyzsza linijka jest poprawna, ale zapisuje "od koñca wartosci"
--    end loop;
--end process;

---- resetowanie dla 1200 bitow
--resetowanie: process(CLK, reset)    
--begin
--    if reset = '1' then
--        result_g0_12 <= (others => '0');
--        result_g1_12 <= (others => '0');
--        result_g2_12 <= (others => '0');
--        result_g3_12 <= (others => '0');
--    elsif rising_edge(CLK) then
--        if i >= 0 then  --od 1199, przesuniecie bitowe, dla ka¿dej z macierzy
--            result_g0_12 <= result_g0_12(1198 downto 0) & bits_data(i);
--            result_g1_12 <= result_g1_12(1198 downto 0) & bits_data(i);
--            result_g2_12 <= result_g2_12(1198 downto 0) & bits_data(i);
--            result_g3_12 <= result_g3_12(1198 downto 0) & bits_data(i);
--            process_done <= true;
--        end if;
--    end if;
--end process;

--petla_1200_bitowa: process(CLK) 
--begin
--    if reset = '1' then
--        i <= 1199;
--        modulo <= '0';
--        modulo1 <= '0';
--        modulo2 <= '0';
--        modulo3 <= '0';
--        msg0 <= (others => '0');
--        msg1 <= (others => '0');
--        msg2 <= (others => '0');
--        msg3 <= (others => '0');
        
--    elsif rising_edge(CLK) then 
--     case state is
--        when E0 =>
--            MSG_12 <= (others => '0');
--            i <= 1199;       --z prawej strony jest najstarszy bit
--            modulo <= '0';
--            modulo1 <= '0';
--            modulo2 <= '0';
--            modulo3 <= '0';
--            msg0 <= (others => '0');
--            msg1 <= (others => '0');
--            msg2 <= (others => '0');
--            msg3 <= (others => '0');
                                    
--        when E1 =>
--        if process_done = true then
--            msg0(6) <= result_g0_12(0) and g0(6);
--            msg0(5) <= result_g0_12(1) and g0(5);
--            msg0(4) <= result_g0_12(2) and g0(4);
--            msg0(3) <= result_g0_12(3) and g0(3);
--            msg0(2) <= result_g0_12(4) and g0(2);
--            msg0(1) <= result_g0_12(5) and g0(1);
--            msg0(0) <= result_g0_12(6) and g0(0);
--            modulo <= msg0(6) xor msg0(5) xor msg0(4) xor msg0(3) xor msg0(2) xor msg0(1) xor msg0(0);  --mod2
            
--            msg1(6) <= result_g1_12(0) and g1(6);
--            msg1(5) <= result_g1_12(1) and g1(5);
--            msg1(4) <= result_g1_12(2) and g1(4);
--            msg1(3) <= result_g1_12(3) and g1(3);
--            msg1(2) <= result_g1_12(4) and g1(2);
--            msg1(1) <= result_g1_12(5) and g1(1);
--            msg1(0) <= result_g1_12(6) and g1(0);
--            modulo1 <= msg1(6) xor msg1(5) xor msg1(4) xor msg1(3) xor msg1(2) xor msg1(1) xor msg1(0);
           
--            msg2(6) <= result_g2_12(0) and g2(6);
--            msg2(5) <= result_g2_12(1) and g2(5);
--            msg2(4) <= result_g2_12(2) and g2(4);
--            msg2(3) <= result_g2_12(3) and g2(3);
--            msg2(2) <= result_g2_12(4) and g2(2);
--            msg2(1) <= result_g2_12(5) and g2(1);
--            msg2(0) <= result_g2_12(6) and g2(0);
--            modulo2 <= msg2(6) xor msg2(5) xor msg2(4) xor msg2(3) xor msg2(2) xor msg2(1) xor msg2(0);
           
--            msg3(6) <= result_g3_12(0) and g3(6);
--            msg3(5) <= result_g3_12(1) and g3(5);
--            msg3(4) <= result_g3_12(2) and g3(4);
--            msg3(3) <= result_g3_12(3) and g3(3);
--            msg3(2) <= result_g3_12(4) and g3(2);
--            msg3(1) <= result_g3_12(5) and g3(1);
--            msg3(0) <= result_g3_12(6) and g3(0);
--            modulo3 <= msg3(6) xor msg3(5) xor msg3(4) xor msg3(3) xor msg3(2) xor msg3(1) xor msg3(0);           

--            if not full then    -- zeby nie przelatywalo cale przesuniecie bitowe, tylko gdy zapelni sie 16 bitami zeby stanelo 
--                oki_12(1199 downto 0) <= oki_12(1198 downto 0) & modulo; -- Dodawanie do rejestru przesuwnego
--                oki1_12(1199 downto 0) <= oki1_12(1198 downto 0) & modulo1;
--                oki2_12(1199 downto 0) <= oki2_12(1198 downto 0) & modulo2;
--                oki3_12(1199 downto 0) <= oki3_12(1198 downto 0) & modulo3;
                
--                -- Sprawdzanie, czy `oki` jest pe³ne
--                if oki_12(1197) = '1' then   --zatrzymanie, gdy ramka 16 bitow
--                    full <= true;
--                end if;
                
--                if oki1_12(1197) = '1' then --bylo 1196
--                    full <= true;
--                end if;
                
--                if oki2_12(1197) = '1' then
--                    full <= true;
--                end if;
                
--                if oki3_12(1197) = '1' then
--                    full <= true;
--                end if;
--            end if;
            
--            if full then
--                modulo <= '0'; -- Resetowanie `modulo` po osi¹gniêciu 16 bitów
--                modulo1 <= '0';
--                modulo2 <= '0';
--                modulo3 <= '0';
--            end if;

--            for p in 0 to 1199 loop   
--                MSG_12(p*4+3 downto p*4) <= oki_12(p) & oki1_12(p) & oki2_12(p) & oki3_12(p);
--                mamto <= '1';        
--                -----------------
--                -- gdy p = 0, zakres to 3 downto 0, czyli bity 3,2,1,0
--                -- gdy p = 1, zakres to 7 downto 4, czyli bity 7,6,5,4
--                -- gdy p = 2, zakres to 11 downto 8, czyli bity 11,10,9,8
--                -----------------        
--            end loop;
                
--        i <= i - 1; --poprawne
--            end if;
--        end case;
--    end if;
--end process;

--sprawdzenie_poprawnosci: process(CLK)
--begin
--    if MSG_12 = matlab then
--        zgadzasie <= '1';
--    else
--        zgadzasie <= '0';
--    end if;
--end process;

-------------------------------------------------------------------------------  zapisanie do pliku
             
dopliku: process(CLK)   
file        output_file            : text is out "C:\Users\ps-1\Desktop\moje\Zadanie 2\pliki\koder.txt";   --zapisane w konkretnej œcie¿ce      
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
    
        if mamto = '1' then
            write(output_line, string'(" "), left, 0);   --spacja stworzona ¿eby dopisaæ drugi bajt, mozna w sumie ja usunac
            write(output_line, MSG); 
--            write(output_line, MSG_12); 
            writeline(output_file, output_line);
        end if;
        
        if (good_v) then 
              assert (true) report "wyslano poprawnie!" severity failure;
        end if;
    end if;
end process;

--final_bit <= X"0000";
--final_bit <= MSG;

end Behavioral;
