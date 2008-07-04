package com.zavoo.svg
{
	import com.zavoo.svg.nodes.SVGRoot;
	
	import flash.geom.Transform;
	
	import mx.containers.Canvas;

	public class SVGViewer extends Canvas
	{
		private var svgRoot:SVGRoot;
		
		public function SVGViewer(){
			svgRoot = new SVGRoot();	
			this.rawChildren.addChild(svgRoot);
		}
				
		/**
		 * Get / Set Functions 
		 **/
		 
		
		/* xml*/
		public function get xml():XML {
			return svgRoot.xml;
		}
				
		public function set xml(xml:XML):void {
						
			//Pass XML off to svgDocReader
			this.svgRoot.xml = xml;
			
			//Have svgDocReader draw SVG
			svgRoot.draw();
			
			// Set/Reset scale
			this.scale = 1;	
		}
		
		
		/* scale */
		public function set scale(scale:Number):void {
			svgRoot.scale = scale;

			//Scale canvas to match size of  SVG
			this.width = svgRoot.origWidth * scale;
			this.height = svgRoot.origHeight * scale; 
		}
		
		public function get scale():Number {
			return svgRoot.scale;				
		}
		
		
		/* scaleX */
		override public function set scaleX(value:Number):void {
			this.svgRoot.scaleX = value;	
		}
		
		override public function get scaleX():Number {
			return this.svgRoot.scaleX;
		}
		
		
		/* scaleY */
		override public function set scaleY(value:Number):void {
			this.svgRoot.scaleY = value;
		}
		
		override public function get scaleY():Number {
			return this.svgRoot.scaleY;
		}
		
		
		/* rotation */
		override public function set rotation(value:Number):void {
			this.svgRoot.rotation = value;
		}
		
		override public function get rotation():Number {
			return this.svgRoot.rotation;
		}
		
		
		/* transform */
		override public function set transform(value:Transform):void {
			this.svgRoot.transform = value;
		}
		
		override public function get transform():Transform {
			return this.svgRoot.transform;
		}
		
		
		/* filters */
		override public function set filters(value:Array):void {
			this.svgRoot.filters = value;
		}
		
		override public function get filters():Array {
			return this.svgRoot.filters;
		}
		
	}
}