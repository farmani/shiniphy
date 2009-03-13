package Search
{
	import Database.ConnectionHandler;
	
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.xml.XMLNode;

	public class SearchMenu extends Sprite
	{
		
		public const maxResults:int = 8;
		
		private var searchBox:TextField;
		private var conn:ConnectionHandler;
		private var results:Array;
			
		public function SearchMenu(conn:ConnectionHandler)
		{
			this.conn = conn;
			
			results = new Array();
			
			this.x = 100;
			this.y = 20;
			
			//  search
			searchBox = new TextField();
			searchBox.height = 20;
			searchBox.width = 150;
			searchBox.background = true;
			searchBox.type = TextFieldType.INPUT;
			searchBox.border = true;
			searchBox.addEventListener(KeyboardEvent.KEY_DOWN, updateSearch);
			
			this.addChild(searchBox);
			
		}
		
		public function newSearch(xnode:XMLNode):void{
			for each(var res:ResultItem in results){
					
				this.removeChild(res);
			}	
			
			results = [];
			
			
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
			
		}
		
		public function addResult(id:int, name:String, dist:int):void{
			
			
			if(results.length < maxResults){
				var r:ResultItem = new ResultItem(id, name, dist, results.length + 1, this);
				results.push(r);
	
				this.addChild(r);
			}
			
		}
		
		public function mouseDown(id:int):void{
			
			conn.findSimilar(id);
			
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