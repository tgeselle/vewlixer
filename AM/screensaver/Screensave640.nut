///////////////////////////////////////////////////
///////////////////////////////////////////////////
//
// Attract-Mode Frontend - Grid layout
//
///////////////////////////////////////////////////
class UserConfig </ help="Navigation controls: Up/Down (to move up and down) and Page Up/Page Down (to move left and right)" />{
	</ label="Grid Artwork", help="The artwork to display in the grid", options="snap,marquee,flyer,wheel", order=1 />
	art="wheel";

	</ label="Rows", help="The number of grid rows", options="1,2,3,4,5,6,7,8", order=2 />
	rows="1";

	</ label="Columns", help="The number of grid columns", options="1,2,3,4,5,6,7,8", order=3 />
	columns="6";

	</ label="Flow", help="Select the flow direction of the grid", options="Horizontal,Vertical", order=4 />
	flow="Vertical";

	</ label="Preserve Aspect Ratio", help="Preserve artwork aspect ratio", options="Yes,No", order=5 />
	aspect_ratio="Yes";

	</ label="Enable Video", help="Enable video artwork in the grid", options="Yes,No", order=6 />
	video="No";

	</ label="Overlay Wheel", help="Overlay the wheel artwork over grid entries?", options="Yes,No", order=7 />
	wheel="No";

	</ label="Transition Time", help="The amount of time (in milliseconds) that it takes to scroll to another grid entry", order=8 />
	ttime="220";
	
	</ label="Basic Movie", help="Enable basic movie mode", options="Yes,No", order=1 />
	basic_movie="Yes";

	</ label="Movie Collage", help="Enable 2x2 movie collage mode", options="Yes,No", order=2 />
	movie_collage="Yes";

	</ label="Image Collage", help="Enable 4x4 image collage mode", options="Yes,No", order=3 />
	image_collage="No";

   </ label="Overlay Artwork", help="Artwork to overlay on videos", options="wheel,flyer,marquee,None", order=4 />
	overlay_art="wheel";

	</ label="Play Sound", help="Play video sounds during screensaver", options="Yes,No", order=5 />
	sound="Yes";
	
	</ label="Preserve Aspect Ratio", help="Preserve the aspect ratio of screensaver snaps/videos", options="Yes,No", order=6 />
	preserve_ar="Yes";
}
	


fe.load_module( "conveyor" );
fe.load_module("animate");
fe.layout.width = 800;
fe.layout.height = 600;

local my_config = fe.get_config();
local rows = my_config[ "rows" ].tointeger();
local cols = my_config[ "columns" ].tointeger();
local height = ( fe.layout.height * 11 / 36 ) / rows.tofloat();
local width = fe.layout.width / cols.tofloat() - (fe.layout.width / 54 );

local vert_flow = ( my_config["flow"] != "Horizontal" );

const PAD=1;
// add background image
local bg = fe.add_image( "assets/background/scbackground.png",
			0, 0, fe.layout.width, fe.layout.height );

	
			
			
class Grid extends Conveyor
{
	frame=null;
	name_t=null;
	num_t=null;
	sel_x=0;
	sel_y=0;
	video_t=null
	frameg=null

	constructor()
	{
		base.constructor();

		sel_x = cols / 2;
		sel_y = rows / 2;
		stride = fe.layout.page_size = vert_flow ? rows : cols;
		fe.add_signal_handler( this, "on_signal" );
	
		try
		{
			transition_ms = my_config["ttime"].tointeger();
		}
		catch ( e )
		{
			transition_ms = 220;
		}
	}

	function update_audio()
	{
		local flag1 = Vid.NoAudio;
		local flag2 = 0;
		if ( my_config["video"] == "No" )
		{
			flag1 = Vid.ImagesOnly | Vid.NoAudio;
			flag2 = Vid.ImagesOnly;
		}

		foreach ( o in m_objs )
			o.m_art.video_flags = flag1;

		local sel = get_sel();
		m_objs[ sel ].m_art.video_flags = flag2;
	}


