--------------------------------------------------
library IEEE; 
use IEEE.numeric_bit.all;
entity ch is
  port (
    x, y, z : in bit_vector(31 downto 0);
    q : out bit_vector(31 downto 0)
  );
end ch;

architecture arch_ch of ch is
begin
	q <= (x and y) xor (not(x) and z);
end architecture;

--------------------------------------------------
library IEEE; 
use IEEE.numeric_bit.all;
entity maj is
port (
  x, y, z : in bit_vector(31 downto 0);
  q : out bit_vector(31 downto 0)
);
end maj;

architecture arch_maj of maj is
begin
	q <= (x and y) xor (x and z) xor (y and z);
end architecture;

--------------------------------------------------

library IEEE; 
use IEEE.numeric_bit.all;
entity sum0 is
  port (
    x : in bit_vector(31 downto 0);
    q : out bit_vector(31 downto 0)
  );
end sum0;

architecture arch_sum0 of sum0 is
begin
	q <= (bit_vector(shift_right(unsigned(x), 2)) or (bit_vector(shift_left(unsigned(x), 30)))) xor (bit_vector(shift_right(unsigned(x), 13)) or (bit_vector(shift_left(unsigned(x), 19)))) xor (bit_vector(shift_right(unsigned(x), 22)) or (bit_vector(shift_left(unsigned(x), 10))));
end architecture;

--------------------------------------------------

library IEEE; 
use IEEE.numeric_bit.all;
entity sum1 is
  port (
    x : in bit_vector(31 downto 0);
    q : out bit_vector(31 downto 0)
  );
end sum1;

architecture arch_sum1 of sum1 is
begin
	q <= (bit_vector(shift_right(unsigned(x), 6)) or (bit_vector(shift_left(unsigned(x), 26)))) xor (bit_vector(shift_right(unsigned(x), 11)) or (bit_vector(shift_left(unsigned(x), 21)))) xor (bit_vector(shift_right(unsigned(x), 25)) or (bit_vector(shift_left(unsigned(x), 7))));
end architecture;

--------------------------------------------------

library IEEE; 
use IEEE.numeric_bit.all;
entity sigma0 is
  port (
    x : in bit_vector(31 downto 0);
    q : out bit_vector(31 downto 0)
  );
end sigma0;

architecture arch_sigma0 of sigma0 is
begin
	q <= (bit_vector(shift_right(unsigned(x), 7)) or (bit_vector(shift_left(unsigned(x), 25)))) xor (bit_vector(shift_right(unsigned(x), 18)) or (bit_vector(shift_left(unsigned(x), 14)))) xor (bit_vector(shift_right(unsigned(x), 3)));
end architecture;

--------------------------------------------------

library IEEE; 
use IEEE.numeric_bit.all;
entity sigma1 is
  port (
    x : in bit_vector(31 downto 0);
    q : out bit_vector(31 downto 0)
  );
end sigma1;

architecture arch_sigma1 of sigma1 is
begin
	q <= (bit_vector(shift_right(unsigned(x), 17)) or (bit_vector(shift_left(unsigned(x), 15)))) xor (bit_vector(shift_right(unsigned(x), 19)) or (bit_vector(shift_left(unsigned(x), 13)))) xor (bit_vector(shift_right(unsigned(x), 10)));
end architecture;

library IEEE;
use IEEE.numeric_bit.all;

entity stepfunner is
    port (
      ai : in bit_vector(31 downto 0);
      rng : out bit_vector(255 downto 0)
    );
end stepfunner;

architecture arch_stepfun of stepfunner is
  component ch is
      port (
        x, y, z : in bit_vector(31 downto 0);
        q : out bit_vector(31 downto 0)
      );
    end component;
  
    component maj is
    port (
      x, y, z : in bit_vector(31 downto 0);
      q : out bit_vector(31 downto 0)
    );
    end component;
    
    component sum0 is
    port (
      x : in bit_vector(31 downto 0);
      q : out bit_vector(31 downto 0)
    );
    end component;
    
    component sum1 is
    port (
      x : in bit_vector(31 downto 0);
      q : out bit_vector(31 downto 0)
    );
    end component;

  signal sum1_a, ch_abc, sum0_a, maj_abc, sum0_b, sum1_b, sum0_c, sum1_c: bit_vector(31 downto 0);
  signal bi, ci : bit_vector(31 downto 0);
  signal ao, bo, co, do, eo, fo, go, ho : bit_vector(31 downto 0);
  signal fc, ea : unsigned(31 downto 0);
  signal resa, rese, repo, reta, reko, koko : unsigned(31 downto 0);

begin
  bi(6 downto 0) <= not(ai(11 downto 5));
  bi(15 downto 7) <= ai(8 downto 0);
  bi(23 downto 16) <= not(ai(23 downto 16));
  bi(31 downto 24) <= ai(30 downto 23) xor ai(24 downto 17);

  ci(3 downto 0) <= bi(31 downto 28) xor ai(27 downto 24);
  ci(11 downto 4) <= not(ai(15 downto 8));
  ci(18 downto 12) <= not(bi(8 downto 2)) xor bi(19 downto 13);
  ci(25 downto 19) <= ai(9 downto 3) and bi(13 downto 7);
  ci(31 downto 26) <= ai(24 downto 19) xor bi(5 downto 0);

  xSum1_a: sum1 port map(ai, sum1_a);
  xCh_abc: ch port map(ai, bi, ci, ch_abc);
  xSum0_a: sum0 port map(ai, sum0_a);
  xMaj_abc: maj port map(ai, bi, ci, maj_abc);
  xSum1_b: sum1 port map(bi, sum1_b);
  xSum0_b: sum0 port map(bi, sum0_b);
  xSum1_c: sum1 port map(ci, sum1_c);
  xSum0_c: sum0 port map(ci, sum0_c);

  fc <= unsigned(ai) + unsigned(sum1_a) + unsigned(ch_abc);
  ea <= unsigned(sum1_c) + unsigned(maj_abc) + unsigned(ch_abc);
  resa <= fc + unsigned(sum0_a) + unsigned(maj_abc);
  rese <= fc + unsigned(bi);
  repo <= unsigned(ai) + unsigned(sum0_c);
  reta <= unsigned(sum0_b) + unsigned(ci);
  reko <= unsigned(sum1_a) + unsigned(sum0_b) + unsigned(sum1_c);
  koko <= unsigned(ea) + unsigned(fc);

  ao <= bit_vector(resa);
  bo <= bit_vector(ea);
  co <= bit_vector(fc);
  do <= bit_vector(repo);
  eo <= bit_vector(rese);
  fo <= bit_vector(reta);
  go <= bit_vector(reko);
  ho <= bit_vector(koko);

  rng <= ao & bo & co & do & eo & fo & go & ho;
end architecture;