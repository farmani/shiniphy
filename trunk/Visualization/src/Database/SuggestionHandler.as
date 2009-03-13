package Database
{
	import __AS3__.vec.Vector;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.xml.XMLNode;

	public class SuggestionHandler extends Sprite
	{
		
		private var resultBox:TextField;
		private var movies:Vector.<Movie>;
		
		public function SuggestionHandler()
		{
			movies = new Vector.<Movie>(1000);
			
			resultBox = new TextField();
			resultBox.height = 300;
			resultBox.width = 300;
			resultBox.background = true;
			resultBox.type = TextFieldType.DYNAMIC;
			resultBox.border = true;
			resultBox.text = "";
			resultBox.selectable = false;
			
			addChild(resultBox);
		}
		
		public function newSimilarSet(xnode:XMLNode):void{
			resultBox.text = "";
			
			xnode = xnode.firstChild;
			while( xnode != null ){
				if( xnode.nodeName == "movie" ){
					
					movies.push(new Movie(xnode));

				}
				xnode = xnode.nextSibling;
			}
		}		
	}
}