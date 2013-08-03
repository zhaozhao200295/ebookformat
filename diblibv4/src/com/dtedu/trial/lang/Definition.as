/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.lang 
{	
	/**
	 * Return type for the parseDefinitions() function <code>StringUtils</code>. 
	 */
	public class Definition 
	{				
		private static var __partsPat:RegExp;		
		private static var __stringPat:RegExp;	
		private static var __argsPat:RegExp;
		
		{
			__partsPat = /(?:([^;]+)\(([^\)]*)\)\s*;?)|(?:([^;]+)\s*;?)|;/g;		
			__stringPat = /'(([^'\\]|\\.)*)'/g;	
			__argsPat = /(?:\s*([^,]+)\s*,?)|,/g;
		}
		
		public static function parseMulti(definitions:String):Vector.<Definition>
		{						
			if (!definitions)
			{
				return null;
			}
			
			var result:Vector.<Definition> = new Vector.<Definition>();
			
			var stringMatches:Array = [];
			definitions = __internalPreParse(definitions, stringMatches);
			
			// Begin parsing for definitions. This regex matches either definitions
			// with arguments, e.g. 'somedef(one, two)', those without 'asd' and
			// empty ones from a semicolon separated string. E.g. the string
			// one(a, b); two; ; three('c'); four();
			// will be parsed into 4 definitions:
			// {name: "one", args: ["a", "b"]},
			// {name: "two", args: undefined},
			// {name: "three", args: ["c"]},
			// {name: "four", args: undefined}
			// The empty definitions will be skipped (one between two and three, one
			// at the very end.			
			var partsMatch:Object;
			__partsPat.lastIndex = 0;
			while (partsMatch = __partsPat.exec(definitions))
			{
				var def:Definition = __internalParse(partsMatch, stringMatches);
				
				// Finish by creating the definition instance with the parsed data.				
				def && result.push(def);
			}
			
			return result;
		}			
		
		public static function parseOne(definitions:String):Vector.<Definition>
		{						
			if (!definitions)
			{
				return null;
			}
			
			var result:Vector.<Definition> = new Vector.<Definition>();
			
			var stringMatches:Array = [];
			definitions = __internalPreParse(definitions, stringMatches);
			
			// Begin parsing for definitions. This regex matches either definitions
			// with arguments, e.g. 'somedef(one, two)', those without 'asd' and
			// empty ones from a semicolon separated string. E.g. the string
			// one(a, b); two; ; three('c'); four();
			// will be parsed into 4 definitions:
			// {name: "one", args: ["a", "b"]},
			// {name: "two", args: undefined},
			// {name: "three", args: ["c"]},
			// {name: "four", args: undefined}
			// The empty definitions will be skipped (one between two and three, one
			// at the very end.			
			var partsMatch:Object;
			__partsPat.lastIndex = 0;
			while (partsMatch = __partsPat.exec(definitions))
			{
				var def:Definition = __internalParse(partsMatch, stringMatches);
				
				// Finish by creating the definition instance with the parsed data.				
				def && result.push(def);
			}
			
			return result;
		}			
		
		private static function __internalPreParse(definitions:String, stringMatches:Array):String
		{
			// Pattern to find string literals (i.e. 'something'), allowing for
			// escaped ' inside the string (i.e. 'some\'thing').						
			var stringMatch:Object;
			__stringPat.lastIndex = 0;
			while (stringMatch = __stringPat.exec(definitions))
			{
				// Store string value and unescape escaped characters.
				stringMatches.push(String(stringMatch[1]).replace(/\\\\/g, "\\").replace(/\\'/g, "'"));
			}
			
			// Remove strings from input and replace them with "s (to later replace
			// the values back).
			return definitions.replace(__stringPat, "'");
		}
		
		private static function __internalParse(partsMatch:Object, stringMatches:Array):Definition
		{
			// The name can either be found at index 1 or 3. It's at 1 if the
			// definition parsed had arguments, at 3 if it had none.
			var defName:String = partsMatch[1] || partsMatch[3];
			if (defName)
			{
				// Trim name.
				defName = defName.replace(/^\s+|\s+$/g, '');
			}
			// Now check (undefined would skip if this were done before trimming
			// but not "empty" names, i.e. spaces.
			if (!defName)
			{
				// Skip empty definitions.
				return null;
			}
			// Filter the arguments.
			var args:Array = [];
			var argList:String = partsMatch[2];
			if (argList)
			{
				// Arguments given, get the separate entries. The arguments must
				// be comma separated. Strings will have been replaced above, so
				// we reinsert the one bottommost from the original search stack
				// whenever we encounter a placeholder (").				
				var argsMatch:Object;
				__argsPat.lastIndex = 0;
				while (argsMatch = __argsPat.exec(argList))
				{
					// Parse argument value.
					var arg:String = argsMatch[1];
					if (arg)
					{
						// If not undefind, trim.
						arg = arg.replace(/^\s+|\s+$/g, '');
					}
					if (arg == "'")
					{
						// Placeholder, replace with actual content.
						args.push(stringMatches.shift());
					}
					else
					{
						// No placeholder, use as is.
						args.push(arg);
					}
				}
				// If the list ends with a comma, insert an additional
				// "undefined" for the right side.
				if (argList.charAt(argList.length - 1) == ",")
				{
					args.push(undefined);
				}
			}
			
			// Finish by creating the definition instance with the parsed data.
			return new Definition(defName, args);
		}
		
		/**
		 * Name of the definition.
		 */
		public var name:String;
		
		/**
		 * Arguments for the definition.
		 */
		public var args:Array;
		
		/**
		 * Create a new definition.
		 */
		public function Definition(name:String, args:Array) 
		{
			this.name = name;
			this.args = args;
		}		
	}		
}
