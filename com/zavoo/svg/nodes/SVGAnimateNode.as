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
		
		override protected function draw():void {		
			if (this.parent != null) {
				NodeTween.removeTweens(SVGNode(this.parent));
			}
						
			var attributeName:String = this.getAttribute('attributeName');
			
			if (NodeTween.isTweeningField(SVGNode(this.parent), attributeName)) {
				return;
			}
				
			var startVal:String = this.getAttribute('from');			
			if (!startVal) {
				startVal = SVGNode(this.parent).getStyle(attributeName)
			}
			var startValInt:Number = timeToSeconds(startVal);			
			
			var endVal:String = this.getAttribute('to');
			var endValInt:Number = timeToSeconds(endVal);
			
			var byVal:String = this.getAttribute('by');
			if (byVal) {
				endValInt = startValInt + timeToSeconds(byVal); 
			}
			
			var begin:String = this.getAttribute('begin');	
			var beginInt:Number = timeToSeconds(begin);
					
			var duration:String = this.getAttribute('dur');
			var durationInt:Number =  timeToSeconds(duration);
			
			var end:String = this.getAttribute('end');
			var endInt:Number = beginInt + durationInt;
			if (!end) {
				endInt = timeToSeconds(end);
			}			
			if (endInt < (beginInt + durationInt)) {
				endInt = beginInt + durationInt;
			}
			
			var repeat:String = this.getAttribute('repeatCount');
			var repeatInt:int;
			
			if (repeat == 'indefinite') {
				repeatInt = NodeTween.REPEAT_INFINITE;
			}
			else {
				repeatInt = SVGColors.cleanNumber(repeat);
			}
			
			NodeTween.addTween(SVGNode(this.parent), attributeName, beginInt, durationInt, endInt, startValInt, endValInt, repeatInt);
			
			
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