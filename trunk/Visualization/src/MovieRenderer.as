package
{
	import fl.controls.Label;
	
	import flare.vis.data.MovieSprite;
	import flare.vis.data.DataSprite;
	import flare.vis.data.render.IRenderer;
	
	import flash.display.Graphics;
	import flash.geom.Matrix;
	public class MovieRenderer implements IRenderer
	{
			
		public function MovieRenderer()
		{
		}
		public function render(d:DataSprite):void
		{
			var g:Graphics = d.graphics;
			var size:Number = 100;
			var w:Number = size;
			var h:Number = size*1.4;
			var label:Label= new Label();
			/* if(MovieSprite.starImage != null)
			{
				g.beginBitmapFill(MovieSprite.starImage, new Matrix())
				g.drawRect(10,50,MovieSprite.starImage.width, MovieSprite.starImage.height);
				g.endFill();
			} */
			g.beginFill(0xff);
			g.endFill();
		}
	}
}