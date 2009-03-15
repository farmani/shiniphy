package Database
{
	import __AS3__.vec.Vector;
	
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import flash.xml.XMLNode;
	
	public class SuggestionHandler extends Sprite
	{
		
		private var movies:Vector.<Movie>;
		
		// filter stuff
		private var keywords:Array;
		private var genres:Vector.<Genre>;
		private var years:Dictionary;
		
		
		private var filterYearStart:int = 0;
		private var filterYearEnd:int = 3000;
		private var filterPopularityMax:int = 10000000;
		private var filterPopularityMin:int = 0;
		
		
		private var movieVis:MovieVis = null;
		
		public function SuggestionHandler(mv:MovieVis)
		{
		
			movieVis = mv;
			movies = new Vector.<Movie>(100);
			
			// set up filter params
			genres = new Vector.<Genre>(29);
			keywords = new Array();
			years = new Dictionary();
			
			for(var i:int=0;i<29;++i){
				genres[i] = new Genre();
			}

		}
		
		public function newSimilarSet(xnode:XMLNode):void{

			movies.length = 0;

			var val:String;
			var key:int;
			// clear out the dictionarys
			for(val in years){
				delete years[val];
			}
			
			keywords = [];
			
			//for(val in keywords){
			//	delete keywords[val];
			//}
			
			for(var i:int=0;i<genres.length;++i){
				genres[i].count = 1;
				genres[i].filtered = false;
			}
			
			
			var mov:Movie;
			
			xnode = xnode.firstChild;
			while( xnode != null ){
				if( xnode.nodeName == "movie" ){
					
					mov = new Movie(xnode);
					
					if(years[mov.year] == null){
						years[mov.year] = 1;
					}else{
						years[mov.year]++;
					}
					
					for each (key in mov.keywords){
						if(keywords[key] == null)
						{
							keywords[key] = new Keyword(key);
						}
						else
						{
							(keywords[key] as Keyword).count++;
						}
						
					}
					
					for each(key in mov.genres){
						genres[key].count++;
					}

					
					movies.push(mov);

				}
				xnode = xnode.nextSibling;
			}
			
			keywords.sortOn("count",Array.NUMERIC | Array.DESCENDING);
			keywords.length = 20;
			
			movieVis.processData(movies);
			
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