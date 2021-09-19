// updated 2/1/2016
// Attract-Mode Front-End - "Robospin" layout
// Notes: Added random text colors, added vertical art option, adjusted text size and position, added static effect for null snaps, deleted some user options.
// 458 End of line!  

class UserConfig {
   </ label="Background Image", help="Choose blue/black/grid or no background.", options="blue,grid,retro,none", order=1 /> enable_image="blue";   
   </ label="Cab Skins", help="Choose robo or moon cab skin", options="robo,moon", order=2/> enable_cab="robo";
   </ label="SpinWheel", help="The artwork to spin", options="marquee,wheel", order=3 /> orbit_art="wheel";
   </ label="VertArt", help="Choose vertical art or wheel art.", options="Yes,No", order=4 /> enable_VertArt="No";
   </ label="Static Effect", help="Crt Static effect when null", options="yes,no", order=5 /> enable_static="yes"; 
   </ label="Bloom Shader Effect", help="Enable bloom Effect (requires shader support)", options="Yes,No", order=6 /> enable_bloom="No";
   </ label="CRT Effect", help="Enable CRT Effect (requires shader support)", options="Yes,No", order=7 /> enable_crt="No";
   </ label="Display Flyer", help="Display the flyer/game box in background.", options="Yes,No", order=8 /> enable_flyer="No";
   </ label="Mask", help="Make background dark/darker or none.", options="dark,darker,none", order=9/> enable_mask="none";
   </ label="Random Text Colors", help=" enable colors.", options="yes,no", order=10 /> enable_colors="yes";
   </ label="Transition Time", help="Time in milliseconds for wheel spin.", order=11 /> transition_ms="25";
   </ label="Logo", help="Enable Logo", options="Yes,No", order=12 /> enable_logo="Yes"; 
   </ label="Marquee", help="Enable Marquee", options="Yes,No", order=13 /> enable_marquee="Yes";
   </ label="Lighted Marquee", help="Enable Lighted Marquee", options="Yes,No", order=14 /> enable_Lmarquee="Yes";
   </ label="Pointers", help="Enable Pointer", options="rocket,hand,none", order=15 /> enable_pointer="rocket"; 
   </ label="Text Frame", help="Enable Text Frame", options="yes,no", order=16 /> enable_frame="yes"; 
}  

local my_config = fe.get_config();
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
fe.layout.font="grobold";
const SNAPBG_ALPHA = 200;


// modules
fe.load_module( "animate" );

// Background Image
if ( my_config["enable_image"] == "blue") 
{
 local bg = fe.add_image( "bkg.png", 0, 0, flw, flh );
}
if ( my_config["enable_image"] == "black")
{
 local bg = fe.add_image( "bkg2.png", 0, 0, flw, flh );
}
if ( my_config["enable_image"] == "grid")
{
 local bg = fe.add_image( "bkg3.png", 0, 0, flw, flh );
}
if ( my_config["enable_image"] == "retro")
{
 local bg = fe.add_image( "bkg4.png", 0, 0, flw, flh );
}
if ( my_config["enable_image"] == "none") 
{
 local bg = fe.add_image( "", 0, 0, flw, flh );
}

// Flyer 
if ( my_config["enable_flyer"] == "Yes") 
{
 local flyer = fe.add_artwork( "flyer", 0, 0, flw, flh);
 flyer.preserve_aspect_ratio = false;
}

//masking
if ( my_config["enable_mask"] == "none" )
{
local masking = fe.add_image( "", 0, 0, flw, flh );
}
if ( my_config["enable_mask"] == "dark" )
{
local masking = fe.add_image( "mask.png", 0, 0, flw, flh );
}
if ( my_config["enable_mask"] == "darker" )
{
local masking = fe.add_image( "mask2.png", 0, 0, flw, flh );
}

local snapbg=null;
if ( my_config["enable_static"] == "yes" )
{
	snapbg = fe.add_image(
		"static.mp4", flx*0.092, fly*0.38, flw*0.226, flh*0.267 );
    snapbg.trigger = Transition.EndNavigation;
	snapbg.skew_y = -fly*0.002;
    snapbg.skew_x = flx*0.009;
    snapbg.pinch_y = 7;
    snapbg.pinch_x = 0;
    snapbg.rotation = -4.7;
	snapbg.set_rgb( 155, 155, 155 );
	snapbg.alpha = SNAPBG_ALPHA;
}
else
{
	local temp = fe.add_text(
		"",
		224, 59, 352, 264 );
	temp.bg_alpha = SNAPBG_ALPHA;
}

//Surface
local surface = fe.add_surface( 640, 480 );
local snap = surface.add_artwork("snap", 0, 0, 640, 480);
snap.trigger = Transition.EndNavigation;
snap.preserve_aspect_ratio = false;

//position and pinch the surface
surface.set_pos(flx*0.092, fly*0.38, flw*0.226, flh*0.267);
surface.skew_y = -fly*0.002;
surface.skew_x = flx*0.009;
surface.pinch_y = 7;
surface.pinch_x = 0;
surface.rotation = -4.7;

