
#include "~/design_customization/app/assets/javascripts/json2.jsx"



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