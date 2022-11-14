----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:49:49 11/11/2022 
-- Design Name: 
-- Module Name:    test-vga - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test-vga is
    Port ( clk : in  STD_LOGIC;
           vga_h_sync : out  STD_LOGIC;
           vga_v_sync : out  STD_LOGIC;
           vga_r : out  STD_LOGIC;
           vga_g : out  STD_LOGIC;
           vga_b : out  STD_LOGIC);
end test-vga;

architecture Behavioral of test-vga is



begin


end Behavioral;

