package flare.vis.data
{
	import fl.controls.Label;
	
	import flare.vis.data.Data;
	import flare.vis.data.NodeSprite;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.text.TextFieldAutoSize;

	public class MovieSprite extends NodeSprite
	{
		public var angle2: Number;
		public var radial_distance: Number;
		public var die:Boolean = false;
		
		protected var label:Label;
		protected var posterLoader:Loader = new Loader();
		public var rating: int = 0;
		protected var lastGenreHt:int = 0;
		public static var loadedCount:int = 0;
		public static var dramaLoader:Loader = new Loader();
		public static var actionLoader:Loader = new Loader();
		public static var romanceLoader:Loader = new Loader();
		public static var starLoader:Loader = new Loader();
		public static var starImage: BitmapData  = null;
		public static var dramaImage: BitmapData  = null;
		public static var actionImage: BitmapData  = null;
		public static var romanceImage: BitmapData  = null;
		public var posterImage: BitmapData  = null;
		public static var closeLoader:Loader = new Loader();
		public static var closeImage: BitmapData  = null;
		public static var quesLoader:Loader = new Loader();
		public static var quesImage: BitmapData  = null;
		public var imageArray:Array = new Array();
		public var isHover:Boolean = false;
		public var quesSprite:Sprite = new Sprite();
		public var closeSprite:Sprite = new Sprite();
		
		public function MovieSprite()
		{
			radial_distance = 0;
			angle2 = 0;
			super();
			addEventListener(MouseEvent.CLICK,onRemoveMovie);
			//width = 100;
			//height = 140;
		}
		protected static function _load_icons1(l:Loader, s:String, file:String):void
		{
			l.name=s; 
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, itemLoaded);
			l.load( new URLRequest(file));
		}
		public static function load_icons():void
		{
			_load_icons1(actionLoader,"action","bomb.jpg");
			_load_icons1(dramaLoader,"action","drama2.jpg");
			_load_icons1(romanceLoader,"action","hearticon.jpg");
			_load_icons1(starLoader,"action","star.jpg");
			_load_icons1(closeLoader,"close","close.jpg");
			_load_icons1(quesLoader,"question","question.jpg");
		}
		public function redraw():void
		{
			var g:Graphics = graphics;
			g.clear();
			g.beginFill(0,0);
			g.drawRect(0,0,100,120);
			g.endFill();
			if(rating > 0 && starImage != null)
			{
				for(var y:int = 0; y < rating; y++)
					drawImage(g,starImage,120,y*20);
			}
			drawImage(g,posterImage,10,0);
			if(imageArray["action"]==1)drawImage(g,actionImage,0,0);
			if(imageArray["drama"]==1)drawImage(g,dramaImage,0,20);
			if(imageArray["romance"]==1)drawImage(g,romanceImage,0,40);
			g.endFill();
			if(isHover==true)
			{
				drawImage(g,closeImage,0,100);
				drawImage(g,quesImage,20,100);
			}
/* 			if(quesSprite.parent == null)
			{
				drawImage(closeSprite.graphics,closeImage,0,0);
				drawImage(quesSprite.graphics,quesImage,0,0);
				addChild(closeSprite);
				addChild(quesSprite);
				closeSprite.y = quesSprite.y = 100; quesSprite.x = 20;
				closeSprite.visible = quesSprite.visible = false;
				closeSprite.addEventListener(MouseEvent.CLICK, onRemoveMovie);
			}
 */		}
		protected function onRemoveMovie(event:MouseEvent):void
		{
			if(event.localX >=0 && event.localX < 40 && event.localY > 100)
			{
				props.particle.die = true;
				die = true;
			}
		}
		protected function drawImage(g:Graphics, b:BitmapData, x:int, y:int, wd:int=-1, ht:int=-1):void
		{
			if(b != null)
			{
				var m:Matrix = new Matrix();
				m.translate(x,y);
				g.beginBitmapFill(b,m,false);
				if(wd == -1)
				g.drawRect(x,y,b.width,b.height);
				else 
				g.drawRect(x,y,wd,ht);
			}
		}
		protected static function createImagefromLoader(l:Loader):BitmapData
		{
			var b:BitmapData= new BitmapData(l.width, l.height, false);
            b.draw(l, new Matrix());
            return b;
		}
		protected static function itemLoaded(e:Event):void
		{
			if(loadedCount == 5)
			{
				starImage =createImagefromLoader(starLoader);
				actionImage =createImagefromLoader(actionLoader);
				dramaImage =createImagefromLoader(dramaLoader);
				romanceImage =createImagefromLoader(romanceLoader);
				closeImage =createImagefromLoader(closeLoader);
				quesImage =createImagefromLoader(quesLoader);
				
			}
			loadedCount++;
		}
		
		protected function removeAllChildsByName(s:String):void
		{
			var d:DisplayObject;
			while ( (d=getChildByName(s)) != null)
			{
				removeChild(d);
			}	
		}
		protected function _addChild(s:String, loader:Loader, X:int, Y:int):void
		{
			if(loader.width == 0)
				imageArray[s] = 0;
			else
			{
				var mySprite:Sprite = new Sprite();
            	var myBitmap:BitmapData = new BitmapData(loader.width, loader.height, false);
            	myBitmap.draw(loader, new Matrix());
            
            	imageArray[s] = 1;
            	redraw();
   			}
            /*mySprite.name = s;
            mySprite.x = X; mySprite.y = Y;
            mySprite.graphics.beginBitmapFill(myBitmap, new Matrix, true);
            mySprite.graphics.drawRect(0, 0, loader.width, loader.height);
            mySprite.graphics.endFill();
            
            addChild(mySprite);*/

		}
		public function setRating(r:int):void
		{
			rating = r;
			removeAllChildsByName("rating");
			for(var i:int = 0; i < rating; i++)
			{
				_addChild("rating",starLoader,120,i*16);
			}
		}
		public function addGenre(s:String):void
		{
			if(s == "action")_addChild(s,actionLoader,0,0);
			if(s == "drama")_addChild(s,dramaLoader,0,20);
			if(s == "romance")_addChild(s,romanceLoader,0,40);
		}
		public function removeGenre(s:String):void
		{
			removeAllChildsByName(s);
		}
		public function setPoster(s:String):void
		{
			var urlRequest:URLRequest = new URLRequest(s);
			posterLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, posterLoaded );
			posterLoader.load( urlRequest );
			posterLoader.x = 20;
			//addChild(posterLoader);setChildIndex(posterLoader, 0);
		}
		public function setTitle(s:String):void
		{
			if(label == null)
			{
				label= new Label();
				label.autoSize = TextFieldAutoSize.CENTER;
				label.width = 100;     
				label.height = 0;     
				label.x = 0;     
				label.y = posterLoader.height - label.height;     
				addChild(label); 
			}
			label.text = s;
		}
		private function posterLoaded (e:Event):void{
		if(label)label.y = posterLoader.height - label.height; //setChildIndex(label, numChildren - 1);
		posterImage=createImagefromLoader(posterLoader);
		redraw();
		}
	}
}