library ieee;
use ieee.numeric_bit.all;

entity UC is
    generic (
        clks_per_cycle : integer := 25000000
    );
    port (
        clock, reset  : in bit;
        RGBY          : in bit_vector(3 downto 0);
        rng_ready     : in bit;
        mem_finished  : in bit;
        death         : in bit;
        play_finished : in bit;
        rec           : out bit;
        start         : out bit;
        seq           : out bit;
        play          : out bit;
        round         : out bit_vector(6 downto 0);
        life_led      : out bit_vector(2 downto 0)
        );
end entity;

architecture arch_uc of UC is
    type state is (reset_s, start_s, mem_s, play_s);
    signal present_state : state := reset_s;
    signal clk_count     : integer range 0 to clks_per_cycle-1 := 0;
    signal round_count   : unsigned(6 downto 0);
    signal life          : unsigned(1 downto 0);
    
begin
    process(clock, reset)
    begin
        if(reset = '1') then
            rec           <= '1';
            start         <= '0';
            seq           <= '0';
            play          <= '0';
            life          <= (others => '0');
            round_count   <= (others => '0');
            present_state <= reset_s;
            
        elsif(falling_edge(clock)) then
            case present_state is
                when reset_s =>
                    rec          <= '1';
                    start        <= '0';
                    seq          <= '0';
                    play         <= '0';
                    life         <= (others => '0');
                    round_count  <= (others => '0');
                    if RGBY /= "0000" then
                        present_state <= start_s;
                    else
                        present_state <= reset_s;
                    end if;
                
                when start_s =>
                    rec   <= '0';
                    start <= '1';
                    seq   <= '0';
                    play  <= '0';
                    life  <= "11";
                    if rng_ready = '1' then
                        present_state <= mem_s;
                    else
                        present_state <= start_s;
                    end if;

                when mem_s =>
                    rec   <= '0';
                    start <= '0';
                    seq   <= '1';
                    play  <= '0';
                    if mem_finished = '1' then
                        present_state <= play_s;
                    else
                        present_state <= mem_s;
                    end if;

                when play_s =>
                    rec   <= '0';
                    start <= '0';
                    seq   <= '0';
                    play  <= '1';
                    if death = '1' then
                        life <= life - 1;
                        if(life /= "01" and life /= "00") then
                            present_state <= mem_s;
                        else
                            present_state <= reset_s;
                        end if;
                    elsif play_finished = '1' then
                        round_count <= round_count + 1;
                        present_state <= mem_s;
                    else
                        present_state <= play_s;
                    end if;

                when others =>
                    present_state <= reset_s;
            end case;
        end if;
    end process;

    round     <= bit_vector(round_count);
    life_led  <= "111" when life = "11" else
                 "011" when life = "10" else
                 "001" when life = "01" else
                 "000" when life = "00" else
                 "000";
end architecture;

------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity seq_round is
    generic (
        clks_per_cycle : integer := 50000000
    );
    port (
        clock, reset  : in bit;
        seq           : in bit_vector(255 downto 0);
        round         : in bit_vector(6 downto 0);
        active        : in bit;
        led           : out bit_vector(3 downto 0);
        done          : out bit
    );
end entity;

architecture arch_seq_round of seq_round is
    signal clk_count   : integer range 0 to clks_per_cycle-1 := 0;
    signal round_count : integer range 0 to 255;
    signal color       : bit_vector(1 downto 0);

begin
    process(clock, reset)
    begin
        if(reset = '1' or active = '0') then
            clk_count <= 0;
            round_count <= 0;
            color <= "00";
        elsif(rising_edge(clock) and active = '1') then
            color <= seq((2*round_count+1) downto (2*round_count));
            if clk_count < clks_per_cycle then
                clk_count <= clk_count + 1;
            else
                round_count <= round_count + 1;
                clk_count <= 0;
            end if;
        end if;
    end process;

    led <= "0001" when (color = "00" and active = '1' and clk_count <= (8*clks_per_cycle/10)) else
           "0010" when (color = "01" and active = '1' and clk_count <= (8*clks_per_cycle/10)) else
           "0100" when (color = "10" and active = '1' and clk_count <= (8*clks_per_cycle/10)) else
           "1000" when (color = "11" and active = '1' and clk_count <= (8*clks_per_cycle/10)) else
           "0000" when (clk_count > (8*clks_per_cycle/10));

    done <= '1' when round_count = to_integer(unsigned(round)) else '0';
