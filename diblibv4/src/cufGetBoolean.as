/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package 
{

    /**
     * Unknown input validation and formatting for boolean values.
     *
     * @param raw
     *				the raw data.
     * @param def
     *				the default value.
     * @return formatted data.
     */
    public function cufGetBoolean(raw:*, def:Boolean = false):Boolean
    {
        if (raw != null)
        {
            return String(raw) == "true";
        }
        else
        {
            return def;
        }
    }
}
