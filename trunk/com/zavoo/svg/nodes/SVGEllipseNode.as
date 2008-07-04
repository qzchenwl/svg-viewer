package com.zavoo.svg.nodes
{
	public class SVGEllipseNode extends SVGNode
	{
		
		public function SVGEllipseNode(xml:XML):void {
			super(xml);
		}	
		
		protected override function generateGraphicsCommands():void {
			
			var cx:Number = this.getAttribute('cx',0);
			var cy:Number = this.getAttribute('cy',0);
			var rx:Number = this.getAttribute('rx',0);
			var ry:Number = this.getAttribute('ry',0);
			
			this._graphicsCommands.push(['ELLIPSE', cx, cy, rx, ry]);
		}
		
	}
}