// This script should be run by Adobe Illustrator on a design file containing// text strings with bracketed tags <hey>.//// This script extracts these tags and places them in a data file:// /output/<original name>_tags.jsn.  Users can get these tags and assign replacement text,// or other things to each tag, place this in: /output/<original name>/_data.jsn file.//// SearchAndReplace.jsx is the script file// responsible for finding and replacing these tags with arbitrary text of an arbitrary color,// etc.#include "~/design_customization/app/assets/javascripts/json2.jsx"var tagsArray = [];if(documents.length > 0){  var textRefs = activeDocument.textFrames;  var originalFolder = activeDocument.fullName.path;  if(textRefs.length > 0)  {    for (var i = 0 ; i < textRefs.length; i++)    {      var textLines = textRefs[i].lines;        if( textLines.length > 0 )        {                for( var x = 0; x < textLines.length; x++ )                {                    var l = textLines[ x ];                    if( l.contents.indexOf( "<" ) > -1 )                    {                        var s = l.contents;                        s = s.replace( "<", "" );                        s = s.replace( ">", "" );                        s = s.replace( / /g, "" );                        tagsArray.push( s );                    }                 } // each line        } // if there are lines    } // each text frame  } // if there are frames   var fileName = activeDocument.name;   fileName = fileName.slice(0, -3);   fileName = originalFolder + "/output/" + fileName + "_tags.jsn";   var writeFile = File( fileName );   out = writeFile.open('w', undefined, undefined);   writeFile.encoding = "UTF-8";   writeFile.lineFeed = "Macintosh";   writeFile.writeln( JSON.stringify( tagsArray ) );   writeFile.close();   activeDocument.close();} // if there are documents