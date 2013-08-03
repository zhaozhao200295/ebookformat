/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.utils
{
    import flash.utils.ByteArray;
    import mx.utils.SHA256;

    public class HashUtil
    {
        public static function toSHA256(input:String):String
        {
            var byteArray:ByteArray = new ByteArray();
            byteArray.writeUTFBytes(input);
            byteArray.position = 0;

            return SHA256.computeDigest(byteArray);
        }

    }
}