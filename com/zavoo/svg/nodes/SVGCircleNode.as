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

package com.zavoo.svg.nodes
{
	public class SVGCircleNode extends SVGNode
	{
		
		public function SVGCircleNode(xml:XML):void {
			super(xml);
		}	
		
		/**
		 * Generate graphics commands to draw a circle
		 **/
		protected override function generateGraphicsCommands():void {
			
			this._graphicsCommands = new  Array();
			
			var cx:Number = this.getAttribute('cx',0);
			var cy:Number = this.getAttribute('cy',0);
			var r:Number = this.getAttribute('r',0);
			
			this._graphicsCommands.push(['CIRCLE', cx, cy, r]);
		}
		
	}
}
