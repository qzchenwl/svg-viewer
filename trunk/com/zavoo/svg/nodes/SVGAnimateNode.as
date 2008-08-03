package com.zavoo.svg.nodes
{
	
	import com.zavoo.svg.data.SVGColors;
	import com.zavoo.svg.utils.NodeTween;
	
	import flash.events.Event;
	
	public class SVGAnimateNode extends SVGNode
	{
		public function SVGAnimateNode(xml:XML):void {
			super(xml);		
		}	
		
		override protected function redrawNode(event:Event):void {
			if (this.parent != null) {
				NodeTween.removeTweens(SVGNode(this.parent));
			}
						
			var attributeName:String = this.getAttribute('attributeName');
				
			var startVal:String = this.getAttribute('from');			
			if (!startVal) {
				startVal = SVGNode(this.parent).getStyle(attributeName)
			}
			var startValInt:int = SVGColors.cleanNumber(startVal);			
			
			var endVal:String = this.getAttribute('to');
			var endValInt:int = SVGColors.cleanNumber(endVal);
			
			var begin:String = this.getAttribute('begin');	
			var beginInt:int = SVGColors.cleanNumber(begin);
					
			var duration:String = this.getAttribute('dur');
			var durationInt:int =  SVGColors.cleanNumber(duration);
			
			var repeat:String = this.getAttribute('repeatCount');
			var repeatInt:int;
			
			if (repeat == 'indefinite') {
				repeatInt = NodeTween.REPEAT_INFINITE;
			}
			else {
				repeatInt = SVGColors.cleanNumber(repeat);
			}
			
			NodeTween.addTween(SVGNode(this.parent), attributeName, beginInt, durationInt, startValInt, endValInt, repeatInt);
			
			
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