library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MAIN is
	port (
		P1_LEFT : in std_logic;
		P1_RIGHT : in std_logic;
		P2_LEFT : in std_logic;
		P2_RIGHT : in std_logic;

		CLOCK : in std_logic;
		HSYNC : out std_logic;
		VSYNC : out std_logic;
		RED : out std_logic;
		GREEN : out std_logic;
		BLUE : out std_logic
	);
end MAIN;

architecture Behavioral of MAIN is
	signal x : natural range 0 to 635 := 0;
	signal y : natural range 0 to 525 := 0;

	constant X_VISIBLE_AREA : natural := 508;
	constant X_FRONT_PORCH : natural := 13;
	constant X_SYNC_PULSE : natural := 76;
	constant X_BACK_PORCH : natural := 38;
	constant X_WHOLE_LINE : natural := 635;

	constant Y_VISIBLE_AREA : natural := 480;
	constant Y_FRONT_PORCH : natural := 10;
	constant Y_SYNC_PULSE : natural := 2;
	constant Y_BACK_PORCH : natural := 33;
	constant Y_WHOLE_FRAME : natural := 525;

	constant RIGHT_BORDER : natural := X_WHOLE_LINE - X_FRONT_PORCH + 2;
	constant LEFT_BORDER : natural := X_SYNC_PULSE + X_BACK_PORCH + 1;
	constant DOWN_BORDER : natural := Y_WHOLE_FRAME - Y_FRONT_PORCH + 1;
	constant UP_BORDER : natural := Y_SYNC_PULSE + Y_BACK_PORCH + 1;
	constant GAME_WIDTH : natural := RIGHT_BORDER - LEFT_BORDER;
	constant GAME_HEIGHT : natural := DOWN_BORDER - UP_BORDER;

	type t_rectangle is record
		x : integer range -10 to GAME_WIDTH;
		y : integer range -10 to GAME_HEIGHT;
		dx : integer range -10 to 10;
		dy : integer range -10 to 10;
		w : natural range 0 to 100;
		h : natural range 0 to 100;
		e : boolean;
	end record;

	type t_color is record
		r : std_logic;
		g : std_logic;
		b : std_logic;
	end record;

	type t_colors is record
		color1 : t_color;
		color2 : t_color;
	end record;

	type t_brick is record
		state : natural range 0 to 2;
	end record;

	constant color_white : t_colors := (
		color1 => ( r => '1', g => '1', b => '1' ),
		color2 => ( r => '1', g => '1', b => '1' )
	);
	constant color_red : t_colors := (
		color1 => ( r => '1', g => '0', b => '0' ),
		color2 => ( r => '1', g => '0', b => '0' )
	);
	constant color_orange : t_colors := (
		color1 => ( r => '1', g => '1', b => '0' ),
		color2 => ( r => '1', g => '0', b => '0' )
	);
	constant color_yellow : t_colors := (
		color1 => ( r => '1', g => '1', b => '0' ),
		color2 => ( r => '1', g => '1', b => '0' )
	);
	constant color_lime : t_colors := (
		color1 => ( r => '1', g => '1', b => '0' ),
		color2 => ( r => '0', g => '1', b => '0' )
	);
	constant color_green : t_colors := (
		color1 => ( r => '0', g => '1', b => '0' ),
		color2 => ( r => '0', g => '1', b => '0' )
	);
	constant color_sky : t_colors := (
		color1 => ( r => '0', g => '1', b => '1' ),
		color2 => ( r => '0', g => '1', b => '0' )
	);
	constant color_cyan : t_colors := (
		color1 => ( r => '0', g => '1', b => '1' ),
		color2 => ( r => '0', g => '1', b => '1' )
	);
	constant color_teal : t_colors := (
		color1 => ( r => '0', g => '1', b => '1' ),
		color2 => ( r => '0', g => '0', b => '1' )
	);
	constant color_blue : t_colors := (
		color1 => ( r => '0', g => '0', b => '1' ),
		color2 => ( r => '0', g => '0', b => '1' )
	);
	constant color_purple : t_colors := (
		color1 => ( r => '1', g => '0', b => '1' ),
		color2 => ( r => '0', g => '0', b => '1' )
	);
	constant color_magenta : t_colors := (
		color1 => ( r => '1', g => '0', b => '1' ),
		color2 => ( r => '1', g => '0', b => '1' )
	);
	constant color_pink : t_colors := (
		color1 => ( r => '1', g => '0', b => '1' ),
		color2 => ( r => '1', g => '0', b => '0' )
	);
