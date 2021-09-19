///////////////////////////////////////////////////
//
// Attract-Mode Frontend - confirm game load plugin slightly modified! by atrfate Oringal by arcadeblisss
//
///////////////////////////////////////////////////
//
// Define use configurable settings
//

const OPT_HELP="The text to show in the menu for this item";
const CMD_HELP="The command to run when this item is selected.  Use @<script_name.nut> to run a squirrel script that is located in the Utility Menu's plugin directory.";

class UserConfig </ help="Calls a Attract Mode Control Menu for Arcade Setups with limited buttons " /> {
	
 </ label="Select", help="Pick the control setting to use in order to navigate right in menus and move the game list", options="custom1,custom2,custom3,custom4,custom5,custom6", order=9 />
	button="";
 </ label="Menu Title", help="The text you want displayed on top of the menu", order=2 />
	menut="Load Game";
}

local config=fe.get_config();
local my_dir = fe.script_dir;
local items = [];

const MAX_OUTPUT_LINES = 40;
local trigger = config["button"]

fe.load_module( "submenu" );

class AnyCommandOutput extends SubMenu
{
	m_t = "";

	constructor()
	{
		base.constructor( "custom2");
		m_t = fe.add_text( "", 0, 0, fe.layout.width, fe.layout.height );
		m_t.charsize=fe.layout.height / MAX_OUTPUT_LINES;
		m_t.align=Align.Left;
		m_t.word_wrap=true;
		m_t.bg_alpha=0;
		m_t.visible = false;
	}

	function on_show() { m_t.visible = true; }
	function on_hide() { m_t.visible = false; }
	function on_scroll_up() { m_t.first_line_hint--; }
	function on_scroll_down() { m_t.first_line_hint++; }

	function show_output( msg )
	{
		m_t.msg = msg;
		m_t.first_line_hint=0;

		show( true );
	}
};
fe.plugin[ "Attract Mode Control Menu" ] <- AnyCommandOutput();


//
// Load the menu with the necessary commands
//


items.append("YES");
items.append( "No" );

//
// Create a tick function that tests if the configured button is pressed and runs
// the corresponding script or command if it is.
//
fe.add_ticks_callback( "control_menu_plugin_tick" );

function control_menu_plugin_tick( ttime )
{
	if ( fe.get_input_state( "custom3" ) )
	{
		local res = fe.overlay.list_dialog( items, "", items.len() / 2 );
		if ( res < 0)
		{
			return;
			}
         else if (res ==0) {
			fe.signal("select");
		} 
	}
}