	function update_frame()
	{
		// Movement Animation for the Game Title
			animation.add( PropertyAnimation( name_t, 
				{   
					property = "position",
					tween = Tween.Linear, 
					start = {
						x =  fe.layout.height / 1.5
						y =  fe.layout.height / -72
					}, 
					end = { 
						x =  0
						y =  fe.layout.height / -72
					}, 
					time = 225
				} ) );
				
				// Pulsatining Aminamtion for the frame Glow
			animation.add( PropertyAnimation( frameg, 
				{   
					property = "alpha",
					tween = Tween.Linear, 
					start =  0,
					end = 255,
					pulse = true,
					time = transition_ms * 2

				} ) );
					// Movement Animation for the frameg
			animation.add( PropertyAnimation( frameg, 
				{   
					property = "position",
					tween = Tween.Linear, 
					end = { 
						x = (width * sel_x + ((fe.layout.width - (fe.layout.width / 1.105448275)) / 2) +9) 
						y = ((fe.layout.height / 1.51 + height * sel_y) + 114)
					}, 
					time = transition_ms 
				} ) );
				// Movement Animation for the frame
			animation.add( PropertyAnimation( frame, 
				{   
					property = "position",
					tween = Tween.Linear, 
					end = { 
						x = (width * sel_x + ((fe.layout.width - (fe.layout.width / 1.105448275)) / 2) + 9) 
						y = ((fe.layout.height / 1.51 + height * sel_y) + 114)
					}, 
					time = transition_ms
					} ) );		
           // Pulsatining Aminamtion for the video
			animation.add( PropertyAnimation( video_t, 
				{   
					property = "alpha",
					tween = Tween.Linear, 
					start = 10,
					end = 255,
					pulse = false,
					time = 700

				} ) );					

		local Wheelclick = fe.add_sound("assets/sounds/Click.mp3")
	    Wheelclick.playing=true
				
		update_audio();

		
		name_t.index_offset = frameg.index_offset = num_t.index_offset = video_t.index_offset = get_sel() - selection_index;	
	}
	function autommove()
		{
			if ( vert_flow && ( sel_x < cols - 1 ) )
			{
				sel_x++;
				update_frame();
				
			}
			else if ( !vert_flow && ( sel_y < rows - 1 ) )
			{
				sel_y++;
				update_frame();
				
			}
			else
			{
				transition_swap_point=0.0;
				do_correction();
				on_selectr()
				sel_x--
				sel_x--
				sel_x--
				sel_x--
				sel_x--
				update_frame()
			}
		}
	function do_correction()
	{
		local corr = get_sel() - selection_index;
		foreach ( o in m_objs )
		{
			local idx = o.m_art.index_offset - corr;
			o.m_art.rawset_index_offset( idx );
			if ( o.m_wheels )
			{
				o.m_wheel.rawset_index_offset( idx );
				o.m_wheels.rawset_index_offset( idx );
				o.m_wheelss.rawset_index_offset( idx );
			}
		}
	}
	function get_sel()
	{
		return vert_flow ? ( sel_x * rows + sel_y ) : ( sel_y * cols + sel_x );
	}
	
	//MoveGridmoreThen once
	function on_selectr()
	{
		fe.list.index += 6
	}
	//MoveGridmoreThen once
	function on_selectk()
	{
		fe.list.index += -6
	}
	function on_signal( sig )
	{
		switch ( sig )	
		{
		case "up":
			if ( vert_flow && ( sel_y > 0 ) )
			{
				sel_y--;
				update_frame();
			}
			else if ( !vert_flow && ( sel_x > 0 ) )
			{
				sel_x--;
				update_frame();
			}
			else
			{
				transition_swap_point=0.5;
				do_correction();
				fe.signal( "prev_game" );
			}
			return true;

		case "down":
			if ( vert_flow && ( sel_y < rows - 1 ))
			{
				sel_y++;
				update_frame();
			}
			else if ( !vert_flow && ( sel_x < cols - 1 ) )
			{
				sel_x++;
				update_frame();
			}
			else
			{
				transition_swap_point=0.5;
				do_correction();
				fe.signal( "next_game" );
			}
			return true;

		case "left":
			if ( vert_flow && ( sel_x > 0 ))
			{
				sel_x--;
				update_frame();
						fe.signal( "next_game" );
			}
			else if ( !vert_flow && ( sel_y > 0 ) )
			{
				sel_y--;
				update_frame();
						fe.signal( "next_game" );
			}
			else
			{
				transition_swap_point=0.0;
				do_correction();
				on_selectk()
			}
			return true;

		case "right":
			if ( vert_flow && ( sel_x < cols - 1 ) )
			{
				sel_x++;
				update_frame();
						fe.signal( "next_game" );
				
			}
			else if ( !vert_flow && ( sel_y < rows - 1 ) )
			{
				sel_y++;
				update_frame();
				fe.signal( "next_game" );
				
			}
			else
			{
				transition_swap_point=0.0;
				do_correction();
				on_selectr()
				sel_x--
				sel_x--
				sel_x--
				sel_x--
				sel_x--
				update_frame()
				
			}
			return true;


		case "exit":
		case "exit_no_menu":
			break;
		case "select":
		default:
			// Correct the list index if it doesn't align with
			// the game our frame is on
			//
			enabled=false; // turn conveyor off for this switch
			local frame_index = get_sel();
			fe.list.index += frame_index - selection_index;

			set_selection( frame_index );
			update_frame();
			enabled=true; // re-enable conveyor
			break;

		}

		return false;
	}

