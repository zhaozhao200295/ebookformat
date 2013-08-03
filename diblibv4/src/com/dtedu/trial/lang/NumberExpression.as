/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.lang
{
    import flash.utils.Dictionary;

    /**
     * This class can be used to generate an operation tree from a term writtin in
     * infix notation.
     *
     * <p>
     * Supported operators are: +, -, *, /, % (mod) and ^ (pow). Unary operators are
     * not supported, so for a leading negative number write 0-number.
     * </p>
     *
     * <p>
     * Normal, round brackets, i.e. "(",and ")" are supported.
     * </p>
     *
     * <p>
     * When evaluating, it is possible to give a list of variables to use. If an
     * unknown variable is encountered, it will be assumed to be 0.
     * </p>
     */
    public class NumberExpression
    {

        // ---------------------------------------------------------------------- //
        // Constants
        // ---------------------------------------------------------------------- //

        /**
         * Valid operators, in decreasing importance.
         */
        private static const operators_:Array = [ "^", "*/%", "+-", "!?" ];

        /**
         * Declaration of brackets.
         */
        private static const brackets_:Array = [ "(", ")" ];

        /**
         * Node cache - this is used to reuse nodes for known expressions, reducing
         * memory footprint considerably.
         */
        private static const nodeCache_:Dictionary = new Dictionary();

        // ---------------------------------------------------------------------- //
        // Variables
        // ---------------------------------------------------------------------- //

        /**
         * Data of this node, either an operator or a number.
         */
        private var data_:*;

        /**
         * Leaf node (variable or number)
         */
        private var isLeaf_:Boolean;

        /**
         * Expression data to the left of this node, if the node is an operator.
         */
        private var left_:NumberExpression;

        /**
         * Expression data to the right of this node, if the node is an operator.
         */
        private var right_:NumberExpression;


        // ---------------------------------------------------------------------- //
        // Construction
        // ---------------------------------------------------------------------- //

        /**
         * Do not use this directly. Use the make() function instead.
         * @see #make(String)
         */
        public function NumberExpression(expression:String)
        {
            init(expression);
        }

        /**
         * Create a new tree from an expression.
         *
         * <p>
         * This has to be a mathematical expression. Known operators are:<br/>
         * +, -, *, /, % (modulo) and ^ (power).
         * </p>
         *
         * @param expression
         *				the expression to parse.
         * @throws ArgumentError Thrown if the expression somehow invalid.
         */
        public static function make(expression:String):NumberExpression
        {
            expression = expression.replace(/\s/g, "");
            var node:NumberExpression = makeInternal(expression);
            if (node.isLeaf_ || node.boundVariables.length)
            {
                return node;
            }
            else
            {
                return nodeCache_[expression] = NumberExpression.make(node.evaluate().toString());
            }
        }

        /**
         * Used internally to avoid unnecessary re-cleaning of the input.
         */
        private static function makeInternal(expression:String):NumberExpression
        {
            return nodeCache_[expression] ||= new NumberExpression(expression);
        }

        /**
         * Helper method for node init, allowing recursive calls (only for brackets
         * and because I'm lazy...)
         *
         * @param expr
         *				the expression to parse.
         * @throws ArgumentError Thrown if the expression somehow invalid.
         */
        private function init(expression:String):void
        {
            // Test if it's empty.
            if (!expression)
            {
                throw new ArgumentError("Invalid empty expression (maybe empty brackets).");
            }

            // Keeping track of the number of open brackets.
            var openBrackets:int = 0;

            // Position of the found operator and its rank.
            var operatorPos:int = -1, operatorRank:int = -1;

            // Search the first operator with the lowest rank.
            var el:int = expression.length;
            for (var i:int = 0; i < el; ++i)
            {
                // Current character as a string for easier working.
                var chr:String = expression.charAt(i);

                // Check what we got.
                if (chr == brackets_[0])
                {
                    // Opening bracket.
                    ++openBrackets;
                }
                else if (openBrackets > 0)
                {
                    if (chr == brackets_[1])
                    {
                        // Closing bracket.
                        if (--openBrackets < 0)
                        {
                            throw new ArgumentError("Invalid input, unexpected closing bracket.");
                        }
                    }
                }
                else
                {
                    // Operator? Check all.
                    var ol:int = operators_.length;
                    for (var rank:int = 0; rank < ol; ++rank)
                    {
                        if (String(operators_[rank]).indexOf(chr) >= 0)
                        {
                            if (operatorRank <= rank)
                            {
                                operatorRank = rank;
                                operatorPos = i;
                            }
                            break;
                        }
                    }
                } // else -> Assume it's a number or variable.
            }

            if (openBrackets > 0)
            {
                throw new ArgumentError("Invalid input, missing closing bracket.");
            }

            if (operatorPos > 0)
            {
                // Found an operator, split the expression at it's position.
                left_ = NumberExpression.makeInternal(expression.substring(0, operatorPos));
                right_ = NumberExpression.makeInternal(expression.substring(operatorPos + 1));
                data_ = expression.charAt(operatorPos);
            }
            else
            {
                // No operator found, check if this might be an expression enclosed
                // in brackets. If yes remove the outermost ones and try again.
                if (expression.charAt(0) == brackets_[0] && expression.charAt(expression.length - 1) == brackets_[1])
                {
                    init(expression.substring(1, expression.length - 1));
                }
                else
                {
                    // Check if the data is valid.
                    if (expression.match(/^\-?[0-9]*\.?[0-9]*$/))
                    {
                        // Already a number.
                        data_ = Number(expression);
                        isLeaf_ = true;
                    }
                    else if (expression.match(/^\-?[a-zA-Z_]*$/))
                    {
                        if (expression.charAt(0) == "-")
                        {
                            // Negative variable.
                            init("0" + expression);
                            return;
                        }
                        // Variable.
                        data_ = expression;
                        isLeaf_ = true;
                    }
                    else
                    {
                        throw new ArgumentError("Remaining expression invalid: '" + expression + "'.");
                    }
                }
            }
        }


        // ---------------------------------------------------------------------- //
        // Evaluation
        // ---------------------------------------------------------------------- //

        /**
         * A list of all variables bound in this expression (i.e. variables used in
         * the leaf nodes of the expression tree with this node at it's root).
         *
         * <p>
         * IMPORTANT: the returned array is generated anew on every call to this
         * getter, so store it in a temporary variable when used more than once.
         * </p>
         */
        public function get boundVariables():Array
        {
            if (isLeaf_)
            {
                if (data_ is Number)
                {
                    return [];
                }
                else
                {
                    return [ String(data_)];
                }
            }
            else
            {
                return left_.boundVariables.concat(right_.boundVariables);
            }
        }

        /**
         * Evaluates the node, by evaluating the left and right part of the node,
         * and combining the parts based on the operator, or, if this is a number
         * returns the number's value.
         *
         * <p>
         * If the stored data is found in the variables dictionary, the value from
         * the dictionary is used.
         * </p>
         *
         * @param variables
         *				a list of variables to use.
         * @return the evaluated expression.
         */
        public function evaluate(variables:Dictionary = null):Number
        {
            if (isLeaf_)
            {
                if (data_ is Number)
                {
                    return Number(data_);
                }
                else
                {
                    if (variables && variables[data_])
                    {
                        return Number(variables[data_]);
                    }
                }
            }
            else
            {
                switch (String(data_).charAt(0))
                {
                    case '+':
                        return left_.evaluate(variables) + right_.evaluate(variables);
                    case '-':
                        return left_.evaluate(variables) - right_.evaluate(variables);
                    case '*':
                        return left_.evaluate(variables) * right_.evaluate(variables);
                    case '/':
                        return left_.evaluate(variables) / right_.evaluate(variables);
                    case '%':
                        return left_.evaluate(variables) % right_.evaluate(variables);
                    case '^':
                        return Math.pow(left_.evaluate(variables), right_.evaluate(variables));                    
                }
            }
            // Variable with no value or broken node (unknown operator).
            return 0;
        }
    }
}
