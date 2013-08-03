package com.dtedu.digipub.commands.page
{
	import com.dtedu.digipub.commands.page.DCLCommand;
	
	public class AddDCLCommand extends DCLCommand
	{
		public function AddDCLCommand()
		{
			super();
		}
		
		protected function add():void
		{
			/*var matrix:Object;			
			var dclc:IDCLComponent;
			for each (var note:IBookCommand in _notes) 
			{
				if(note.data)
				{
					dclc = focusPage.factory.createComponentFromXML(XML(note.data));
				}
				else
				{
					try
					{						
						dclc = focusPage.factory.createComponentByName(note.matrix["type_state"]);
						note.data = dclc.saveToXML();
					} 
					catch(error:Error) 
					{
						return;
					}					
				}	
				matrix = note.matrix;
				for(var key:String in matrix) 
				{
					var value:Object = matrix[key]
					if(key != "type_state" && value != "0")
					{
						dclc.setDynamicProperty(key, matrix[key]);
					}
				}
				(!note.id)?(note.id = dclc.id):(dclc.id=note.id);
				focusPage.addElements(dclc);
				bookViewer.bookController.bookFile.manifest.addElementXMLNode( dclc );
				focusPage.savePage();
			}
			*/
		}
	}
}