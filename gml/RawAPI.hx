package gml;

/**
 * ...
 * @author YellowAfterlife
 */
#if (sfgml_next)
typedef RawAPI = gml.__macro.GmlAPI2;
#else
typedef RawAPI = gml.__macro.GmlAPI1;
#end