begin

	process (CLOCK)
		-- Function convert std_logic to integer
		impure function to_integer (
			s : std_logic) return natural is
		begin
			if s = '1' then
				return 1;
			end if;
			return 0;
		end function;

		-- Function for clamping x to range a and b
		impure function clamp (
			x : integer;
			a : integer;
			b : integer) return natural is
		begin
			if x <= a + 1 then
				return a + 1;
			end if;
			if x >= b then
				return b;
			end if;
			return x;
		end function;

		impure function absolute (
			a : integer) return integer is
		begin
			if a > 0 then
				return a;
			end if;
			if a < 0 then
				return 0 - a;
			end if;
			return 0;
		end function;

		impure function intersection (
			b1: t_rectangle;
			b2: t_rectangle) return boolean is
		begin
			if b1.x > b2.x + b2.w or b2.x > b1.x + b1.w or
				b1.y > b2.y + b2.h or b2.y > b1.y + b1.h then
				return false;
			end if;
			return true;
		end function;

		-- Function for bouncing
		impure function bounce (
			box1 : t_rectangle;
			box2 : t_rectangle) return t_rectangle is
			variable box : t_rectangle;
		begin
			box := box1;
			if intersection(box1, box2) then
				if box1.x <= box2.x - box1.w or box1.x >= box2.x + box2.w then
					box.dx := 0 - box.dx;
					box.x := box.x + box.dx;
					box.e := true;
				end if;
				if box1.y <= box2.y - box1.h or box1.y >= box2.y + box2.h then
					box.dy := 0 - box.dy;
					box.y := box.y + box.dy;
					box.e := true;
				end if;
			end if;
			return box;
		end function;

		procedure set_color(
			c : t_color) is
		begin
			RED <= c.r;
			GREEN <= c.g;
			BLUE <= c.b;
		end procedure;

		procedure draw_rectangle(
			r : t_rectangle;
			c : t_colors) is
			variable xx : natural;
			variable yy : natural;
		begin
			-- Move to viewport
			xx := r.x + LEFT_BORDER;
			yy := r.y + UP_BORDER;

			if x >= xx and x < xx + r.w and y >= yy and y < yy + r.h then
				if y mod 2 = 0 then
					if x mod 2 = 0 then
						set_color(c.color1);
					else
						set_color(c.color2);
					end if;
				else
					if x mod 2 = 1 then
						set_color(c.color1);
					else
						set_color(c.color2);
					end if;
				end if;
			end if;
		end procedure;

		procedure draw_circle(
			r : t_rectangle;
			cR : std_logic;
			cG : std_logic;
			cB : std_logic) is
			variable xx : natural;
			variable yy : natural;
			variable rr : natural;
		begin
			-- Move to viewport
			rr := r.w / 2;
			xx := r.x + LEFT_BORDER + rr;
			yy := r.y + UP_BORDER + rr;

			if (x-xx)*(x-xx) + (y-yy)*(y-yy) <= rr*rr then
				RED <= cR;
				GREEN <= cG;
				BLUE <= cB;
			end if;
		end procedure;

		variable game_counter : natural range 0 to 1000000 := 0;

		variable player1 : t_rectangle := (
			x => GAME_WIDTH / 2,
			y => GAME_HEIGHT * 7/8,
			dx => 0,
			dy => 0,
			w => 48,
			h => 8,
			e => false
		);
		variable player2 : t_rectangle := (
			x => GAME_WIDTH / 2,
			y => GAME_HEIGHT * 6/8,
			dx => 0,
			dy => 0,
			w => 48,
			h => 8,
			e => false
		);

		variable ball : t_rectangle := (
			x => GAME_WIDTH / 2,
			y => GAME_HEIGHT / 2,
			dx => 1,
			dy => 1,
			w => 8,
			h => 8,
			e => false
		);

		constant default_particle : t_rectangle := (
			x => 0,
			y => 0,
			dx => 0,
			dy => 0,
			w => 6,
			h => 6,
			e => false
		);

		type t_rectangle_array is array (natural range 0 to 3) of t_rectangle;
		variable particle_array : t_rectangle_array := (
			others => default_particle
		);

		constant default_brick : t_brick := (
			state => 1
		);

		constant BRICK_COUNT_X : natural := 16;
		constant BRICK_COUNT_Y : natural := 12;
		constant BRICK_SPACING : natural := 2;
		constant BRICK_Y_OFFSET : natural := 32;

		type t_brick_array is array (natural range 0 to BRICK_COUNT_X * BRICK_COUNT_Y) of t_brick;
		variable brick_array : t_brick_array := (
			others => default_brick
		);

		type t_color_array is array (natural range 0 to 11) of t_colors;
		constant color_array : t_color_array := (
			0 => color_red,
			1 => color_orange,
			2 => color_yellow,
			3 => color_lime,
			4 => color_green,
			5 => color_sky,
			6 => color_cyan,
			7 => color_teal,
			8 => color_blue,
			9 => color_purple,
			10 => color_magenta,
			11 => color_pink
		);

		variable brick_i : natural range 0 to BRICK_COUNT_X * BRICK_COUNT_Y := 0;
		variable brick : t_rectangle := (
			x => 0,
			y => 0,
			dx => 0,
			dy => 0,
			w => 30,
			h => 10,
			e => false
		);
		variable brick_draw : t_rectangle := (
			x => 0,
			y => 0,
			dx => 0,
			dy => 0,
			w => 30,
			h => 10,
			e => false
		);

		variable brick_color : t_colors;

	begin

		if CLOCK'event and CLOCK = '1' then

			game_counter := game_counter + 1;
			if game_counter = 80000 then
				game_counter := 0;

				-- Players Movement
				player1.dx := to_integer(P1_LEFT) - to_integer(P1_RIGHT);
				player2.dx := to_integer(P2_LEFT) - to_integer(P2_RIGHT);

				-- Ball Bounce to Screen
				if ball.x = 1 or ball.x = GAME_WIDTH - ball.w then
					ball.dx := 0 - ball.dx;
				end if;
				if ball.y = 1 or ball.y = GAME_HEIGHT - ball.h then
					ball.dy := 0 - ball.dy;
				end if;

				-- Ball Bounce to Player
				ball.e := false;
				ball := bounce(ball, player1);
				if ball.e = false then
					ball := bounce(ball, player2);
				end if;

				-- Player1 Movement Applied
				player1.x := player1.x + player1.dx;
				player1.x := clamp(player1.x, 0, GAME_WIDTH - player1.w);

				-- Player2 Movement Applied
				player2.x := player2.x + player2.dx;
				player2.x := clamp(player2.x, 0, GAME_WIDTH - player2.w);

				-- Ball Movement Applied
				ball.x := ball.x + ball.dx;
				ball.y := ball.y + ball.dy;
				ball.x := clamp(ball.x, 0, GAME_WIDTH - ball.w);
				ball.y := clamp(ball.y, 0, GAME_HEIGHT - ball.h);

				-- Move Particle
				for i in 0 to 3 loop
					particle_array(i).x := particle_array(i).x + particle_array(i).dx;
					particle_array(i).y := particle_array(i).y + particle_array(i).dy;
					particle_array(i).x := clamp(particle_array(i).x, 0, GAME_WIDTH - particle_array(i).w);
					particle_array(i).y := clamp(particle_array(i).y, 0, GAME_HEIGHT - particle_array(i).h);
				end loop;
			end if;

			-- Set Blackscreen
			RED <= '0';
			GREEN <= '0';
			BLUE <= '0';

			-- Draw Ball
			draw_circle(ball, '1', '1', '1');

			-- Draw Player
			draw_rectangle(player1, color_orange);
			draw_rectangle(player2, color_teal);

			-- Draw Brick
			brick.x := (brick_i mod BRICK_COUNT_X) * (brick.w + 2);
			brick.y := BRICK_Y_OFFSET + (brick_i / BRICK_COUNT_X) * (brick.h + 2);

			-- Ball Bounce to Brick
			-- if brick_array(brick_i).state > 0 then
			-- 	ball.e := false;
			-- 	ball := bounce(ball, brick);
			-- 	if ball.e then
			-- 		brick_array(brick_i).state := brick_array(brick_i).state - 1;

			-- 		for i in 0 to 3 loop
			-- 			particle_array(i).e := true;
			-- 			particle_array(i).x := ball.x + ball.w / 2;
			-- 			particle_array(i).y := ball.y + ball.h / 2;
			-- 		end loop;
			-- 	end if;
			-- end if;

			-- Draw Bricks
			for i in 0 to BRICK_COUNT_Y * BRICK_COUNT_X - 1 loop
				if brick_array(i).state > 0 then
					brick_draw.x := (i mod BRICK_COUNT_X) * (brick.w + BRICK_SPACING);
					brick_draw.y := BRICK_Y_OFFSET + (i / BRICK_COUNT_X) * (brick.h + BRICK_SPACING);
					draw_rectangle(brick_draw, color_array(i / BRICK_COUNT_X));
				end if;
			end loop;

			-- Draw Particle
			particle_array(0).dx := 1;
			particle_array(0).dy := 1;
			particle_array(1).dx := -1;
			particle_array(1).dy := 1;
			particle_array(2).dx := 1;
			particle_array(2).dy := -1;
			particle_array(3).dx := -1;
			particle_array(3).dy := -1;
			for i in 0 to 3 loop
				if particle_array(i).e then
					draw_rectangle(particle_array(i), color_white);
				end if;
			end loop;

			brick_i := brick_i + 1;
			if brick_i = BRICK_COUNT_X * BRICK_COUNT_Y then
				brick_i := 0;
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