package Search
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;

	public class ResultItem extends Sprite
	{
		private var id:int;
		private var dist:int;
		private var pos:int;
		
		private var trueHeight:int = 20;
		
		private var nameField:TextField;
		
		private var searchParent:SearchMenu;
		
		
		public function ResultItem(id:int, name:String, dist:int, pos:int, parent:SearchMenu)
		{
			
			this.dist = dist;
			this.pos = pos;
			this.id = id;
			
			this.searchParent = parent;
			
			nameField = new TextField();
			nameField.x = 0;
			nameField.y = trueHeight*pos;
			nameField.height = 20;
			nameField.width = 250;
			nameField.background = false;
			nameField.type = TextFieldType.DYNAMIC;
			nameField.border = false;
			nameField.text = name;
			nameField.selectable = false;
			
			this.addChild(nameField);
			
			//graphics.beginFill(0xCCCCCC);
			//graphics.drawRect(0,trueHeight*pos,150,trueHeight-5);
			//graphics.endFill();
			
			this.addEventListener(MouseEvent.CLICK, mouseDown);
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseIn);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			
			graphics.beginFill(0xFFFFFF);
			graphics.drawRect(0,trueHeight*pos,250,trueHeight);
			graphics.endFill();
		}
		
		public function mouseDown(evt:MouseEvent):void{
			
			searchParent.performSimilaritySearch(this.id);
			
		}
		
		public function mouseIn(evt:MouseEvent):void{
			
			graphics.beginFill(0x9999AA);
			graphics.drawRect(0,trueHeight*pos,250,trueHeight);
			graphics.endFill();
			
		}
		public function mouseOut(evt:MouseEvent):void{
			
			graphics.beginFill(0xFFFFFF);
			graphics.drawRect(0,trueHeight*pos,250,trueHeight);
			graphics.endFill();
			
		}
	}
}