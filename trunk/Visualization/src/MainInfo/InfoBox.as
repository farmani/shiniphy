package MainInfo
{
	import Database.Movie;
	
	import fl.controls.TextArea;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;

	public class InfoBox extends Sprite
	{
		
		private var backgroundImg:Loader;
		private var info:TextArea;
		private var whyBox:TextField;
		private var bkSprite:Sprite = null;
		private var movie:Movie;
		
		public function InfoBox()
		{
			
			movie = null;
			
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
			
			whyBox.text = "asssss" + 
					"ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss" + 
					"ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss" + 
					"ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss" + 
					"ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss" + 
					"ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss" + 
					"ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss" + 
					"ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss" + 
					"ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss" + 
					"ss";
			
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










