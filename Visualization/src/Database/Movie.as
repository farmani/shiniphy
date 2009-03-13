package Database
{
	import flash.xml.XMLNode;
	
	public class Movie
	{
		
		
		public var id:int = -1;
		public var movieName:String = "";
		public var score:Number = 0;
		
		public var svdC10:int = -1;
		public var svdC50:int = -1;
		public var svdC200:int = -1;
		
		public var genreC10:int = -1;
		public var genreC50:int = -1;
		public var genreC100:int = -1;
		
		public var keywordsC10:int = -1;
		public var keywordsC50:int = -1;
		public var keywordsC500:int = -1;
		
		public var support:int = -1;
		
		public var year:int = -1;
		public var imdbRating:Number = 0;
		public var netFlixRating:Number = 0;
		
		
		
		public function Movie(xnode:XMLNode){
			
			if(xnode.childNodes.length < 3){
				trace("Too few arguments");
			}
			
			id = parseInt(xnode.childNodes[0].firstChild);
			movieName = xnode.childNodes[1].firstChild;
			score = parseFloat(xnode.childNodes[2].firstChild);
			netFlixRating = parseInt(xnode.childNodes[3].firstChild);
			imdbRating = parseInt(xnode.childNodes[4].firstChild);
			support = parseInt(xnode.childNodes[5].firstChild);
			
		}
	}
}






