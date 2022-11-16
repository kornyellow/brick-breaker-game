library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MAIN is
	port (
		BUTTON_A : in std_logic;
		BUTTON_B : in std_logic;
		LEFT : in std_logic;
		RIGHT : in std_logic;
		MIDDLE : in std_logic;
		CLOCK : in std_logic;
		BUZZER : out std_logic;
		GREEN : out std_logic;
		HSYNC : out std_logic;
		VSYNC : out std_logic;
		BLUE : out std_logic;
		RED : out std_logic
	);
end MAIN;

architecture Behavioral of MAIN is
	constant X_VISIBLE_AREA : integer := 508;
	constant X_FRONT_PORCH : integer := 13;
	constant X_SYNC_PULSE : integer := 76;
	constant X_BACK_PORCH : integer := 38;
	constant X_WHOLE_LINE : integer := 635;

	constant Y_VISIBLE_AREA : integer := 480;
	constant Y_FRONT_PORCH : integer := 10;
	constant Y_SYNC_PULSE : integer := 2;
	constant Y_BACK_PORCH : integer := 33;
	constant Y_WHOLE_FRAME : integer := 525;

	constant RIGHT_BORDER : integer := X_WHOLE_LINE - X_FRONT_PORCH + 1;
	constant LEFT_BORDER : integer := X_SYNC_PULSE + X_BACK_PORCH + 1;
	constant DOWN_BORDER : integer := Y_WHOLE_FRAME - Y_FRONT_PORCH + 1;
	constant UP_BORDER : integer := Y_SYNC_PULSE + Y_BACK_PORCH + 1;
	constant GAME_WIDTH : integer := RIGHT_BORDER - LEFT_BORDER;
	constant GAME_HEIGHT : integer := DOWN_BORDER - UP_BORDER;
	constant GAME_BORDER_SIZE : integer := 3;

	signal x : integer range -1 to 700 := 0;
	signal y : integer range -1 to 700 := 0;

	type brick is record
		x : integer range -1 to 700;
		y : integer range -1 to 700;
		w : integer range 0 to 50;
		h : integer range 0 to 50;
		e : std_logic;
	end record brick;

	constant default_brick : brick := (
		x => 0,
		y => 0,
		w => 40,
		h => 16,
		e => '1'
	);

	type bricks_array is array (natural range 0 to 59) of brick;

	signal bricks : bricks_array := (
		others => default_brick
	);

	signal player_x : integer range -1 to 700 := 0;
	signal player_y : integer range -1 to 700 := GAME_HEIGHT*7/8;
	signal player_dir_x : integer range -1 to 1 := 0;
	signal player_dir_y : integer range -1 to 1 := 0;
	signal player_counter : integer := 0;
	constant player_width : integer := 64;
	constant player_height : integer := 8;

	signal ball_x : integer range -1 to 700 := 200;
	signal ball_y : integer range -1 to 700 := 350;
	signal ball_dir_x : integer range -1 to 1 := 1;
	signal ball_dir_y : integer range -1 to 1 := -1;
	signal ball_counter : integer := 0;
	constant ball_size : integer := 8;

	signal buzzer_counter : integer := 0;
	constant buzzer_delay : integer := 50000;

	-- Function for detecting 2D collision horizontal
	function collision_rectangle (
		x1 : integer := 0;
		w1 : integer := 0;
		x2 : integer := 0;
		w2 : integer := 0;
		y1 : integer := 0;
		h1 : integer := 0;
		y2 : integer := 0;
		h2 : integer := 0)

		return integer is
		variable result : integer := 0;
	begin
		if x1 < x2 + w2 and x1 + w1 > x2 and
			y1 < y2 + h2 and h1 + y1 > y2 then
			result := 1;
		else
			result := 0;
		end if;

		return result;
	end function;

