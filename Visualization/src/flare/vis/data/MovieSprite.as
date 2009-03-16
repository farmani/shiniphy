package flare.vis.data
{
	import Database.Movie;
	
	import MainInfo.InfoBox;
	
	import __AS3__.vec.Vector;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class MovieSprite extends NodeSprite
	{
		public var angle2: Number;
		public var radial_distance: Number;
		public var die:Boolean = false;
		
		protected var label:TextField;
		protected var posterLoader:Loader = new Loader();
		public var rating: int = 0;
		protected var lastGenreHt:int = 0;
		public static var loadedCount:int = 0;
		public static var infoBox:InfoBox;

		public var IsMainMovie:Boolean = false;
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
		
		public static var posterw:int = 88, posterh:int = 123;
		public static var iconw:int =16, iconh:int = 16;
		public static var starw:int = 16, starh:int = 16;
	
		private static var movieRenderer:MovieRenderer = new MovieRenderer();
		public var movie:Movie = null;	
		public function MovieSprite(mv:Movie=null, movieRenderer: MovieRenderer=null)
		{
			if(mv != null)
			{
				movie = mv;
				//rating = (movie.netFlixRating+1)/2;
				rating = movie.netFlixRating;
				setTitle(movie.movieName);
				var movieId:int = movie.id-1;
				setPoster("../../flix_images/"+movieId.toString()+".jpg");
				//Add the genres
				for(var j:int = 0; j < movie.genres.length; j++)
					addGenre(MovieVis.mapGenre(movie.genres[j]));
			}
			radial_distance = 0;
			angle2 = 0;
			super();
			addEventListener(MouseEvent.CLICK,onRemoveMovie);
		}
		public function hasGenre(id:int):int 
		{
			for(var j:int = 0; j < movie.genres.length; j++)
				if( id == MovieVis.mapGenre(movie.genres[j]))
					return id;
			return -1;
		}
		public function selectGenre(genres:Vector.<sGenreLayout>):sGenreLayout
		{
			//Find the first common genre
			var bGenreMatchFound:sGenreLayout = new sGenreLayout();
			bGenreMatchFound.id = -1;
			for(var i:int = 0; i < genres.length; i++)
			{
				bGenreMatchFound.id  = hasGenre(genres[i].id);
				if(bGenreMatchFound.id != -1) break;
			}
			if(bGenreMatchFound.id == -1)
			{
			trace ("no match found for: "+movie.movieName);return bGenreMatchFound;}
			
			//See if has a common genre on left or right. Give equal probablity
			var right:int, left:int;
			if(Math.random() > 0.5)
			{
				right = i >= genres.length-1? 0: i+1;
				left  = i <= 0? genres.length-1:i-1;
			}
			else
			{
				left  = i >= genres.length-1? 0: i+1;
				right = i <= 0? genres.length-1:i-1;
			}
			var other:int = right;
			var dummy:int = hasGenre(genres[right].id);
			if(dummy == -1){other = hasGenre(genres[left].id);other = left;}
			if(dummy == -1){bGenreMatchFound.angle = genres[i].angle; bGenreMatchFound.range = genres[i].range; return bGenreMatchFound;}
			
			bGenreMatchFound.range = (genres[i].range + genres[other].range)/2;
			bGenreMatchFound.angle = (genres[i].angle + genres[other].angle)/2;
			if(Math.abs(genres[i].angle - genres[other].angle) > 180)
				bGenreMatchFound.angle += bGenreMatchFound.angle > 0? -180:180;
	
			return bGenreMatchFound;
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
		public function redraw(gin:Graphics = null):void
		{
			renderer = movieRenderer; 
			var g:Graphics = gin==null?graphics:gin;
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
			//Draw a gray rectangle for better readability
			g.beginFill(0x7f7f7f,0.72);
			if(label != null)
			g.drawRect(iconw,posterh-label.height,posterw,label.height);
			g.endFill();
			for(var i:int = 0 ; i < MAX_GENRE ; i++)
				if(imageArray[i] == 1)
					drawImage(g,genreImage[i],0,iconh*i); //draw genres
			if(isHover==true)
			{
				if(IsMainMovie==false)drawImage(g,closeImage,posterw,0);
				//drawImage(g,quesImage ,iconw*2,posterh-iconh);
			}
		}
		protected function onRemoveMovie(event:MouseEvent):void
		{
			if(event.localX >=posterw && event.localX < posterw+iconw && event.localY < iconh && IsMainMovie == false)
			{
				props.particle.die = true;
				die = true;
			}
			else //if(event.localX >=iconw*2 && event.localX < 3*iconw && event.localY > posterh-iconh)
			{
				var s:Sprite = new Sprite();
				var _ishover:Boolean = isHover; isHover = false;
				redraw(s.graphics);
				isHover = _ishover;
				infoBox.setBackgroundImage(s);
				infoBox.visible = true;
				infoBox.setMovie(movie);
			}
		}
		public static function drawImage(g:Graphics, b:BitmapData, x:int, y:int, wd:int=-1, ht:int=-1):void
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
			//var b:BitmapData= new BitmapData(l.width, l.height, true);
            //b.draw(l, new Matrix());
            var b:BitmapData = Bitmap(l.content).bitmapData;
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
			//s="Miss Congeniality";
			var leading:Number = 2;
			var tf1:TextFormat = new TextFormat();
			tf1.font = "Arial"; tf1.size = 12;
			tf1.color = 0xffffffff;
			tf1.leading = leading;
			var d:TextField = new TextField();
			d.autoSize = "left";
			d.text = s;
			d.defaultTextFormat = tf1;
			d.setTextFormat(tf1);
			
			if(label == null)
			{
				label= new TextField();
				//label.blendMode = BlendMode.INVERT;
				//label.autoSize = TextFieldAutoSize.CENTER;
				//tf1.bold="true";
				label.wordWrap = true;
				label.multiline=true;
				label.defaultTextFormat = tf1;
				addChild(label); 
			}
			label.width = posterw; 
			var lines:int = (d.textWidth+posterw-1) /posterw;    
			label.height = d.textHeight * (lines) + (lines-1)*leading ;     
			label.x = iconw;     
			label.y = posterh - label.height ;     
			label.text = s;

		}
		private function posterLoaded (e:Event):void{
		if(label)label.y = posterLoader.height - label.height; //setChildIndex(label, numChildren - 1);
		posterImage=createImagefromLoader(posterLoader);
		redraw();
		}
	}
}