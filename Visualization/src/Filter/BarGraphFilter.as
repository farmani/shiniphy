package Filter
{
	import fl.controls.Slider;
	import fl.events.SliderEvent;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	
	public class BarGraphFilter extends Sprite
	{
		public static function rgb2hex(r:int, g:int, b:int):Number {
		    return(r<<16 | g<<8 | b);
		}
		
		//private var _fmt:TextFormat = new TextFormat("Helvetica,Arial",18,0,true,false);
	    private var lastVisitDateSlider:Slider;
	    private var yearSlider:Slider;
	    private var yearSlider2:Slider;
	    private var myParent:FilterHandler;
	    
	    public var mainHeight:Number;
	    public var mainWidth:Number;
	    
	    public var inColor:int = rgb2hex(88,184,214);
	    public var outColor:int = rgb2hex(218,226,228);
	    
	    private var yTexts:Array, xTexts:Array, values:Array;
	    
	    public var stepSize:Number;
        public var offSet:Number;
        public var topVal:Number, barWidth:Number;
        public var snapInterval:int, max:int, min:int;
        
        public var font:TextFormat;

		public function BarGraphFilter(myParent:FilterHandler, width:int, height:int)
		{
            this.myParent = myParent;

			yearSlider = new Slider();
            yearSlider.x = 0;
            yearSlider.y = height;
            yearSlider.snapInterval = 10;
            yearSlider.width = width;
            yearSlider.addEventListener( SliderEvent.CHANGE, updateYearFilter );
            
            yearSlider2 = new Slider();
            yearSlider2.x = 0;
            yearSlider2.y = height;
            yearSlider2.snapInterval = 10;
            yearSlider2.width = width;
            yearSlider2.addEventListener( SliderEvent.CHANGE, updateYearFilter );
            
            mainHeight = height;
            mainWidth = width;
            
            xTexts = new Array();
            yTexts = new Array();
            values = null;
            
            font = new TextFormat();
			font.align = "right";
			font.font = "Calibri";

            var tmp:TextField;
            for(var i:int=0;i<5;++i){
            	tmp = new TextField();
            	tmp.selectable = false;
            	
            	tmp.defaultTextFormat = font;
            	yTexts.push(tmp);
            	addChild(tmp);
            	
            }
            
			//yearSlider.addChild(yearSlider2.getChildAt(0));
			//yearSlider.setChildIndex(yearSlider.getChildAt(2), yearSlider.numChildren-1);
			//yearSlider.getChildAt(0).visible = false;
			yearSlider2.getChildAt(0).visible = false;
			yearSlider.getChildAt(0).visible = false;
			
			yearSlider.visible = false;
			yearSlider2.visible = false;

			// TODO add dragger between them
			this.addChild( yearSlider );
            this.addChild( yearSlider2 );
            
 		}
		
		public function reset():void{
			
			yearSlider.value = 1880;
			yearSlider2.value = 2005;
			
			
		}

		public function setUp(values:Array, labels:Array, barWidth:Number, min:int, max:int, slider1Val:int, doubleSlider:Boolean, slider2Val:int = 0):void{
			
			if(values.length != labels.length){
				trace("Array lengths missmatch error");
				return;
			}
			
			this.values = [];
			this.values = values;
			
			for each(var txty:TextField in xTexts){
				this.removeChild(txty);
			}
			
			this.xTexts = [];
			
			this.min = min;
			this.max = max;
			this.barWidth = barWidth;
			
			yearSlider.visible = true;
			
			graphics.clear();
			
			
			
			if(slider1Val > slider2Val){
				var tmp:int = slider1Val;
				slider1Val = slider2Val;
				slider2Val = tmp;
			}
			
			
			yearSlider.minimum = min;
            yearSlider.maximum = max;
			yearSlider.value = slider1Val;
            
            yearSlider2.minimum = min;
            yearSlider2.maximum = max;
            
            if(doubleSlider){
				yearSlider2.visible = true;
				yearSlider2.value = slider2Val; 
				
			}else{
				yearSlider2.value = max; 
			}
                     
            
            topVal = 0;
            
            for each(var val:Number in values){
            	
            	if(val > topVal)
            		topVal = val;
            	
            }
            
            stepSize = mainWidth/values.length;
            offSet = stepSize/2;
            snapInterval = (max-min)/(values.length - 1);
            
            yearSlider.x = yearSlider2.x = offSet + 7;
            yearSlider.width = yearSlider2.width = mainWidth - stepSize;
            yearSlider.snapInterval = yearSlider2.snapInterval = snapInterval;
            
            
            graphics.lineStyle(2, 0, .75);
            graphics.moveTo(0,- .1 * mainHeight);
            graphics.lineTo(0,mainHeight);
            graphics.lineTo(mainWidth + offSet,mainHeight);

            var i:int = 0;
            
             graphics.lineStyle(1, 0, .1);
            
            for(i = 0;i<5;++i){
            	
            	yTexts[i].text = (Math.round((topVal*(5-i)/5)*10)*.1).toPrecision(2);
            	yTexts[i].x = -102;
            	yTexts[i].y = i*mainHeight*.2 - 9;
            	            	
            	graphics.moveTo(1, i*mainHeight*.2);
            	graphics.lineTo(mainWidth + offSet, i*mainHeight*.2);
            	
            }
            
            i = 0;
            graphics.lineStyle(0, 0xCCCCCC, 0);
            
            var xLabel:TextField;
            // Draw bars ! 
            for each(val in values){
            	
            	if(val != 0){
            		if(slider1Val <= min + i*snapInterval && slider2Val >= min + i*snapInterval){
            			graphics.beginFill(inColor);
            		}else{
            			graphics.beginFill(outColor);
            		}
	            	
					graphics.drawRect(i*stepSize+offSet*barWidth, mainHeight - 1, stepSize*barWidth, mainHeight*(-val/topVal));
					graphics.endFill();
            	}
            	xLabel = new TextField();
            	xLabel.text = labels[i];
            	xLabel.defaultTextFormat = font;
            	xLabel.x = i*stepSize + 10;
            	xLabel.y = mainHeight*(1-val/topVal) - 20;
            	xLabel.height = 20;
            	this.addChild(xLabel);
            	xTexts.push(xLabel);
            	
				++i;
            	
            }            
            
			
			
		}
 			
	       
		private function updateYearFilter( sliderEvent:SliderEvent ):void
        {
        	
        	
        	var sliderMin:int = Math.min(yearSlider2.value,yearSlider.value);
        	var sliderMax:int = Math.max(yearSlider2.value,yearSlider.value);
        	
        	if(values){
        		
        		graphics.lineStyle(0, 0xCCCCCC, 0);
        		
        		// Draw bars ! 
        		var i:int = 0;
	            for each(var val:Number in values){
	            	
	            	if(val != 0){
	            		if(sliderMin <= min + i*snapInterval && sliderMax >= min + i*snapInterval){
	            			graphics.beginFill(inColor);
	            		}else{
	            			graphics.beginFill(outColor);
	            		}
		            	
						graphics.drawRect(i*stepSize+offSet*barWidth, mainHeight - 1, stepSize*barWidth, mainHeight*(-val/topVal));
						graphics.endFill();
	            	}
					++i;
	            	
	            } 
        		
        		
        	}
        	
        	myParent.setFilterRange(sliderMin, sliderMax, this);
        	
        }
	}
}