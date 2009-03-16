package Database
{
	import Filter.FilterHandler;
	
	import __AS3__.vec.Vector;
	
	import flash.utils.Dictionary;
	import flash.xml.XMLNode;
	
	public class SuggestionHandler
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
		private var filters:FilterHandler;
		
		private var movieVis:MovieVis = null;
		
		public function SuggestionHandler(mv:MovieVis, filters:FilterHandler)
		{
			this.filters = filters;
			movieVis = mv;
			movies = new Vector.<Movie>();
			
			// set up filter params
			genres = new Vector.<Genre>(29);
			keywords = new Array();
			years = new Dictionary();
			
			for(var i:int=0;i<29;++i){
				genres[i] = new Genre();
			}

		}
		
		public function newSimilarSet(xnode:XMLNode):void{

			filters.reset();

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
			keywords.length = 10;
			
			i = 0;
			var yearArr:Array = new Array();
			yearArr[0] = 0;
			
			for(var j:int=1820;j<2007;++j){
				
				if(j > 1950 && j % 10 == 0){
					++i;
					yearArr[i] = 0;
				}	
							
				if(years[j] != null){
				
					yearArr[i] += years[j];
				
				
				}
			}
			filters.setYears(yearArr);
			movieVis.processData(movies);
			
		}
		
		public function filterOnKeyword(id:int, filter:Boolean):void{
			
			
			for each (var tmp:Keyword in keywords){
				if(id == tmp.key){
					tmp.filtered = filter;
					updateFiltering();
					return;
				}
			}        	
		}
		
        public function filterOnGenre(id:int, filter:Boolean):void{
        	
        	var tmp:Genre = genres[id];
			
			
			if(tmp != null){
				
				tmp.filtered = filter;
				updateFiltering();
        		
			}
        	
        	
        }
        public function filterOnYear(start:int, end:int):void{
        	
        	filterYearStart = start;
        	filterYearEnd = end;
        	
        	updateFiltering();
        	// update viz
        	
        }
        
        public function filterOnPopularity(min:int, max:int):void{
        	
        	filterPopularityMin = min;
        	filterPopularityMax = max;
        	
        	updateFiltering();
        	
        	// update viz
        	
        }
		
		private function updateFiltering():void{
			
			var key:int;
			var filterKey:Keyword;
			var key2:int;
			for each(var mov:Movie in movies){
				if(mov.year > filterYearEnd || mov.year < filterYearStart){
					
					mov.filtered = true;
					continue;
				}else if(mov.support > filterPopularityMax || mov.support < filterPopularityMin){
					
					mov.filtered = true;
					continue;
				
				}else if(mov.genres.length > 0) {
					
					for each (key in mov.genres){
						if(genres[key].filtered)
							mov.filtered = true;

					}
					
					continue;
				}else if(mov.keywords.length > 0) {
					
					for each (key in mov.keywords){
						for each (filterKey in keywords){
							if(filterKey.filtered && key == filterKey.key){
								mov.filtered = true;
								
							}
						}
					}
					continue;
				}else{
					mov.filtered = false;
				}				
			}
			
			
			
		}	
	}
}