	function on_transition( ttype, var, ttime )
	{
		switch ( ttype )
		{
		case Transition.StartLayout:
		case Transition.FromGame:
			if ( ttime < transition_ms )
			{
				for ( local i=0; i< m_objs.len(); i++ )
				{
					local r = i % rows;
					local c = i / rows;
					local num = rows + cols - 2;
					if ( num < 1 )
						num = 1;

					local temp = 510 * ( num - r - c ) / num * ttime / transition_ms;
					m_objs[i].set_alpha( ( temp > 255 ) ? 255 : temp );
				}

				frame.alpha = 255 * ttime / transition_ms;
				return true;
			}

			local old_alpha = m_objs[ m_objs.len()-1 ].m_art.alpha;

			foreach ( o in m_objs )
				o.set_alpha( 255 );

			frame.alpha = 255;

			if ( old_alpha != 255 )
				return true;

			break;

		case Transition.ToGame:
		case Transition.EndLayout:
			if ( ttime < transition_ms )
			{
				for ( local i=0; i< m_objs.len(); i++ )
				{
					local r = i % rows;
					local c = i / rows;
					local num = rows + cols - 2;
					if ( num < 1 )
						num = 1;

					local temp = 255 - 510 * ( num - r - c ) / num * ttime / transition_ms;
					m_objs[i].set_alpha( ( temp < 0 ) ? 0 : temp );
				}
				frame.alpha = 255 - 255 * ttime / transition_ms;
				return true;
			}

			local old_alpha = m_objs[ m_objs.len()-1 ].m_art.alpha;

			foreach ( o in m_objs )
				o.set_alpha( 0 );

			frame.alpha = 0;

			if ( old_alpha != 0 )
				return true;

			break;
		case Transition.FromOldSelection:
		case Transition.ToNewList:
			update_audio();

			foreach ( o in m_objs )
				o.dim_if_needed();
			break;
		}

		return base.on_transition( ttype, var, ttime );
	}
}

::gridc <- Grid();

class MySlot extends ConveyorSlot
{
	m_num = 0;
	m_shifted = false;
	m_art = null;
	m_wheel = null;
	m_wheels = null;
	m_wheelss = null;

	constructor( num )
	{
		m_num = num;

		m_art = fe.add_artwork( my_config["art"], 0, 0,
				width - 2*PAD, height - 2*PAD );

		m_art.preserve_aspect_ratio = (my_config["aspect_ratio"]=="Yes");
		m_art.video_flags = Vid.NoAudio;
		if ( my_config["video"] == "No" )
			m_art.video_flags = Vid.ImagesOnly | Vid.NoAudio;

		m_art.alpha = 0;

		if ( my_config["wheel"] == "Yes" )
		{
			m_wheels = fe.add_artwork( "wheel", 0, 0,
					width - 4*PAD, height - 4*PAD );
			m_wheels.preserve_aspect_ratio = true;
			m_wheelss = fe.add_clone( m_wheels );
			m_wheel = fe.add_clone( m_wheels );
			m_wheels.set_rgb( 0, 0, 0 );
			m_wheelss.set_rgb( 0, 0, 0 );
		}

		base.constructor();
	}

