package flare.vis.data
{
	import __AS3__.vec.Vector;
	
	import fl.controls.Label;
	
	import flash.display.BitmapData;
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
		public static var MAX_GENRE:int = 8;
		public static var genreLoader:Vector.<Loader> = new Vector.<Loader>(MAX_GENRE);
		public static var genreImage:Vector.<BitmapData> = new Vector.<BitmapData>(MAX_GENRE);
		public static var genrePaths:Vector.<String> = new Vector.<String>(MAX_GENRE);

		public static var closeLoader:Loader = new Loader();
		public static var quesLoader:Loader = new Loader();
		public static var starLoader:Loader = new Loader();

		public static var closeImage:BitmapData = null;
		public static var quesImage:BitmapData = null;
		public static var starImage:BitmapData = null;
		public var posterImage: BitmapData  = null;
		public var imageArray:Array = new Array(10);
		public var isHover:Boolean = false;
		public var quesSprite:Sprite = new Sprite();
		public var closeSprite:Sprite = new Sprite();
		
		public var posterw:int = 110, posterh:int = 150;
		public var iconw:int =16, iconh:int = 16;
		public var starw:int = 20, starh:int = 20;
			
		public function MovieSprite()
		{
			radial_distance = 0;
			angle2 = 0;
			super();
			addEventListener(MouseEvent.CLICK,onRemoveMovie);
		}
		protected static function _load_icons1(l:Loader, s:String, file:String):void
		{
			l.name=s; 
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, itemLoaded);
			l.load( new URLRequest(file));
		}
		public static function load_icons():void
		{
			for(var i:int = 0; i < MAX_GENRE ; i++)
				genreLoader[i] = new Loader();
			genrePaths[0]="drama.png"; genrePaths[1]="action.png"; genrePaths[2]="romance.png"; genrePaths[3]="comedy.png"; 
			genrePaths[4]="scifi.png"; genrePaths[5]="horror.png"; genrePaths[6]="thriller.png"; genrePaths[7]="misc.png"; 
			
			for(var i: int = 0; i < MAX_GENRE; i++)
				_load_icons1(genreLoader[i],"Genre",genrePaths[i]);
			_load_icons1(closeLoader, "close", "close.png");
			_load_icons1(quesLoader, "question", "question.png");
			_load_icons1(starLoader, "star", "star.png");
			
		}
		public function redraw():void
		{
			var g:Graphics = graphics;
			if(posterImage != null)posterh = posterImage.height;
			g.clear();
			g.beginFill(0,0);
			g.drawRect(0,0,iconw+posterw+starw,posterh);
			g.endFill();
			if(rating > 0 && starImage != null)
			{
				for(var y:int = 0; y < rating; y++)
					drawImage(g,starImage,iconw+posterw,y*starh);
			}
			drawImage(g,posterImage,iconw,0); //draw poster
			for(var i:int = 0 ; i < 10 ; i++)
				if(imageArray[i] == 1)
					drawImage(g,genreImage[i],0,iconh*i); //draw genres
			g.endFill();
			if(isHover==true)
			{
				drawImage(g,closeImage,iconw  ,posterh-iconh);
				drawImage(g,quesImage ,iconw*2,posterh-iconh);
			}
		}
		protected function onRemoveMovie(event:MouseEvent):void
		{
			if(event.localX >=0 && event.localX < iconw && event.localY > posterh-iconh)
			{
				props.particle.die = true;
				die = true;
			}
			else if(event.localX >=iconw && event.localX < 2*iconw && event.localY > posterh-iconh)
			{
				//INFO BOX
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
			if(loadedCount == 10)
			{
				for(var i:int = 0; i < MAX_GENRE; i++)
					genreImage[i] = createImagefromLoader(genreLoader[i]);
				closeImage =createImagefromLoader(closeLoader);
				quesImage =createImagefromLoader(quesLoader);
				starImage =createImagefromLoader(starLoader);
			}
			loadedCount++;
		}
		
		public function setRating(r:int):void
		{
			rating = r;
		}
		public function addGenre(i:int):void
		{
			imageArray[i] = 1;
		}
		public function removeGenre(i:int):void
		{
			imageArray[i] = 0;
		}
		public function setPoster(s:String):void
		{
			var urlRequest:URLRequest = new URLRequest(s);
			posterLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, posterLoaded );
			posterLoader.load( urlRequest );
			posterLoader.x = iconw;
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