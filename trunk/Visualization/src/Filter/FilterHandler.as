package Filter
{
	import Database.SuggestionHandler;
	
	import flash.display.Sprite;

	public class FilterHandler extends Sprite
	{
		
		private var dataHandler:SuggestionHandler;
		private var yearFilter:YearFilter;
		
		public function FilterHandler()
		{
			this.dataHandler = null;
			
			yearFilter = new YearFilter(this);
			addChild(yearFilter);
		}
		
		public function init(dataHandler:SuggestionHandler):void{
			
			
			this.dataHandler = dataHandler;
		}
		
		public function setTimeRange(min:int, max:int):void{
			
			dataHandler.filterOnYear(min,max);
			
		}
		
		public function reset():void{
			
			yearFilter.reset();
			
			
		}
		
	}
}