	function on_progress( progress, var )
	{
		if ( var == 0 )
			m_shifted = false;

		if ( vert_flow )
		{
			local r = m_num % rows;
			local c = m_num / rows;

			if ( abs( var ) < rows )
			{
				m_art.x = c * width + (fe.layout.width / 16);
				m_art.y = fe.layout.height / 24
					+ ( fe.layout.height * 11 / 36 ) * ( progress * cols - c ) + PAD + (fe.layout.height / 1.4594594594);
			}
			else
			{
				local prog = ::gridc.transition_progress;
				if ( prog > ::gridc.transition_swap_point )
				{
					if ( var > 0 ) c++;
					else c--;
				}

				if ( var > 0 ) prog *= -1;

				m_art.x = ( c + prog ) * width + PAD;
				m_art.y = fe.layout.height / 24 + r * height + PAD + (fe.layout.height / 1.4594594594);
			}
	
		}
		else
		{
			local r = m_num / cols;
			local c = m_num % cols;

			if ( abs( var ) < cols )
			{
				m_art.x = fe.layout.width * ( progress * rows - r ) + PAD;
				m_art.y = fe.layout.height / 24 + r * height + PAD;
			}
			else
			{
				local prog = ::gridc.transition_progress;
				if ( prog > ::gridc.transition_swap_point )
				{
					if ( var > 0 ) r++;
					else r--;
				}

				if ( var > 0 ) prog *= -1;

				m_art.x = c * width + PAD;
				m_art.y = fe.layout.height / 24 + ( r + prog ) * height + PAD ;
			}
		}

		if ( m_wheel )
		{
			m_wheels.x = m_art.x + PAD + 1;
			m_wheels.y = m_art.y + PAD + 1;
			m_wheelss.x = m_art.x + PAD - 1;
			m_wheelss.y = m_art.y + PAD - 1;
			m_wheel.x = m_art.x + PAD;
			m_wheel.y = m_art.y + PAD;
		}

		dim_if_needed();
	}

	function swap( other )
	{
		m_art.swap( other.m_art );
		if ( m_wheel )
		{
			m_wheel.swap( other.m_wheel );
			m_wheels.swap( other.m_wheels );
			m_wheelss.swap( other.m_wheelss );
		}
	}

	function set_index_offset( io )
	{
		m_art.index_offset = io;
		if ( m_wheel )
		{
			m_wheel.index_offset = io;
			m_wheels.index_offset = io;
			m_wheelss.index_offset = io;
		}
	}

	function reset_index_offset()
	{
		m_art.rawset_index_offset( m_base_io ); 
		if ( m_wheel )
		{
			m_wheel.rawset_index_offset( m_base_io );
			m_wheels.rawset_index_offset( m_base_io );
			m_wheelss.rawset_index_offset( m_base_io );
		}
	}

	function set_alpha( alpha )
	{
		m_art.alpha = alpha; 
		if ( m_wheel )
		{
			m_wheel.alpha = alpha;
			m_wheels.alpha = alpha;
			m_wheelss.alpha = alpha;
		}
	}

	function dim_if_needed()
	{
		if ( m_wheel )
		{
			//
			// If we have an art and a wheel, make the art a bit darker
			//
			if (( m_wheel.file_name.len() > 0 )
					&& ( m_art.file_name.len() > 0 ))
				m_art.set_rgb( 140, 140, 140 );
			else
				m_art.set_rgb( 255, 255, 255 );
		}
	}
}

local my_array = [];
for ( local i=0; i<rows*cols; i++ )
	my_array.push( MySlot( i ) );
 
gridc.set_slots( my_array, gridc.get_sel() );

// Frame 1 Yellow
gridc.frame=fe.add_image( "assets/uielements/frame.png", width * 2, height * 2, 123, 33 );

// Frame 1 whiteglow
gridc.frameg=fe.add_image( "assets/uielements/frameglow.png", width * 2, height * 2, 123, 33 );

// add the name text
gridc.name_t =  fe.add_text( "[Title]", 0, fe.layout.height / -72 , fe.layout.width ,fe.layout.height / 20  );
gridc.name_t.font = "futureforces";

