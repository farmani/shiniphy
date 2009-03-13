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
		
		private var trueHeight:int = 30;
		
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
			nameField.y = 30 + trueHeight*pos;
			nameField.background = false;
			nameField.type = TextFieldType.DYNAMIC;
			nameField.border = false;
			nameField.text = name;
			nameField.selectable = false;
			
			this.addChild(nameField);
			
			graphics.beginFill(0xCCCCCC);
			graphics.drawRect(0,30 + trueHeight*pos,150,trueHeight-5);
			graphics.endFill();
			
			this.addEventListener(MouseEvent.CLICK, mouseDown);
			
		}
		
		public function mouseDown(evt:MouseEvent):void{
			
			searchParent.mouseDown(this.id);
			
		}
	}
}