end architecture;

------------------------------------------------------------------------

library ieee;
use IEEE.numeric_bit.all;
entity hex2seg is
    port ( hex : in  bit_vector(3 downto 0);
           seg : out bit_vector(6 downto 0)
        );
end hex2seg;

architecture comportamental of hex2seg is
begin
	seg <=  not "0111111" when hex = "0000" else
			not "0000110" when hex = "0001" else
			not "1011011" when hex = "0010" else
			not "1001111" when hex = "0011" else
			not "1100110" when hex = "0100" else
			not "1101101" when hex = "0101" else
			not "1111101" when hex = "0110" else
			not "0000111" when hex = "0111" else
			not "1111111" when hex = "1000" else
			not "1101111" when hex = "1001" else
			not "1110111" when hex = "1010" else
			not "1111100" when hex = "1011" else
			not "0111001" when hex = "1100" else
			not "1011110" when hex = "1101" else
			not "1111001" when hex = "1110" else
			not "1110001" when hex = "1111";


end comportamental;

------------------------------------------------------------------------

library ieee;
use IEEE.numeric_bit.all;
entity dec2seg is
    port ( round  : in  bit_vector(6 downto 0);
           HEX0   : out bit_vector(6 downto 0);
           HEX1   : out bit_vector(6 downto 0);
           HEX2   : out bit_vector(6 downto 0);
           HEX3   : out bit_vector(6 downto 0);
           HEX4   : out bit_vector(6 downto 0)
        );
end dec2seg;

architecture arch_dec2seg of dec2seg is
    component hex2seg is
        port ( hex : in  bit_vector(3 downto 0);
               seg : out bit_vector(6 downto 0)
            );
    end component;

    signal dec : unsigned(6 downto 0);
    signal d0, d1, d2, d3 : unsigned(3 downto 0);
    signal h0, h1, h2, hn : bit_vector(6 downto 0);

begin
    dec <= unsigned(round)-1;

    d0 <= "0000" when dec mod 10 = 0 else
          "0001" when dec mod 10 = 1 else
          "0010" when dec mod 10 = 2 else
          "0011" when dec mod 10 = 3 else
          "0100" when dec mod 10 = 4 else
          "0101" when dec mod 10 = 5 else
          "0110" when dec mod 10 = 6 else
          "0111" when dec mod 10 = 7 else
          "1000" when dec mod 10 = 8 else
          "1001" when dec mod 10 = 9;
    
    d1 <= "0000" when dec/10 mod 10 = 0 else
          "0001" when dec/10 mod 10 = 1 else
          "0010" when dec/10 mod 10 = 2 else
          "0011" when dec/10 mod 10 = 3 else
          "0100" when dec/10 mod 10 = 4 else
          "0101" when dec/10 mod 10 = 5 else
          "0110" when dec/10 mod 10 = 6 else
          "0111" when dec/10 mod 10 = 7 else
          "1000" when dec/10 mod 10 = 8 else
          "1001" when dec/10 mod 10 = 9;

    d2 <= "0000" when dec/100 mod 10 = 0 else
          "0001" when dec/100 mod 10 = 1;

    xD0 : hex2seg port map (bit_vector(d0), h0);
    xD1 : hex2seg port map (bit_vector(d1), h1);
    xD2 : hex2seg port map (bit_vector(d2), h2);
    x0  : hex2seg port map ("0000", hn);

    HEX0 <= hn;

    HEX1 <= (others => '1') when (dec = 0 or (round = "0000000")) else
            hn              when dec > 0 else
            (others => '1');

    HEX2 <= (others => '1') when (dec = 0 or (round = "0000000")) else
            h0              when dec > 0 else
            (others => '1');

    HEX3 <= (others => '1') when (dec < 10 or (round = "0000000")) else
            h1              when dec >= 10 else
            (others => '1');

    HEX4 <= (others => '1') when (dec < 100 or (round = "0000000")) else
            h2              when dec >= 100 else
            (others => '1');

end architecture;

