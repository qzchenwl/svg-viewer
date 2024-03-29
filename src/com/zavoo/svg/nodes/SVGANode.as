/*
Copyright (c) 2008 James Hight

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

package com.zavoo.svg.nodes {
	import flash.events.MouseEvent;
	import flash.net.URLRequest;	
	
	public class SVGANode extends SVGNode {
		
		public var url:String; 
		public var target:String;
		
		public function SVGANode(xml:XML = null) {
			super(xml);
		}
		
		override protected function generateGraphicsCommands():void {
			url = this._xml.@xlink::href;
			target = this._xml.@target;
			if (!target) {
				target = '_self';
			}
		}
		
		override protected function draw():void {
			if (this.parent is SVGNode) {
				SVGNode(this.parent).addEventListener(MouseEvent.CLICK, onParentMouseClick);
			}
		}
		
		private function onParentMouseClick(event:MouseEvent):void {
			var urlRequest:URLRequest = new URLRequest(url);
			flash.net.navigateToURL(urlRequest, target);
		}
		
	}
}