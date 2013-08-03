/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.dcl
{
	import com.dtedu.dcl.interfaces.IDCLComponent;
	import com.dtedu.dcl.interfaces.IDCLStyleSheet;
	import com.dtedu.digipub.interfaces.IView;
	import com.dtedu.trial.interfaces.IDisposable;
	import com.dtedu.trial.utils.DictionaryUtil;
	import com.dtedu.trial.utils.StringUtil;
	
	import flash.utils.Dictionary;

    /**
     * This class provides management and evaluation of styles.
     *
     * <p>
     * It can be used to parse and store style definitions, as well as to apply the
     * stored definitions to objects.
     * </p>
     */
    internal class DCLStyleSheet implements IDCLStyleSheet, IDisposable
    {
		private static function __addStyleDefinitions(styles:Dictionary, newDefinitions:String):void
		{						
			for each (var definition:String in newDefinitions.split(";"))
			{
				definition = StringUtil.trim(definition);
				// Skip blank definitions.
				if (!definition)
				{
					continue;
				}
				
				var defParts:Array = definition.split(":", 2);
				// Skip incomplete definitions.
				if (defParts.length < 2)
				{
					continue;
				}
				
				var defName:String = StringUtil.trim(defParts[0]);
				var defValue:String = StringUtil.trim(defParts[1]);
				styles[defName] = defValue;
			}			
		}
		
        /**
         * Used to keep track of known styles.
         *
         * <p>
         * This contains objects, which each contain a Dictionary of known styles
         * for the current path, plus another dictionary mapping to children.
         * </p>
         */
        private var styles:StyleNode;

        /**
         * Creates a new styles managing class.
         *
         * @param styleSheet
         *				if given, all styles from the given stylesheet are copied
         *				into the new one.
         */
        public function DCLStyleSheet(styleSheet:IDCLStyleSheet = null)
        {
            if (styleSheet && (styleSheet is DCLStyleSheet))
            {
                styles = DCLStyleSheet(styleSheet).styles.clone();
            }
            else
            {
                styles = new StyleNode();
            }
        }

        /**
         * @inheritDoc
         */
        public function dispose():void
        {
            styles && styles.dispose();

            styles = null;
        }

        /**
         * Adds a list of styles.
         *
         * <p>
         * Styles must be in CSS-like format, i.e. the class name or element name
         * must be followed by curly brackets encapsulating the attribute values,
         * which must be in <code>attributeName: value</code> format, separated by
         * semicolons (;).
         * </p>
         *
         * @param input
         *				the style definition to parse.
         */
        public function addStyleDefinitions(input:String):void
        {
            if (!input)
            {
                return;
            }
            // Remove newlines.
            input = input.replace(/\n|\r/g, "");

            // Remove comments.
            input = input.replace(/\/\*.*?\*\//g, "");

            // Convert tabs to spaces.
            input = input.replace(/\t/g, " ");

            // Get style classes
            var clazzes:Array = input.match(new RegExp("([^\{]+\{[^\}]*\})", "g"));
            for each (var clazz:String in clazzes)
            {
                // Get parts.
                var parts:Array = clazz.match(new RegExp("([^\{]+)\{([^\}]*)\}"));
                // Check if input was valid.
                if (!parts || parts.length < 3)
                {
                    continue;
                }

                // Get the parts.
                var targets:Array = StringUtil.trim(parts[1]).split(",");
                var definitions:String = StringUtil.trim(parts[2]);

                // This takes care of comma separated multiple classes with the
                // same definitions.
                for each (var target:String in targets)
                {
                    target = StringUtil.trim(target);
                    if (!target)
                    {
                        continue;
                    }
                    // Process the target / find where to insert in our dictionary.
                    var targetNode:StyleNode = styles;
                    for each (var path:String in target.split(" "))
                    {
                        path = StringUtil.trim(path);
                        // Skip blank entries.
                        if (!path)
                        {
                            continue;
                        }
                        if (targetNode.children[path] == null)
                        {
                            targetNode.children[path] = new StyleNode();
                        }
                        targetNode = targetNode.children[path];
                    }
					
					__addStyleDefinitions(targetNode.styles, definitions);                    
                }
            }
        }

        /**
         * @inheritDoc
         */
        public function applyStyles(object:IDCLComponent):void
        {            
            if (!object)
            {
                return;
            }					

            // Build the path to the element.
            var path:Array = [ object ];
            var walker:IDCLComponent = object;
            while (walker = walker.parent)
            {
				path.unshift(walker);
            }

            // Accumulator for our styles.
            var acc:Dictionary = new Dictionary();

            // Walk the whole path back down, starting at the root of the style
            // tree. If we can follow the style tree down to the element type, we
            // can apply the style.
            var pl:int = path.length - 1;
            for (var i:int = pl; i >= 0; --i)
            {
                _matchStyleTree(path, i, styles, acc);
            }
			
			// Process inline style
			var inlineStyles:String = object.inlineStyle;
			
			if (inlineStyles)
			{
				__addStyleDefinitions(acc, inlineStyles);
			}

            // Done, all styles accumulated, apply them to the object.
            for each (var attribute:String in DictionaryUtil.getKeys(acc))
            {
                // Only apply attributes not manually set for the element.
                if (object.hasDynamicProperty(attribute))
                {
                    continue;
                }
				
				object.setDynamicProperty(attribute, acc[attribute], true);
            }
        }
		
		public function applyDisplayObjectStyles(object:IView, styleName:String, item:Array):void
		{
			if (!object)
			{
				return;
			}
			
			var styleNode:StyleNode = styles.children[styleName];
			
			if(!styleNode)
			{
				return;
			}
			
			for each(var key:String in item)
			{
				object[key] = styleNode.styles[key];
			}
		}

        /**
         * Match the path against the style tree and get applying styles.
         *
         * @param path
         *				the path to match.
         * @param pos
         *				the current position in the path (when walking down).
         * @param styleNode
         *				the current node in the style tree looked at.
         * @param acc
         *				an accumulator into which to put styles. Previously found
         *				styles will be overwritten.
         */
        private function _matchStyleTree(path:Array, pos:uint, styleNode:StyleNode, acc:Dictionary):void
        {
            if (pos < path.length)
            {
                // Not there yet... check what children come into question and walk
                // down those paths (if they exist).
                var current:IDCLComponent = path[pos];
                // Lowest priority: the element type itself.
                var childCandidates:Array = [ current.type ];
                // Medium priority: unbound / general classes.
                var style:String;
                for each (style in current.styleClasses)
                {
                    childCandidates.push("." + style);
                }
                // High priority: element classes.
                for each (style in current.styleClasses)
                {
                    childCandidates.push(current.type + "." + style);
                }
                // Max priority: named elements (equivalent to HMTL/CSS ids)
                if (current.id)
                {
                    childCandidates.push("#" + current.id);
                    for each (style in current.styleClasses)
                    {
                        childCandidates.push("#" + current.id + "." + style);
                    }
                }
                // Check which of the candidates we can satisfy.
                for each (var childCandidate:String in childCandidates)
                {
                    if (styleNode.children[childCandidate])
                    {
                        _matchStyleTree(path, pos + 1, styleNode.children[childCandidate], acc);
                    }
                }
            }
            else
            {
                // We made it to the end! Apply styles of the current node.
                for each (var key:String in DictionaryUtil.getKeys(styleNode.styles))
                {
                    acc[key] = styleNode.styles[key];
                }
            }
        }
		
		
    }
}

import com.dtedu.trial.interfaces.IDisposable;

import flash.utils.Dictionary;

internal class StyleNode implements IDisposable
{
    public var styles:Dictionary;

    public var children:Dictionary;

    public function StyleNode(styles:Dictionary = null)
    {
        this.styles = styles || new Dictionary();
        children = new Dictionary();
    }

    public function clone():StyleNode
    {
        var newNode:StyleNode = new StyleNode(Dictionary(cufDeepCopy(styles)));
        for (var path:String in children)
        {
            newNode.children[path] = StyleNode(children[path]).clone();
        }
        return newNode;
    }

    public function dispose():void
    {
        if (children)
        {
            for (var k:* in children)
            {
                StyleNode(children[k]).dispose();
                delete children[k];
            }
        }

        styles = null;
        children = null;
    }
}
