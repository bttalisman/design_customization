// see extractTags.jsx
#include "~/design_customization/app/assets/javascripts/json2.jsx"function hexToRgb(hex) {    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);    return result ? {        r: parseInt(result[1], 16),        g: parseInt(result[2], 16),        b: parseInt(result[3], 16)    } : null;}var basePath = activeDocument.path;var docName = activeDocument.name;docName = docName.slice( 0, -3 ); // trim the last three characters '.ai'// Load the file containing prompts mapped to replacement text.var dataFileName = basePath + "/" + docName + "_data.jsn";var charStyle, charAttr, aColor, tempName;var read_file = File( dataFileName );read_file.open( 'r', undefined, undefined );var s = read_file.read();read_file.close();var data;data = JSON.parse( s );// alert( 's: ' + s );var allTagSettings = data[ 'tag_settings' ];if(documents.length > 0){  var textRefs = activeDocument.textFrames;   if(textRefs.length > 0)   {      for (var i = 0 ; i < textRefs.length; i++)      {            var textLines = textRefs[i].lines;//            alert( 'textLines.length: ' + textLines.length );            if( textLines.length > 0 )            {                    for( var x = 0; x < textLines.length; x++ )                    {                        var l = textLines[ x ];                        if( l.contents.indexOf( "<" ) > -1 )                        {                            var key = l.contents;                            var replaceText;                            var newColor;                            // alert( 'found! key: ' + key );                            key = key.replace( "<", "" );                            key = key.replace( ">", "" );                            key = key.replace( / /g, "" );                            // alert( 'key: ' + key );                            // alert( 'allTagSettings: ' + allTagSettings );                            if( allTagSettings[key] == null )                            {                              continue;                            }                            replaceText = allTagSettings[ key ][ 'replacement_text' ];                            newColor = allTagSettings[ key ][ 'text_color' ]                            if( (newColor != '') && (newColor != null) )                            {                              tempName = 'temp' + newColor; // something unique?                              charStyle = app.activeDocument.characterStyles.add( tempName );                              charAttr = charStyle.characterAttributes;// http://jongware.mit.edu/iljscs6html/iljscs6/pc_CharacterAttributes.html                              aColor = new RGBColor();                              var red = hexToRgb( newColor ).r;                              var green = hexToRgb( newColor ).g;                              var blue = hexToRgb( newColor ).b;  //                            alert( 'red: ' + red );  //                            alert( 'green: ' + green );  //                            alert( 'blue: ' + blue );                              aColor.red = red;                              aColor.green = green;                              aColor.blue = blue;                              charAttr.fillColor = aColor;                              charStyle.applyTo(textRefs[ i ].textRange);                            }                            l.contents = replaceText;                        }                     } // each line            } // if there are lines      } // each text frame   } // if there are frames   // Export to JPG   var jpgFileName = basePath + "/output/" + docName + "_mod.jpg";   saveInFile = new File( jpgFileName );   var options = new ExportOptionsJPEG();   options.antiAliasing = true;   options.artBoardClipping = true;   // This is necessary for artemix, but risky cuz the guide names vary   //var guideLayer = app.activeDocument.layers.getByName("Design Guides");   //if( guideLayer != null )   //{   //   guideLayer.visible = false;   //}   activeDocument.exportFile( saveInFile, ExportType.JPEG, options );   // Save the modified AI file   modAIFileName = basePath + "/output/" + docName + "_mod.ai";   saveInFile = new File( modAIFileName );   activeDocument.saveAs( saveInFile );   activeDocument.close();} // if there are documents
