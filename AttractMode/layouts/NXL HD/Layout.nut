///////////////////////////////////////////////////
//
// 2/4/2017
// added more manufactures to db cleaned up some of the code
///1/20/2017
//Atrfate
// Adding alot of new features kind of hard to documented
// New system to read "Status" option in game menu This used for nxl theme, to check the games version if nesys game or not
// new System to read "manufacturer data" and spit out some japnease text on screen
// added animations to the new features
// more surface cleanup and other fixes/minor changes
// Attract-Mode Frontend - Grid layout Neysys mod
// 12/9/16
// Chanaged Redunant animations, by adding the artwork assets to surfaces
//12/1/16
///Atrfate
//Varuious changes and tweaks to ui elements aswell as complete updated artset for the nesicaxlive system
//Hijacked Romlist to enable system images to be displayed
//added system of orgin on screen display
// 10/8/10
// AtrFate
// {feature} new sounds added and changed existing ones, new click new artwork toggle
//  { Change } fixed placement after arcadeblisss;s left right fix.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 2016-10-7
// ArcadeBliss
///{ bug fix } Fixed left right movement in grid.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 2016-17-23 atrfate Changelog
// [fixed] various issues insvoling vertical mode
///such as defining the placement of the grid similar to how horizotal mode is handled//
//// removed grid background to make its own layer so it can be placed above videos that clip into it.
///added free play text, and network to new layer
// added new animation for video swapping
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 2016-07-23 atrfate Changelog
/// [ Feature ] new text animation for title manufature and grid load
/// [ Feature ] added new frameg, this is used to create a better glow effect animation
/// [ Feature ] new animation for Logo display
//  [ Feature ] added new frameg, this is used to create a better glow effect animation
// 2016-07-23 atrfate Changelog
/// [Feature] new sounds for Game start, Game select, and game cancel
//  [ BugFix ] Moved wheel Click sound into frame movement controls to properly play
//
///////////////////////////////////////////////////
// 2016-07-23 atrfate Changelog
/// [Feature] info.buttons changed to toggle option between controls and buttons
//  [ Add ] new artwork for publishers to DB

///////////////////////////////////////////////////
// 2016-07-23 atrfate Changelog
/// [Change] Changed Zorder To a higher number seems to help fix the zorder bug
///////////////////////////////////////////////////

// 2016-07-23 atrfate Changelog
/// [Change] PAD now broken into padx and pay
/// [Change] Changed the way the grid moves left moves entire grid left 1 game vise vira for right
/// [Change] Changed alinment of list text
///////////////////////////////////////////////////

// 2016-07-23 atrfate Changelog
/// [Change] Seperated the the background form the menu controls , this way people have custom controls more easily
/// [Change] Changed the Background image at some point the grid on the background was made of center
///////////////////////////////////////////////////

// 2016-07-23 ArcadeBliss Changelog
///===============================================================
// - [CHANGE] Lag improvement. Added trigger=Transition.EndNavigation to all artworks
// - [CHANGE] Moved arrow and background artwork to artwork section in script
// - [CHANGE] Change layout settings default to match Atrfate recommendations
// - [CHANGE] Write a function to ensure Genre is a specific length

// 2016-07-22 Atrfate Chanlog
///===============================================================
////Changed enlarge to smaller number
////Changed placement of arrows in loading order ( no longer shows above artwork)
////[Feature]chnages artwork rotate to video/title/flyer
/// Not yet implemented making new frame for selection

// 2016-07-22 ArcadeBliss Changelog
// =============================================
// - [BUGFIX] changed active wheel's zorder again to be lower than the menu overlay
// - [BUGFIX] Bloom setting was not working
// - [BUGFIX] Fixed rotating artwork not working as requested

// 2016-07-22 ArcadeBliss Changelog
// =============================================
// - [FEATURE] fancy animated wheels on first start
// - [CHANGE] changed active wheel's zorder to highest to ensure overlap does not occur
// - [BUGFIX] fix a scrolling bug when fast scrolling is active
// - [BUGFIX] selectable Artwork was not updating when not visible


// 2016-07-21 ArcadeBliss Changelog
// =============================================
// - [FEATURE] animated frame movement
// - [FEATURE] animated selected game (under the frame)
// - [CHANGE] completed code for the "start game" menu (is turned off when showing normal AM menus)
// - [FEATURE] allow to cycle through the artwork of the selected game
// - [FEATURE] added default artwork in case needed artwork is missing
// - [FEATURE] create a new animation for the animate plugin allow center scaling of artwork using exact width and height values (see the modules folder in the theme)
// - [FEATURE] created user setting to pick which artwork to use for the game selection list
// - [FEATURE] created user setting to cycle through the artwork of the selected game using a key
// - [FEATURE] created user setting to turn on a bloom shader effect for the select game
// - [CHANGE] change the frame1.png to allow it to cycle colors (now all white)
// - [CHANGE] removed redundant code and errors
// - [CHANGE] documented theme inline for the future
// - [CHANGE] ensure all Artwork is displayed correctly for the selected game
// - [BUGFIX] fix a bug in the animate plugin (see the modules folder)


class UserConfig </ help="Navigation controls: Up/Down (to move up and down) and Page Up/Page Down (to move left and right)" />{
	</ label="Grid Artwork", help="The artwork to display in the grid", options="snap,marquee,flyer,wheel", order=1 />
	art="wheel";

