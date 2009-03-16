package Search
{
	import Database.ConnectionHandler;
	
	import fl.containers.ScrollPane;
	
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldType;
	import flash.xml.XMLNode;


	public class SearchMenu extends Sprite
	{
		
		public const maxResults:int = 15;
		
		private var searchBox:TextField;
		private var conn:ConnectionHandler;
		private var results:Sprite;
		private var resultArea:ScrollPane;
		
		
			
		public function SearchMenu(conn:ConnectionHandler)
		{
			this.conn = conn;
			
			results = new Sprite();
			resultArea = new ScrollPane();
			
			//  search
			searchBox = new TextField();
			searchBox.height = 29;
			searchBox.width = 330;
			searchBox.x=searchBox.y=1; 
			searchBox.background = false;
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
			circles.graphics.drawRoundRect(searchBox.x-1,searchBox.y-1,searchBox.width+1,searchBox.height+1,10,10);
			circles.graphics.endFill();
			
			resultArea.width = searchBox.width+1;
			resultArea.height = 120;
			resultArea.y = searchBox.height+searchBox.y+1;
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
			
			
			xnode = xnode.firstChild;
				while( xnode != null ){
					if( xnode.nodeName == "movie" ){
						xnode = xnode.firstChild;
						var id:int = parseInt(xnode.firstChild.nodeValue);
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

			if(kevt.keyCode != 8 && keyString.length > 0){
				conn.search(this, searchBox.text + keyString);
			}else if(kevt.keyCode == 8 && searchBox.text.length > 2){
				conn.search(this, searchBox.text.substr(0, searchBox.text.length - 1));
			}
		}	
	}
}