package {
	import Database.ConnectionHandler;
	
	import Search.SearchMenu;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;

	[SWF(width="850", height="600", backgroundColor="#ffffff", frameRate="30")]
	
	public class Visualization extends Sprite
	{
		private var conn:ConnectionHandler;

		private var searchMenu:SearchMenu;
		
		public function Visualization()
		{
			
			// Basic settings for our stage. Since all items will be
			// attached to the sprite that this class extends they all inherit
			// these settings
			this.stage.frameRate = 12;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			// things are drawn from the top left
			this.stage.align = StageAlign.TOP_LEFT;
			
			
			
		
			conn = new ConnectionHandler("127.0.0.1");
			
			// ./act -h 174.129.187.48 -U psi -w pass19wd -d psi
			//conn.setUpDatabase("174.129.187.48", "psi", "pass19wd", "psi");
			conn.Connect();
			
			searchMenu = new SearchMenu(conn);
			
			this.addChild(searchMenu);
			
			
			// -------------------
			
			
			
			//stage.addEventListener(Event.REMOVED,appClosed);
			
			
		}		
	}
}
