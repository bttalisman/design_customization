# Design Templating and Customization

This application allows designers to templatize an Adobe Illustrator design, in turn allowing customers to create personalized versions of the design.  It's intended to simultaneously leverage and control the awesome power of Illustrator.

## Users of this System

The intended user of all template-related UI is a designer, familiar with AI, Bombsheller, and our customization practices.

The intended user for all version-related UI is a customer, and therefore not necessarily familiar with anything.

## Managed Objects

Each DesignTemplate object is associated with an Adobe Illustrator file.  A DesignTemplate object encapsulates a description of how customers will be prompted to create their unique versions.  Each template is associated with an OS folder, referred to as its 'working folder'

Each Version object encapsulates a customer’s specifications of how one particular version is to be created.  A Version is associated with an OS folder, referred to as its 'working folder'.  A Version’s specifications are passed along to AI when generating output.

### Colors and Palettes

Colors and Palettes are used to manage color usage.  Color objects can be created for appealing colors, and grouped into Palettes. In this way a customer's choices can be limited.  Colors can be created in the app UI, or imported from AI.

#### Creating Colors

When a color is created, the color is specified with an RGB color picker.  Specifying a cmyk color would be preferable, but I could not find a ready-made cmyk picker, so it's possible one would have to make one.  Not all rgb colors map to cmyk.  AI can convert rgb to cmyk, as done in bin/illustrator_processing/extractAllText.jsx.  If a user creates a version using a color that does not have a cmyk equivalent, the color switch just doesn't happen.

#### Importing Colors

When a user creates a template, the Edit page displays all colors extracted from the document, each containing cmyk and rgb representations, as well as swatch name if there is one.  A super user is presented with an option to import the extracted colors into the system.  This is just a way to populate the collection of managed colors with useful and appealing cmyk colors.

### Replacement Images

A Replacement Image is essentially an uploaded file that will replace a 'placed item' found in an AI file.  ReplacementImages may contain image files or zip archives containing image files. In the case that a ReplacementImage is a zip, its items will be cycled through randomly when replacing placed items for a version.

A Collage is an alternative to a Replacement Image, essentially being a collection of images, currently implemented as a connection to Instagram.  When created, a collage downloads a collection of images from Instagram into an OS folder.

### Managed Assets

A ManagedAsset is an image or a block of text that can be associated with a template.  Versions of a template will display these images and text.  The intention is to give the user creating the version a clue about what can be produced.


