package flare.vis.controls
{
	import fl.controls.Label;
	
	import flare.vis.data.DataSprite;
	import flare.vis.data.MovieSprite;
	
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * Interactive control for dragging items. A DragControl2 will enable
	 * dragging of all Sprites in a container object by clicking and dragging
	 * them.
	 */
	public class DragControl2 extends Control
	{
		private var _cur:Sprite;
		private var _mx:Number, _my:Number;
		
		/** Indicates if drag should be followed at frame rate only.
		 *  If false, drag events can be processed faster than the frame
		 *  rate, however, this may pre-empt other processing. */
		public var trackAtFrameRate:Boolean = false;
		
		/** The active item currently being dragged. */
		public function get activeItem():Sprite { return _cur; }
		
		/**
		 * Creates a new DragControl2.
		 * @param filter a Boolean-valued filter function determining which
		 *  items should be draggable.
		 */		
		public function DragControl2(filter:*=null) {
			this.filter = filter;
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			super.attach(obj);
			obj.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		/** @inheritDoc */
		public override function detach() : InteractiveObject
		{
			if (_object != null) {
				_object.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
			return super.detach();
		}
		
		protected function onMouseDown(event:MouseEvent) : void {
			var s:Sprite = event.target as Sprite;
			if(s==null)
			{
				if(event.target as fl.controls.Label != null)
					s = ((fl.controls.Label)(event.target)).parent as Sprite;
				else if(event.target as Loader != null)
					s = ((Loader)(event.target)).parent as Sprite;
				else return;
			}
			if (s==null) return; // exit if not a sprite
			if( s is DataSprite && (s as DataSprite).fixed == true )return;
			if( s is MovieSprite && (s as MovieSprite).IsMainMovie == true )return;
			
			if (_filter==null || _filter(s)) {
				_cur = s;
				_mx = _object.mouseX;
				_my = _object.mouseY;
				if (_cur is DataSprite) (_cur as DataSprite).fix();

				_cur.stage.addEventListener(MouseEvent.MOUSE_MOVE, onDrag);
				_cur.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				
				event.stopPropagation();
			}
		}
		
		protected function onDrag(event:Event) : void {
			var x:Number = _object.mouseX;
			var y:Number = _object.mouseY;
			if (x != _mx) {
				_cur.x += (x - _mx);
				_mx = x;
			}
			
			if (y != _my) {
				_cur.y += (y - _my);
				_my = y;
			}
		}
		
		protected function onMouseUp(event:MouseEvent) : void {
			if (_cur != null) {
				_cur.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				_cur.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
				
				if (_cur is DataSprite) (_cur as DataSprite).unfix();
				event.stopPropagation();
			}
			_cur = null;
		}
		
	} // end of class DragControl2
}