package com.zavoo.svg.nodes
{
	public class SVGMask extends SVGNode
	{
		private var _revision:uint = 0;
		private var _clipPath:SVGClipPathNode;
		
		
		public function SVGMask(clipPathNode:SVGClipPathNode){
			this._clipPath = clipPathNode;
			//super();
			super(this._clipPath.xml);
			//this._revision = this._clipPath.revision;
		}
		
		override protected function draw():void {
			
			if (this._clipPath.revision != this._revision) {
				refreshClipPath();
			}			
		}
		
		override protected function nodeBeginFill():void {
			this.graphics.lineStyle(0,0,0);
			this.graphics.beginFill(0x000000,1);
		}
		
		private function refreshClipPath():void {			
			this._xml = this._clipPath.xml;
			this._revision = this._clipPath.revision;
			
			this.clearChildren();
			//this.mask = null;
			
			this.parse();
			this.refreshGraphics();
		}
		
		override public function getStyle(name:String):String {
			var style:String = '';
			
			//Return default values if a style is not set
			if ((name == 'opacity') 
				|| (name == 'fill-opacity')
				|| (name == 'stroke-opacity')
				|| (name == 'stroke-width')) {				
				style = '1';				
			}
			
			if (name == 'fill') {
				style = 'black';				
			}
			
			if (name == 'stroke') {
				style = 'none';				
			}
			
			return style;			
					
		}
	}
}