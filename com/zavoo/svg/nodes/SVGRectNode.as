package com.zavoo.svg.nodes
{
	import flash.display.DisplayObject;
	
	public class SVGRectNode extends SVGNode
	{				
		public function SVGRectNode(xml:XML):void {
			super(xml);
		}	
		
		/**
		 * Generate graphics commands to draw a rectangle
		 **/
		protected override function generateGraphicsCommands():void {
			
			this._graphicsCommands = new  Array();
			
			var x:Number = this.getAttribute('x',0);
			var y:Number = this.getAttribute('y',0);
			var width:Number = this.getAttribute('width',0);
			var height:Number = this.getAttribute('height',0);			
			
			this._graphicsCommands.push(['RECT', x, y, width, height]);
		}	
		
		override public function set mask(value:DisplayObject):void {
			super.mask = value;
		}
	}
}