// add the video
gridc.video_t = fe.add_artwork( "Video", -25, fe.layout.height / 20, 850, fe.layout.height * 0.805);
gridc.video_t.preserve_aspect_ratio=true




// add the japnase text
gridc.num_t = fe.add_text( "[AltTitle]", 0, fe.layout.height / 1.095 , fe.layout.width ,fe.layout.height / 30 );
gridc.num_t.font = "MSMINCHO";
gridc.num_t.style = Style.Bold

	// add Free play text
local free = fe.add_text( "FREE PLAY", fe.layout.width / 32 , fe.layout.height / 1.045 , fe.layout.width ,fe.layout.height / 28 );
free.font = "futureforces";
free.align = Align.Left
	// Pulsatining Aminamtion for the free pulse
			animation.add( PropertyAnimation( free, 
				{   
					property = "alpha",
					tween = Tween.Linear, 
					start =  10,
					end = 255,
					pulse = true,
					time = 1200

				} ) );
local free2 = fe.add_text( "FREE PLAY",  fe.layout.width / - 32, fe.layout.height / 1.045 , fe.layout.width ,fe.layout.height / 28 );
free2.font = "futureforces";
free2.align = Align.Right
	// Pulsatining Aminamtion for the free pulse
			animation.add( PropertyAnimation( free2, 
				{   
					property = "alpha",
					tween = Tween.Linear, 
					start = 10,
					end = 255,
					pulse = true,
					time = 1200

				} ) );
				
	// add network image
	local networkimage = fe.add_image("assets/uielements/network.png", fe.layout.width / 360 , fe.layout.height /1.04347826087 , fe.layout.width / 42.6666666667 , fe.layout.height / 25  );
	local networkimageclone = fe.add_clone (networkimage)
	networkimageclone.set_pos(fe.layout.width / 1.02949061662,fe.layout.height /1.04347826087)
	
	
		// add Free play text
local demo = fe.add_text( "demonstration mode", 0 , fe.layout.height / 1.045 , fe.layout.width ,fe.layout.height / 28 );
demo.font = "futureforces";
demo.align = Align.Centre
	// Pulsatining Aminamtion for the free pulse
			animation.add( PropertyAnimation( demo, 
				{   
					property = "alpha",
					tween = Tween.Bounce, 
					start =  0,
					end = 255,
					pulse = true
					time = 4750

				} ) );

/// get the system to auto go right so many seconds
gridc.update_frame();

local config = fe.get_config();

class MovieMode5
{
	MIN_TIME = 4000; // the minimum amount of time this mode should run for (in milliseconds)
	obj=0;
	logo=0;
	start_time=0;
	is_exclusive=false;
	obj=null
    chance = 70
	constructor()
	{
		obj = gridc.video_t
		obj.video_flags = Vid.NoAutoStart | Vid.NoLoop;
	    obj.preserve_aspect_ratio = true;

	}

     function init( ttime )
	{
		start_time=ttime;
		obj.visible = true;
		obj.video_playing = true;
	}

	// return true if mode should continue, false otherwise
	function check( ttime )
	{
		local elapsed = ttime - start_time;
		return (( obj.video_playing == true ) || ( elapsed <= MIN_TIME ));
	}
		function on_select()
	{
		// select the presently displayed game
		fe.list.index += obj.index_offset;
	}
		function reset()
	{
		obj.visible = false;
		gridc.autommove();
	}

};

local config = fe.get_config();





function get_new_offset( obj )
{
	// try a few times to get a file
	for ( local i=0; i<6; i++ )
	{
		obj.index_offset = rand();

		if ( obj.file_name.len() > 0 )
			return true;
	}
	return false;
}

//
// Container for a wheel image w/ shadow effect
//
class ArtOverlay
{
	logo=0;
	logo_shadow=0;
	in_time=0;
	out_time=0;
	
	constructor( x, y, width, height, shadow_offset )
	{
		if ( config["overlay_art"] != "None" )
		{
		   
		
			logo_shadow = fe.add_artwork(
				config["overlay_art"],
				x + shadow_offset +12,
				y + shadow_offset + 70,
				width - 50,
				height - 50);

			logo_shadow.preserve_aspect_ratio = true;

			logo = fe.add_clone( logo_shadow );
			logo.set_pos( 15, y +70 );

			logo_shadow.set_rgb( 0, 0, 0 );
			logo_shadow.visible = logo.visible = false;
		}
	}

