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
    public function cufGetDateTime(raw:*, def:Date = null):Date
    {
        if (raw != null)
        {
            return new Date(Date.parse(raw));
        }
        else
        {
            return def;
        }
    }
}