if ( my_config["enable_bloom"] == "Yes" )
{
    local sh = fe.add_shader( Shader.Fragment, "bloom_shader.frag" );
	sh.set_texture_param("bgl_RenderedTexture"); 
	surface.shader = sh;
}

if ( my_config["enable_crt"] == "Yes" )
{
    local sh = fe.add_shader( Shader.VertexAndFragment, "crt.vert", "crt.frag" );
	sh.set_param( "rubyInputSize", 640, 480 );
    sh.set_param( "rubyOutputSize", ScreenWidth, ScreenHeight );
    sh.set_param( "rubyTextureSize", 640, 480 );
	sh.set_texture_param("rubyTexture"); 
	surface.shader = sh;
}

if ( my_config["enable_marquee"] == "Yes" )
{
local marquee = fe.add_artwork("marquee", flx*0.117, fly*0.086, flw*0.35, flh*0.14 );
 marquee.trigger = Transition.EndNavigation;
 marquee.skew_x = 11;
 marquee.pinch_x = -2;
 marquee.pinch_y = 3;
 marquee.rotation = -1.5;
   if ( my_config["enable_Lmarquee"] == "Yes" )
{
    local shader = fe.add_shader( Shader.Fragment "bloom_shader.frag" );
	shader.set_texture_param("bgl_RenderedTexture"); 
	marquee.shader = shader;
}

}
 else
 {
local user = fe.add_image("user.png", flx*0.117, fly*0.086, flw*0.35, flh*0.14 );
 user.trigger = Transition.EndNavigation;
 user.skew_x = 11;
 user.pinch_x = -2;
 user.pinch_y = 3;
 user.rotation = -1.5;
}

//cabinet image
if ( my_config["enable_cab"] == "robo" )
{
 local cab = fe.add_image( "robo.png", 0, 0, flw, flh );
}

if ( my_config["enable_cab"] == "moon" )
{
  local cab = fe.add_image( "moon.png", 0, 0, flw, flh );
} 

//enable frame to help text standout 
if ( my_config["enable_frame"] == "yes" )
{
local frame = fe.add_image( "frame.png", flx*0.338, fly*0.88, flw*0.32, flh*0.13 );
frame.alpha = 180;
}

//Year & Manufacturer info
local textm = fe.add_text("([Year]) " + "[Manufacturer]", flx*0.27, fly*0.885, flw*0.46, flh*0.021);
textm.set_rgb( 255, 255, 255 );
//textm.style = Style.Bold; 
//textm.align = Align.Left;

//Title info
local textt = fe.add_text( "[Title]", flx*0.35, fly*0.918, flw*0.3, flh*0.04  );
textt.set_rgb( 225, 255, 255 );
//textt.style = Style.Bold; 
//textt.align = Align.Left;
textt.rotation = 0;

//Category info
local textc = fe.add_text( "[Category]", flx*0.35, fly*0.975, flw*0.3, flh*0.021  );
textc.set_rgb( 255, 255, 255 );
//textc.style = Style.Italic; 
//textc.align = Align.Left;

local filter = fe.add_text( "[ListFilterName]: [ListEntry]-[ListSize]", flx*0.7, fly*0.98, flw*0.3, flh*0.016 );
filter.set_rgb( 255, 255, 255 );
//filter.style = Style.Italic;
filter.align = Align.Right;
filter.rotation = 0;

local play = fe.add_text( "Played  " + "[PlayedCount]", flx*0.797, fly*0.96, flw*0.2, flh*0.016 );
play.set_rgb( 255, 255, 255 );
play.align = Align.Right;   

//VertArt
if ( my_config["enable_VertArt"] == "Yes") 
{
fe.load_module( "conveyor" );
local wheel_x = [ flx*0.71, flx*0.71, flx*0.71, flx*0.71, flx*0.71, flx*0.71, flx*0.66, flx*0.71, flx*0.71, flx*0.71, flx*0.71, flx*0.71, ]; 
local wheel_y = [ -fly*0.22, -fly*0.105, fly*0.0, fly*0.105, fly*0.215, fly*0.325, fly*0.436, fly*0.61, fly*0.72 fly*0.83, fly*0.935, fly*0.99, ];
local wheel_w = [ flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.28, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, ];
local wheel_a = [  80,  80,  80,  80,  80,  80, 255,  80,  80,  80,  80,  80, ];
local wheel_h = [  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11, flh*0.168,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11, ];
local wheel_r = [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ];
local num_arts = 10;

class WheelEntry extends ConveyorSlot
{
	constructor()
	{
		base.constructor( ::fe.add_artwork( my_config["orbit_art"] ) );
	}

	function on_progress( progress, var )
	{
		local p = progress / 0.1;
		local slot = p.tointeger();
		p -= slot;
		
		slot++;

		if ( slot < 0 ) slot=0;
		if ( slot >=10 ) slot=10;

		m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
		m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
		m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
		m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
		m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
		m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
	}
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
	wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle one showing the current
// selection (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
	wheel_entries.insert( num_arts/2, WheelEntry() );

local conveyor = Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 50;
try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }
}
 else
{
fe.load_module( "conveyor" );
local wheel_x = [ flx*0.80, flx*0.795, flx*0.756, flx*0.725, flx*0.70, flx*0.68, flx*0.63, flx*0.68, flx*0.70, flx*0.725, flx*0.756, flx*0.76, ]; 
local wheel_y = [ -fly*0.22, -fly*0.105, fly*0.0, fly*0.105, fly*0.215, fly*0.325, fly*0.436, fly*0.61, fly*0.72 fly*0.83, fly*0.935, fly*0.99, ];
local wheel_w = [ flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.28, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, ];
local wheel_a = [  80,  80,  80,  80,  80,  80, 255,  80,  80,  80,  80,  80, ];
local wheel_h = [  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11, flh*0.168,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11, ];
//local wheel_r = [  31,  26,  21,  16,  11,   6,   0, -11, -16, -21, -26, -31, ];
local wheel_r = [  30,  25,  20,  15,  10,   5,   0, -10, -15, -20, -25, -30, ];
local num_arts = 10;

class WheelEntry extends ConveyorSlot
{
	constructor()
	{
		base.constructor( ::fe.add_artwork( my_config["orbit_art"] ) );
	}

	function on_progress( progress, var )
	{
		local p = progress / 0.1;
		local slot = p.tointeger();
		p -= slot;
		
		slot++;

		if ( slot < 0 ) slot=0;
		if ( slot >=10 ) slot=10;

		m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
		m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
		m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
		m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
		m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
		m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
	}
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
	wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle one showing the current
// selection (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
	wheel_entries.insert( num_arts/2, WheelEntry() );

local conveyor = Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 50;
try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }
}

