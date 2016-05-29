
#include "~/design_customization/app/assets/javascripts/json2.jsx"// Each collage is an object representing all of the files in a given// folder.  The getFile() method cycles through all of the files.var COLLAGES = {};function hexToRgb(hex) {  var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);  return result ? {      r: parseInt(result[1], 16),      g: parseInt(result[2], 16),      b: parseInt(result[3], 16)  } : null;}function getCollage( path ){  c = COLLAGES[ path ];  // every path gets its own collage  if( typeof c == 'undefined' )  {    c = makeCollage();    c.init( path );    COLLAGES[ path ] = c;  }  return c;}function makeCollage(){  var collage = (function () {    var files;    var i = 0;    increment = function() {      if( i + 1 < files.length )      {        i++;      }      else      {        i = 0;      }    };    return {      // public methods      init: function ( path ) {        var folder = new Folder( path );        files = folder.getFiles();      },      getFile: function () {        var fileName = files[ i ];        f = new File( fileName );        increment();        return f;      }    };  })();  return collage;}var basePath = activeDocument.path;var docName = activeDocument.name;docName = docName.slice( 0, -3 ); // trim the last three characters// Load the file containing prompts mapped to replacement text.var dataFileName = basePath + "/" + docName + "_data.jsn";var charStyle, charAttr, aColor, tempName;var read_file = File( dataFileName );read_file.open( 'r', undefined, undefined );var s = read_file.read();read_file.close();var data;data = JSON.parse( s );var allImageSettings = data.image_settings;//alert( s );if(documents.length > 0){  var placedItems = activeDocument.placedItems;    if(placedItems.length > 0)    {      for (var i = 0 ; i < placedItems.length; i++)      {        var item = placedItems[i];        var itemName = item.name        var itemSettings = allImageSettings[ itemName ];        if( itemSettings != null )        {          var type = itemSettings.type;          var newPath, c;          if( type == 'ReplacementImage' )          {            newPath = itemSettings.path;            if( newPath != '' )            {              f = new File( newPath );              item.file = f;            }          }          if( type == 'Collage' )          {            newPath = itemSettings.path;            if( newPath != '' )            {              c = getCollage( newPath );              f = c.getFile();              item.file = f;            }          }        } // got item settings      } // each placed item    } // if there are placed items   // Export to JPG   var jpgFileName = basePath + "/output/" + docName + "_mod.jpg";   saveInFile = new File( jpgFileName );   var options = new ExportOptionsJPEG();   options.antiAliasing = true;   options.artBoardClipping = true;   // This is necessary for artemix, but risky cuz the guide names vary   //var guideLayer = app.activeDocument.layers.getByName("Design Guides");   //if( guideLayer != null )   //{   //   guideLayer.visible = false;   //}   activeDocument.exportFile( saveInFile, ExportType.JPEG, options );   // Save the modified AI file   modAIFileName = basePath + "/output/" + docName + "_mod.ai";   saveInFile = new File( modAIFileName );   activeDocument.saveAs( saveInFile );   activeDocument.close();} // if there are documents
