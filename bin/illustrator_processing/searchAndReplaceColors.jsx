
#include "~/design_customization/app/assets/javascripts/json2.jsx"function hexToRgb(hex) {  var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);  return result ? {      r: parseInt(result[1], 16),      g: parseInt(result[2], 16),      b: parseInt(result[3], 16)  } : null;}function getPNGOptions(){  var pngExportOpts = new ExportOptionsPNG24();  pngExportOpts.antiAliasing = true;  pngExportOpts.artBoardClipping = true;  //pngExportOpts.horizontalScale = 100.0;  //pngExportOpts.matte = true;  //pngExportOpts.matteColor = 0, 0, 0;  pngExportOpts.saveAsHTML = false;  pngExportOpts.transparency = true;  //pngExportOpts.verticalScale = 100.0;  return pngExportOpts;}var basePath = activeDocument.path;var docName = activeDocument.name;docName = docName.slice( 0, -3 ); // trim the last three characters// Load the file containing prompts mapped to replacement text.var dataFileName = basePath + "/" + docName + "_data.jsn";var charStyle, charAttr, aColor, tempName;var read_file, s, data;try {  read_file = File( dataFileName );  read_file.open( 'r', undefined, undefined );  s = read_file.read();  read_file.close();} catch( e ){  alert( 'could not open data file.' );}try {  data = JSON.parse( s );} catch( e ){  alert( 'could not parse data file.  s: ' + s );}var ALL_COLOR_SETTINGS = data.color_settings;//alert( 'ALL_COLOR_SETTINGS: ' + JSON.stringify( ALL_COLOR_SETTINGS ) );function is_pretty_close( a,  b ){  var bReturn = false;  var dif = Math.abs( a - b );  if( dif < 0.001 ) {    bReturn = true;  }  return bReturn;}function find_in_settings( color ){  var key;  var bFound = false;  for ( key in ALL_COLOR_SETTINGS )  {    if (ALL_COLOR_SETTINGS.hasOwnProperty(key)) {      if( is_pretty_close( parseFloat( ALL_COLOR_SETTINGS[key].orig_c ), color.cyan ) &&          is_pretty_close( parseFloat( ALL_COLOR_SETTINGS[key].orig_m ), color.magenta ) &&          is_pretty_close( parseFloat( ALL_COLOR_SETTINGS[key].orig_y ), color.yellow ) &&          is_pretty_close( parseFloat( ALL_COLOR_SETTINGS[key].orig_k ), color.black ) )      {        bFound = true;        break;      }    }  }  if( bFound )  {    return key;  }  else  {    return null;  }}function is_valid_cmyk( settings ){  var bValid = false;  if( typeof(settings.new_c) == 'number' &&      typeof(settings.new_m) == 'number' &&      typeof(settings.new_y) == 'number' &&      typeof(settings.new_k) == 'number' )  {    bValid = true;  }  return bValid;}function get_new_color( key ){  var settings = ALL_COLOR_SETTINGS[ key ];  if( is_valid_cmyk( settings ) )  {    newColor = new CMYKColor();    newColor.cyan = settings.new_c;    newColor.magenta = settings.new_m;    newColor.yellow = settings.new_y;    newColor.black = settings.new_k;  }  else  {    var rgb = hexToRgb( settings.new_hex );    newColor = new RGBColor();    newColor.red = rgb.r;    newColor.blue = rgb.b;    newColor.green = rgb.g;  }  return newColor;}function process_color( color ){  var colorType = color.typename;  if( colorType === 'GradientColor' )  {    var grad = color.gradient;    var stops = grad.gradientStops;    var gradStopsCount = stops.length;    for( var stopIndex = 0; stopIndex < gradStopsCount; stopIndex++ )    {      var stop = stops[ stopIndex ];      var key = find_in_settings( stop.color );      if( key ) {        stop.color = get_new_color( key );      }    }  }}if(documents.length > 0){  var pageItems = activeDocument.pageItems;  var pageItemCount = pageItems.length;  for( var itemIndex = 0; itemIndex < pageItemCount; itemIndex++ )  {    var item = pageItems[ itemIndex ];    try    {      var color = item.fillColor;      if( color )      {        process_color( color );      }    }    catch( e )    {    }    try    {      color = item.strokeColor;      if( color )      {        process_color( color );      }    }    catch( e )    {    }  } // for each page item} // if there are documents



 // Export to JPG

 var jpgFileName = basePath + "/output/" + docName + "_mod.jpg";
 saveInFile = new File( jpgFileName );

 var options = new ExportOptionsJPEG();
 options.antiAliasing = true;
 options.artBoardClipping = true;

 activeDocument.exportFile( saveInFile, ExportType.JPEG, options );
 activeDocument.exportFile( saveInFile, ExportType.PNG24, getPNGOptions() );


 // Save the modified AI file
 modAIFileName = basePath + "/output/" + docName + "_mod.ai";
 saveInFile = new File( modAIFileName );
 activeDocument.saveAs( saveInFile );


 activeDocument.close();
