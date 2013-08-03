package com.dtedu.digipub.dib
{
	import com.dtedu.digipub.interfaces.IBookFile;
	import com.dtedu.digipub.interfaces.IPageFile;
	import com.dtedu.digipub.interfaces.ITOCNode;
	import com.dtedu.trial.interfaces.IDisposable;
	
	public class TOCNode implements ITOCNode, IDisposable
	{		
		private var _parent:ITOCNode;
		private var _name:String;
		private var _pageID:String;		
		private var _childNodes:Vector.<ITOCNode>;
		
		public function TOCNode(parentNode:ITOCNode)
		{			
			_parent = parentNode;
		}					
		
		public function get name():String
		{
			return _name;
		}
		
		public function get pageID():String
		{
			return _pageID;
		}
		
		public function get parent():ITOCNode
		{
			return _parent;
		}
		
		public function get hasChildren():Boolean
		{
			return _childNodes != null;
		}
		
		public function get childNodes():Vector.<ITOCNode>
		{
			return _childNodes;
		}			
		
		public function load(data:*):void
		{
			_disposeNode();
			
			var content:XML = XML(data);
			
			_name = content.@name;
			
			_pageID = (content.@page) ? content.@page : null;						
			
			if (content.hasComplexContent())
			{								
				_childNodes = new Vector.<ITOCNode>();
				
				for each (var node:XML in content.node)
				{
					var dibTOC:ITOCNode = new TOCNode(this);
					dibTOC.load(node);										
					
					_childNodes.push(dibTOC);
				}
			}
		}
		
		public function save():XML
		{
			var tocTopNode:XML = DIBCommon.tocNodeTemplate.copy();
			tocTopNode.@name = this._name;
			tocTopNode.@page = this._pageID;
			
			if (_childNodes)
			{
				for each (var tocNode:ITOCNode in _childNodes)
				{
					tocTopNode.appendChild(tocNode.save());
				}
			}
			
			return tocTopNode;
		}				
		
		public function appendChild(node:ITOCNode):void
		{
			_childNodes ||= new Vector.<ITOCNode>();
			_childNodes.push(node);
		}
		
		public function dispose():void
		{
			_disposeNode();			
			
			_parent = null;
		}
		
		private function _disposeNode():void
		{
			for each (var node:IDisposable in _childNodes)
			{
				node.dispose();
			}
			
			_childNodes = null;
		}
	}
}