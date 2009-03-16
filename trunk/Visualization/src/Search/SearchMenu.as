package Search
{
	import Database.ConnectionHandler;
	
	import fl.containers.ScrollPane;
	
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.xml.XMLNode;


	public class SearchMenu extends Sprite
	{
		
		public const maxResults:int = 15;
		
		private var searchBox:TextField;
		private var conn:ConnectionHandler;
		private var results:Sprite;
		private var resultArea:ScrollPane;
		
		private var findSimilarOnReturn:Boolean;
			
		public function SearchMenu(conn:ConnectionHandler)
		{
			this.conn = conn;
			
			results = new Sprite();
			resultArea = new ScrollPane();
			findSimilarOnReturn = false;
			//  search
			var bordery:int = 2;
			var borderx:int = 5;
			searchBox = new TextField();
			searchBox.height = 30-bordery;
			searchBox.width = 331-borderx;
			searchBox.x=borderx; searchBox.y=bordery; 
			searchBox.background = true;
			searchBox.type = TextFieldType.INPUT;
			searchBox.border = false;
			searchBox.addEventListener(KeyboardEvent.KEY_DOWN, updateSearch);
			var tf:TextFormat = new TextFormat();
			tf.font = "Calibri"; tf.size = 20;
			searchBox.defaultTextFormat = tf;

			//Draw the textbox
			var circles:Sprite = new Sprite();
			circles.graphics.lineStyle(1,MovieVis.rgb2hex(88,184,214));
			circles.graphics.beginFill(0,0);
			circles.graphics.drawRoundRect(searchBox.x-borderx,searchBox.y-bordery,searchBox.width+borderx*2,searchBox.height+bordery*2,10,10);
			circles.graphics.endFill();
			
			resultArea.width = searchBox.width+borderx;
			resultArea.height = 120;
			resultArea.y = searchBox.height+searchBox.y+bordery;
			resultArea.x = searchBox.x;
			//resultArea.horizontalScrollBar.visible = false;
			resultArea.visible = false;
			resultArea.source = results;
			resultArea.horizontalScrollPolicy = "off";
			resultArea.verticalScrollPolicy = "auto";
			
			
			this.addChild(circles);
			this.addChild(searchBox);
			this.addChild(resultArea);
			
			searchBox.addEventListener(MouseEvent.CLICK, mouseDown);
			
			
			
			
		}
		
		public function newSearch(xnode:XMLNode):void{
			while (results.numChildren > 0){
  				results.removeChildAt(0);
			}
		
			this.resultArea.visible = false;
			
			//results = [];
			
			var firstId = -1;
			
			xnode = xnode.firstChild;
			while( xnode != null ){
				if( xnode.nodeName == "movie" ){
					xnode = xnode.firstChild;
					var id:int = parseInt(xnode.firstChild.nodeValue);
					if(firstId == -1){
						firstId = id;
					}
					xnode = xnode.nextSibling;
					var name:String = xnode.firstChild.nodeValue;
					xnode = xnode.nextSibling;
					var dist:int = parseInt(xnode.firstChild.nodeValue);
					
					addResult(id, name, dist);
					
					
					xnode = xnode.parentNode;

				}
				xnode = xnode.nextSibling;
			}
			
			this.resultArea.update();
			setChildIndex(resultArea,numChildren - 1);
			setChildIndex(searchBox,numChildren - 1);
			
			
			if(findSimilarOnReturn && firstId != -1){
				performSimilaritySearch(firstId);
			}
			
			findSimilarOnReturn = false;
			
		}
		
		public function addResult(id:int, name:String, dist:int):void{
			
			
			
			if(results.numChildren < maxResults){
				var r:ResultItem = new ResultItem(id, name, dist, results.numChildren, this);
				results.addChild(r);
				
			}
			
			
			this.resultArea.visible = true;
			
		}
		
		public function performSimilaritySearch(id:int):void{
			
			resultArea.visible = false;
			conn.findSimilar(id);
			
			
		}
		
		public function mouseDown(evt:MouseEvent):void{
			
			if(searchBox.text.length < 2){
				resultArea.visible = false;
			}else{
				
				if(evt.stageX < searchBox.width + this.x && evt.stageX > this.x && evt.stageY > this.y && evt.stageY < searchBox.height+ this.y){
					resultArea.visible = true;
				}else{
					resultArea.visible = false;
				}
				
				
			}
			
		}
		
		public function updateSearch(kevt:KeyboardEvent):void{
			
			if (conn.waitingForData || searchBox.text.length < 1) {
				return;
			}
			
			
						
			var keyString:String = String.fromCharCode(kevt.keyCode);
			
			if(kevt.keyCode == 13 && searchBox.text.length > 2){
				findSimilarOnReturn = true;
				conn.search(this, searchBox.text);
				return;
				
			}
			findSimilarOnReturn = false;

			if(kevt.keyCode != 8 && keyString.length > 0){
				conn.search(this, searchBox.text + keyString);
			}else if(kevt.keyCode == 8 && searchBox.text.length > 2){
				conn.search(this, searchBox.text.substr(0, searchBox.text.length - 1));
			}
		}	
	}
}