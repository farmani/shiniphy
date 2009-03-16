package 
{
	import Database.Keyword;
	
	import MainInfo.InfoBox;
	
	import __AS3__.vec.Vector;
	
	import flare.HoverControl2;
	import flare.util.Shapes;
	import flare.vis.Visualization;
	import flare.vis.controls.DragControl2;
	import flare.vis.controls.ExpandControl;
	import flare.vis.controls.IControl;
	import flare.vis.data.Data;
	import flare.vis.data.MovieSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.events.SelectionEvent;
	import flare.vis.operator.encoder.PropertyEncoder;
	import flare.vis.operator.layout.ForceDirectedLayout2;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import Database.Movie;
	public class MovieVis extends Sprite
	{
	//import Database.Movie;
		
		private var vis:flare.vis.Visualization;
		private var movieRenderer:MovieRenderer = new MovieRenderer(); 
		private var opt:Array;
		private var idx:int = -1;
		public static  var rad:Number = 350;
		public static  var cx:Number = 400;
		public static  var cy:Number = 400;
		private var data:Data = new Data();
		private var GenreLabels:Sprite = null;
		public function MovieVis(ibox:InfoBox)
		{
			MovieSprite.infoBox = ibox;
			ibox.visible = false;
		/* 88,184,214
144,194,210
218,226,228 */

			var circles:Sprite = new Sprite();
			MovieVis.drawCircle(circles.graphics,MovieVis.cx,MovieVis.cy, MovieVis.rad*1/3,MovieVis.rgb2hex(88,184,214));
			MovieVis.drawCircle(circles.graphics,MovieVis.cx,MovieVis.cy, MovieVis.rad*2/3,MovieVis.rgb2hex(144,194,210));
			MovieVis.drawCircle(circles.graphics,MovieVis.cx,MovieVis.cy, MovieVis.rad*3/3,MovieVis.rgb2hex(218,226,228));
			this.addChild(circles);
	
		}
		
		//bitwise conversion of rgb color to a hex value
		public static function rgb2hex(r:int, g:int, b:int):Number {
		    return(r<<16 | g<<8 | b);
		}
		//bitwise conversion of a hex color into rgb values
		public static function hex2rgb(hex:int):Object{
		    var red:int = hex>>16;
		    var greenBlue:int = hex-(red<<16)
		    var green:int = greenBlue>>8;
		    var blue:int = greenBlue - (green << 8);
		  //trace("r: " + red + " g: " + green + " b: " + blue);
		    return({r:red, g:green, b:blue});
		}
		
		public static function drawCircle(g:Graphics, x:Number, y:Number, radius:Number, fillColor:Number, fillAlpha:Number=1):void {
	        g.lineStyle(1, fillColor, fillAlpha);
    		g.beginFill(0, 0); 
	        g.moveTo(x + radius, y);
	        g.curveTo(radius + x, Math.tan(Math.PI / 8) * radius + y, Math.sin(Math.PI / 4) * radius + x, Math.sin(Math.PI / 4) * radius + y);
	        g.curveTo(Math.tan(Math.PI / 8) * radius + x, radius + y, x, radius + y);
	        g.curveTo(-Math.tan(Math.PI / 8) * radius + x, radius+ y, -Math.sin(Math.PI / 4) * radius + x, Math.sin(Math.PI / 4) * radius + y);
	        g.curveTo(-radius + x, Math.tan(Math.PI / 8) * radius + y, -radius + x, y);
	        g.curveTo(-radius + x, -Math.tan(Math.PI / 8) * radius + y, -Math.sin(Math.PI / 4) * radius + x, -Math.sin(Math.PI / 4) * radius + y);
	        g.curveTo(-Math.tan(Math.PI / 8) * radius + x, -radius + y, x, -radius + y);
	        g.curveTo(Math.tan(Math.PI / 8) * radius + x, -radius + y, Math.sin(Math.PI / 4) * radius + x, -Math.sin(Math.PI / 4) * radius + y);
	        g.curveTo(radius + x, -Math.tan(Math.PI / 8) * radius + y, radius + x, y);
	        g.endFill();
		}

		public static function mapGenreIdToName(g:int):String
		{
			if(g==0)return "Drama"; if(g==1)return "Action"; if(g==2)return "Romance"; if(g==3)return "Comedy";
			if(g==4)return "Sci-Fi"; if(g==5)return "Horror"; if(g==6)return "Thriller"; if(g==7)return "Misc";
			return " ";
			//return MovieSprite.genrePaths[g];
		}
		public static function mapGenre(g:int):int
		{
			switch(g)
			{
				case 1: case 17: return 2;//Romance;
				case 19: return 5;//Horror;
				case 2: case 3: case 6: case 7: case 9: case 10: case 12: case 15: case 18: return 0;//drama ;
				case 4: case 16: case 8: case 22: return 1;//action;
				case 5: return 3;//Comedy
				case 13: case 14: return 4;//Sci-Fi; 
				case 11: case 20: case 21: return 6;//thriller
				case 23: case 24: case 25: case 26: case 27: case 28: return 7;//Misc
			}
			return 0;
		}
		public static function clampangle(a:Number):Number
		{
			if(a > 180)return a-360;
			if(a < -180)return a+360;
			return a;
		}
	
		private function createGenreTextField(id:int, angle:Number):TextField
		{
			var t:TextField = new TextField();
			t.x = cx+1.1*rad*Math.cos(Math.PI/180*angle)-25;
			t.y = cy+1.1*rad*Math.sin(Math.PI/180*angle);
			t.text = mapGenreIdToName(id);
			t.selectable = false;
			t.mouseEnabled = false;
			t.autoSize = "center";
			t.background = false;
			var tf1:TextFormat = new TextFormat();
			tf1.font = "Calibri"; tf1.size = 24;
			tf1.align="center";
			tf1.bold = true
			t.setTextFormat(tf1);
			t.defaultTextFormat = tf1;
			return t;
		}
		public function processData(mvs:Vector.<Movie>):void
		{
			if(GenreLabels != null)
				removeChild(GenreLabels);
			GenreLabels = new Sprite();
			data.nodes.clear();
			
			var i:int, j:int;
			var offx:int = (MovieSprite.iconw+MovieSprite.posterw+MovieSprite.starw)/2;
			var offy:int = (MovieSprite.posterh)/2;

/* 			var minsup:Number = 1e7;
			var maxsup:Number = -1;
			for(i = 1; i < mvs.length; i++)
			{
				if(minsup > mvs[i].netFlixRating)minsup = mvs[i].netFlixRating;
				if(maxsup < mvs[i].netFlixRating)maxsup = mvs[i].netFlixRating;
			}
 */
			//Support range
			var minsup:Number = 1e7;
			var maxsup:Number = -1;
			for(i = 1; i < mvs.length; i++)
			{
				if(minsup > mvs[i].score)minsup = mvs[i].score;
				if(maxsup < mvs[i].score)maxsup = mvs[i].score;
			}

			var genreArray:Array = new Array();
			//Compute the genre score
			for(i = 0; i < mvs.length; i++)
			{
				for(j = 0; j < mvs[i].genres.length; j++)
				{
					var map:int = mapGenre(mvs[i].genres[j]);
						if(genreArray[map] == null)
							genreArray[map] = new Keyword(map);
						else
							(genreArray[map] as Keyword).count++;
				}
			}
			//Sort the array
			genreArray.sortOn("count",Array.NUMERIC | Array.DESCENDING);

			//The main movie
			var n1:MovieSprite = new MovieSprite(mvs[0],movieRenderer); n1.x = cx-offx; n1.y = cy-offy; data.addNode(n1); n1.addGenre(0);
				
			//Compute the number of Genre
			var tot_count:int = 0; 
			for(i = 0; i < 4; i++)
				if((genreArray[0] as Keyword).count > 2.5*(genreArray[i] as Keyword).count)//Should be less than this
					break;
				else{
					tot_count += (genreArray[i] as Keyword).count ;
				} 
			var numGenre:int = i;
			var genrelayout:Vector.<sGenreLayout> = new Vector.<sGenreLayout>(numGenre);
			for(i = 0; i < numGenre; i++)genrelayout[i] = new sGenreLayout();
			var startpos:int = numGenre/2-0.5;
			genrelayout[startpos].angle = -120; 
			genrelayout[startpos].range = 360*(1.0*(genreArray[0] as Keyword).count/tot_count )/2; 
			genrelayout[startpos].id = (genreArray[0] as Keyword).key;
			GenreLabels.addChild(createGenreTextField(genrelayout[startpos].id, genrelayout[startpos].angle));  
			
			var left:int = startpos - 1;
			var right:int = startpos + 1;
			i = 1;
			while ( i < numGenre )
			{
				genrelayout[right].id = (genreArray[i] as Keyword).key;
				genrelayout[right].range = 360*(1.0*(genreArray[i] as Keyword).count/tot_count )/2;
				genrelayout[right].angle = clampangle(genrelayout[right-1].angle + genrelayout[right-1].range + genrelayout[right].range);
				GenreLabels.addChild(createGenreTextField(genrelayout[right].id, genrelayout[right].angle));  
				right++;
				i++;
				if(i == numGenre ) break;
				
				genrelayout[left].id = (genreArray[i] as Keyword).key;
				genrelayout[left].range = 360*(1.0*(genreArray[i] as Keyword).count/tot_count )/2;
				genrelayout[left].angle = clampangle(genrelayout[left+1].angle -(genrelayout[left+1].range + genrelayout[left].range));
				GenreLabels.addChild(createGenreTextField(genrelayout[left].id, genrelayout[left].angle));  
 				left--;
				i++;
			}
						
			//Layout the genre's 
/* 			var r:Vector.<MovieSprite> = new Vector.<MovieSprite>(3);
			var angleArr:Array = new Array(numGenre);angleArr[0]=60; angleArr[1]=180; angleArr[2]=-60;
			for(var i:int; i < 3; i++)
			{
				r[i]=new MovieSprite(); r[i].fix(); data.addNode(r[i]);
				r[i].angle2 = angleArr[i];r[i].size = 5; r[i].radial_distance = rad; 
				r[i].x = cx+rad*Math.cos(r[i].angle2/180*Math.PI);
				r[i].y = cy+rad*Math.sin(r[i].angle2/180*Math.PI);
				r[i].data["title"]="Comedy";
				r[i].alpha = 0;
			}
 */			
			var r:Vector.<MovieSprite> = new Vector.<MovieSprite>(numGenre);
			for(var i:int; i < numGenre; i++)
			{
				r[i]=new MovieSprite(); r[i].fix(); data.addNode(r[i]);
				r[i].angle2 = genrelayout[i].angle;r[i].size = 5; r[i].radial_distance = rad; 
				r[i].x = cx+rad*Math.cos(r[i].angle2/180*Math.PI);
				r[i].y = cy+rad*Math.sin(r[i].angle2/180*Math.PI);
				r[i].data["title"]="Comedy";
				r[i].alpha = 0;
			}

			var movieArray:Array = new Array(20);
			
			for(i = 1; i < 80 && i < mvs.length; i++)
			{
				if(mvs[i].filtered)
					continue;
				
				var n:MovieSprite = new MovieSprite(mvs[i], movieRenderer); 
				var layout:sGenreLayout  = n.selectGenre(genrelayout); 
				if(layout.id == -1)//this movie had no common genre what a retard 
					layout = genrelayout[(int)(0.5+Math.random()*(numGenre-1))];//place them randomly
				movieArray[i] = n;
				data.addNode(n);
				/* var a:Array = new Array(3);
				var b:Array = new Array(3);
				
 				for(j = 0; j < 3; j++){
 					if(Math.random() > 0.5)
 						a[j] = 1;
 				}
				j = Math.random()*3;
				var cnt:int = 0;
 				if(a[j] == 1)
 					{data.addEdgeFor(r[j],n);b[j]=1;cnt=1;}
 				if(a[(j+2)%3] == 1)
 					{data.addEdgeFor(r[(j+2)%3],n);b[(j+2)%3]=1;cnt++;}
 				else if(a[(j+1)%3] == 1) 		
 					{data.addEdgeFor(r[(j+1)%3],n);b[(j+1)%3]=1;cnt++;}
				if(cnt == 0){j=Math.random()*3;data.addEdgeFor(r[j],n);b[j]=1;cnt=1;}
				if(b[0] == 1)n.addGenre(0);
				if(b[1] == 1)n.addGenre(1);
				if(b[2] == 1)n.addGenre(2);
				if(cnt == 0)n.angle2 = 0;
				else if(cnt == 1){for(j = 0; j < 3; j++)if(b[j] == 1)n.angle2=angleArr[j];}
				else {for(j = 0; j < 3; j++)if(b[j] == 1){
				var j2:int; if(b[(j+2)%3]==1)j2 = (j+2)%3; else j2 =(j+1)%3;
				n.angle2=(angleArr[j]+angleArr[j2])/2;
				if(n.angle2 == 0)if(Math.abs(angleArr[j]) > 90)n.angle2 = 180;
				}}
				n.radial_distance = Math.random()*150+rad-150; 
				 */
				if(1)// && i > 0)
				{
					n.radial_distance = (minsup-mvs[i].score)/(maxsup-minsup)*200+rad; 
					var bAdded:Boolean = false;
					var range:Number = layout.range;
					n.angle2 = layout.angle;
					var step:Number = 2;
					for(j = 0; j < range; j+=step)
					{
						var bintersects:Boolean = false;
						for(var sign:int = -1; sign<=1 && bAdded == false; sign+=2)
						{
							var t:Number = n.angle2+j*sign;
							n.x=cx-offx+n.radial_distance*Math.cos(t*Math.PI/180);
							n.y=cy-offy+n.radial_distance*Math.sin(t*Math.PI/180);
							for(var k:int = 0; k < i;k++)
							{
								if(movieArray[k] != null && rectIntersect(n, movieArray[k],offx,offy)==true)
								{
									bintersects = true;
									break;
								}
							}
							if(bintersects == false)
							{
								bAdded = true; 
								n.angle2 = t;
								break;
							}
						}
					}
					if(bAdded == false)
					{
						movieArray[i] = null;
						data.remove(n);
						continue;
					}
				}
							  
				//if(i == 0){n.radial_distance = 362; n.angle2 = -60;}
				//n.angle2 = (i-10)*18; n.radial_distance = rad; 
					
				n.x=cx-offy+n.radial_distance*Math.cos(n.angle2*Math.PI/180);
				n.y=cy-offy+n.radial_distance*Math.sin(n.angle2*Math.PI/180);
				addChild(GenreLabels);
				//n.setTitle(((int)(n.radial_distance)).toString()+","+((int)(n.angle2)).toString());
			}
		}
		public function init():void
		{
			// create data and set defaults
			//var data:Data = GraphUtil.diamondTree(3,4,4);
			opt = options(rad*2, rad*2);
			idx = 0;
			data = new Data();

/* 			var n1:MovieSprite = new MovieSprite(); n1.x = cx; n1.y = cy; data.addNode(n1);
			n1.setRating(5); 
			n1.addGenre("action");
			n1.setPoster("1.jpg");
				
			var r:Vector.<MovieSprite> = new Vector.<MovieSprite>(3);
			var angleArr:Array = new Array(3);angleArr[0]=60; angleArr[1]=180; angleArr[2]=-60;
			for(var i:int; i < 3; i++)
			{
				r[i]=new MovieSprite(); r[i].fix(); data.addNode(r[i]);
				r[i].angle2 = angleArr[i];r[i].size = 5; r[i].radial_distance = rad; 
				r[i].x = cx+rad*Math.cos(r[i].angle2/180*Math.PI);
				r[i].y = cy+rad*Math.sin(r[i].angle2/180*Math.PI);
				r[i].data["title"]="Comedy";
				r[i].alpha = 0;
			}
			var movieArray:Array = new Array(20);
			var j:int;
			
			for(i = 0; i < 30; i++)
			{
				var n:MovieSprite = new MovieSprite(); 
				movieArray[i] = n;
				data.addNode(n);n.rating = Math.random()*5;
				n.renderer = movieRenderer; 
				var a:Array = new Array(3);
				var b:Array = new Array(3);
				
 				for(j = 0; j < 3; j++){
 					if(Math.random() > 0.5)
 						a[j] = 1;
 				}
				j = Math.random()*3;
				var cnt:int = 0;
 				if(a[j] == 1)
 					{data.addEdgeFor(r[j],n);b[j]=1;cnt=1;}
 				if(a[(j+2)%3] == 1)
 					{data.addEdgeFor(r[(j+2)%3],n);b[(j+2)%3]=1;cnt++;}
 				else if(a[(j+1)%3] == 1) 		
 					{data.addEdgeFor(r[(j+1)%3],n);b[(j+1)%3]=1;cnt++;}
				if(cnt == 0){j=Math.random()*3;data.addEdgeFor(r[j],n);b[j]=1;cnt=1;}
				if(b[0] == 1)n.addGenre("romance");
				if(b[1] == 1)n.addGenre("drama");
				if(b[2] == 1)n.addGenre("action");
				if(cnt == 0)n.angle2 = 0;
				else if(cnt == 1){for(j = 0; j < 3; j++)if(b[j] == 1)n.angle2=angleArr[j];}
				else {for(j = 0; j < 3; j++)if(b[j] == 1){
				var j2:int; if(b[(j+2)%3]==1)j2 = (j+2)%3; else j2 =(j+1)%3;
				n.angle2=(angleArr[j]+angleArr[j2])/2;
				if(n.angle2 == 0)if(Math.abs(angleArr[j]) > 90)n.angle2 = 180;
				}}
				n.radial_distance = Math.random()*150+rad-150; 
				
				if(1)// && i > 0)
				{
					n.radial_distance = (Math.random()-1)*200+rad; 
					var bAdded:Boolean = false;
					var angle:Number = 60;
					var step:Number = 2;
					for(j = 0; j < angle; j+=step)
					{
						var bintersects:Boolean = false;
						for(var sign:int = -1; sign<=1 && bAdded == false; sign+=2)
						{
							var t:Number = n.angle2+j*sign;
							n.x=cx+n.radial_distance*Math.cos(t*Math.PI/180);
							n.y=cy+n.radial_distance*Math.sin(t*Math.PI/180);
							for(var k:int = 0; k < i;k++)
							{
								if(movieArray[k] != null && rectIntersect(n, movieArray[k],60,70)==true)
								{
									bintersects = true;
									break;
								}
							}
							if(bintersects == false)
							{
								bAdded = true; 
								n.angle2 = t;
								break;
							}
						}
					}
					if(bAdded == false)
					{
						movieArray[i] = null;
						data.remove(n);
					}
				}
							  
				//if(i == 0){n.radial_distance = 362; n.angle2 = -60;}
				//n.angle2 = (i-10)*18; n.radial_distance = rad; 
					
				n.x=cx+n.radial_distance*Math.cos(n.angle2*Math.PI/180);
				n.y=cy+n.radial_distance*Math.sin(n.angle2*Math.PI/180);
				n.setTitle(((int)(n.radial_distance)).toString()+","+((int)(n.angle2)).toString());
				n.setPoster("1.jpg");
			}
 */			
			data.nodes.setProperties(opt[idx].nodes);
			data.edges.setProperties(opt[idx].edges);
			for (var j:int =0; j<data.nodes.length; ++j) {
				data.nodes[j].data.label = String(j);
				data.nodes[j].buttonMode = true;
			}
			// sort to ensure that children nodes are drawn over parents
			data.nodes.sortBy("depth");
			//data.remove(n3);
			// create the visualization
			vis = new Visualization(data);
			vis.bounds = new Rectangle(x,y,rad*2,rad*2);
			vis.operators.add(opt[idx].op);
			
			//Add labels to the viz
			/* var labeler:Labeler = new Labeler(labelFunction);
			labeler.cacheText =false ;
			vis.operators.add(labeler); */
			
			vis.setOperator("nodes", new PropertyEncoder(opt[idx].nodes, "nodes"));
			vis.setOperator("edges", new PropertyEncoder(opt[idx].edges, "edges"));
			vis.controls.add(new HoverControl2(NodeSprite,
				// by default, move highlighted items to front
				HoverControl2.MOVE_AND_RETURN,
				// highlight node border on mouse over
				function(e:SelectionEvent):void {
					e.node.lineWidth = 2;
					e.node.lineColor = 0x88ff0000;
				},
				// remove highlight on mouse out
				function(e:SelectionEvent):void {
					e.node.lineWidth = 0;
					e.node.lineColor = opt[idx].nodes.lineColor;
				}));
			vis.controls.add(opt[idx].ctrl);
			vis.update();
			addChild(vis);
 
		}
	   private function rectIntersect(pi:MovieSprite, pj:MovieSprite,dimx:int=60, dimy:int=70):Boolean
	   {
			if(pi.y+dimy < pj.y-dimy)	return false;
			if(pi.y-dimy > pj.y+dimy)	return false;
			if(pi.x+dimx < pj.x-dimx)	return false;
			if(pi.x-dimx > pj.x+dimx)	return false;
			return true;
		}
		/**
		 * This method builds a collection of layout operators and node
		 * and edge settings to be applied in the demo.
		 */
		private function options(w:Number, h:Number):Array
		{//"simulation.dragForce.drag": 0.2,
						
			var a:Array = [
				{
					name: "Force",
					op: new ForceDirectedLayout2(true),
					param: {
						"simulation.nbodyForce.gravitation":-10000,
						defaultParticleMass: 1,
						defaultSpringLength: 0.23,
						defaultSpringTension: 1.1
					},
					update: true,
					ctrl: new DragControl2(MovieSprite)
				}
			];
			
			// default values
			var nodes:Object = {
				shape: Shapes.SQUARE,
				fillColor: 0x88aaaaaa,
				lineColor: 0xdddddddd,
				lineWidth: 1,
				size: 12,
				alpha: 1,
				visible: true
			}
			var edges:Object = {
				lineColor: 0xffcccccc,
				lineWidth: 1,
				alpha: 1,
				visible: true
			}
			var ctrl:IControl = new ExpandControl(MovieSprite,
				function():void { vis.update(1, "nodes","main").play(); });
			
			// apply defaults where needed
			var name:String;
			for each (var o:Object in a) {
				if (!o.nodes)
					o.nodes = nodes;
				else for (name in nodes)
					if (o.nodes[name]==undefined)
						o.nodes[name] = nodes[name];
					
				if (!o.edges)
					o.edges = edges;
				else for (name in edges)
					if (o.edges[name]==undefined)
						o.edges[name] = edges[name];
				
				if (!("ctrl" in o)) o.ctrl = ctrl;
				if (o.param) o.op.parameters = o.param;
			}
			return a;
		}
		
		public function play():void
		{
			if (opt[idx].update) vis.continuousUpdates = true;
		}
		
		public function stop():void
		{
			vis.continuousUpdates = false;
		}
	}
}