begin

	process (CLOCK) begin

		if CLOCK'event and CLOCK = '1' then

			-- Buzzer Default State
			if buzzer_counter > 0 then
				buzzer_counter <= buzzer_counter - 1;
				BUZZER <= '1';
			else
				BUZZER <= '0';
			end if;

			-- Player Movement
			if LEFT = '0' and RIGHT = '0' then
				player_dir_x <= 0;
			elsif LEFT = '0' and player_x > 0 then
				player_dir_x <= -1;
			elsif RIGHT = '0' and player_x <= GAME_WIDTH - player_width then
				player_dir_x <= 1;
			else
				player_dir_x <= 0;
			end if;

			-- Ball Bounce to Wall
			if ball_x < 0 then
				ball_x <= 0;
				ball_dir_x <= 1;
				buzzer_counter <= buzzer_delay;
			end if;
			if ball_x >= GAME_WIDTH - ball_size then
				ball_x <= ball_x - 1;
				ball_dir_x <= -1;
				buzzer_counter <= buzzer_delay;
			end if;
			if ball_y < 0 then
				ball_y <= 0;
				ball_dir_y <= 1;
				buzzer_counter <= buzzer_delay;
			end if;
			if ball_y >= GAME_HEIGHT - ball_size then
				ball_y <= ball_y - 1;
				ball_dir_y <= -1;
				buzzer_counter <= buzzer_delay;
			end if;

			-- Ball Bounce to Player
			if collision_rectangle(
				player_x, player_width, ball_x + ball_dir_x, ball_size,
				player_y, player_height, ball_y + ball_dir_y, ball_size) = 1
			then
				if ball_y + ball_size = player_y or
					ball_y = player_y + player_height then
					if ball_dir_y = 1 then
						ball_dir_y <= -1;
					else
						ball_dir_y <= 1;
					end if;
				end if;
				if ball_x + ball_size = player_x or
					ball_x = player_x + player_width then
					if ball_dir_x = 1 then
						ball_dir_x <= -1;
					else
						ball_dir_x <= 1;
					end if;
				end if;

				buzzer_counter <= buzzer_delay;
			end if;

			-- Reset Bricks
			if bricks(0).e = '0' and bricks(1).e = '0' and bricks(2).e = '0' and bricks(3).e = '0' and
				bricks(4).e = '0' and bricks(5).e = '0' and bricks(6).e = '0' and bricks(7).e = '0' and
				bricks(8).e = '0' and bricks(9).e = '0' and bricks(10).e = '0' and bricks(11).e = '0' and
				bricks(12).e = '0' and bricks(13).e = '0' and bricks(14).e = '0' and bricks(15).e = '0' and
				bricks(16).e = '0' and bricks(17).e = '0' and bricks(18).e = '0' and bricks(19).e = '0' and
				bricks(20).e = '0' and bricks(21).e = '0' and bricks(22).e = '0' and bricks(23).e = '0' and
				bricks(24).e = '0' and bricks(25).e = '0' and bricks(26).e = '0' and bricks(27).e = '0' and
				bricks(28).e = '0' and bricks(29).e = '0' and bricks(30).e = '0' and bricks(31).e = '0' and
				bricks(32).e = '0' and bricks(33).e = '0' and bricks(34).e = '0' and bricks(35).e = '0' and
				bricks(36).e = '0' and bricks(37).e = '0' and bricks(38).e = '0' and bricks(39).e = '0' and
				bricks(40).e = '0' and bricks(41).e = '0' and bricks(42).e = '0' and bricks(43).e = '0' and
				bricks(44).e = '0' and bricks(45).e = '0' and bricks(46).e = '0' and bricks(47).e = '0' then
				for i in 0 to 47 loop
					bricks(i).e <= '1';
				end loop;
			end if;

			-- Ball hit bricks
			for i in 0 to 47 loop
				if bricks(i).e = '1' and collision_rectangle(
					bricks(i).x, bricks(i).w, ball_x + ball_dir_x, ball_size,
					bricks(i).y, bricks(i).h, ball_y + ball_dir_y, ball_size) = 1
				then
					if ball_y + ball_size = bricks(i).y or
						ball_y = bricks(i).y + bricks(i).h then
						ball_dir_y <= ball_dir_y * (-1);
					end if;
					if ball_x + ball_size = bricks(i).x or
						ball_x = bricks(i).x + bricks(i).w then
						ball_dir_x <= ball_dir_x * (-1);
					end if;
					bricks(i).e <= '0';

					buzzer_counter <= buzzer_delay;
				end if;
			end loop;

			-- Player Movement Applied
			player_counter <= player_counter + 1;
			if player_counter = 100000 then
				player_x <= player_x + player_dir_x;
				player_y <= player_y + player_dir_y;
				player_counter <= 0;
			end if;

			-- Ball Movement Applied
			ball_counter <= ball_counter + 1;
			if ball_counter = 100000 then
				ball_x <= ball_x + ball_dir_x;
				ball_y <= ball_y + ball_dir_y;
				ball_counter <= 0;
			end if;

			-- Set Blackscreen
			RED <= '0';
			GREEN <= '0';
			BLUE <= '0';

			-- Draw each Bricks first row
			for index in 0 to 11 loop
				if bricks(index).e = '1' and
					x >= LEFT_BORDER + bricks(index).x and
					x <= LEFT_BORDER + bricks(index).x + bricks(index).w and
					y >= UP_BORDER + bricks(index).y and
					y <= UP_BORDER + bricks(index).y + bricks(index).h then

					bricks(index).x <= index * (bricks(index).w + 3);
					bricks(index).y <= 1 * (bricks(index).h + 3);

					RED <= '1';
					GREEN <= '0';
					BLUE <= '1';
				end if;
			end loop;
			-- Draw each Bricks second row
			for index in 12 to 23 loop
				if bricks(index).e = '1' and
					x >= LEFT_BORDER + bricks(index).x and
					x <= LEFT_BORDER + bricks(index).x + bricks(index).w and
					y >= UP_BORDER + bricks(index).y and
					y <= UP_BORDER + bricks(index).y + bricks(index).h then

					bricks(index).x <= (index mod 12) * (bricks(index).w + 3);
					bricks(index).y <= 2 * (bricks(index).h + 3);

					RED <= '0';
					GREEN <= '1';
					BLUE <= '0';
				end if;
			end loop;
			-- Draw each Bricks third row
			for index in 24 to 35 loop
				if bricks(index).e = '1' and
					x >= LEFT_BORDER + bricks(index).x and
					x <= LEFT_BORDER + bricks(index).x + bricks(index).w and
					y >= UP_BORDER + bricks(index).y and
					y <= UP_BORDER + bricks(index).y + bricks(index).h then

					bricks(index).x <= (index mod 12) * (bricks(index).w + 3);
					bricks(index).y <= 3 * (bricks(index).h + 3);

					RED <= '1';
					GREEN <= '1';
					BLUE <= '0';
				end if;
			end loop;
			-- Draw each Bricks fourth row
			for index in 36 to 47 loop
				if bricks(index).e = '1' and
					x >= LEFT_BORDER + bricks(index).x and
					x <= LEFT_BORDER + bricks(index).x + bricks(index).w and
					y >= UP_BORDER + bricks(index).y and
					y <= UP_BORDER + bricks(index).y + bricks(index).h then

					bricks(index).x <= (index mod 12) * (bricks(index).w + 3);
					bricks(index).y <= 4 * (bricks(index).h + 3);

					RED <= '1';
					GREEN <= '0';
					BLUE <= '0';
				end if;
			end loop;

			-- Draw Ball
			if x >= LEFT_BORDER + ball_x and x <= LEFT_BORDER + ball_x + ball_size and
				y >= UP_BORDER + ball_y and y <= UP_BORDER + ball_y + ball_size then
				RED <= '1';
				GREEN <= '1';
				BLUE <= '1';
			end if;

			-- Draw Player
			if x >= LEFT_BORDER + player_x and x <= LEFT_BORDER + player_x + player_width and
				y >= UP_BORDER + player_y and y <= UP_BORDER + player_y + player_height then
				RED <= '1';
				GREEN <= '1';
				BLUE <= '1';
			end if;

			-- Draw Border
			if (x >= LEFT_BORDER and x <= LEFT_BORDER + GAME_BORDER_SIZE) or
				(x <= RIGHT_BORDER and x >= RIGHT_BORDER - GAME_BORDER_SIZE) or
				(y >= UP_BORDER and y <= UP_BORDER + GAME_BORDER_SIZE + 1) or
				(y <= DOWN_BORDER and y >= DOWN_BORDER - GAME_BORDER_SIZE - 1) then
				RED <= '0';
				GREEN <= '1';
				BLUE <= '1';
			end if;

			-- Hsync and Vsync
			if x > 0 and x <= X_SYNC_PULSE then
				HSYNC <= '0';
			else
				HSYNC <= '1';
			end if;

			if y > 0 and y <= Y_SYNC_PULSE then
				VSYNC <= '0';
			else
				VSYNC <= '1';
			end if;

			x <= x + 1;

			if x = X_WHOLE_LINE then
				y <= y + 1;
				x <= 0;
			end if;

			if y = Y_WHOLE_FRAME then
				y <= 0;
			end if;

		end if;
	end process;

end Behavioral;