------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity play_round is
    generic (
        clks_per_cycle : integer := 25000000
    );
    port (
        clock, reset  : in bit;
        seq           : in bit_vector(255 downto 0);
        round         : in bit_vector(6 downto 0);
        active        : in bit;
        RGBY          : in bit_vector(3 downto 0);
        led           : out bit_vector(3 downto 0);
        done          : out bit;
        death         : out bit
    );
end entity;

architecture arch_play of play_round is
    type state_main is (reset_s, on_s, play_s);
    signal state       : state_main := reset_s;
    signal round_count : integer range 0 to 255;
    signal color_user  : bit_vector(1 downto 0);
    signal color_seq   : bit_vector(1 downto 0);

begin
    process(clock, reset)
    begin
        if(reset = '1' or active = '0') then
            round_count <= 0;
            color_user <= "00";
            color_seq <= "00";
            death <= '0';
            state <= reset_s;
        elsif(rising_edge(clock) and active = '1') then
            case state is
                when reset_s =>
                    round_count <= 0;
                    color_user <= "00";
                    color_seq <= "00";
                    death <= '0';
                    if active = '1' then
                        state <= on_s;
                    else
                        state <= reset_s;
                    end if;
                
                when on_s =>
                    color_seq <= seq((2*round_count+1) downto (2*round_count));
                    if RGBY /= "0000" then
                        case RGBY is
                            when "0001" => color_user <= "00";
                            when "0010" => color_user <= "01";
                            when "0100" => color_user <= "10";
                            when "1000" => color_user <= "11";
							when others => color_user <= "00";
                        end case;
                        state <= play_s;
                    else
                        state <= on_s;
                    end if;

                when play_s =>
                    if RGBY = "0000" then
                        if(color_user = color_seq) then
                            round_count <= round_count + 1;
                            state <= on_s;
                        else
                            death <= '1';
                            state <= reset_s;
                        end if;
                    end if;
            end case;
        end if;
    end process;
    
    led <= RGBY;
    done <= '1' when round_count = to_integer(unsigned(round)) else '0';

end architecture;

------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity reg is
    port (
        clock, reset    : in bit;
        active          : in bit;
        ai              : in bit_vector(255 downto 0);
        ao              : out bit_vector(255 downto 0);
        done            : out bit
    );
end entity;

architecture arch_reg of reg is
    signal internal : bit_vector(255 downto 0);
    signal check    : bit_vector(255 downto 0);

begin
    process(clock, reset)
    begin
        if(reset = '1') then
            internal <= (others => '0');
            check <= (others => '0');
            done <= '0';
        elsif(rising_edge(clock)) then
            if(active = '1') then
                internal <= ai;
                if(internal /= check) then
                    check <= ai;
                    done <= '1';
                end if;
            end if;
        end if;
    end process;
    ao <= internal;

end architecture;

------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity random_step is
    port (
        clock, reset  : in bit;
        active        : in bit;
        rec           : in bit;
        rng           : out bit_vector(255 downto 0);
        done          : out bit
    );
end entity;

architecture arch_random of random_step is
    component stepfunner is
        port (
          ai : in bit_vector(31 downto 0);
          rng : out bit_vector(255 downto 0)
        );
    end component;

    component reg is
        port (
            clock, reset    : in bit;
            active          : in bit;
            ai              : in bit_vector(255 downto 0);
            ao              : out bit_vector(255 downto 0);
            done            : out bit
        );
    end component;

    signal clock_count : unsigned(31 downto 0);
    signal seed        : bit_vector(31 downto 0);
    signal rng_i       : bit_vector(255 downto 0);
    signal reg_rst     : bit;

begin
    reg_rst <= reset or rec;
    process(clock, reset)
    begin
        if(reset = '1') then
            clock_count <= (others => '0');
            seed <= (others => '0');
        elsif(rising_edge(clock)) then
            if(active = '1') then
                seed <= bit_vector(clock_count);
            end if;
            clock_count <= clock_count + 1;
        end if;
    end process;

    xRng : stepfunner port map (seed, rng_i);
    xReg : reg port map (clock, reg_rst, active, rng_i, rng, done);

end architecture;

------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity giragira is
    generic (
        clks_per_cycle : integer := 25000000
    );
    port (
        clock        : in bit;
        led          : out bit_vector(3 downto 0)
    );
end entity;

architecture arch_gira of giragira is
    signal count : unsigned(1 downto 0) := "00";
    signal clk_count : integer range 0 to clks_per_cycle-1 := 0;

