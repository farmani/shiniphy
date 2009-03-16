package MainInfo
{
	import Database.Movie;
	
	import fl.controls.TextArea;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class InfoBox extends Sprite
	{
		
		private var backgroundImg:Loader;
		private var info:TextArea;
		private var whyBox:TextField;
		private var bkSprite:Sprite = null;
		private var movie:Movie;
		
		public var font:TextFormat;
		
		public function InfoBox()
		{
			this.x = 600;
			this.y = 400;
			movie = null;
			
			font = new TextFormat();
			font.align = "left";
			font.size = 12;
			font.font = "Calibri";
			
			//this.visible = false;
			var urlRequest:URLRequest = new URLRequest("../images/mainInfo.png");
			backgroundImg = new Loader( );
			backgroundImg.contentLoaderInfo.addEventListener(Event.COMPLETE, setLoaded );
			backgroundImg.load( urlRequest );
			
			info = new TextArea();
			info.x = 25;
			info.y = 41;
			info.width = 333;
			info.height = 360;
			//info.multiline = true;
			//info.border = true;
			info.wordWrap = true;
			info.textField.border = false;
			info.setStyle("upSkin",Sprite);
			info.setStyle("info", font);
			info.textField.setTextFormat(font);
			info.textField.defaultTextFormat = font;
		
			
			info.htmlText = "a";
			
			addChild(info);
			
			whyBox = new TextField();
			whyBox.x = 406;
			whyBox.y = 232;
			whyBox.width = 125;
			whyBox.height = 160;
			whyBox.multiline = true;
			//info.border = true;
			whyBox.wordWrap = true;
			whyBox.defaultTextFormat = font;
			
			
			addChild(whyBox);
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}
		
		private function setLoaded (e:Event):void{
      	
      		this.addChild(backgroundImg);
      		setChildIndex(backgroundImg, 0);
      		
      	}
      	
      	public function setMovie(mov:Movie):void{
      		movie = mov;
      		
      		if(mov.score < 10000){
      		
      		whyBox.text = "We based this recommendation on the following:\n" + 
					+ Math.round(100*mov.similarRatingScore) + "% user ratings\n" + 
					+ Math.round(100*mov.directorScore) + "% director\n" + 
					+ Math.round(100*mov.genreScore) + "% genres\n" + 
					+ Math.round(100*mov.keywordScore) + "% keywords\n" + 
					+ Math.round(100*mov.yearScore) + "% time period\n";
					
      		}else{
      			whyBox.text = "";
      		}
      		
      		if(mov.id > 1){
      			
      			info.text = mov.movieName + "(" + mov.year + ")\nScore on netflix: " + 
      						mov.netFlixRating + "\nNumber of users who have seen it: " + mov.support + "\n\n";
      			
      			
	      		var url:String = "../../htmlinfos/info(" + (mov.id - 1) +")";
				var loadit:URLLoader = new URLLoader();
				loadit.addEventListener(Event.COMPLETE, completeHandler);
				loadit.load(new URLRequest(url));
      		}else{
      			//info.htmlText = "Error movie not found in html info database";
      		}
			
      		
      	}
      	
      	private function completeHandler(event:Event):void {
			var text:String = event.target.data as String;
			
			info.appendText(text.substring(text.indexOf("<p>") + 3, text.indexOf("</p>")));
		}
      	
      	public function setBackgroundImage(s:Sprite):void
      	{
      		if(bkSprite != null)
      			removeChild(bkSprite);
      		bkSprite = s;
      		bkSprite.x = 396; bkSprite.y = 41;
      		addChild(bkSprite);
      	}
      	private function mouseDown(e:MouseEvent):void{
      		
      		if(e.localY > 2 && e.localY < 18){
      			if(e.localX > 555 && e.localX < 571){
      				stopDrag();
      				visible = false;
      			}else{
      				this.startDrag();
      			}
      		}
      	}
      	
      	private function mouseUp(e:MouseEvent):void{
      		
      		this.stopDrag();

      		
      	}
		
	}
}










