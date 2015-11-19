LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY sound IS
	PORT ( CLOCK_50,AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,AUD_ADCDAT			:IN STD_LOGIC;	  
			CLOCK_27															:IN STD_LOGIC;
			KEY																:IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			SW																	:IN STD_LOGIC_VECTOR(17 downto 0);
			I2C_SDAT															:INOUT STD_LOGIC;
			I2C_SCLK,AUD_DACDAT,AUD_XCK								:OUT STD_LOGIC);
END sound;

ARCHITECTURE Behavior OF sound IS

	   -- CODEC Cores
	
	COMPONENT clock_generator
		PORT(	CLOCK_27														:IN STD_LOGIC;
		    	reset															:IN STD_LOGIC;
				AUD_XCK														:OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT audio_and_video_config
		PORT(	CLOCK_50,reset												:IN STD_LOGIC;
		    	I2C_SDAT														:INOUT STD_LOGIC;
				I2C_SCLK														:OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT audio_codec
		PORT(	CLOCK_50,reset,read_s,write_s							:IN STD_LOGIC;
				writedata_left, writedata_right						:IN STD_LOGIC_VECTOR(23 DOWNTO 0);
				AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK		:IN STD_LOGIC;
				read_ready, write_ready									:OUT STD_LOGIC;
				readdata_left, readdata_right							:OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
				AUD_DACDAT													:OUT STD_LOGIC);
	END COMPONENT;
	
	SIGNAL read_ready, write_ready, read_s, write_s		      :STD_LOGIC;
	SIGNAL writedata_left, writedata_right							:STD_LOGIC_VECTOR(23 DOWNTO 0);	
	SIGNAL readdata_left, readdata_right							:STD_LOGIC_VECTOR(23 DOWNTO 0);	
	SIGNAL reset															:STD_LOGIC;
  
      
  constant Ccount : integer := 183;
  constant Dcount : integer := 164;
  constant Ecount : integer := 146;
  constant Fcount : integer := 137;
  constant Gcount : integer := 122;
  constant Acount : integer := 109; 
  constant Bcount : integer := 97;  
  constant NEGAMPLITUDE : unsigned(writedata_left'range) := to_unsigned(-10000, writedata_left'length);
  constant MAXAMPLITUDE : unsigned(writedata_left'range) := to_unsigned(10000, writedata_left'length);
  
  signal Anote,Bnote,Cnote,Dnote,Enote,Fnote,Gnote : unsigned(writedata_left'LENGTH-1 downto 0) := (others => '0');
  
BEGIN

	reset <= NOT(KEY(0));
	read_s <= '0';	

	my_clock_gen: clock_generator PORT MAP (CLOCK_27, reset, AUD_XCK);
	cfg: audio_and_video_config PORT MAP (CLOCK_50, reset, I2C_SDAT, I2C_SCLK);
	codec: audio_codec PORT MAP(CLOCK_50,reset,read_s,write_s,writedata_left, writedata_right,AUD_ADCDAT,
	AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK,read_ready, write_ready,readdata_left, readdata_right,AUD_DACDAT);
  
  process(CLOCK_50) 
  
		variable a_count : integer := 0;
		variable b_count : integer := 0;
		variable c_count : integer := 0;
		variable d_count : integer := 0;
		variable e_count : integer := 0;
		variable f_count : integer := 0;
		variable g_count : integer := 0;
		
		variable a_sign : std_logic := '0';
		variable b_sign : std_logic := '0';
		variable c_sign : std_logic := '0';
		variable d_sign : std_logic := '0';
		variable e_sign : std_logic := '0';
		variable f_sign : std_logic := '0';
		variable g_sign : std_logic := '0';		
		
		variable writedata : std_logic_vector(writedata_left'LENGTH-1 downto 0) := (others => '0');
		
      begin
        if(rising_edge(CLOCK_50)) then
          if(write_ready = '1') then

            if(a_count = Acount) then
              a_sign := not a_sign;
              a_count := 0;
            else
              a_count := a_count + 1;
            end if; 	
				
            if(b_count = Bcount) then
              b_sign := not b_sign;
              b_count := 0;
            else
              b_count := b_count + 1;
            end if; 
				
            if(c_count = Ccount) then
              c_sign := not c_sign;
              c_count := 0;
            else
              c_count := c_count + 1;
            end if; 
							
            if(d_count = Dcount) then
              d_sign := not d_sign;
              d_count := 0;
            else
              d_count := d_count + 1;
            end if; 
				
            if(e_count = Ecount) then
              e_sign := not e_sign;
              e_count := 0;
            else
              e_count := e_count + 1;
            end if; 

            if(f_count = Fcount) then
              f_sign := not f_sign;
              f_count := 0;
            else
              f_count := f_count + 1;
            end if; 
				
            if(g_count = Gcount) then
              g_sign := not g_sign;
              g_count := 0;
            else
              g_count := g_count + 1;
            end if;		
				
          end if;
        
        if(SW(6) = '1') then  
          if(c_sign = '1') then
            Cnote <= MAXAMPLITUDE;
          else
            Cnote <= NEGAMPLITUDE;
          end if;
        else
          Cnote <= (others => '0');
        end if;
		  
        if(SW(5) = '1') then  
          if(d_sign = '1') then
            Dnote <= MAXAMPLITUDE;
          else
            Dnote <= NEGAMPLITUDE;
          end if;
        else
          Dnote <= (others => '0');
        end if;		  
		  
        if(SW(4) = '1') then  
          if(e_sign = '1') then
            Enote <= MAXAMPLITUDE;
          else
            Enote <= NEGAMPLITUDE;
          end if;
        else
          Enote <= (others => '0');
        end if;		  

        if(SW(3) = '1') then  
          if(f_sign = '1') then
            Fnote <= MAXAMPLITUDE;
          else
            Fnote <= NEGAMPLITUDE;
          end if;
        else
          Fnote <= (others => '0');
        end if;

		  if(SW(2) = '1') then  
          if(g_sign = '1') then
            Gnote <= MAXAMPLITUDE;
          else
            Gnote <= NEGAMPLITUDE;
          end if;
        else
          Gnote <= (others => '0');
        end if;

		  if(SW(1) = '1') then  
          if(a_sign = '1') then
            Anote <= MAXAMPLITUDE;
          else
            Anote <= NEGAMPLITUDE;
          end if;
        else
          Anote <= (others => '0');
        end if;	

		  if(SW(0) = '1') then  
          if(b_sign = '1') then
            Bnote <= MAXAMPLITUDE;
          else
            Bnote <= NEGAMPLITUDE;
          end if;
        else
          Bnote <= (others => '0');
        end if;
	
		  
		  if(write_ready = '1') then
			write_s <= '1';
		   writedata := std_logic_vector(Anote + Bnote + Cnote + Dnote + Enote + Fnote + Gnote);
			writedata_left <= writedata;
			writedata_right <= writedata;
		  else
			write_s <= '0';
		 end if;
        
      end if;
        
    end process; 
  
  
  
 
END Behavior;
