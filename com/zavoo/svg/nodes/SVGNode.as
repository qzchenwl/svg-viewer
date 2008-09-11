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
	import com.zavoo.svg.nodes.mask.SVGMask;
	
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	
		
	/** Base node extended by all other SVG Nodes **/
	public class SVGNode extends Sprite
	{	
		public static const attributeList:Array = ['stroke', 'stroke-width', 'stroke-dasharray', 
										 'stroke-opacity', 'stroke-linecap', 'stroke-linejoin',
										 'fill', 'fill-opacity', 'opacity', 
										 'font-family', 'font-size', 'letter-spacing', 'filter'];
		
		
		public namespace xlink = 'http://www.w3.org/1999/xlink';
		public namespace svg = 'http://www.w3.org/2000/svg';
		
		/**
		 * Set by svgRoot() to cache the value of the root node
		 **/ 
		private var _svgRoot:SVGRoot = null;
			
		/**
		 * SVG XML for this node
		 **/	
		protected var _xml:XML;
	
		/**
		 * List of graphics commands to draw node.
		 * Generated by generateGraphicsCommands()
		 **/
		protected var _graphicsCommands:Array;

		/**
		 * Used for caching node attribute style values. font, font-size, stroke, etc...
		 * Set by setAttributes()
		 * Used by getStyle()
		 **/
		protected var _style:Object;
		
		/**
		 * If true, redraw sprite graphics
		 * Set to true on any change to xml
		 **/
		protected var _invalidDisplay:Boolean = false;
		
				
		/**
		 * Constructor
		 *
		 * @param xml XML object containing the SVG document. @default null	
		 *
		 * @return void.		
		 */
		public function SVGNode(xml:XML = null):void {			
			this.xml = xml;			
			this.addEventListener(Event.ADDED, registerId);			
		}			
		
		/** 
		 * Called to generate AS3 graphics commands from the SVG instructions		    
		 **/
		protected function generateGraphicsCommands():void {
			this._graphicsCommands = new  Array();	
		}
		
		/**
		 * Load attributes/styling from the XML. 
		 * Attributes are applied in functions called later.
		 * Creates a sprite mask if a clip-path is given.
		 **/
		protected function setAttributes():void {			
			
			var xmlList:XMLList;
			
			this._style = new Object();
			
			//Get styling from XML attribute list
			for each (var attribute:String in SVGNode.attributeList) {
				xmlList = this._xml.attribute(attribute);
				if (xmlList.length() > 0) {
					this._style[attribute] = xmlList[0].toString();
				}
			}
			
			//Get styling from XML attribute 'style'
			xmlList = this._xml.attribute('style');
			if (xmlList.length() > 0) {
				var styleString:String = xmlList[0].toString();
				var styles:Array = styleString.split(';');
				for each(var style:String in styles) {
					var styleSet:Array = style.split(':');
					if (styleSet.length == 2) {
						this._style[styleSet[0]] = styleSet[1];
					}
				}
			}
			
			//Setup ClipPath
			xmlList = this._xml.attribute('clip-path');
			if (xmlList.length() > 0) {
				var clipPath:String = xmlList[0].toString();
				clipPath = clipPath.replace(/url\(#(.*?)\)/si,"$1");
				var clipPathNode:SVGClipPathNode = this.svgRoot.getElement(clipPath);
				if (clipPathNode != null) {					
					this.addMask(clipPathNode);
				}				
			}
			
			//If there is not a transform attribute see if we can load the placement values,
			//Don't load both transform and placement values
			if (this.getAttribute('transform') == null) {				
				this.loadAttribute('x');	
				this.loadAttribute('y');
				this.loadAttribute('rotate', 'rotation');
			}	
			
			this.loadStyle('opacity', 'alpha');			
								
		}
		
		/**
		 * Load attributes/styling from the XML. 
		 * Attributes are applied in functions called later.
		 * Creates a sprite mask if a clip-path is given.		 
		 *
		 * @param clipPathNode SVGClipPathNode to be used as a mask for the node		 		
		 */		 
		private function addMask(clipPathNode:SVGClipPathNode):void {
			if (this.mask != null) {								
				this.removeChild(this.mask);
				this.mask = null;
			}
			var svgMask:SVGMask = new SVGMask(clipPathNode);
			this.addChild(svgMask);
			this.mask = svgMask;
		}
		
			
		/** 
		 * Perform transformations defined by the transform attribute 
		 **/
		protected function transformNode():void {
			
			var trans:String = this.getAttribute('transform');
			
			if (trans != null) {
				var transArray:Array = trans.match(/\S+\(.*?\)/sg);
				for each(var tran:String in transArray) {
					var tranArray:Array = tran.split('(',2);
					if (tranArray.length == 2)
					{						
						var command:String = String(tranArray[0]);
						var args:String = String(tranArray[1]);
						args = args.replace(')','');
						var argsArray:Array = args.split(/[, ]/);
						
						switch (command) {
							case "matrix":
								if (argsArray.length == 6) {
									var nodeMatrix:Matrix = this.transform.matrix;
									nodeMatrix.a = argsArray[0];
									nodeMatrix.b = argsArray[1];
									nodeMatrix.c = argsArray[2];
									nodeMatrix.d = argsArray[3];
									nodeMatrix.tx = argsArray[4];
									nodeMatrix.ty = argsArray[5];
									this.transform.matrix = nodeMatrix;
								}
								break;
								
							case "translate":
															
								if (argsArray.length == 1) {
									this.x = SVGColors.cleanNumber(argsArray[0]) + SVGColors.cleanNumber(this.getAttribute('x'));									
								}
								else if (argsArray.length == 2) {
									this.x = SVGColors.cleanNumber(argsArray[0]) + SVGColors.cleanNumber(this.getAttribute('x'));
									this.y = SVGColors.cleanNumber(argsArray[1]) + SVGColors.cleanNumber(this.getAttribute('y'));
								}
								break;
								
							case "scale":
								if (argsArray.length == 1) {
									this.scaleX = argsArray[0];
									this.scaleY = argsArray[0];
								}
								else if (argsArray.length == 2) {
									this.scaleX = argsArray[0];
									this.scaleY = argsArray[1];
								}
								break;
								
							case "skewX":
								// To Do
								break;
								
							case "skewY":
								// To Do
								break;
								
							case "rotate":
								this.rotation = argsArray[0];
								break;
								
							default:
								trace('Unknown Transformation: ' + command);
						}
					}
				}				
			}
		}
		
		/**
		 * Load an XML attribute into the current node
		 * 
		 * @param name Name of the XML attribute to load
		 * @param field Name of the node field to set. If null, the name attribute will be used as the field attribute.
		 **/ 
		protected function loadAttribute(name:String, field:String = null):void {
			if (field == null) {
				field = name;
			}
			var tmp:String = this.getAttribute(name);
			if (tmp != null) {
				this[field] = SVGColors.cleanNumber(tmp);
			}
		} 
		
		/**
		 * Load an SVG style into the current node
		 * 
		 * @param name Name of the SVG style to load
		 * @param field Name of the node field to set. If null, the value of name will be used as the field attribute.
		 **/ 
		protected function loadStyle(name:String, field:String = null):void {
			if (field == null) {
				field = name;
			}
			var tmp:String = this.getStyle(name);
			if (tmp != null) {
				this[field] = tmp;
			}
		}
		
		
		/** 
		 * Clear current graphics and call runGraphicsCommands to render SVG element 
		 **/
		protected function draw():void {
			this.graphics.clear();			
			this.runGraphicsCommands();
		}
				
				
		/** 
		 * Called at the start of drawing an SVG element.
		 * Sets fill and stroke styles
		 **/
		protected function nodeBeginFill():void {
			//Fill
			var fill_alpha:Number;
			var fill_color:Number
			
			var fill:String = this.getStyle('fill');
			if ((fill == 'none') || (fill == '')) {
				fill_alpha = 0;
				fill_color = 0;
			}			
			else {			
				fill_alpha = SVGColors.cleanNumber(this.getStyle('fill-opacity'));
				fill_color = SVGColors.getColor((fill));
				this.graphics.beginFill(fill_color, fill_alpha);
			}
			
			
			
			//Stroke
			var line_color:Number;
			var line_alpha:Number;
			var line_width:Number;
			
			var stroke:String = this.getStyle('stroke');
			if ((stroke == 'none') || (stroke == '')) {
				line_alpha = 0;
				line_color = 0;
				line_width = 0;
			}
			else {
				line_color = SVGColors.cleanNumber(SVGColors.getColor(stroke));
				line_alpha = SVGColors.cleanNumber(this.getStyle('stroke-opacity'));
				line_width = SVGColors.cleanNumber(this.getStyle('stroke-width'));
			}
			
			var capsStyle:String = this.getStyle('stroke-linecap');
			if (capsStyle == 'round'){
				capsStyle = CapsStyle.ROUND;
			}
			if (capsStyle == 'square'){
				capsStyle = CapsStyle.SQUARE;
			}
			else {
				capsStyle = CapsStyle.NONE;
			}
			
			var jointStyle:String = this.getStyle('stroke-linejoin');
			if (jointStyle == 'round'){
				jointStyle = JointStyle.ROUND;
			}
			else if (jointStyle == 'bevel'){
				jointStyle = JointStyle.BEVEL;
			}
			else {
				jointStyle = JointStyle.MITER;
			}
			
			var miterLimit:String = this.getStyle('stroke-miterlimit');
			if (miterLimit == null) {
				miterLimit = '4';
			}
			
			this.graphics.lineStyle(line_width, line_color, line_alpha, false, LineScaleMode.NORMAL, capsStyle, jointStyle, SVGColors.cleanNumber(miterLimit));
					
		}
		
		/** 
		 * Called at the end of drawing an SVG element
		 **/
		protected function nodeEndFill():void {
			this.graphics.endFill();
		}
		
		/**
		 * Execute graphics commands contained in var _graphicsCommands
		 **/ 
		protected function runGraphicsCommands():void {
			
			var firstX:Number = 0;
			var firstY:Number = 0;
					
			for each (var command:Array in this._graphicsCommands) {
				switch(command[0]) {
					case "SF":
						this.nodeBeginFill();
						break;
					case "EF":
						this.nodeEndFill();
						break;
					case "M":
						this.graphics.moveTo(command[1], command[2]);
						//this.nodeBeginFill();
						firstX = command[1];
						firstY = command[2];
						break;
					case "L":
						this.graphics.lineTo(command[1], command[2]);
						break;
					case "C":
						this.graphics.curveTo(command[1], command[2],command[3], command[4]);
						break;
					case "Z":
						this.graphics.lineTo(firstX, firstY);
						//this.nodeEndFill();
						break;
					case "LINE":
						this.nodeBeginFill();
						this.graphics.moveTo(command[1], command[2]);
						this.graphics.lineTo(command[3], command[4]);
						this.nodeEndFill();				
						break;
					case "RECT":
						this.nodeBeginFill();
						if (command.length == 5) {
							this.graphics.drawRect(command[1], command[2],command[3], command[4]);
						}
						else {
							this.graphics.drawRoundRect(command[1], command[2],command[3], command[4], command[5], command[6]);
						}
						this.nodeEndFill();				
						break;		
					case "CIRCLE":
						this.nodeBeginFill();
						this.graphics.drawCircle(command[1], command[2], command[3]);
						this.nodeEndFill();
						break;
					case "ELLIPSE":
						this.nodeBeginFill();						
						this.graphics.drawEllipse(command[1], command[2],command[3], command[4]);
						this.nodeEndFill();
						break;
				}
			}
		}
		
		/**
		 * If node has an "id" attribute, register it with the root node
		 **/
		protected function registerId(event:Event):void {
			this.removeEventListener(Event.ADDED, registerId);		
				
			var id:String = this._xml.@id;
			if (id != "") {
				this.svgRoot.registerElement(id, this);
			}
						
		}
		
		/**
		 * Parse the SVG XML.
		 * This handles creation of child nodes.
		 **/
		protected function parse():void {
			
			for each (var childXML:XML in this._xml.children()) {	
					
				var nodeName:String = childXML.localName();
				
				if (childXML.nodeKind() == 'element') {
					
					nodeName = nodeName.toLowerCase();
					
					switch(nodeName) {
						case "animate":
							this.addChild(new SVGAnimateNode(childXML));
							break;	
						case "animatemotion":
							this.addChild(new SVGAnimateMotionNode(childXML));
							break;	
						case "animatecolor":
							this.addChild(new SVGAnimateColorNode(childXML));
							break;	
						case "animatetransform":
							this.addChild(new SVGAnimateTransformNode(childXML));
							break;	
						case "circle":
							this.addChild(new SVGCircleNode(childXML));
							break;		
						case "clippath":
							this.addChild(new SVGClipPathNode(childXML));
							break;
						case "desc":
							//Do Nothing
							break;
						case "defs":
							this.addChild(new SVGDefsNode(childXML));
							break;
						case "ellipse":
							this.addChild(new SVGEllipseNode(childXML));
							break;
						case "filter":
							this.addChild(new SVGFilterNode(childXML));
							break;
						case "g":						
							this.addChild(new SVGGroupNode(childXML));
							break;
						case "image":						
							this.addChild(new SVGImageNode(childXML));
							break;
						case "line": 
							this.addChild(new SVGLineNode(childXML));
							break;	
						case "mask":
							this.addChild(new SVGMaskNode(childXML));
							break;						
						case "metadata":
							//Do Nothing
							break;
						case "namedview":
							//Add Handling 
							break;							
						case "polygon":
							this.addChild(new SVGPolygonNode(childXML));
							break;
						case "polyline":
							this.addChild(new SVGPolylineNode(childXML));
							break;
						case "path":						
							this.addChild(new SVGPathNode(childXML));
							break;
						case "rect":
							this.addChild(new SVGRectNode(childXML));
							break;
						case "set":
							this.addChild(new SVGSetNode(childXML));
							break;
						case "symbol":
							this.addChild(new SVGSymbolNode(childXML));
							break;						
						case "text":	
							this.addChild(new SVGTextNode(childXML));
							break; 
						case "title":	
							this.addChild(new SVGTitleNode(childXML));
							break; 
						case "tspan":						
							this.addChild(new SVGTspanNode(childXML));
							break; 
						case "use":
							this.addChild(new SVGUseNode(childXML));
							break;
							
						case "null":
							break;
							
						default:
							trace("Unknown Element: " + nodeName);
							break;	
					}	
				}				
			}			
		}
		
		/**
		 * Get a node style (ex: fill, stroke, etc..)
		 * Also checks parent nodes for the value if it is not set in the current node.
		 *
		 * @param name Name of style to retreive
		 * 
		 * @return Value of style or null if it is not found
		 **/
		public function getStyle(name:String):String{
			if (this._style.hasOwnProperty(name)) {
				return this._style[name];
			}
			
			var attribute:String = this.getAttribute(name);
			if (attribute) {
				return attribute;
			}
			
			//Opacity should not be inherited
			else if (name == 'opacity') {
				return '1';
			}
			else if (this.parent is SVGNode) {
				return SVGNode(this.parent).getStyle(name);
			}
			return null;
		}
			
		/**
		 * @param attribute Attribute to retrieve from SVG XML
		 * 
		 * @param defaultValue to return if attribute is not found
		 * 
		 * @return Returns the value of defaultValue
		 **/
		protected function getAttribute(attribute:*, defaultValue:* = null):* {
			var xmlList:XMLList = this._xml.attribute(attribute);
			if (xmlList.length() > 0) {
				return xmlList[0].toString();
			}			
			return defaultValue;
			
		}
		
		/**
		 * Remove all child nodes
		 **/		
		protected function clearChildren():void {			
			while(this.numChildren) {
				this.removeChildAt(0);
			}
		}
		
				
		/**
		 * Force a redraw of a node and its children
		 **/
		public function invalidateDisplay():void {
			if (this._invalidDisplay == false) {
				this._invalidDisplay = true;
				this.addEventListener(Event.ENTER_FRAME, redrawNode);
			}			
		}
		
		/**
		 * Triggers on ENTER_FRAME event
		 * Redraws node graphics if _invalidDisplay == true
		 **/
		protected function redrawNode(event:Event):void {
			if (this.parent == null) {
				return;
			}		
			
			if (this._invalidDisplay) {
				
				this._invalidDisplay = false;
				this.removeEventListener(Event.ENTER_FRAME, redrawNode);
				
				if (this._xml != null) {	
				
					//this.clearChildren();
					this.graphics.clear();		
					
					if (this.numChildren == 0) {
						this.parse();						
					}
					
					this.setAttributes();						
					this.generateGraphicsCommands();	
					this.transformNode();		
					this.draw();	
					
					this.setupFilters();								
				}	
			}
		}
		
		/**
		 * Add any assigned filters to node
		 **/
		protected function setupFilters():void {
			var filterName:String = this.getStyle('filter');
			if ((filterName != null)
				&& (filterName != '')) {
				var matches:Array = filterName.match(/url\(#([^\)]+)\)/si);
				if (matches.length > 0) {
					filterName = matches[1];
					var filterNode:SVGFilterNode = this.svgRoot.getElement(filterName);
					if (filterNode != null) {
						this.filters = filterNode.getFilters();
					}
				}
			}
		}
				
		//Getters / Setters
		
		/**
		 * Recursively searches for the root node
		 * 
		 * @return Root SVG node
		 **/ 
		public function get svgRoot():SVGRoot {
			if (this._svgRoot == null) {
				if (this is SVGRoot) {
					this._svgRoot = SVGRoot(this);
				}			
				if (this.parent is SVGRoot) {
					this._svgRoot = SVGRoot(this.parent);
				}
				else if (this.parent != null) {
					if (this.parent is SVGNode) {
						this._svgRoot = SVGNode(this.parent).svgRoot;
					}
				}
			}
			return this._svgRoot;
		}
			
		/** 
		 * @private 
		**/		
		public function set xml(xml:XML):void {		
			this._xml = xml;
			this.invalidateDisplay();
		}
		
		/**
		 * SVG XML
		 **/
		public function get xml():XML {
			return this._xml;
		}

		/** 
		 * @private
		 * Temporary function to make debugging easier 
		 **/
		 public function get children():Array {
			var myChildren:Array = new Array();
			for (var i:int = 0; i < this.numChildren; i++) {
				myChildren.push(this.getChildAt(i));
			}
			return myChildren;
		} 
		
		/** 
		 * @private
		 * Temporary function to make debugging easier 
		 **/
		public function get graphicsCommands():Array {
			return this._graphicsCommands;
		}
			
		
		/**
		 * Set node style to new value
		 * Updates SVG XML and then calls refreshGraphis()
		 * 
		 * @param name Name of style
		 * @param value New value for style
		 **/
		public function setStyle(name:String, value:String):void {
			//Stick in the main attribute if it exists
			var attribute:String = this.getAttribute(name);
			if (attribute != null) {
				if (attribute != value) {
					this._xml.@[name] = value;
					this.invalidateDisplay();
				}
			}
			else {
				updateStyleString(name, value);
			}
		}
		
		/**
		 * Update a value inside the attribute style
		 * <node style="...StyleString...">
		 * 
		 * @param name Name of style
		 * @param value New value for style
		 **/ 
		private function updateStyleString(name:String, value:String):void {
			if (this._style[name] == value) {
				return;
			}
			
			this._style[name] = value;
			
			var newStyleString:String = '';
			
			for (var key:String in this._style) {
				if (newStyleString.length > 0) {
					newStyleString += ';';
				}
				newStyleString += key + ':' + this._style[key];
			}
			
			this._xml.@style = newStyleString;		
			
			this.invalidateDisplay();
			
		}
		
	}
}
