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
	import com.zavoo.svg.events.SVGEvent;
	import com.zavoo.svg.events.SVGMouseEvent;
	import com.zavoo.svg.events.SVGMutationEvent;
	import com.zavoo.svg.nodes.fills.SVGGradientFill;
	import com.zavoo.svg.nodes.mask.SVGMask;
	
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.utils.describeType;
	
		
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
		 * Used to calculate width for gradients
		 **/
		private var _minX:Number = 0;
		
		/**
		 * Used to calculate width for gradients
		 **/
		private var _maxX:Number = 0;
		
		/**
		 * Used to calculate height for gradients
		 **/
		private var _minY:Number = 0;
		
		/**
		 * Used to calculate height for gradients
		 **/
		private var _maxY:Number = 0;
			
		/**
		 * Flag set if a node is a copy of another node. 
		 * Example: children of a Use node
		 */
		protected var _isCopy:Boolean = false;
		
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
		
		protected var _firstRendering:Boolean = true;
		
		/**
		 * The ID of this node. Used so we can detect if the ID has changed.
		 */
		protected var _id:String = null;
		
		public function nodeType():String {
			
			var type:XML = describeType(this);
			return type.@name;
			
		}
			
				
		/**
		 * Constructor
		 *
		 * @param xml XML object containing the SVG document. @default null	
		 *
		 * @return void.		
		 */
		public function SVGNode(xml:XML = null):void {	
			this._xml = xml;		
			this.xml = xml;			
				
			
			setupEvents();		
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
			
			var parentIsCopy:Boolean = false;
			
			this.registerNode();

			this._style = new Object();
			
			//Get styling from XML attribute list
			for each (var attribute:String in SVGNode.attributeList) {
				xmlList = this._xml.attribute(attribute);
				if (xmlList.length() > 0) {
					this._style[attribute] = SVGColors.trim(xmlList[0].toString());
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
						this._style[SVGColors.trim(styleSet[0])] = SVGColors.trim(styleSet[1]);
					}
				}
			}
			
			//Setup ClipPath
			xmlList = this._xml.attribute('clip-path');
			if (xmlList.length() > 0) {
				var clipPathNode:SVGClipPathNode;
				
				var clipPath:String = xmlList[0].toString();
				clipPath = clipPath.replace(/url\(#(.*?)\)/si,"$1");
				var cNode:SVGNode = this.svgRoot.getElement(clipPath);
				if (cNode is SVGDefsNode) {
					var defNode:SVGDefsNode = SVGDefsNode(cNode);
					
					clipPathNode = new SVGClipPathNode(defNode.getDef(clipPath));
					this.addChild(clipPathNode);
				}
				else {
					clipPathNode = SVGClipPathNode(cNode);
				}
				
				if (clipPathNode != null) {					
					this.addMask(clipPathNode);
				}				
			}
					
			this.loadAttribute('x');	
			this.loadAttribute('y');
			this.loadAttribute('rotate', 'rotation');				
			
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
						args = args.replace(/\s*,\s*/g, ','); 
						var argsArray:Array = args.split(/[, ]/);
						
						switch (command) {
							case "matrix":
								if (argsArray.length == 6) {
									var nodeMatrix:Matrix = new Matrix();
									nodeMatrix.a = argsArray[0];
									nodeMatrix.b = argsArray[1];
									nodeMatrix.c = argsArray[2];
									nodeMatrix.d = argsArray[3];
									nodeMatrix.tx = argsArray[4];
									nodeMatrix.ty = argsArray[5];
									
									var matrix:Matrix = this.transform.matrix.clone();
									matrix.concat(nodeMatrix);
									
									this.transform.matrix = matrix;
									
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
			
			var gradient:Array = fill.match(/^\s*url\(#(\S+)\)/si);
			var name:String;
			
			fill_alpha = SVGColors.cleanNumber(this.getStyle('fill-opacity'));
			
			if ((fill == 'none') || (fill == '')) {
				fill_alpha = 0;
				fill_color = 0; 
			}			
			else if( gradient && gradient.length ) {
				var fillNode:SVGNode = this.svgRoot.getElement(gradient[1]);	
				if (fillNode is SVGDefsNode) {
					//Check for secondary color					
					/* var secondColor:String = StringUtil.trim(fill.replace(/^\s*url\(#(\S+)\)/si, ''));
					if (secondColor) {
						this.graphics.beginFill(SVGColors.getColor(secondColor), fill_alpha);
					} */
					var nodeXML:XML = SVGDefsNode(fillNode).getDef(gradient[1]);
					name = nodeXML.localName().toString().toLowerCase();
					if ((name == 'lineargradient') || (name == 'radialgradient')) {
						SVGGradientFill.gradientFill(this, SVGDefsNode(fillNode).getDef(gradient[1]));
					}
					
				}	
			}
			else {		
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
		
		protected function registerNode():void {
			//We need to account for Use nodes nested inside of other Use nodes / Symbols
			var parentIsCopy:Boolean = false;
			if (this.parent is SVGNode) {
				parentIsCopy = SVGNode(this.parent).isCopy;
			}			
			if (parentIsCopy) {
				this._isCopy = true;
			}
			else {
				//Unregister and re-register the node's ID if it has changed
				var newID:String = this._xml.@id;
				if (newID == '' || newID == null) {
					newID = null;
				}
	 			
				if (newID != null && newID != this._id) {
					this.svgRoot.unregisterElement(this._id);
					this._id = newID;
					this.svgRoot.registerElement(this._id, this);
				}
			}
		}
		
		/**
		 * If node has an "id" attribute, register it with the root node
		 **/
		protected function onNodeAdded(event:Event):void {
			if (this.svgRoot) {	
				
				this.registerNode();
							
				this.svgRoot.dispatchEvent(new SVGMutationEvent(this, SVGMutationEvent.DOM_NODE_INSERTED)); 
			}
						
		}
		
		protected function onNodeRemoved(event:Event):void {
			if (this.svgRoot) {			
				this.svgRoot.dispatchEvent(new SVGMutationEvent(this, SVGMutationEvent.DOM_NODE_REMOVED));
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
					
					var validNode:Boolean = true;
					
					switch(nodeName) {
						case "a":
							this.addChild(new SVGANode(childXML));
							break;
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
			if (this._style && this._style.hasOwnProperty(name)) {
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
		public function getAttribute(attribute:*, defaultValue:* = null):* {
			var xmlList:XMLList = this._xml.attribute(attribute);
			if (xmlList.length() > 0) {
				return xmlList[0].toString();
			}			
			return defaultValue;
			
		}
		
		/**
		 * @param attribute Attribute to set in SVG XML
		 * 
		 * @param attrValue to set		
		 **/
		public function setAttribute(attribute:String, attrValue:*):void {
			var xmlList:XMLList = this._xml.attribute(attribute);
			xmlList[0] = attrValue;

			this.invalidateDisplay();
		}
		
		/**
		 * Append a node
		 * 
		 * @param xml XML of new node
		 * 
		 * @param parentId ?
		 **/
		public function appendDomChild(xml:XML, parentId:String):void {
			this.clearChildren();
			this._xml.appendChild(xml);
			this.invalidateDisplay();
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
				if (this.svgRoot != null 
					&& !(this is SVGRoot)) {
					this.svgRoot.invalidNodeCount++;
				}
				for (var i:int = 0; i < this.numChildren; i++) {
					var child:DisplayObject = this.getChildAt(i);
					if (child is SVGNode) {
						SVGNode(child).invalidateDisplay();
					}
				}
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
				if (this._xml != null) {	
				
					//this.clearChildren();
					this.graphics.clear();		
					
					if (this.numChildren == 0) {
						this.parse();						
					}
					
					this.x = 0;
					this.y = 0;
					
					this.setAttributes();						
					this.generateGraphicsCommands();	
					this.transformNode();		
					this.draw();	
					
					this.setupFilters();								
				}
				
				this._invalidDisplay = false;
				this.removeEventListener(Event.ENTER_FRAME, redrawNode);		
				
				
				if (!(this is SVGRoot)) {
					this.svgRoot.invalidNodeCount--;
				}
				else if (this is SVGRoot) {
					var hasChildren:Boolean = false;
					for (var i:int = 0; i < this.numChildren; i++) {
						var child:DisplayObject = this.getChildAt(i);
						if (child is SVGNode) {
							hasChildren = true;
							break;
						}
					}
					if (!hasChildren) { 
						this.dispatchEvent(new SVGEvent(SVGEvent.SVG_LOAD));
					}
 				}
									
			}
		}
		
		/**
		 * Track nodes as they are added so we know when to send the RENDER_DONE event
		 **/
		override public function addChild(child:DisplayObject):DisplayObject {
			if (child is SVGRoot) {
				trace ("wtf?");
			}
			if (child is SVGNode) {				
				this.svgRoot.invalidNodeCount++;
			}
			
			super.addChild(child);	
			return child;
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
		
		/**
		 * Check value of x against _minX and _maxX, 
		 * Update values when appropriate
		 **/
		protected function setXMinMax(value:Number):void {
			if (value < this._minX) {
				this._minX = value;
			}
			if (value > this._maxX) {
				this._maxX = value;
			}
		}
		
		/**
		 * Check value of y against _minY and _maxY, 
		 * Update values when appropriate
		 **/
		protected function setYMinMax(value:Number):void {
			if (value < this._minY) {
				this._minY = value;
			}
			if (value > this._maxY) {
				this._maxY = value;
			}
		}
		
		/**
		 * Get width calculated from _minX and _maxX
		 **/
		public function getRoughWidth():Number {
			return this._maxX - this._minX;
		}
		
		/**
		 * Get height calculated from _minY and _maxY
		 **/
		public function getRoughHeight():Number {
			return this._maxY - this._minY;
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
			this.clearChildren();
			this.invalidateDisplay();
			
			if (this.svgRoot) { //if !null then already added
				this.svgRoot.dispatchEvent(new SVGMutationEvent(this, SVGMutationEvent.DOM_CHARACTER_DATA_MODIFIED));
			}
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
		
		
		public function get isCopy():Boolean {
			return this._isCopy;
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
		
		/*
		 **** EVENTS ****
		 */
		
		protected function setupEvents():void {
			this.addEventListener(Event.ADDED, onNodeAdded);
			this.addEventListener(Event.REMOVED, onNodeRemoved);
			
			this.addEventListener(MouseEvent.CLICK, onMouseClick);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected function onMouseClick(event:MouseEvent):void {
			if (this.svgRoot) {	
				var svgMouseEvent:SVGMouseEvent = new SVGMouseEvent(this, SVGMouseEvent.CLICK, event.bubbles, 
					event.cancelable, event.localX, event.localY, event.relatedObject, event.ctrlKey, 
					event.altKey, event.shiftKey, event.bubbles, event.delta);
					
				this.svgRoot.dispatchEvent(svgMouseEvent);
				this.svgRoot.currentNode = this;
			}
		}
		
		protected function onMouseDown(event:MouseEvent):void {
			if (this.svgRoot) {	
				var svgMouseEvent:SVGMouseEvent = new SVGMouseEvent(this, SVGMouseEvent.MOUSE_DOWN, event.bubbles, 
					event.cancelable, event.localX, event.localY, event.relatedObject, event.ctrlKey, 
					event.altKey, event.shiftKey, event.bubbles, event.delta);
				
				this.svgRoot.dispatchEvent(svgMouseEvent);
			}
		}
		
		protected function onMouseMove(event:MouseEvent):void {
			if (this.svgRoot) {	
				var svgMouseEvent:SVGMouseEvent = new SVGMouseEvent(this, SVGMouseEvent.MOUSE_MOVE, event.bubbles, 
					event.cancelable, event.localX, event.localY, event.relatedObject, event.ctrlKey, 
					event.altKey, event.shiftKey, event.bubbles, event.delta);				
			
				this.svgRoot.dispatchEvent(svgMouseEvent);
			}
		}
		
		protected function onMouseOut(event:MouseEvent):void {
			if (this.svgRoot) {	
				var svgMouseEvent:SVGMouseEvent = new SVGMouseEvent(this, SVGMouseEvent.MOUSE_OUT, event.bubbles, 
					event.cancelable, event.localX, event.localY, event.relatedObject, event.ctrlKey, 
					event.altKey, event.shiftKey, event.bubbles, event.delta);
				
				this.svgRoot.dispatchEvent(svgMouseEvent);
			}
		}
		
		protected function onMouseOver(event:MouseEvent):void {
			if (this.svgRoot) {	
				var svgMouseEvent:SVGMouseEvent = new SVGMouseEvent(this, SVGMouseEvent.MOUSE_OVER, event.bubbles, 
					event.cancelable, event.localX, event.localY, event.relatedObject, event.ctrlKey, 
					event.altKey, event.shiftKey, event.bubbles, event.delta);
					
				this.svgRoot.dispatchEvent(svgMouseEvent);
			}
		}
		
		protected function onMouseUp(event:MouseEvent):void {
			if (this.svgRoot) {	
				var svgMouseEvent:SVGMouseEvent = new SVGMouseEvent(this, SVGMouseEvent.MOUSE_UP, event.bubbles, 
					event.cancelable, event.localX, event.localY, event.relatedObject, event.ctrlKey, 
					event.altKey, event.shiftKey, event.bubbles, event.delta);
					
				this.svgRoot.dispatchEvent(svgMouseEvent);
			}
		}
	}
}