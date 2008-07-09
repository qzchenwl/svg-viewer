package com.zavoo.svg
{
	
	import com.zavoo.svg.nodes.SVGRoot;
	
	import flash.geom.Transform;
	
	import mx.containers.Canvas;

	/**
	 * Flex container for the SVG Renderer
	 **/
	public class SVGViewer extends Canvas
	{
		private var _xml:XML;
		private var _svgRoot:SVGRoot;
		
		public function SVGViewer() {
			super();
			this._svgRoot = new SVGRoot(null);
			this.rawChildren.addChild(this._svgRoot);
		}
		
		/**
		 * @private
		 **/
		public function set xml(value:XML):void {			
			this._svgRoot.xml = value;
						
		}
		
		/**
		 * Access _svgRoot xml value
		 **/
		public function get xml():XML {
			return this._svgRoot.xml
		}
		
		/**
		 * @private
		 **/
		public function set scale(scale:Number):void {
			this._svgRoot.scale = scale;

			//Scale canvas to match size of  SVG
			this.width = this._svgRoot.width;
			this.height = this._svgRoot.height; 
		}
		
		/**
		 * Set scaleX and scaleY at the same time
		public function get scale():Number {
			return svgRoot.scale;				
		}
		
		
		/**
		 * @private
		 **/
		override public function set scaleX(value:Number):void {
			this._svgRoot.scaleX = value;	
		}
		
		override public function get scaleX():Number {
			return this._svgRoot.scaleX;
		}
		
		
		/**
		 * @private
		 **/
		override public function set scaleY(value:Number):void {
			this._svgRoot.scaleY = value;
		}
		
		override public function get scaleY():Number {
			return this._svgRoot.scaleY;
		}
		
		
		/**
		 * @private
		 **/
		override public function set rotation(value:Number):void {
			this._svgRoot.rotation = value;
		}
		
		override public function get rotation():Number {
			return this._svgRoot.rotation;
		}
		
		
		/**
		 * @private
		 **/
		override public function set transform(value:Transform):void {
			this._svgRoot.transform = value;
		}
		
		override public function get transform():Transform {
			return this._svgRoot.transform; 
		}
		
		
		/**
		 * @private
		 **/
		override public function set filters(value:Array):void {
			this._svgRoot.filters = value;
		}
		
		override public function get filters():Array {
			return this._svgRoot.filters;
		}
		
	}
}