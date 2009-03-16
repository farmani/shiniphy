package Filter
{
	import Database.SuggestionHandler;
	
	import flash.display.Sprite;

	public class FilterHandler extends Sprite
	{
		
		private var dataHandler:SuggestionHandler;
		private var yearFilter:BarGraphFilter;
		
		public function FilterHandler()
		{
			this.dataHandler = null;
			
			yearFilter = new BarGraphFilter(this, 250,80);
			
			
			
			yearFilter.x = 50;
			yearFilter.y = 100;
			
			addChild(yearFilter);
		}
		
		public function setYears(years:Array):void{
			
			var egon2:Array = new Array("-1960","1960s","1970s","1980s","1990s", "2000s");
			
			yearFilter.setUp(years, egon2, 0.7, 200, 300, 200, true, 300);
		}
		
		public function init(dataHandler:SuggestionHandler):void{
			
			
			this.dataHandler = dataHandler;
		}
		
		public function setFilterRange(min:int, max:int, filter:BarGraphFilter):void{
			
			dataHandler.filterOnYear(min,max);
			
		}
		
		public function reset():void{
			
			yearFilter.reset();
			
			
		}
		
	}
}