// This script should be run by Adobe Illustrator on a design file containing// placed images with unique names.//// This script extracts these image names and places them in a data file:// /output/<original name>_images.jsn.  Users can get these names and assign replacement images,// or other things, place this in: /output/<original name>/_data.jsn file.//// SearchAndReplaceImages.jsx is the script file// responsible for finding and replacing these images with other images.#include "/Users/bent/customization/app/assets/javascripts/json2.jsx"#include "/Users/bent/customization/app/assets/javascripts/include-for-ai.js"var itemsArray = [];if(documents.length > 0){  var placedItems = activeDocument.placedItems;//  alert( 'placedItems.length: ' + placedItems.length );  var originalFolder = activeDocument.fullName.path;  if(placedItems.length > 0)  {    for (var i = 0 ; i < placedItems.length; i++)    {      var item = placedItems[i];      var item_name = item.name;      if( item_name != '' )      {        var index = indexOf( itemsArray, item_name );        if( index === -1 )        {          itemsArray.push( item_name );        }      }    } // each text frame  } // if there are frames   var fileName = activeDocument.name;   fileName = fileName.slice(0, -3);   fileName = originalFolder + "/output/" + fileName + "_images.jsn";   var writeFile = File( fileName );   out = writeFile.open('w', undefined, undefined);   writeFile.encoding = "UTF-8";   writeFile.lineFeed = "Macintosh";//   alert( JSON.stringify( itemsArray ) );   writeFile.writeln( JSON.stringify( itemsArray ) );   writeFile.close();   activeDocument.close();} // if there are documents