package com.zavoo.svg.nodes
{
	/** 
	 * Contains drawing instructions used by SVGUseNode
	 * It is not rendered directly
	 **/
	public class SVGDefsNode extends SVGSymbolNode
	{
		
		public function SVGDefsNode(xml:XML):void {
			super(xml);
		}		
		
		/* override protected function setAttributes():void {
			//Register Symbol		
			this.svgRoot.registerDef(this);
		} */
		
		public function getDef(name:String):XML {
			for each(var node:XML in this._xml.children()) {
				if (node.@id == name) {
					return node;
				}
			}
			return null;
		}
		
		override protected function registerId():void {
			for each (var defNode:XML in this._xml.children()) {
				var id:String = defNode.@id;
				if (id != "") {
					this.svgRoot.registerElement(id, this);
				}
			}
		}
	}
}