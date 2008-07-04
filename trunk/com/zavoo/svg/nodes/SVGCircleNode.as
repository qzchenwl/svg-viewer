package com.zavoo.svg.nodes
{
	public class SVGCircleNode extends SVGNode
	{
				
		public function SVGCircleNode(xml:XML):void {
			super(xml);
		}	
		
		protected override function generateGraphicsCommands():void {
			
			var cx:Number = this.getAttribute('cx',0);
			var cy:Number = this.getAttribute('cy',0);
			var r:Number = this.getAttribute('r',0);
			
			this._graphicsCommands.push(['CIRCLE', cx, cy, r]);
		}
		
	}
}