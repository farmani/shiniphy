package 
{
	import __AS3__.vec.Vector;
	
	import flare.HoverControl2;
	import flare.vis.Visualization;
	import flare.vis.data.Data;
	import flare.vis.data.MovieSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.events.SelectionEvent;
	import flare.vis.controls.DragControl2;
	import flare.vis.controls.ExpandControl;
	import flare.vis.operator.encoder.PropertyEncoder;
	import flare.vis.controls.IControl;
	import flare.vis.operator.layout.ForceDirectedLayout2;
	import flare.util.Shapes;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	public class MovieVis extends Sprite
	{
		private var vis:flare.vis.Visualization;
		private var movieRenderer:MovieRenderer = new MovieRenderer(); 
		private var opt:Array;
		private var idx:int = -1;
		public function MovieVis()
		{
		}
		public function init():void
		{
			// create data and set defaults
			//var data:Data = GraphUtil.diamondTree(3,4,4);
			var rad:Number = 400;
			var cx:Number = 400;
			var cy:Number = 400;
			opt = options(rad*2, rad*2);
			idx = 0;
			var data:Data = new Data();
			var r:Vector.<MovieSprite> = new Vector.<MovieSprite>(3);
			var angleArr:Array = new Array(3);angleArr[0]=60; angleArr[1]=180; angleArr[2]=-60;
			var n1:MovieSprite = new MovieSprite(); n1.x = cx; n1.y = cy; data.addNode(n1);
			n1.setRating(5); 
			n1.addGenre("action");
			n1.setPoster("1.jpg");
				
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
			for(i = 0; i < 30; i++)
			{
				var n:MovieSprite = new MovieSprite(); 
				movieArray[i] = n;
				data.addNode(n);n.rating = Math.random()*5;
				n.renderer = movieRenderer; 
				var a:Array = new Array(3);
				var b:Array = new Array(3);
 				for(var j:int = 0; j < 3; j++)
 					if(Math.random() > 0.5)
 						a[j] = 1;
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
			
			data.nodes.setProperties(opt[idx].nodes);
			data.edges.setProperties(opt[idx].edges);
			for (var j:int=0; j<data.nodes.length; ++j) {
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