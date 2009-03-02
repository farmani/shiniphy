package {
	import Database.ConnectionHandler;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	[SWF(width="850", height="600", backgroundColor="#ffffff", frameRate="30")]
	
	public class Visualization extends Sprite
	{
		private var conn:ConnectionHandler;
		
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
			
			conn.setUpDatabase("67.202.59.214", "cs345a", "cs345a", "netflix");
			conn.Connect();
			
			//stage.addEventListener(Event.REMOVED,appClosed);
			
			
		}
		
	}
}
