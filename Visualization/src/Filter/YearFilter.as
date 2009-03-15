package Filter
{
	import fl.controls.Slider;
	import fl.events.SliderEvent;
	
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import com.dougmccune.controls.*;
	
	public class YearFilter extends Sprite
	{
		
		//private var _fmt:TextFormat = new TextFormat("Helvetica,Arial",18,0,true,false);
	    private var lastVisitDateSlider:Slider;
	    private var yearSlider:com.dougmccune.controls.VSlider;

		public function YearFilter()
		{
            yearSlider = new com.dougmccune.controls.VSlider();
//			yearSlider.trackHighlightSkin ="com.dougmccune.skins.SliderThumbHighlightSkin";
            yearSlider.allowTrackClick=true;
            yearSlider.allowThumbOverlap=true;             
            yearSlider.liveDragging=true; 
            yearSlider.showDataTip=true;  
            yearSlider.thumbCount=2;  
            yearSlider.values=[-2000, 4000];

			yearSlider.x = 100;
			yearSlider.y = 100;
			
            yearSlider.minimum = 0;
            yearSlider.maximum = 18;
            yearSlider.width = 200;
            yearSlider.value = 0;
            yearSlider.addEventListener( SliderEvent.CHANGE, updateYearFilter );
            this.addChild( yearSlider );
 		}
		
		private function setYearRange(years:int):void
		{
 		}		
 			
	       
	private function updateYearFilter( sliderEvent:SliderEvent ):void
        {
        }
	}
}