begin
    process(clock)
    begin
        if(rising_edge(clock)) then
            if clk_count < clks_per_cycle then
                clk_count <= clk_count + 1;
            else
                count <= count + 1;
                clk_count <= 0;
            end if;
        end if;
    end process;

    led <= "0001" when count = "00" else
           "0010" when count = "01" else
           "0100" when count = "10" else
           "1000" when count = "11" else
           "0000";
end architecture;

------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity genius is
    port (
        clock, reset  : in bit;
        RGBY          : in bit_vector(3 downto 0);
        led           : out bit_vector(3 downto 0);
        HEX0   : out bit_vector(6 downto 0);
        HEX1   : out bit_vector(6 downto 0);
        HEX2   : out bit_vector(6 downto 0);
        HEX3   : out bit_vector(6 downto 0);
        HEX4   : out bit_vector(6 downto 0);
        LEDR   : out bit_vector(9 downto 0)
    );
end entity;

architecture arch_genius of genius is
    component UC is
        generic (
            clks_per_cycle : integer := 25000000
        );
        port (
            clock, reset  : in bit;
            RGBY          : in bit_vector(3 downto 0);
            rng_ready     : in bit;
            mem_finished  : in bit;
            death         : in bit;
            play_finished : in bit;
            rec           : out bit;
            start         : out bit;
            seq           : out bit;
            play          : out bit;
            round         : out bit_vector(6 downto 0);
            life_led      : out bit_vector(2 downto 0)
            );
    end component;

    component dec2seg is
        port ( round  : in  bit_vector(6 downto 0);
               HEX0   : out bit_vector(6 downto 0);
               HEX1   : out bit_vector(6 downto 0);
               HEX2   : out bit_vector(6 downto 0);
               HEX3   : out bit_vector(6 downto 0);
               HEX4   : out bit_vector(6 downto 0)
            );
    end component;

    component seq_round is
        generic (
            clks_per_cycle : integer := 50000000
        );
        port (
            clock, reset  : in bit;
            seq           : in bit_vector(255 downto 0);
            round         : in bit_vector(6 downto 0);
            active        : in bit;
            led           : out bit_vector(3 downto 0);
            done          : out bit
        );
    end component;

    component play_round is
        generic (
            clks_per_cycle : integer := 25000000
        );
        port (
            clock, reset  : in bit;
            seq           : in bit_vector(255 downto 0);
            round         : in bit_vector(6 downto 0);
            active        : in bit;
            RGBY          : in bit_vector(3 downto 0);
            led           : out bit_vector(3 downto 0);
            done          : out bit;
            death         : out bit
        );
    end component;

    component random_step is
        port (
            clock, reset  : in bit;
            active        : in bit;
            rec           : in bit;
            rng           : out bit_vector(255 downto 0);
            done          : out bit
        );
    end component;

    component giragira is
        generic (
            clks_per_cycle : integer := 25000000
        );
        port (
            clock        : in bit;
            led          : out bit_vector(3 downto 0)
        );
    end component;

    signal c_req, c_start, c_seq, c_play        : bit;
    signal m_rng, m_mem, m_death, m_play : bit;
    signal seq, seqd                     : bit_vector(255 downto 0);
	signal round                         : bit_vector(6 downto 0); 
    signal seq_led, play_led, gira_led   : bit_vector(3 downto 0);
    signal life_led                      : bit_vector(2 downto 0);

begin
    xUC   : UC          port map (clock, reset, RGBY, m_rng, m_mem, m_death, m_play, c_req, c_start, c_seq, c_play, round, life_led);
    xRng  : random_step port map (clock, reset, c_start, c_req, seq, m_rng);
    xSeq  : seq_round   port map (clock, reset, seq, round, c_seq, seq_led, m_mem);
    xPlay : play_round  port map (clock, reset, seq, round, c_play, RGBY, play_led, m_play, m_death);
    xGira : giragira    port map (clock, gira_led);
    xPonto: dec2seg     port map (round, HEX0, HEX1, HEX2, HEX3, HEX4);

    led  <= seq_led  when c_seq = '1' else
           play_led when c_play = '1' else
           gira_led when c_req = '1' else
           (others => '0');

    LEDR <= "0000000" & life_led;
end architecture;