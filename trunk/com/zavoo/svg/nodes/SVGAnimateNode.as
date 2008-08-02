package com.zavoo.svg.nodes
{
	import caurina.transitions.Tweener;
	
	import com.zavoo.svg.data.SVGColors;
	
	import flash.events.Event;
	
	public class SVGAnimateNode extends SVGNode
	{
		public function SVGAnimateNode(xml:XML):void {
			super(xml);		
		}	
		
		override protected function redrawNode(event:Event):void {
			if (this.parent != null) {
				Tweener.removeTweens(this.parent);
			}
			
			var tweenParameters:Object = new Object();
			
			var attributeName:String = this.getAttribute('attributeName');
				
			var startVal:String = this.getAttribute('from');			
			if (startVal != null) {
				SVGNode(this.parent).setStyle(attributeName, startVal);
			}
			
			var endVal:String = this.getAttribute('to');
			
			
			var begin:String = this.getAttribute('begin');			
			var duration:String = this.getAttribute('dur');
			
			
			
			
			Tweener.addTween(this.parent, tweenParameters);
		}
		
		private function timeToSeconds(value:String):Number {
			return SVGColors.cleanNumber(value);
		}
		
		
		/* override protected function draw():void {
			var attribute:String = this.getAttribute('attributName');
			var begin:String = this.getAttribute('begin');
			var end:String = this.getAttribute('end');
			var
		} */
		
	}
}