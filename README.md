# Design Templating and Customization

This application allows designers to templatize an Adobe Illustrator design, in turn allowing customers to create personalized versions of the design.  It's intended to simultaneously leverage and control the awesome power of Illustrator.

## Users

The intended user of all template-related UI is a designer, familiar with AI, Bombsheller, and our customization practices.

The intended user for all version-related UI is a customer, and therefore not necessarily familiar with anything.

## Managed Objects

Each Design Template object is associated with an Adobe Illustrator file.  A Design Template object encapsulates a description of how customers will be prompted to create their individual versions.  A template is associated with an OS folder, referred to as its 'working folder'

Each Version object encapsulates a customer’s specifications of how one particular version is to be created.  A Version is associated with an OS folder, referred to as its 'working folder'.  A Version’s specifications are passed along to AI when generating output.

Colors and Palettes are used to manage color usage.  Color objects can be created for appealing colors, and grouped into Palettes. In this way a customer's choices can be limited.

A Replacement Image is essentially an uploaded file that will replace a 'placed item' found in an AI file.

A Collage is an alternative to a Replacement Image, essentially being a collection of images, currently implemented as a connection to Instagram.  When created, a collage downloads a collection of images from Instagram into an OS folder.  




![alt text]( https://raw.github.com/bttalisman/design_customization/diagram.svg "Diagram")

## Languages and Environments

This is a Rails application, but several other scripting languages are used as needed.

The Adobe Illustrator application is used to run a script written in JavaScript, but any AI-supported scripting language could be used.  This script has access to the entire Illustrator API.  AppleScript is used as little as possible: to launch Adobe Illustrator, load the AI script, and close Illustrator.  A Ruby OS script creates this AppleScript in memory, runs it, and generates a collection of output files including .ai, .jpeg, and any other type needed.  These files are initially placed in the ‘output’ subfolder of the Version’s working folder. The OS script copies these output files to their final location, as well as initiates any further processing that needs to occur.

## Distributed Installation

This application can be installed on a single machine responsible for hosting the application as well as running AI.  Alternatively, it can be installed on two machines, one publicly facing, and the other running AI.  In the distributed case, both machines have an identical installation of the application, and they need access to a common file system.

## Process Overview

When a Design Template is created, the original AI file is copied into the template’s working folder. AI is then used to extract information about any customizable elements found in the design.  Separate scripts are used to extract data about placed items (images) and customizable text (tags).  These scripts cause AI to generate ‘tags’ and ‘images’ json files, stored in the Design Template’s working folder.  The designer is asked about how these extracted elements are to be treated when versions are created, and these settings are stored in the application database as the json string DesignTemplate.prompts.  For example, if the tag ‘gonzo’ is found in the AI file and the designer specifies that customers can set the color of this tag, the prompts json indicates that for the tag ‘gonzo’ the color can be set.

When a Version is created, the ‘prompts’ json string of the associated DesignTemplate describes how to present to the customer the final questions that need to be answered for the final output, the customized design.  A customer’s answers to these questions are stored as a json string in Version.values.  All settings in Version.values are temporarily stored in a json file expected by the AI script ultimately creating the final version.  Continuing the above example, Version.values matches the tag ‘gonzo’ to the hex code of the color desired by the customer.

The file responsible for launching AI is: /bin/illustrator_processing/run_AI_script.rb.  This script expects a single runtime argument specifying the name of a configuration file.  This json file contains the name of the AI source file, the name of an Illustrator script file, and an output folder location.  This configuration file will be created and saved in a Version’s working folder prior to processing the version, or a Design Template’s folder prior to processing the template.  From these settings, run_AI_script.rb generates an AppleScript snippet that launches AI, loads the AI file, loads and runs the script file, and closes AI.

Separate AI script files are responsible for extracting images and tags, as well as executing each type of search and replace necessary whenever a version is processed.  These files are all in /bin/illustrator_processing.

The AI script responsible for creating a version will expect to find a json file containing all necessary settings in the folder along side the source AI file, named as the source file with '\_data' appended.  When a Version is processed, all of the customer’s specifications from Version.values are loaded into this file.

When a version is processed, the output from the tags search and replace is used as the input to the images search and replace.  In this way a series of transformations can be performed, but this may not be necessary.  If this chaining gets ridiculous these functions can certainly be executed separately.

## Extensible UI

Both versions and templates require extensible UI.  It’s not known before the original AI file is processed what customizable elements will be found.  In addition, the way a designer creates a template dictates what the UI for associated versions will look like.  

All generally known UI is found in the views for each model as expected.  All extensible UI components are found in the ‘partials’ folder, and are controlled by the ‘partials’ controller.

Extensible UI is only provided by the ‘edit’ views for versions and templates.  Ajax requests are made by the ‘edit’ views to the partials controller, requesting UI for the template or version as necessary.  Extensible UI for these objects is only available after the version or template has been created and saved, due to the way attachments are created and associated.

When a user clicks Save, pending javaScript validation a json object containing all settings, both extensible and general, is created and posted to the appropriate controller.