	</ label="Gane Selection Glow", help="Add a highlight effect to the select game", options="Yes,No", order=2 />
	shader="false";
	</ label="Preserve Grid Artwork Aspect Ration", help="Preserve grid artwork aspect ratio", options="Yes,No", order=3 />
	aspect_ratio="No";

	</ label="Logo Artwork", help="The artwork to display in the upper right corner", options="logo,snap,marquee,flyer,wheel", order=4 />
	logo="logo";

    </ label="Flow", help="Select the flow direction of the grid", options="Horizontal,Vertical", order=7 />
	flow="Horizontal";

    </ label="Background", help="The filename of the image or video to display in the background", order=8 />
	bg_image="assets/backgrounds/Background.png";

	</ label="Transition Time", help="The amount of time (in milliseconds) that it takes to scroll to another grid entry", order=9 />
	ttime="175";
	</ label="Rotate Art", help="Choose that key to switch the artwork shown", options="custom1,custom2,custom3,custom4,custom5,custom6", order=10 />
	artRotate="custom1";
	</ label="Buttons update", help="This controls what the buttons with update with either control field or the button field", options="Buttons,Con," order=11 />
	nbuttons="Con";

}

fe.load_module( "conveyor" );
fe.load_module("animate");

fe.layout.width = 1920;
fe.layout.height = 1080;

//Overlay Menu Settings
const OVERLAY_ALPHA =190;
const PADX=2; // Snap padding
const PADY=2; // Snap padding
const ENLARGE = 0.125 // Enlarge ratio for the selected grid artwork

local my_config = fe.get_config();
local rows = 2;
local cols = 4;
local height = ( fe.layout.height * 11 / 48.85 ) / rows.tofloat();
local width = fe.layout.width / cols.tofloat() / 1.10 - 10;
local frame_width = ((width - 2 * PADX ) + (width * ENLARGE))+15;  // set the size of the frame larger than the snaps
local frame_height = ((height - 2 * PADY) + (height * ENLARGE))+15; // set the size of the frame larger than the snaps
local frameg_width = ((width - 3 * PADX ) + (width * ENLARGE))+15;  // set the size of the frame larger than the snaps
local frameg_height = ((height - 3 * PADY) + (height * ENLARGE))+15; // set the size of the frame larger than the snaps
local vert_flow = ( my_config["flow"] != "Horizontal" );
local aspect_ratio = true;
local Nbutton1 = ( my_config[ "nbuttons"] )
if (my_config["aspect_ratio"] == "No")
	aspect_ratio = false;