![alt text]( https://github.com/bttalisman/design_customization/blob/master/diagram.jpg "Diagram")

## Languages and Environments

This is a Rails application, but several other scripting languages are used as needed.

The Adobe Illustrator application is used to run a script written in JavaScript, but any AI-supported scripting language could be used.  This script has access to the entire Illustrator API.  AppleScript is used as little as possible: to launch Adobe Illustrator, load the AI script, and close Illustrator.  A Ruby OS script creates this AppleScript in memory, runs it, and generates a collection of output files including .ai, .jpeg, .png, .json, and any other type needed.  These files are initially placed in the ‘output’ subfolder of a Version’s,
or a DesignTemplate's working folder. The OS script copies these output files to their final location, as well as initiates any further processing that needs to occur.

## Distributed Installation

This application can be installed on a single machine responsible for hosting the application as well as running AI.  Alternatively, it can be installed on two machines, one publicly facing, and the other running AI.  In the distributed case, both machines have an identical installation of the application, and they need access to a common file system. This
feature is largely experimental and untested, you may choose to remove it entirely.

## Process Overview

When a Design Template is created, the original AI file is copied into the template’s working folder. AI is then used to extract information about any customizable elements found in the design.  Separate scripts are used to extract data about placed items (images) and customizable text (tags), and colors.  These scripts cause AI to generate ‘tags’, ‘images’, and 'all_colors' json files, stored in the Design Template’s working folder.  The designer is asked about how these extracted elements are to be treated when versions are created, and these settings are stored in the application database as the json string DesignTemplate.prompts.  For example, if the tag ‘gonzo’ is found in the AI file and the designer specifies that customers can set the color of this tag, the prompts json indicates that for the tag ‘gonzo’ the color can be set.

After the designer has made these specifications, the AI file is loaded once more and all placed items are replaced with references to an existing image. This allows the AI design file to be loaded when versions are being created, without AI complaining about missing images.  This is necessary if versions are to be created remotely.

When a Version is created, the ‘prompts’ json string of the associated DesignTemplate describes how to present to the customer the final questions that need to be answered for the final output, the customized design.  A customer’s answers to these questions are stored as a json string in Version.values.  When the final version is being generated, all settings in Version.values are temporarily stored in a json file expected by the AI script ultimately creating the final version.  Continuing the above example, Version.values matches the tag ‘gonzo’ to the hex code of the color desired by the customer.

The file responsible for launching AI is: /bin/illustrator_processing/run_AI_script.rb.  This script expects a single runtime argument specifying the name of a configuration file.  This json file contains the name of the AI source file, the name of an Illustrator script file, and an output folder location.  This configuration file will be created and saved in a Version’s working folder prior to processing the version, or a Design Template’s folder prior to processing the template.  From these settings, run_AI_script.rb generates an AppleScript snippet that launches AI, loads the AI file, loads and runs the script file, and closes AI.

Separate AI script files are responsible for extracting images, tags, and colors, as well as executing each type of search and replace necessary whenever a version is processed.  These files are all in /bin/illustrator_processing.

The AI script responsible for creating a version expects to find a json file containing all necessary settings in the folder along side the source AI file, named as the source file with '\_data' appended.  When a Version is processed, all of the customer’s specifications from Version.values are loaded into this file.

When a version is processed, the output from the tags search and replace is used as the input to the images search and replace.  The output of the images search and replace is used as the input to the colors search and replace.  In this way a series of transformations can be performed.

## Extensible UI

Both versions and templates require extensible UI.  It’s not known before the original AI file is processed what customizable elements will be found.  In addition, the way a designer creates a template dictates what the UI for associated versions will look like.  

All generally known UI is found in the views for each model as expected.  All extensible UI components are found in the ‘partials’ folder, and are controlled by the ‘partials’ controller.

Extensible UI is only provided by the ‘edit’ views for versions and templates.  Ajax requests are made by the ‘edit’ views to the partials controller, requesting UI for the template or version as necessary.  Extensible UI for these objects is only available after the version or template has been created and saved, due to the way attachments are created and associated.

## Settings schema

### design_template.prompts

JSON object describing constraints on how versions can be made, other properties of the template such as the dimensions of placed items that may affect versions.  These settings generally affect the creation of a version indirectly.

Info for a particular tag is stored in an object, the key referencing that object is the name of the tag.  The same is true for placed items.  The search and replace scripts can then easily locate the relevant settings when they encounter an item or a tag.  Colors are different, the key referring to a color's settings is constructed from the cmyk values, but this key is not used by search scripts to look up settings.  Colors often have slight variations in values, and I didn't find lookup by name to be a practical solution.  Instead, setting lookup is done by comparing the actual cmyk values, allowing for some floating point tolerance.  If speed ever becomes a concern, making the hash lookup work would improve performance.

To see the code that builds these objects, checking out design_templates_helper.set_color_prompts(),
design_templates_helper.set_tag_prompts(), etc...

```json
  tag_settings:
    tag_name:
      prompt: 'stuff'
      max_length: '33'
      min_length: '2'
      pick_color: 'checked'
      use_palette: 'checked'
      palette_id: '4'

  image_settings:
    image_name:
      replace_image: 'checked'
      fit_image: 'checked'
      original_image:
      original_height: '356'
      original_width: '343'

  trans_butt_settings:
    left_image_name: 'lefty'
    right_image_name: 'righty'
    tb_set_color: 'checked'

  color_settings:  
    '57.42187560.1562563.67187541.796875':
      replace_color: 'checked'
      rep_co_orig_co_name: 'drab blue'
      rep_co_orig_co_hex: '#3f3b35'
      rep_co_orig_co_c: '57.421875'
      rep_co_orig_co_m: '60.15625'
      rep_co_orig_co_y: '63.671875'
      rep_co_orig_co_k: '41.796875'

```

### version.values

JSON object describing the user's final input into how the version will be made.  This object is saved to the file system before the illustrator scripts are run, making these data available to the script.

Check out versions_helper.set_tag_values(), versions_helper.set_color_values(), etc...

```json
  tag_settings:
    tag_name:
      replacement_text: 'stuff'
      text_color: '#333333'

  image_settings:
    image_name:
      replacement_image_id: 345
      path: '/path/to/thing.jpg'
      type: 'ReplacementImage'
    another_name:
      collage_id: 333
      path: '/path/to/folder'
      type: 'Collage'

  trans_butt_settings:
    tb_text: 'JUICY'
    tb_color: '0xffaacc'
    tb_hw_ratio: '1.4'
    tb_v_align: 'center'
    tb_font: 'helvetica'

  color_settings:
    new_c: '23.3'
    new_m: '23.3'
    new_y: '23.3'
    new_k: '23.3'
    new_hex: '#333333'
    orig_c: '3.33'
    orig_m: '4.44'
    orig_y: '5.55'
    orig_k: '33.2'
    orig_hex: '#444444'

```
