package Filter
{
	import fl.controls.Slider;
	import fl.events.SliderEvent;
	
	import flash.display.Sprite;
	
	
	public class YearFilter extends Sprite
	{
		
		//private var _fmt:TextFormat = new TextFormat("Helvetica,Arial",18,0,true,false);
	    private var lastVisitDateSlider:Slider;
	    private var yearSlider:Slider;
	    private var yearSlider2:Slider;
	    private var myParent:FilterHandler;

		public function YearFilter(myParent:FilterHandler)
		{
            this.myParent = myParent;

			yearSlider = new Slider();
            yearSlider.x = 60;
            yearSlider.y = 101;
            yearSlider.snapInterval = 10;
            yearSlider.width = 200;
            yearSlider.value = 1880;
            yearSlider.minimum = 1880;
            yearSlider.maximum = 2005;
            yearSlider.addEventListener( SliderEvent.CHANGE, updateYearFilter );
            
            
            yearSlider2 = new Slider();
            yearSlider2.x = 60;
            yearSlider2.y = 101;
            yearSlider2.snapInterval = 10;
            yearSlider2.width = 200;
            yearSlider2.minimum = 1880;
            yearSlider2.maximum = 2005;
            yearSlider2.value = 2005;
            yearSlider2.addEventListener( SliderEvent.CHANGE, updateYearFilter );

			//yearSlider.addChild(yearSlider2.getChildAt(0));
			//yearSlider.setChildIndex(yearSlider.getChildAt(2), yearSlider.numChildren-1);
			//yearSlider.getChildAt(0).visible = false;
			yearSlider2.getChildAt(0).visible = false;

			// TODO add dragger between them
			this.addChild( yearSlider );
            this.addChild( yearSlider2 );
            
 		}
		
		public function reset():void{
			
			yearSlider.value = 1880;
			yearSlider2.value = 2005;
			
			
		}		
 			
	       
		private function updateYearFilter( sliderEvent:SliderEvent ):void
        {
        	
        	var min:int = Math.min(yearSlider2.value,yearSlider.value);
        	var max:int = Math.max(yearSlider2.value,yearSlider.value);
        	
        	myParent.setTimeRange(min, max);
        	
        }
	}
}