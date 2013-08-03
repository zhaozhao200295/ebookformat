/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package 
{

    /**
     * Unknown input validation and formatting floating point values.
     *
     * @param raw
     *				the raw data.
     * @param def
     *				the default value.     
     * @return formatted data.
     */
    public function cufGetNumber(raw:*, def:Number = 0):Number
    {
        if (raw != null)
        {
            return parseFloat(String(raw));            
        }
        else
        {
            return def;
        }
    }
}
