entity coc is
	port (
		SW       : in bit_vector(9 downto 0);
		KEY      : in bit_vector(3 downto 0);
        CLOCK_50 : in bit;
		GPIO_0   : out bit_vector(31 downto 0);
        HEX0     : out bit_vector(6 downto 0);
        HEX1     : out bit_vector(6 downto 0);
        HEX2     : out bit_vector(6 downto 0);
        HEX3     : out bit_vector(6 downto 0);
        HEX4     : out bit_vector(6 downto 0);
        LEDR     : out bit_vector(9 downto 0)
	);
end entity;

architecture arch_toplevel of coc is
    component genius is
        port (
            clock, reset  : in bit;
            RGBY          : in bit_vector(3 downto 0);
            led           : out bit_vector(3 downto 0);
            HEX0          : out bit_vector(6 downto 0);
            HEX1          : out bit_vector(6 downto 0);
            HEX2          : out bit_vector(6 downto 0);
            HEX3          : out bit_vector(6 downto 0);
            HEX4          : out bit_vector(6 downto 0);
            LEDR          : out bit_vector(9 downto 0)
        );
    end component;

    signal rst  : bit;
    signal RGBY : bit_vector(3 downto 0);
    signal led  : bit_vector(3 downto 0);

begin
    RGBY <= not(KEY);
    rst <= SW(0);
    
    x: genius port map (CLOCK_50, rst, RGBY, led, HEX0, HEX1, HEX2, HEX3, HEX4, LEDR);

    GPIO_0(3 downto 0) <= led;
end architecture;