	function init( index_offset, ttime, duration )
	{
		if ( config["overlay_art"] != "None" )
		{
			logo.index_offset = index_offset;
			logo.visible = logo_shadow.visible = true;
			logo.alpha = logo_shadow.alpha = 0;
			in_time = ttime + 1000; // start fade in one second in

			if ( config["overlay_art"] == "wheel" )
			{
				// start fade out 2 seconds before video ends
				// for wheels
				out_time = ttime + duration - 2000;
			}
			else
			{
				// otherwise just flash for 4 seconds
				out_time = ttime + 4000;
			}
		}
	}

	function reset()
	{
		if ( config["overlay_art"] != "None" )
		{
			logo.visible = logo_shadow.visible = false;
		}
	}

	function on_tick( ttime )
	{
		if (( config["overlay_art"] != "None" )
			&& ( logo.visible ))
		{
			if ( ttime > out_time + 1000 )
			{
				logo.visible = logo_shadow.visible = false;
			}
			else if ( ttime > out_time )
			{
				logo.alpha = logo_shadow.alpha = 255 - ( 255 * ( ttime - out_time ) / 1000.0 );
			}
			else if ( ( ttime < in_time + 1000 ) && ( ttime > in_time ) )
			{
				logo.alpha = logo_shadow.alpha = ( 255 * ( ttime - in_time ) / 1000.0 );
			}
		}
	}
};

//
// Default mode - just play a video through once
//
class MovieMode
{
	MIN_TIME = 4000; // the minimum amount of time this mode should run for (in milliseconds)
	obj=0;
	logo=0;
	start_time=0;
	is_exclusive=false;

	constructor()
	{
		obj = gridc.video_t
		obj.video_flags = Vid.NoAutoStart | Vid.NoLoop;
	    obj.preserve_aspect_ratio = true;


		logo = ArtOverlay( 10, fe.layout.height - 640, 400, 175, 2 );
	}

	function init( ttime )
	{
		start_time=ttime;
		obj.visible = true;
		obj.video_playing = true;

		logo.init( obj.index_offset, ttime, obj.video_duration );
	}

	function reset()
	{
		obj.visible = false;
		gridc.autommove();
		logo.reset();
	}

	// return true if mode should continue, false otherwise
	function check( ttime )
	{
		local elapsed = ttime - start_time;
		return (( obj.video_playing == true ) || ( elapsed <= MIN_TIME ));
	}

	function on_tick( ttime )
	{
		logo.on_tick( ttime );
	}

	function on_select()
	{
		// select the presently displayed game
		fe.list.index += obj.index_offset;
	}
};

// 2x2 video display. Runs until first video ends
//
class MovieCollageMode
{
	objs = [];
	logos = [];
	ignore = [];
	ignore_checked = false;
	chance = 40; // precentage chance that this mode is triggered
	is_exclusive=false;
	BACKGROUND= false

	constructor()
	{
	    BACKGROUND = fe.add_image( "assets/background/scbackground.png",
		0, 0, fe.layout.width, fe.layout.height );
		BACKGROUND.set_rgb(0,0,0)
		BACKGROUND.visible=false
		
		objs.append( _add_obj( 0, 0  ,Vid.NoAutoStart | Vid.NoLoop ));
		objs.append( _add_obj( 1, 0 ,Vid.NoAutoStart | Vid.NoLoop | Vid.NoAudio ) );
		objs.append( _add_obj( 0, 1 , Vid.NoAutoStart | Vid.NoLoop | Vid.NoAudio ) );
		if ( config["sound"] == "No" )
			objs.append( _add_obj( 1, 1 ) );
		else
			objs.append( _add_obj( 1, 1, Vid.NoAutoStart | Vid.NoLoop | Vid.NoAudio ) );

		for ( local i=0; i<objs.len(); i++ )
		{
			ignore.append( false );
			logos.append( ArtOverlay( objs[i].x -5000, objs[i].y + objs[i].height - 5000, 260, 120, 1 ) );
		}
	}

