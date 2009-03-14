package Database
{
	import __AS3__.vec.Vector;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.xml.XMLNode;
	
	public class SuggestionHandler extends Sprite
	{
		
		private var movies:Vector.<Movie>;
		
		// filter stuff
		private var keywords:Array;
		private var genres:Array;
		private var filterYearStart:int = 0;
		private var filterYearEnd:int = 3000;
		private var filterPopularityMax:int = 10000000;
		private var filterPopularityMin:int = 0;
		private var movieVis:MovieVis = null;
		
		public function SuggestionHandler(mv:MovieVis)
		{
			var mvs:Vector.<Movie> = new Vector.<Movie>();
		
			movieVis = mv;
			movies = new Vector.<Movie>(100);
			
			// set up filter params
			genres = new Array();
			keywords = new Array();

		}
		
		public function newSimilarSet(xnode:XMLNode):void{

			movies.length = 0;

			keywords = [];
			genres = [];
			
			xnode = xnode.firstChild;
			while( xnode != null ){
				if( xnode.nodeName == "movie" ){
					
					movies.push(new Movie(xnode));

				}
				xnode = xnode.nextSibling;
			}
			
			var egon:Number = 0;
			if(movieVis != null)
			{
				//Just fill dummy genre info
				for(var i:int = 0; i < movies.length; i++)
				{
					movies[i].genres["action"]=Math.random()>0.5?1:0;
					movies[i].genres["romance"]=Math.random()>0.5?1:0;
					movies[i].genres["drama"]=Math.random()>0.5?1:0;
				}
				movieVis.processData(movies);
			}
		}
		
		private function filterOnKeyword(id:String, filter:Boolean):void{
			
			var tmp:Keyword = keywords[id];
			
			
			if(tmp != null){
				
				tmp.filtered = filter;
				updateFiltering();
        		// update viz
			}
			
        	
		}
		
        private function filterOnGenre(id:int, filter:Boolean):void{
        	
        	var tmp:Genre = genres[id];
			
			
			if(tmp != null){
				
				tmp.filtered = filter;
				updateFiltering();
        		// update viz
			}
        	
        	
        }
        private function filterOnYear(start:int, end:int):void{
        	
        	filterYearStart = start;
        	filterYearEnd = end;
        	
        	updateFiltering();
        	// update viz
        	
        }
        
        private function filterOnPopularity(min:int, max:int):void{
        	
        	filterPopularityMin = min;
        	filterPopularityMax = max;
        	
        	updateFiltering();
        	
        	// update viz
        	
        }
		
		private function updateFiltering():void{
			
			for each(var mov:Movie in movies){
				if(mov.year > filterYearEnd || mov.year < filterYearStart){
					
					mov.filtered = true;
					continue;
				}else if(mov.support > filterPopularityMax || mov.support < filterPopularityMin){
					
					mov.filtered = true;
					continue;
				
				}else if(mov.genres.length > 0) {
					
					continue;
				}else if(mov.keywords.length > 0) {
					
					continue;
				}else{
					mov.filtered = false;
				}				
			}
			
		}	
	}
}