////////////////////////////////
//
//  Setup Conveyour Grid
//
////////////////////////////////
	class Grid extends Conveyor
	{
	    frameg=null;
		frame=null;
		name_t=null;
		num_t=null;
		sel_x=0;
		sel_y=0;
		child_t=null;
		mfa_t=null;
		wbfs_t=null;
		wbvs_t=null;
		wbcs_t=null;
		wbts_t=null;
		img_t=null;
		img_s=null;
		manufacturer=null;
		bt_t=null;
		jap_t=null;
		net_t=null;
		jap_rss=null;
		over_t=null;
		prev_sel =0;

		constructor()
		{
			base.constructor();

			sel_x = cols / 3;
			sel_y = rows / 3;
			stride = fe.layout.page_size = vert_flow ? rows : cols;



			try
			{
				transition_ms = my_config["ttime"].tointeger();
			}
			catch ( e )
			{
				transition_ms = 220;
			}
		}

		function update_frame()
		{
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
						x = (width * sel_x + ((fe.layout.width - (fe.layout.width / 1.105448275)) / 2)) - ((frame_width - (width))/2) + 20 - 2,
						y = ((fe.layout.height / 1.51 + height * sel_y)) - ((frame_height - (height))/2)
					},
					time = transition_ms
				} ) );

			// Movement Animation for the frame
			animation.add( PropertyAnimation( frame,
				{
					property = "position",
					tween = Tween.Linear,
					end = {
						x = (width * sel_x + ((fe.layout.width - (fe.layout.width / 1.105448275)) / 2)) - ((frame_width - (width))/2) + 20 - 2,
						y = ((fe.layout.height / 1.51 + height * sel_y)) - ((frame_height - (height))/2)
					},
					time = transition_ms
				} ) );
				// Movement Animation for the Game Title
			animation.add( PropertyAnimation( child_t,
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



					// Movement Animation for the Game system
			animation.add( PropertyAnimation( img_s,
				{
				    property = "alpha",
					tween = Tween.Linear,
					start =  0,
					end = 135,
					pulse = false,
					time = transition_ms * 3
				} ) );


		// Movement Animation for the bottom title
			animation.add( PropertyAnimation( jap_rss,
				{
					property = "position",
					tween = Tween.Linear,
					start = {
						x =  1920
						y =  fe.layout.height / 1.045  - 58
					},
					end = {
						x =  -1920
						y =  fe.layout.height / 1.045  - 58
					},
					time = 14000
					loop = true
				} ) );





			// Update all of the text and artwork
			bt_t.index_offset = img_t.index_offset = mfa_t.index_offset = child_t.index_offset  = num_t.index_offset = get_sel() - selection_index;
			name_t.set_index_offset(get_sel() - selection_index);
			wbts_t.index_offset = wbcs_t.index_offset = wbvs_t.index_offset = wbfs_t.index_offset = get_sel() - selection_index;
			jap_rss.index_offset = jap_t.index_offset = over_t.index_offset = img_s.index_offset = get_sel() - selection_index;
			net_t.index_offset = get_sel() - selection_index;



			ChangeArtwork.fade()
			fadeanimation()
		}



		// get the current position of the frame (is the same index for the snap under the frame)
		function get_sel()
		{

			return ( sel_x * rows + sel_y ) ;
		}


		// logic used to move the frame
		function move_frame( direction )
		{
		    local Wheelclick = fe.add_sound("assets/sounds/Click.mp3")

			switch ( direction )
			{
			case "down":
				transition_swap_point=0.0;
				if ( vert_flow && ( sel_y > 0 ) )
				{
					sel_y--;
					Wheelclick.playing=true
					update_frame();
				}
				else if ( !vert_flow && ( sel_x > 0 ) )
				{
					sel_x--;
					Wheelclick.playing=true
					update_frame();
				}
				else{
				    Wheelclick.playing=true
					return false;
				}
				return true;
				break;

			case "up":
				transition_swap_point=0.0;
				if ( vert_flow && ( sel_y < rows - 1 ))
				{
					sel_y++;
					Wheelclick.playing=true
					update_frame();
				}
				else if ( !vert_flow && ( sel_x < cols - 1 ) )
				{
					sel_x++;
					Wheelclick.playing=true
					update_frame();
				}
				else{
				    Wheelclick.playing=true
					return false;
				}
				return true;
				break;

			case "left":
				transition_swap_point=0.0;
				if ( vert_flow && ( sel_x > 0 ))
				{
					sel_x--;
					Wheelclick.playing=true
					update_frame();
				}
				else if ( !vert_flow && ( sel_y > 0 ) )
				{
					sel_y++;
					Wheelclick.playing=true
					update_frame();
				}
				else{
				    Wheelclick.playing=true
					return false;
				}
				return true;
				break;

			case "right":
				transition_swap_point=0.0;
				if ( vert_flow && ( sel_x < cols - 1 ) )
				{
					sel_x++;
					Wheelclick.playing=true
					update_frame();
				}
				else if ( !vert_flow && ( sel_y < rows - 1 ) )
				{
					sel_y--;
					Wheelclick.playing=true
					update_frame();
				}
				else{
				    Wheelclick.playing=true
					return false;
				}
				return true;
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

			// return the selected index offset of the current frame
			return get_sel()- selection_index;
		}

		function set_slots( objs, sel_index=-1 )
		{

			if (fe.overlay.is_up == false )
			{
			if ( sel_index < 0 )
				selection_index = objs.len() / 2;
			else
				selection_index = sel_index;

			m_objs = [];

			for ( local i=0; i<objs.len(); i++ )
			{
				m_objs.push( objs[i] );
				m_objs[i].m_base_progress = i.tofloat() / objs.len();

				m_objs[i].m_base_io = i - selection_index;

				m_objs[i].reset_index_offset();

			    m_objs[i].on_progress( m_objs[i].m_base_progress, 0 );
				//animate the slots into place

				//animate the items for the initail_setup
			//	m_objs[i].initial_load_setup( m_objs[i].m_base_progress, 0 );

			}
			}
		}

		function on_transition( ttype, var, ttime )
		{
			switch ( ttype )
			{
			case Transition.StartLayout:
			case Transition.FromGame:
				if ( ttime < transition_ms )
				{
					return true;
				}

		//		local old_alpha = m_objs[ m_objs.len()-1 ].snap.alpha;

				frame.alpha = 255;

	//			if ( old_alpha != 255 )
	//				return true;

				break;

			case Transition.ToGame:
			case Transition.EndLayout:
				if ( ttime < transition_ms )
				{
					return true;
				}

				frame.alpha = 0;

				break;

			case Transition.FromOldSelection:
			case Transition.ToNewList:

				break;
			}

			return base.on_transition( ttype, var, ttime );
		}
	}

////////////////////////////////
//
//  Setup Conveyour Slots
//
////////////////////////////////

	class MySlot extends ConveyorSlot
	{
		snap = null;
		m_num = null;
		transition_ms = null;
		original_snap_width = null;
		original_snap_height = null;
		snap_width_delta = null;
		snap_height_delta = null;
		orginal_snap_y = null;
		orginal_snap_x = null;
		select_status=false;
		bloomActive = false;
		sel_x=0;
		sel_y=0;

		constructor( num )
		{

			transition_ms = my_config["ttime"].tointeger();

			m_num = num;

			snap = fe.add_artwork( my_config["art"], 0, 0, width - 4*PADX, height - 4*PADY );
			snap.trigger = Transition.EndNavigation;

			original_snap_width = width - 4*PADX;
			original_snap_height = height - 4*PADY;

			snap_width_delta = (original_snap_width * ENLARGE) / 2;
			snap_height_delta = (original_snap_height * ENLARGE) / 2;

			base.constructor();
		}





		function on_progress( progress, var )
		{

			local r = m_num % rows;
			local c = m_num / rows;

			if ( abs( var ) < rows )
			{
		     //	  (colums position / game item width) + width of the game menu put in the middle of the screen - the

				if (select_status)
				{
					snap.x = (c * width) + (fe.layout.width - (fe.layout.width / 1.105448275)) / 2 + 20 - (snap_width_delta) + 1;
					snap.y =  ((fe.layout.height / 1.51) + r * height) - (snap_height_delta) + 2;

				} else {
					snap.x = (c * width) + (fe.layout.width - (fe.layout.width / 1.105448275)) / 2 + 20;
					snap.y =  ((fe.layout.height / 1.51) + r * height) + 2;
				}



			} else {

				local prog = ::gridc.transition_progress;
				if ( prog > ::gridc.transition_swap_point )
				{
					if ( var > 0 ) c++;
					else c--;
				}

				if ( var > 0 ) prog *= -1;

				 	if (select_status)
				{
				 snap.x = ((c + prog) * width) + (fe.layout.width - (fe.layout.width / 1.105448275)) / 2 - (snap_width_delta) + 20 ;
				 snap.y = ((fe.layout.height / 1.51) + r * height) + 2 - (snap_height_delta);

				} else {
				 snap.x = ((c + prog) * width) + (fe.layout.width - (fe.layout.width / 1.105448275)) / 2 + 10;
				 snap.y = ((fe.layout.height / 1.51) + r * height) + 2;
				}


			}
		}



		function preserveAspect(value)
		{
			snap.preserve_aspect_ratio = value;
			return
		}

		function activateBloom()
		{
			local sh = null;
			if (bloomActive && select_status)
			{
				sh = fe.add_shader( Shader.Fragment, "assets/shaders/bloom_shader.frag" );
				sh.set_texture_param("bgl_RenderedTexture");
				snap.shader = sh;
			} else {
				sh = fe.add_shader( Shader.Empty, "assets/shaders/bloom_shader.frag" ) ;
				snap.shader = sh;
			}

			return
		}

		function swap( other )
		{
			snap.swap( other.snap );
		}

		function set_index_offset( io )
		{
			snap.index_offset = io;
		}

		function reset_index_offset()
		{
			snap.rawset_index_offset( m_base_io );
		}


		// mute / unmute videos
		function video_play(button)
		{
			if (button == "ON") {
				snap.video_flags= Vid.Default;
			} else {
				snap.video_flags= Vid.NoAudio;
			}
			return;
		}

		function grow()
		{
			select_status = true;
			activateBloom();
			snap.zorder=20;
			animation.add( ScaleWidthHeight( snap,
			{
				property = "scale",
				tween = Tween.Linear,
				end = {
					w = snap.width + (snap.width * ENLARGE),
					h = snap.height + (snap.height * ENLARGE)
				},
				time = 1
			} ) );


			return;
		}

		function shrink()
		{
			select_status = false;
			activateBloom();
			snap.zorder=3;
			animation.add( ScaleWidthHeight( snap,
			{
				property = "scale",
				tween = Tween.Linear,
				end = {
					w = original_snap_width,
					h = original_snap_height
				},
				time = transition_ms
			} ) );

			return;
		}

	}
////////////////////////////////////////
//
//Change Artwork using Configured button
//
///////////////////////////////////////
	class ChangeArtwork
	{
		artWork_to_Rotate = [];
		image = [];
		image_index = null;
		_trigger = null;
		test=0;

		constructor(trigger)
		{
			image_index = 0;

			_trigger = trigger;

			artWork_to_Rotate = ["snap","flyer","title"];

			foreach (i in artWork_to_Rotate)
			{
				image.push(fe.add_artwork( i, 0 , fe.layout.height / 20, fe.layout.width, fe.layout.height * 0.605 - 4));

			}

			foreach (i in image)
			{
				i.preserve_aspect_ratio = true;
				i.trigger = Transition.EndNavigation;
				i.alpha = 0;

			}

			image[2].video_flags = Vid.ImagesOnly;

			image[image_index].alpha = 255;

			fe.add_signal_handler(this, "on_signal");
		}

		function set_index_offset(value)
		{
			foreach (o in image)
			{
				o.index_offset = value;
			}
		}
		function fade()
		{
		   if ( image[0].alpha == 255)
		   {
		   image[1].alpha = 0
	    // Fadeanimation
			animation.add( PropertyAnimation( image[0],
				{
				    property = "alpha",
					tween = Tween.Linear,
					start =  0,
					end = 255,
					pulse = false,
					time = 225
				} ) );
				}
				   if ( image[1].alpha == 255)
		   {
		   image[0].alpha = 0
	    // Fadeanimation
			animation.add( PropertyAnimation( image[1],
				{
				    property = "alpha",
					tween = Tween.Linear,
					start =  0,
					end = 255,
					pulse = false,
					time = 225
				} ) );
				}
		}


		function rotate_image()
		{
			//hide current image
			image[image_index].alpha = 0;

			//turn off snap audio if when hiding
			if (image_index == 0)
				image[image_index].video_flags = Vid.NoAudio;

			//show next image
			image_index++ ;
			if (image_index == artWork_to_Rotate.len())
				image_index = 0;
			image[image_index].alpha = 0;
          if ( image[image_index].alpha == 0 );
		  {
	    // Fadeanimation
			animation.add( PropertyAnimation( image[image_index],
				{
				    property = "alpha",
					tween = Tween.Linear,
					start =  0,
					end = 255,
					pulse = false,
					time = 225
				} ) );
		 }

			// if current selection is the video, turn on the sound
			if (image_index == 0)
				image[image_index].video_flags = 0 ;

		    //Play a sound to change images

	         local Artsort = fe.add_sound("assets/sounds/sort.mp3")
		    Artsort.playing=true



			return;
		}

		// set up the button to trigger the signal
		function on_signal( signal )
		{
			if ( signal == _trigger )
			{
				this.rotate_image();
			}
		}

	}


//////////////////////////////////
// Setup Artwork for Layout
//////////////////////////////////

	// add background image
	if ( my_config[ "bg_image" ].len() > 0 )
	fe.add_image( my_config[ "bg_image" ],
			0, 0, fe.layout.width, fe.layout.height );

    //Gridbackground note flitertag is drawn after video
	local bgforgrid = fe.add_image("assets/uielements/gridbackground.png", 0,0,fe.layout.width, fe.layout.height)
	local bgforgrid2 = fe.add_image("assets/uielements/Grid Backgroundrss.png", 0,0,fe.layout.width, fe.layout.height)



	// add selection arrows
	local arrows = fe.add_image("assets/uielements/arrow.png", 0 ,fe.layout.height * 0.720 + 12,fe.layout.height / 12,fe.layout.height / 12);
	local arrow2 = fe.add_image("assets/uielements/arrow2.png", fe.layout.width / 1.048034 ,fe.layout.height * 0.720 + 12,fe.layout.height / 12,fe.layout.height / 12);

    // add MenuControls artwork
	local menucontrols = fe.add_image("assets/uielements/Menucontrols.png",(fe.layout.width * ( -0.0260416666 )), fe.layout.height * 0.29166666666, fe.layout.width * 0.234375, 0);
     menucontrols.preserve_aspect_ratio=true





	// Populate the conveyor
	::gridc <- Grid();
	local my_array = [];
	for ( local i=0; i<rows*cols; i++)
	{
		my_array.push( MySlot( i ) );
		if (my_config["shader"] == "Yes")
			my_array[i].bloomActive = true;

		my_array[i].preserveAspect(aspect_ratio);
	}
	gridc.set_slots( my_array, gridc.get_sel() );

	//add rotatable artwork with a key
	gridc.name_t =  ChangeArtwork(my_config["artRotate"]);

	   //Gridbackground flitertag
	local bgforgrid2 = fe.add_image("assets/uielements/flitertag.png", 0,0,fe.layout.width, fe.layout.height)


	// add game title to top
	gridc.child_t = fe.add_text( "[Title]", 0, fe.layout.height / -72 , fe.layout.width ,fe.layout.height / 20  );
	gridc.child_t.font = "futureforces";

	// add top layout overlay
	local bgoverlay = fe.add_image("assets/uielements/wings.png", 0 ,0 ,fe.layout.width ,fe.layout.height );
	bgoverlay.preserve_aspect_ratio = true;

	// add network image
	gridc.net_t = fe.add_image("[!network]", fe.layout.width / 360 , fe.layout.height /1.04347826087 , fe.layout.width / 42.6666666667 , fe.layout.height / 27  );
	gridc.net_t.preserve_aspect_ratio = true
	local networkimageclone = fe.add_clone (gridc.net_t)
    networkimageclone.set_pos(fe.layout.width / 1.02949061662,fe.layout.height /1.04347826087)
	networkimageclone.preserve_aspect_ratio = true

	// add the infobox graphic
	local Infobox1 = fe.add_image( "assets/uielements/INFOBOX2.png", fe.layout.width / 1.217 - 20, fe.layout.height / 4.245 + 10, 330 , 440);

	//Add FadeSurface For FadeAnimations
	local fadeitems = fe.add_surface(fe.layout.width,fe.layout.height)
	local fadeitems2 = fe.add_surface(fe.layout.width,fe.layout.height)



	// add the logo artwork to the top left
	gridc.mfa_t = fadeitems.add_artwork(my_config["logo"],  fe.layout.height / 72, fe.layout.height / 17, fe.layout.height / 2.91, fe.layout.width / 11.3408);;
	gridc.mfa_t.preserve_aspect_ratio = true;
	gridc.mfa_t.trigger = Transition.EndNavigation;



	// add the game manufacturer logo
	gridc.img_t = fadeitems.add_image( "[!publisher]", fe.layout.width / 1.25, fe.layout.height / 17, fe.layout.height / 2.91, fe.layout.height / 6.38);
	gridc.img_t.preserve_aspect_ratio = true;
	gridc.img_t.trigger = Transition.EndNavigation;




		function fadeanimation()
	{

    // Fadeanimation
			animation.add( PropertyAnimation( fadeitems,
				{
				    property = "alpha",
					tween = Tween.Linear,
					start =  0,
					end = 255,
					pulse = false,
					time = 250
				} ) );
		 }





	// add the game system logo
	gridc.img_s = fe.add_image( "[!systemg]", 5, fe.layout.height / 4.65, fe.layout.height / 8.5, fe.layout.width / 60);
	gridc.img_s.trigger = Transition.EndNavigation;
	gridc.img_s.preserve_aspect_ratio = true;
    gridc.img_s.alpha = 100;

	// add the filter name text
	local sorting = fe.add_text( "[FilterName]", 0, fe.layout.height / 1.618, fe.layout.width, fe.layout.height / 36 )
	sorting.font = "Squares Bold Free";
	sorting.align = Align.Left

	//add the game entry info
   gridc.num_t = fe.add_text( "[ListEntry]/[ListSize]", fe.layout.width / - 1.185, fe.layout.height / 1.618, fe.layout.width, fe.layout.height / 36 )
   gridc.num_t.font = "Squares Bold Free";
   gridc.num_t.align = Align.Right;


	// add the number of players to the info box
	gridc.wbvs_t = fadeitems2.add_text( "[Players]", fe.layout.width / 2.306 - 30, fe.layout.height / 3.829, fe.layout.width ,fe.layout.height / 32.7  );
	gridc.wbvs_t.font = "Squares Bold Free";

	// add the genre to the infobox
	gridc.wbts_t = fadeitems2.add_text( "[!genre]", fe.layout.width / 2.306 - 30, fe.layout.height / 2.938, fe.layout.width ,fe.layout.height / 32.7  );
	gridc.wbts_t.font = "Squares Bold Free";

	// add the year to the infobox
	gridc.wbfs_t = fadeitems2.add_text( "[Year]", fe.layout.width / 2.306 - 30, fe.layout.height / 2.482, fe.layout.width ,fe.layout.height / 32.7  );
	gridc.wbfs_t.font = "Squares Bold Free";

	// add the game rotation to the infobox
	gridc.wbcs_t = fadeitems2.add_text( "[Rotation]", fe.layout.width / 2.306 - 30, fe.layout.height / 2.087, fe.layout.width ,fe.layout.height / 32.7  );
	gridc.wbcs_t.font = "Squares Bold Free";

	// add the button controls picture to the infobox
	gridc.bt_t = fadeitems2.add_image("[!buttons]", fe.layout.width / 1.122 - 30, fe.layout.height / 1.92, fe.layout.height / 7.2, fe.layout.height / 7.2);
	gridc.bt_t.preserve_aspect_ratio = true;
	gridc.bt_t.trigger = Transition.EndNavigation;

	// add the japanese text to the lower bottom
	gridc.jap_t = fe.add_text( "[AltTitle]", 0, fe.layout.height / 1.045 , fe.layout.width ,fe.layout.height / 30 );
	gridc.jap_t.font = "MSMINCHO";
	gridc.jap_t.style = Style.Bold

	// add the frame selection box
	gridc.frame = fe.add_image( "assets/uielements/frame.png", frame_width * 2, frame_height * 2, frame_width, frame_height );
	gridc.frame.alpha = 0;
	// add the frame selection box glow
	gridc.frameg = fe.add_image( "assets/uielements/frameglow.png", frame_width * 2, frame_height * 2, frameg_width, frameg_height );
	gridc.frameg.alpha = 0;

    gridc.jap_rss = fe.add_text( "[!rss]", 0, fe.layout.height / 1.045  - 58, fe.layout.width ,fe.layout.height / 30 );
	gridc.jap_rss.font = "MSMINCHO";
	gridc.jap_rss.style = Style.Bold



	// Dynamically change the genre text
	function genre(offset)
	{
		local result = "UNKNOWN";
		local cat = " " + fe.game_info(Info.Category, offset).tolower();
		local supported = {
			//filename : [ match1, match2 ]
			"action": [ "action" ],
			"adventure": [ "adventure" ],
			"fighting": [ "fighting", "fighter", "beat'em up" ],
			"platform": [ "platformer", "platform" ],
			"puzzle": [ "puzzle" ],
			"racing": [ "racing", "driving" ],
			"rpg": [ "rpg", "role playing", "role playing game" ],
			"shooter": [ "shooter", "shmup" ],
			"sports": [ "sports", "boxing", "golf", "baseball", "football", "soccer" ],
			"strategy": [ "strategy"],
			"mahjong": [ "mahjong" ],

		}

		local matches = [];
		foreach( key, val in supported )
		{
			foreach( nickname in val )
			{
				if ( cat.find(nickname, 0) ) matches.push(key);
			}
		}
		if ( matches.len() > 0 )
			result = matches[0];

		return result;
	}


		// Dynamically change th networktype
	function network(offset)
	{   local m = fe.game_info(Info.Status, offset) + 1;

			if  (  m.tointeger()  > 3850000)

			m = "assets/uielements/networkoff.png";

		 else if (  m.tointeger()  < 10)
		{
			m = "assets/uielements/networkoff.png";
			}
			else
		{
			m = "assets/uielements/network.png";
			}
		return m;

	}



	// Dynamically change the Manufacturer rss text
	function rss(offset)
	{
		local result = "デベロッパー / プロデューサー Unknown / ゲーム情報については、http：//Attractmode.org をご覧ください";
		local cat = " " + fe.game_info(Info.Manufacturer, offset);
		local supported = {
			//filename : [ match1, match2 ]
			"デベロッパー / プロデューサー ARC SYSTEM WORKS / ゲーム情報については、http：/arcsystemworks.com/ をご覧ください": [ "Arc System Works" ],
			"デベロッパー / プロデューサー CAVE Co., ltd. / ゲーム情報については、https://www.cave.co.jp/en/ をご覧ください。": [ "Cave" ],
			"デベロッパー / プロデューサー EXAMU / ゲーム情報については、https://www.examu.co.jp/ をご覧ください。": [ "Examu" ],
			"デベロッパー / プロデューサー TAITO CORP. / ゲーム情報については、http：//Nesica.net/ をご覧ください。": [ "Taito" ],
			"デベロッパー / プロデューサー BOUKEN/YOTSUBANE / ゲーム情報については、http：//www.taito.com をご覧ください。": [ "Yotsubane" ],
			"デベロッパー / プロデューサー ATLUS / ゲーム情報については、http：//atlus.com/ をご覧ください。": [ "Atlus" ],
			"デベロッパー / プロデューサー SKONEC / ゲーム情報については、http：//www.skonec.com をご覧ください。": [ "Skonec" ],
			"デベロッパー / プロデューサー SUCCESS / ゲーム情報については、https://www.success-corp.co.jp/ をご覧ください": [ "shooter", "shmup" ],
			"デベロッパー / プロデューサー CAPCOM / ゲーム情報については、www.capcom.co.jp/ をご覧ください。": [ "Capcom" ],
			"デベロッパー / プロデューサー TREASURE inc. / ゲーム情報については http://www.treasure-inc.co.jp/ をご覧ください。": [ "Treasure"],
			"デベロッパー / プロデューサー SNK/PLAYMORE / ゲーム情報については、https://www.snk-corp.co.jp/us/ をご覧ください。": [ "SNK Playmore" ]
			"デベロッパー / プロデューサー NYU MEDIA/YDT / ゲーム情報については、http://nyu-media.com/ をご覧ください。": [ "Nyu Media" ]
			"デベロッパー / プロデューサー SEIBU KAIHATSU/MOSS / ゲーム情報については、http://www.mossjp.co.jp/ をご覧ください。": [ "Moss" ]
			"デベロッパー / プロデューサー LAB ZERO GAMES/M2 / ゲーム情報については、https://labzerogames.com/ をご覧ください。": [ "Lab Zero Games" ]
			"デベロッパー / プロデューサー FK DIGITAL / ゲーム情報については、http://www.fkdigital.net をご覧ください。": [ "FK Digital" ]
			"デベロッパー / プロデューサー HOBIBOX / ゲーム情報については、http://www.teck.jp/ をご覧ください。": [ "TechArts" ]
			"デベロッパー / プロデューサー G.REV / ゲーム情報については、http://www.grev.co.jp/ をご覧ください。": [ "G.rev" ]
			"デベロッパー / プロデューサー Arika .ltd / ゲーム情報については、http://www.arika.co.jp/ をご覧ください。": [ "Arika" ]
			"デベロッパー / プロデューサー 07th-Expansion / ゲーム情報については、http://07th-expansion.net/ をご覧ください。": [ "07th-Expansion" ]
			"デベロッパー / プロデューサー Baseson / ゲーム情報については、http://baseson.nexton-net.jp/ をご覧ください。": [ "Baseson" ]
			"デベロッパー / プロデューサー Edelweiss / ゲーム情報については、http://edelweiss.skr.jp/ をご覧ください。": [ "Edelweiss" ]
			"デベロッパー / プロデューサー eigoMANGA / ゲーム情報については、http://www.eigomanga.com/ をご覧ください。": [ "eigoMANGA" ]
			"デベロッパー / プロデューサー Flat/ ゲーム情報については、http://exceedseries.com をご覧ください。": [ "Flat" ]
			"デベロッパー / プロデューサー French Bread / ゲーム情報については、http://www13.plala.or.jp/french/ をご覧ください。": [ "French Bread" ]
			"デベロッパー / プロデューサー Frontier Aja/ ゲーム情報については、http：//aja-games.com をご覧ください。": [ "Frontier Aja" ]
			"デベロッパー / プロデューサー nrf / ゲーム情報については、http：//aja-games.com をご覧ください。": [ "nrf" ]
			"デベロッパー / プロデューサー PROJECT ATSUKI / ゲーム情報については、http://www.fightabase.com/compMain.aspx?id=802 をご覧ください。": [ "PROJECT ATSUKI" ]
			"デベロッパー / プロデューサー Type moon / ゲーム情報については、http://www.typemoon.org/ をご覧ください。": [ "Type moon" ]
			"デベロッパー / プロデューサー rocking andiod/ ゲーム情報については、http://www.rockinandroid.com/ をご覧ください。": [ "rocking andiod" ]
			"デベロッパー / プロデューサー Paragon/ ゲーム情報については、Paragon をご覧ください。": [ "Paragon" ]
			"デベロッパー / プロデューサー Team Shanghai Alice / ゲーム情報については、Touhou Project をご覧ください。": [ "Team Shanghai Alice" ]
          "mahjong": [ "mahjong" ],

		}

		local matches = [];
		foreach( key, val in supported )
		{
			foreach( nickname in val )
			{
				if ( cat.find(nickname, 0) ) matches.push(key);
			}
		}
		if ( matches.len() > 0 )
			result = matches[0];

		return result;
	}

	// Dynamically change the manufacturer artwork
	function publisher(offset)
	{
		local m = fe.game_info(Info.Manufacturer, offset);
		if (m.len() >0)
			m = "assets/publisher logos/" + m + ".png";
		return m;
	}

		// Dynamically change the System artwork
	function systemg(offset)
	{
		local m = fe.game_info(Info.AltRomname, offset);
		if (m.len() >0)
			m = "assets/system/" + m + ".png";
		return m;
	}




	// Dynamically change the button artwork
	function buttons(offset)

	{
	if ( my_config["nbuttons"] == "Con" )

	{   local m = fe.game_info(Info.Buttons, offset);

		if (m.len() > 0 )
			m = "assets/buttons/" + m + "button.png";
		else
			m="assets/buttons/1button.png";
		return m;

	}
	else if ( my_config["nbuttons"] == "Buttons" )
	{
	    local m = fe.game_info(Info.Control, offset);
		if (m.len() > 0 )

			m = "assets/buttons/" + m + "button.png";
		else
			m="assets/buttons/1button.png";
		return m;
	}
	}

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

////////////////////////////////////////
//
//Configure Start Game Menu
//
///////////////////////////////////////
	// Overall Surface
	local overlaySurface = fe.add_surface(fe.layout.width,fe.layout.height);
	overlaySurface.visible = false;
	overlaySurface.zorder=101;
	// translucent background
	local overlayBackground = overlaySurface.add_image("assets/uielements/black.png",0,0, fe.layout.width  , fe.layout.height );
	overlayBackground.alpha = 150;

	// create extra surface for the menu
	local overlayMenuSur = overlaySurface.add_surface(577,360);
	overlayMenuSur.set_pos(681.5, 360);

	// fade out the background
	overlayMenuSur.add_image("assets/uielements/menuframe.png",0,0,557,360); // Add the menu frame

	// create the listbox for the menu including text colors and styles
	local overlay_lb = overlayMenuSur.add_listbox(fe.layout.width / 640 + 60,fe.layout.height / 4.36 + 50,fe.layout.width / 4.42396, fe.layout.height / 13.5 - 80); //Add the listbox
	overlay_lb.rows = 1; // the listbox will have 1 slot
	overlay_lb.charsize  = 35;
	overlay_lb.set_rgb( 128, 128, 128 );
	overlay_lb.sel_style = Style.Bold;
	overlay_lb.font = "Squares Bold Free";
	overlay_lb.set_sel_rgb( 255, 255, 255 );
	overlay_lb.set_selbg_rgb( 80, 180 , 230);

	local overlayMenuTitle = overlayMenuSur.add_text("",0,0,322,35); //Add the menu title
	overlayMenuTitle.charsize=30;
	overlayMenuTitle.style = Style.Bold;
	overlayMenuTitle.set_rgb(255,165,0);

	//Add Logo to the menu
	gridc.over_t= overlaySurface.add_artwork( "wheel" ,fe.layout.width / 2.56 + 57, fe.layout.height / 2.5116 , fe.layout.width / 4.5714 - 110, 85);
	gridc.over_t.preserve_aspect_ratio = false;
	gridc.over_t.trigger = Transition.EndNavigation;

	// Do a fade effect for the menu when called
	fe.add_transition_callback( "orbit_transition" );

	//register to capture the select key and show menu if necessary
	fe.add_signal_handler("select_game")
	function select_game(signal)
	{

		if (signal == "select") // select was pushed
		{
			//no menu is currently open and select was pressed. Run the game choice menu to give the user a choice
			if (fe.overlay.is_up == false )
			{
			    local SelectClick = fe.add_sound("assets/sounds/Select.mp3")
			    SelectClick.playing=true

				// tell Attractmode we are using a custom overlay menu
				fe.overlay.set_custom_controls( overlayMenuTitle, overlay_lb );

				// show the menu and ask the user
				local result = fe.overlay.list_dialog( ["YES","NO"], "", 0 );

				// remove the menu
				fe.overlay.clear_custom_controls();

				// start game if chosen
				if (result)
				{
				 local Wheelclick = fe.add_sound("assets/sounds/Click.mp3")
				 Wheelclick.playing=true
					return true;
			}
				else{
				   local startclick = fe.add_sound("assets/sounds/start.mp3")
				   startclick.playing=true
				   return false;

					}
			}
		}

		return false;
	}

	function orbit_transition( ttype, var, ttime )
	{
		switch ( ttype )
		{
		case Transition.ShowOverlay:
			overlaySurface.visible = true;
			if ( ttime < 255 )
			{
				overlaySurface.alpha = ttime;
				return true;
				gridc.update_frame();

			}
			else
			{
					overlaySurface.alpha = 255;
			}
			break;

		case Transition.HideOverlay:
			if ( ttime < 255 )
			{
				overlaySurface.alpha = 255 - ttime;

				  return true;
			}
			else
			{
				local old_alpha;
					old_alpha = overlaySurface.alpha;
					overlaySurface.alpha = 0;
				if ( old_alpha != 0 )
					return true;
			}
			overlaySurface.visible = false;
			break;
		}
		return false;
	}

	// move the frame to the inital position
	gridc.update_frame();
	my_array[gridc.get_sel()].grow();


////////////////////////////////////////////////////
// layout Main Loop
////////////////////////////////////////////////////

	// move the frame located in the grid object
	// based on joystick movement
	fe.add_signal_handler( "cursorMovement" );
	function cursorMovement(sig)
	{
		local more_processing = null;
		local before = null;
		local after = null;
		switch (sig)
		{
			case "down":
			case "up":
			case "left":
			case "right":
			case "select":

				before = gridc.get_sel();
				more_processing = gridc.move_frame(sig);
				after = gridc.get_sel();

			if (before != after)
			{	my_array[before].shrink();
				my_array[after].grow();
			}

				return more_processing;
				break;

		}

		return false;
	}
