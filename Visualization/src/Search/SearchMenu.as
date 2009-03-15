package Search
{
	import Database.ConnectionHandler;
	
	import fl.containers.ScrollPane;
	
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
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
			
			resultArea.width = 250;
			resultArea.height = 120;
			resultArea.y = 21;
			resultArea.x = 1;
			//resultArea.horizontalScrollBar.visible = false;
			resultArea.visible = false;
			resultArea.source = results;
			resultArea.horizontalScrollPolicy = "off";
			resultArea.verticalScrollPolicy = "auto";
			
			
			//  search
			searchBox = new TextField();
			searchBox.height = 20;
			searchBox.width = 250;
			searchBox.background = true;
			searchBox.type = TextFieldType.INPUT;
			searchBox.border = true;
			searchBox.addEventListener(KeyboardEvent.KEY_DOWN, updateSearch);
			
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
			
			conn.findSimilar(id);
			resultArea.visible = false;
			
		}
		
		public function mouseDown(evt:MouseEvent):void{
			
			if(searchBox.text.length > 1){
				resultArea.visible = true;
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