#include "~/design_customization/app/assets/javascripts/json2.jsx"function hexToRgb(hex) {  var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);  return result ? {      r: parseInt(result[1], 16),      g: parseInt(result[2], 16),      b: parseInt(result[3], 16)  } : null;}function is_pretty_close( a,  b ){  var bReturn = false;  var dif = Math.abs( a - b );  if( dif < 0.001 ) {    bReturn = true;  }  return bReturn;}function indexInColorsArray( color ){  var bFound = false;  var i;  for( i = 0; i < COLORS.length; i++ )  {    if( is_pretty_close( COLORS[i].c, color.c) &&        is_pretty_close( COLORS[i].m, color.m) &&        is_pretty_close( COLORS[i].y, color.y) &&        is_pretty_close( COLORS[i].k, color.k) )    {      bFound = true;      break;    }  }  if( bFound ) {    return i;  }  else  {    return -1;  }}function existsInColorsArray( color ){  var i = indexInColorsArray( color );  var bFound = false;  if( i == -1 ) {    bFound = false;  }  else  {    bFound = true;  }  return bFound;}var COLORS = [];var RGB_DOC;var ORIGINAL_DOC;function is_valid_cmyk( o ){  var bValid = false;  if( typeof(o.c) == 'number' &&      typeof(o.m) == 'number' &&      typeof(o.y) == 'number' &&      typeof(o.k) == 'number' )  {    bValid = true;  }  return bValid;}function get_color_json( color ){  var c = color.cyan;  var m = color.magenta;  var y = color.yellow;  var k = color.black;  var r = 0;  var g = 0;  var b = 0;  try  {    // translate the cmyk color to rgb//    RGB_DOC.defaultStrokeColor = color;//    var transColor = RGB_DOC.defaultStrokeColor;//    r = transColor.red;//    g = transColor.green;//    b = transColor.blue;  }  catch( e )  {  }  if( (r === 0) && (g === 0) && (b === 0) )  {    r = 255 * (1 - c/100 ) * ( 1 - k/100 );    g = 255 * (1 - m/100 ) * ( 1 - k/100 );    b = 255 * (1 - y/100 ) * ( 1 - k/100 );//    alert( 'my rgb: ' + r + ', ' + g + ', ' + b );  }  var o = {};  o.c = c;  o.m = m;  o.y = y;  o.k = k;  o.r = r;  o.g = g;  o.b = b;  return o;}function writeColorToArray( color ){//  alert( 'writing color: ' + color );  o = get_color_json( color );//  alert( 'o: ' + JSON.stringify( o ) );  if( is_valid_cmyk( o ) )  {    if( !existsInColorsArray( o ) ) {      COLORS.push( o );    }  }}function logColor( color ){  var colorType = color.typename;  if( colorType === 'GradientColor' )  {    // gradient colors are actually a set of colors//    alert( 'got a gradient color' );    var grad = color.gradient;    var stops = grad.gradientStops;    var gradStopsCount = stops.length;//    alert( 'gradStopsCount: ' + gradStopsCount );    for( var stopIndex = 0; stopIndex < gradStopsCount; stopIndex++ )    {      var stop = stops[ stopIndex ];      var stopColor = stop.color;      writeColorToArray( stopColor );    } // for each stop  } // color is a gradientColor  else  {    // color is not a gradientColor    writeColorToArray( color )  }}function logSwatch( swatch ){  var color = swatch.color;  var o = get_color_json( color );  var i = indexInColorsArray( o );  if( i === -1 )  {    logColor( color );    i = indexInColorsArray( o );  }  o = COLORS[ i ];  try  {    var sName = swatch.name;    o.name = sName;  }  catch( e )  {  }}if(documents.length > 0){  ORIGINAL_DOC = activeDocument;  // Use this doc to convert cmyk to rgb  RGB_DOC = app.documents.add( DocumentColorSpace.RGB );  var pageItems = ORIGINAL_DOC.pageItems;  var pageItemCount = pageItems.length;//  alert( 'pageItemCount: ' + pageItemCount );  for( var itemIndex = 0; itemIndex < pageItemCount; itemIndex++ )  {    var item = pageItems[ itemIndex ];    try    {      var fillColor = item.fillColor;      if( fillColor ) {        logColor( fillColor ); }    }    catch( e )    {    }    try    {      var strokeColor = item.strokeColor;      if( strokeColor ) {        logColor( strokeColor ); }    }    catch( e )    {    }  } // for each pageItem  var swatches = ORIGINAL_DOC.swatches;  var swatchesCount = swatches.length;  for( var swatchIndex = 0; swatchIndex < swatchesCount; swatchIndex++ )  {    var swatch = swatches[ swatchIndex ];    logSwatch( swatch );  }  var originalFolder = ORIGINAL_DOC.fullName.path;  var fileName = ORIGINAL_DOC.name;  fileName = fileName.slice(0, -3);  fileName = originalFolder + "/output/" + fileName + "_all_colors.jsn";  var writeFile = File( fileName );  out = writeFile.open('w', undefined, undefined);  writeFile.encoding = "UTF-8";  writeFile.lineFeed = "Macintosh";  writeFile.writeln( JSON.stringify( COLORS, null, 2 ) );  writeFile.close();  ORIGINAL_DOC.close( SaveOptions.DONOTSAVECHANGES );  RGB_DOC.close( SaveOptions.DONOTSAVECHANGES );} // if there are documents