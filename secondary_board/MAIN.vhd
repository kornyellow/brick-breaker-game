library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MAIN is
	port (
		CLOCK : in std_logic;

		P1_LEFT : in std_logic;
		P1_RIGHT : in std_logic;
		P2_LEFT : in std_logic;
		P2_RIGHT : in std_logic;

		P1_LEFT_OUT : out std_logic;
		P1_RIGHT_OUT : out std_logic;
		P2_LEFT_OUT : out std_logic;
		P2_RIGHT_OUT : out std_logic
	);
end MAIN;

architecture Behavioral of MAIN is

begin

	process (CLOCK)
	begin
		P1_LEFT_OUT <= P1_LEFT;
		P1_RIGHT_OUT <= P1_RIGHT;
		P2_LEFT_OUT <= P2_LEFT;
		P2_RIGHT_OUT <= P2_RIGHT;
	end process;

end Behavioral;