	function _add_obj( x, y, vf=Vid.NoAudio | Vid.NoAutoStart | Vid.NoLoop )
	{
		local temp = fe.add_artwork( "", x*fe.layout.width, y*fe.layout.height, fe.layout.width, fe.layout.height );
		temp.visible = false;
		temp.video_flags = vf;
	    temp.preserve_aspect_ratio = true;

		return temp;
	}

	function obj_init( idx, ttime )
	{
		objs[idx].visible = true;
		BACKGROUND.visible = true;
		get_new_offset( objs[idx] );

		// try not to duplicate videos
		if ( fe.list.size > 7 )
		{
			for ( local j=0; j<4; j++ )
			{
				if (( j != idx ) && ( objs[idx].file_name == objs[j].file_name ))
				{
					get_new_offset( objs[idx] );
					break;
				}
			}
		}

		objs[idx].video_playing = true;

		logos[idx].init( objs[idx].index_offset, ttime, objs[idx].video_duration );
	}

	function init( ttime )
	{
		for ( local i=0; i<objs.len(); i++ )
		{
			obj_init( i, ttime );
			ignore[i] = false;
		}

		ignore_checked = false;
	}

	function reset()
	{
		foreach ( o in objs )
		{	
		    BACKGROUND.visible = false
			o.visible = false;
			o.video_playing = false;
		}

		foreach ( l in logos )
			l.reset();
	}

	// return true if mode should continue, false otherwise
	function check( ttime )
	{
		if (( ttime < 4000 ) || ( is_exclusive ))
			return true;
		else if ( ignore_checked == false )
		{
			//
			// We ignore videos that stopped playing within the first
			// 4 seconds (images are captured by this too)
			//
			local all_are_ignored=true;
			for ( local i=0; i<objs.len(); i++ )
			{
				if ( objs[i].video_playing == false )
					ignore[i] = true;
				else
					all_are_ignored = false;
			}

			ignore_checked = true;
			return (!all_are_ignored);
		}

		for ( local i=0; i<objs.len(); i++ )
		{
			if (( objs[i].video_playing == false )
					&& ( ignore[i] == false ))
				return ( ( rand() % 2 ) == 0 ); // 50/50 chance of leaving mode
		}
		return true;
	}

	function on_tick( ttime )
	{
		foreach ( l in logos )
			l.on_tick( ttime );

		for ( local i=0; i<objs.len(); i++ )
		{
			if ( objs[i].video_playing == false )
				obj_init( i, ttime );	
		}
	}

	function on_select()
	{
		// randomly select one of the presently displayed games
		fe.list.index += objs[ rand() % 4 ].index_offset;
	}
};
//
// Movie mode is always on, turn on the others as configured by the user
//
local modes = [];
local default_mode = MovieMode();

if ( config["movie_collage"] == "Yes" )
	modes.append( MovieCollageMode() );

if ( config["image_collage"] == "Yes" )
	modes.append( ImageCollageMode() );

if (( config["basic_movie"] == "No" ) && ( modes.len() > 0 ))
{
	default_mode = modes[0];
	modes.remove( 0 );
}

if ( modes.len() == 0 )
	default_mode.is_exclusive = true;

local current_mode = default_mode;
local first_time = true;

fe.add_ticks_callback( "saver_tick" );

//
// saver_tick gets called repeatedly during screensaver.
// stime = number of milliseconds since screensaver began.
//
function saver_tick( ttime )
{
	if ( first_time ) // special case for initializing the very first mode
	{
		current_mode.init( ttime );
		first_time = false;
	}

	if ( current_mode.check( ttime ) == false )
	{
		//
		// If check returns false, we change the mode
		//
		current_mode.reset();

		current_mode = default_mode;
		foreach ( m in modes )
		{
			if ( ( rand() % 100 ) < m.chance )
			{
				current_mode = m;
				break;
			}
		}

		current_mode.init( ttime );
	}
	else
	{
		current_mode.on_tick( ttime );
	}
}

fe.add_signal_handler( "saver_signal_handler" );

function saver_signal_handler( sig )
{
	if ( sig == "select" )
		current_mode.on_select();

	return false;
}
