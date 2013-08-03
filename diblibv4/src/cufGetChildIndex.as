/**
 * Common Utility Functions
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package 
{		
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;

	public function cufGetChildIndex(container:DisplayObjectContainer, component:DisplayObject):int
	{
		if (component is IVisualElement && container is IVisualElementContainer)
		{
			return IVisualElementContainer(container).getElementIndex(IVisualElement(component));
		}
		else if (container.hasOwnProperty("rawChildren"))
		{
			return Object(container).rawChildren.getChildIndex(component);
		}
		
		return container.getChildIndex(component);			
	}	
}