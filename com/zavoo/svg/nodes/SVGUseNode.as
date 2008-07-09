package com.zavoo.svg.nodes
{
	public class SVGUseNode extends SVGNode
	{		
		
		/**
		 * Symbol or Definition to be rendered
		 **/
		private var _symbol:SVGSymbolNode; 
		
		/**
		 * Copy of original XML, before _symbol XML is loaded
		 **/
		private var _useXML:XML;
		
		/**
		 * Track changes to _symbol
		 **/		  
		private var _revision:uint = 0;
		
		public function SVGUseNode(xml:XML):void {
			super(xml);			
		}				
		
		/**
		 * If _symbol revision has changed, reload element
		 * Call SVGNode.draw()
		 **/
		override protected function draw():void {
			if (this._symbol == null) {
				var href:String = this._xml.@xlink::href;
				href = href.replace(/^#/,'');
				
				this._symbol = this.svgRoot.getElement(href);

			}
			
			if (this._symbol.revision != this._revision) {
				refreshSymbol();
			}
			
			super.draw();
		}
		
		/**
		 * Load _symbol child XML as this nodes child XML
		 * Remove all children
		 * Parse SVG XML
		 * Draw graphics
		 **/
		private function refreshSymbol():void {		
			if (this._symbol is SVGDefsNode) {
				var href:String = this._xml.@xlink::href;
				href = href.replace(/^#/,'');
				this._xml.setChildren(SVGDefsNode(this._symbol).getDef(href));				
			}
			else {
				this._xml.setChildren(this._symbol.xml.children());
				
			}
			this._revision = this._symbol.revision;
			
			this.clearChildren();
			
			this.parse();			
			this.refreshGraphics();
		}
		
		/**
		 * Store a copy of the original XML in _useXML
		 * Set SVGNode.xml
		 **/		
		override public function set xml(xml:XML):void {
			this._useXML = xml; //Save a copy of the original XML
			super.xml = xml;
		}
		
		/**
		 * SVGUseNode is a copy, do not register
		 **/
		override protected function registerId():void {
			//Do Nothing		
		}
		
	}
}