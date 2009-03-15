package Database
{
	import flash.xml.XMLNode;
	
	public class Movie
	{
		
		
		public var id:int = -1;
		public var movieName:String = "";
		
		public var score:Number = 0;
		public var keywordScore:Number = 0;
		public var genreScore:Number = 0;
		public var directorScore:Number = 0;
		public var similarRatingScore:Number = 0;
		public var yearScore:Number = 0;
		
		public var support:int = -1;
		
		public var year:int = -1;
		public var imdbRating:Number = 0;
		public var netFlixRating:Number = 0;
		
		public var genres:Array;
		public var keywords:Array;
		
		public var filtered:Boolean = false;
		
		public function Movie(xnode:XMLNode){
			
			genres = new Array(); //Associative map i.e. genres["comedy"] = 1 or 0;
			keywords = new Array();
			
			if(xnode.childNodes.length < 11){
				trace("Too few arguments");
			}
			
			id = parseInt(xnode.childNodes[0].firstChild);
			movieName = xnode.childNodes[1].firstChild;
			
			score = parseFloat(xnode.childNodes[2].firstChild);
			keywordScore = parseFloat(xnode.childNodes[3].firstChild);
			genreScore = parseFloat(xnode.childNodes[4].firstChild);
			directorScore = parseFloat(xnode.childNodes[5].firstChild);
			similarRatingScore = parseFloat(xnode.childNodes[6].firstChild);
			yearScore = parseFloat(xnode.childNodes[7].firstChild);
			
			year = parseInt(xnode.childNodes[8].firstChild);
			
			netFlixRating = parseInt(xnode.childNodes[9].firstChild);
			imdbRating = parseInt(xnode.childNodes[10].firstChild);
			support = parseInt(xnode.childNodes[11].firstChild);
			
			var tmpstr:String;
			if(xnode.childNodes[12].firstChild != null){
				tmpstr = xnode.childNodes[12].firstChild;
				var tmparr:Array = tmpstr.split(",");
				
				for(var i:int=0;i<tmparr.length;++i){
					genres.push(parseInt(tmparr[i]));
				}
			}
			if(xnode.childNodes[13].firstChild != null){
				
				tmpstr = xnode.childNodes[13].firstChild;
				keywords = tmpstr.split(",");

			}
		}
	}
}






