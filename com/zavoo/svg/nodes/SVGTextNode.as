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
	import com.zavoo.svg.data.SVGColors;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.system.Capabilities;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	
	/** SVG Text element node **/
	public class SVGTextNode extends SVGNode
	{	
		
		/**
		 * Hold node's text
		 **/
		private var _text:String = '';
		
		/**
		 * Hold text path node if text follows a path
		 **/
		private var _textPath:SVGNode = null;
		
		/**
		 * TextField to render nodes text
		 **/
		private var _textField:TextField;
		
		/**
		 * Bitmap to display text rendered by _textField
		 **/
		private var _textBitmap:Bitmap;
		
		public function SVGTextNode(xml:XML):void {			
			super(xml);			
		}
		
		/**
		 * Get any child text (not text inside child nodes)
		 * If this node has any text create a TextField at this._textField
		 * Call SVGNode.parse()
		 **/
		override protected function parse():void {
			this._text = '';
			
			for each(var childXML:XML in this._xml.children()) {
				if (childXML.nodeKind() == 'text') {
					this._text += childXML.toString();
				}
			}
			
			if (this._text != '') {
				this._textField = new TextField();
				this._textField.autoSize = TextFieldAutoSize.LEFT;
			}
			
			super.parse();
		}
		
		/**
		 * Call SVGNode.setAttributes()
		 * If this node contains text load text format (font, font-size, color, etc...)
		 * Render text to a bitmap and add bitmap to node
		 **/
		override protected function setAttributes():void {
			
			super.setAttributes();
			
			var embeddedFonts:Array = Font.enumerateFonts();
			
			if (this._textField != null) {
				var fontFamily:String = this.getStyle('font-family');				
				var fontSize:String = this.getStyle('font-size');
				var fill:String = this.getStyle('fill');
												
				var textFormat:TextFormat = this._textField.getTextFormat();
				
				if (embeddedFonts.length == 0) { //No embedded fonts, use system fonts
					this._textField.embedFonts = false;
					if (fontFamily != null) {
						fontFamily = fontFamily.replace("'", '');
						textFormat.font = fontFamily;						
					}
				}
				else { //Use embedded fonts
					this._textField.embedFonts = true;					
					textFormat.font = Font(embeddedFonts[0]).fontName;
				}
				
				if (fontSize != null) {
					//Handle floating point font size
					var fontSizeNum:Number = SVGColors.cleanNumber(fontSize);
					
					//Scale font to current DPI					
					fontSizeNum *= Capabilities.screenDPI / 72;
					
					var fontScale:Number = Math.floor(fontSizeNum);
					textFormat.size = fontScale;
					
					fontScale = fontSizeNum / fontScale;
					
					_textField.scaleX = fontScale;
					_textField.scaleY = fontScale;
					
				}
							
				if (fill != null) {
					textFormat.color = SVGColors.getColor(fill);
				}
								
				this._textField.text = this._text;
				this._textField.setTextFormat(textFormat);
				
				if (this._textBitmap != null) {
					if (this.contains(this._textBitmap)) {
						this.removeChild(this._textBitmap);
					}
					this._textBitmap = null;
				} 
				
				if (this.contains(this._textField)) {
					this.removeChild(this._textField);
				}
				
				var textLineMetrics:TextLineMetrics = this._textField.getLineMetrics(0);
								
				if (embeddedFonts.length == 0) { //No embedded fonts, so we need to render the text to bitmap to support rotated text
					var bitmapData:BitmapData = new BitmapData(this._textField.width, this._textField.height, true, 0x000000);
					
					//Double resolution of bitmap
					//this._textField.scaleX = this._textField.scaleX * 2;
					//this._textField.scaleY = this._textField.scaleY * 2;
					
					bitmapData.draw(this._textField);			
					
					this._textBitmap = new Bitmap(bitmapData);
					//this._textBitmap.scaleX = 0.5;
					//this._textBitmap.scaleY = 0.5;
					this._textBitmap.smoothing = true;		
								
					this._textBitmap.x = -2; //account for 2px gutter
					this._textBitmap.y =  -2; //account for 2px gutter
					
					this._textField = null;
				}
				else { //There is an embedded font so display TextField				
					
					this._textField.x = -2; //account for 2px gutter
					this._textField.y = -textLineMetrics.ascent - 2; //account for 2px gutter
					
				}
			}
		}	
		
		/**
		 * Add _textBitmap to node
		 **/
		override protected function draw():void {
			super.draw();
			if (this._textBitmap != null) {
				this.addChild(this._textBitmap);			
			}		
			if (this._textField != null) {
				this.addChild(this._textField);			
			}	
		} 		
		
		override protected function transformNode():void {
			super.transformNode();	
		}	
	}
}
