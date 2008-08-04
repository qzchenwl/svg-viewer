package com.zavoo.svg.utils
{
	
	import com.zavoo.svg.nodes.SVGNode;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import mx.core.Application;

	public class NodeTween {
		public static const REPEAT_INFINITE:int = -1;
		
		//static
		public static var tweens:Dictionary = new Dictionary();
		public static var listening:Boolean = false;
		
		public static function init():void {
			tweens = new Dictionary();
			listening = false;
		}
		
		public static function addTween (target:SVGNode, field:String, delay:Number, duration:Number, end:Number, fromVal:Number, toVal:Number, repeat:int):NodeTween {
						
			var nodeTween:NodeTween = new NodeTween(target, field, delay, duration, end, fromVal, toVal, repeat);
			
			if (!listening) {
				Application.application.stage.addEventListener(Event.ENTER_FRAME, renderTweens);				
				NodeTween.listening = true;
			}
			
			if (tweens[target] == undefined) {
				tweens[target] = new Dictionary();
			}
			
			tweens[target][nodeTween] = nodeTween;
			
			return nodeTween;
		}
		
		public static function removeTween(nodeTween:NodeTween):void {
			
			if ( tweens[nodeTween._target][nodeTween] != undefined ) {
				
				delete tweens[nodeTween._target][nodeTween];
			}
			
			for each (var object:Object in tweens[nodeTween._target]) {
				return;
			}
			
			//Object is empty
			delete tweens[nodeTween._target];
			
			checkTweens();
		}
		
		public static function removeTweens(target:SVGNode):void {
			return;
			if (tweens != null) {
				delete tweens[target];
				checkTweens();
			}
		}
				
		public static function isTweening(target:SVGNode):Boolean {
			if (tweens[target] is undefined) {
				return false;
			}
			return true;
		}
		
		public static function isTweeningField(target:SVGNode, field:String):Boolean {
			if ( (tweens == null)
				|| (tweens[target] == undefined) 
				|| (tweens[target][field] == undefined)) {
				return false;
			} 
			return true;
		}
		
		private static function renderTweens(event:Event):void {
			for each (var dictionary:Dictionary in tweens) {
				for each (var nodeTween:NodeTween in dictionary) {
					nodeTween.renderTween();
				}
			}
		}
		
		private static function checkTweens():void {
			for each (var dictionary:Dictionary in tweens) {
				return;
			}
			
			//No more tweens, remove ENTER_FRAME hook
			Application.application.stage.removeEventListener(Event.ENTER_FRAME, renderTweens);
			listening = false;
		}
		
		
		
		// class
		private var _target:SVGNode;
		private var _field:String;
		
		private var _fromVal:Number;
		private var _toVal:Number;		
		private var _valSpan:Number;
		
		private var _startTime:int;
		
		private var _delay:int;
		private var _duration:int;
		private var _end:int;
		
		private var _repeat:int;
		
		
		
		public function NodeTween(target:SVGNode, field:String, delay:Number, duration:Number, end:Number, fromVal:Number, toVal:Number, repeat:int) {
			this._target = target;
			this._field = field;
			
			//Convert to milliseconds
			this._delay = delay * 1000;
			this._duration = duration * 1000;
			this._end = end * 1000;
			
			this._fromVal = fromVal;
			this._toVal = toVal;
			this._valSpan = toVal - fromVal;
			
			this._repeat = repeat;
			
			this._startTime = getTimer();
		}
		
		private function renderTween():void {
			var time:int = getTimer();
			
			var timeLapsed:int = time - this._startTime;
			
			
			if (timeLapsed < this._delay) {
				return;
			}
						
			timeLapsed -= this._delay;
			
			var factor:Number = 1;
			var newVal:Number;
			
			if (timeLapsed < this._duration) {
				factor = timeLapsed / this._duration;
				newVal = this._fromVal + (factor * this._valSpan);
			}
			else {
				newVal = this._toVal;
				if (timeLapsed > this._end) {
					if (this._repeat == 0) {
						removeTween(this);
					}
					else {
						if (this._repeat > 0) {
							this._repeat--;
						}
						
						this._startTime += this._delay + this._duration;
					}
				}
			}
			
			this._target.setStyle(this._field, newVal.toString());
			
		}
		
	}
}