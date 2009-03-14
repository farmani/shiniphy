package {
	import Database.ConnectionHandler;
	import Database.SuggestionHandler;
	
	import Search.SearchMenu;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.system.Security;

	[SWF(width="850", height="600", backgroundColor="#ffffff", frameRate="30")]
	
	public class Visualization extends Sprite
	{
		private var conn:ConnectionHandler;
		private var mainViz:SuggestionHandler;
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
			
			
			var host:String = "127.0.0.1";
			var chatPort:int = 1024;
			var policyPort:int = chatPort + 1;
			
			Security.loadPolicyFile("xmlsocket://" + host + ":" + policyPort);
			
			mainViz = new SuggestionHandler();
		
			conn = new ConnectionHandler(host, chatPort, mainViz);
			
			// ./act -h 174.129.187.48 -U psi -w pass19wd -d psi
			//conn.setUpDatabase("174.129.187.48", "psi", "pass19wd", "psi");
			conn.Connect();
			
			searchMenu = new SearchMenu(conn);
			
			mainViz.x = 100;
			mainViz.y = 50;
			
			searchMenu.x = 125;
			searchMenu.y = 20;
			
			
			// make sure to add in right order so that search dropdown is on top
			this.addChild(mainViz);
			this.addChild(searchMenu);
			
			// -------------------
			
			
			
			//stage.addEventListener(Event.REMOVED,appClosed);
			
			
		}		
	}
}