//property animation - wheel pointers
if ( my_config["enable_pointer"] == "rocket") 
{
local point = fe.add_image("pointer.png", flx*0.88, fly*0.34, flw*0.2, flh*0.35);

local alpha_cfg = {
    when = Transition.ToNewSelection,
    property = "alpha",
    start = 110,
    end = 255,
    time = 300
}
animation.add( PropertyAnimation( point, alpha_cfg ) );

local movey_cfg = {
    when = Transition.ToNewSelection,
    property = "y",
    start = point.y,
    end = point.y,
    time = 200
}
animation.add( PropertyAnimation( point, movey_cfg ) );

local movex_cfg = {
    when = Transition.ToNewSelection,
    property = "x",
    start = flx*0.83,
    end = point.x,
    time = 200	
}	
animation.add( PropertyAnimation( point, movex_cfg ) );
}

if ( my_config["enable_pointer"] == "hand") 

 {
 local point = fe.add_image("pointer2.png", flx*0.88, fly*0.34, flw*0.2, flh*0.35);
 local alpha_cfg = {
    when = Transition.ToNewSelection,
    property = "alpha",
    start = 110,
    end = 255,
    time = 300
}
animation.add( PropertyAnimation( point, alpha_cfg ) );

local movey_cfg = {
    when = Transition.ToNewSelection,
    property = "y",
    start = point.y,
    end = point.y,
    time = 200
}
animation.add( PropertyAnimation( point, movey_cfg ) );

local movex_cfg = {
    when = Transition.ToNewSelection,
    property = "x",
    start = flx*0.83,
    end = point.x,
    time = 200	
}	
animation.add( PropertyAnimation( point, movex_cfg ) );
}

if ( my_config["enable_pointer"] == "none") 
{
 local point = fe.add_image( "", 0, 0, 0, 0 );
}

if ( my_config["enable_logo"] == "Yes" )
{
 local logo = fe.add_image("mame.png", flx*0.001, fly*0.18, flw*0.11, flh*0.05 );
 logo.trigger = Transition.EndNavigation;
 logo.rotation = -15;
 fe.add_transition_callback("transition_callback" );  
 function transition_callback(ttype, var, ttime)
{
    switch ( ttype )
    {
        case Transition.ToNewList:
            switch ( fe.list.name )
            {
              
				case "MAME":
                logo.file_name = "mame.png";
                break;
                case "SNES":
                logo.file_name = "snes.png";
                break;
                case "NES":
                logo.file_name = "nes.png";
                 break;            
                case "GENESIS":
                logo.file_name = "sega.png";
                break; 			
			    case "kat5200":
                logo.file_name = "atari.png";
                break; 			
                case "N64":
                logo.file_name = "n64.png";
                break; 			
			}
			break;
    }

}

}

// random number for the RGB levels

if ( my_config["enable_colors"] == "yes" )
{
function brightrand() {
 return 255-(rand()/255);
}

local red = brightrand();
local green = brightrand();
local blue = brightrand();

// Color Transitions
fe.add_transition_callback( "color_transitions" );
function color_transitions( ttype, var, ttime ) {
 switch ( ttype )
 {
  case Transition.StartLayout:
  case Transition.ToNewSelection:
  red = brightrand();
  green = brightrand();
  blue = brightrand();
  play.set_rgb  (red,green,blue);
  filter.set_rgb(red,green,blue);
  textm.set_rgb (red,green,blue);
  textc.set_rgb (red,green,blue);
  textt.set_rgb (red,green,blue);
  break;
 }
 return false;
}
}








