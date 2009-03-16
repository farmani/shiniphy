package Filter
{
	import Database.SuggestionHandler;
	
	import fl.controls.Slider;
	import fl.events.SliderEvent;
	
	import flash.display.Sprite;

	public class FilterHandler extends Sprite
	{
		
		private var dataHandler:SuggestionHandler;
		private var genreSlider:Slider;
		private var yearFilter:BarGraphFilter, ratingFilter:BarGraphFilter, genreFilter:BarGraphFilter;
		
		public function FilterHandler()
		{
			this.dataHandler = null;
			
			yearFilter = new BarGraphFilter(this, 250,80);
			genreFilter = new BarGraphFilter(this,250,80);
			ratingFilter = new BarGraphFilter(this,250,80);
			
			
			genreSlider = new Slider();
			genreSlider.x = 1000;
            genreSlider.y = 500;
            //genreSlider.snapInterval = 10;
            genreSlider.width = 250;
            genreSlider.minimum = -1;
            genreSlider.maximum = 5;
            genreSlider.value = 1;
            genreSlider.addEventListener( SliderEvent.CHANGE, genreSliderUpdate );
			genreSlider.visible = false;
			
			yearFilter.x = 1000;
			yearFilter.y = 100;
			
			ratingFilter.x = 1000;
			ratingFilter.y = 250;
			
			genreFilter.x = 1000;
			genreFilter.y = 400;
			
			addChild(yearFilter);
			addChild(ratingFilter);
			addChild(genreFilter);
			addChild(genreSlider);
		}
		
		public function setYears(years:Array):void{
			
			var egon2:Array = new Array("-1960","1960s","1970s","1980s","1990s", "2000s");
			
			yearFilter.setUp(years, egon2, 0.7, 1950, 2000, 1950, true, 2000);
		}
		
		public function setRatings(ratings:Array):void{
			
			var egon2:Array = new Array("1 Star", "2 Star", "3 Star", "4 Star","5 Star");
			
			ratingFilter.setUp(ratings, egon2, .7, 1, 5, 1, false);
			
		}
		
		public function setGenres(genres:Array):void{
			
			
			var egon2:Array = new Array("Drama", "Action", "Romance", "Comedy","Sci-Fi", "Horror", "Thriller", "Misc");
			
			genreFilter.setUp(genres, egon2, .7, 1, 5, 1, false);
			genreFilter.yearSlider.visible = false;
			
			genreSlider.visible = true;
		}
		
		public function init(dataHandler:SuggestionHandler):void{
			
			
			this.dataHandler = dataHandler;
		}
		
		public function setFilterRange(min:int, max:int, filter:BarGraphFilter):void{
			
			if(filter == yearFilter){
				dataHandler.filterOnYear(min,max);
			}else if(filter == ratingFilter){
				dataHandler.filterOnPopularity(min,max);
			}
			
		}
		
		public function genreSliderUpdate( sliderEvent:SliderEvent ):void{
			
			dataHandler.filterOnGenreFuzzy(genreSlider.value);
			
			
			
		}
		
		public function reset():void{
			
			yearFilter.reset();
			genreFilter.reset();
			//genreSlider.value = 1;
			ratingFilter.reset();
			
		}
		
	}
}