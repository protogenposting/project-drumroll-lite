// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function array_has(array,value){
	for(var i=0;i<array_length(array);i++)
	{
		if(array[i]==value)
		{
			return true
		}
	}
	return false
}