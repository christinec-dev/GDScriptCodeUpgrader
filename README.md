# Code Upgrader Plugin
Code Upgrader is a tool designed to help upgrade your GDScript code from Godot 3 to Godot 4. This plugin automates the process of updating deprecated methods, properties, and syntax, ensuring your projects are compatible with the latest version of Godot.

## Notice 
This plugin is a work-in-progress tool.

Please know that I might not have picked up all the changes, as there are a lot, so if you find ones that I haven’t added, you can let me know and I will implement those fixes into the plugin! 

### Next Steps
- Do more focused testing on all the individual Nodes, especially for the TileMap node, to see where I can add more conversions.
- Continuously test the updated functions with a variety of code snippets to ensure that all transformations are applied correctly and do not interfere with each other or modify unintended parts of the code.
- Optimize the performance, especially if applied to large bodies of code, and optimize or refactor as necessary to ensure efficiency.

## Links
- [Wiki](https://github.com/christinec-dev/GDScriptCodeUpgrader/wiki/Tutorial)
- AssetLib Download (Awaiting Approval)

## Usage Instructions 
- Download the plugin and enable it.
- If enabled correctly, there should be a new dock on the left side of the editor.
- This dock has two parts: a code input and an output panel.
- We will paste our Godot 3 code in the input panel, and copy our Godot 4 code from the output panel.
- Press execute and your code should be converted!

## Screenshots
![Screenshot 2024-08-09 100646](https://github.com/user-attachments/assets/fc175a57-70c6-40b7-bd70-07784d5944d7)

![Screenshot 2024-08-09 100719](https://github.com/user-attachments/assets/a5af7c62-1634-4f26-9639-4401fb79cc03)

## Completion Log
- Replacements for `export` and `onready` keywords.
- Transformation of `yield` statements to await with various patterns.
- Updated `signal connection` syntax to use direct method calls.
- Modified `signal connection` syntax to include `parameters` with binding.
- Simplified `move_and_slide()` usage and removed specific property assignments.
- Transformed `signal emission` syntax to `direct method` calls.
- Handled `signal emissions` with `parameters`.
- Updated `file` opening syntax with a detailed commented guide.
- Added the guide for the `set_cell` and `set_cell_v` syntax.
- Changed access from `.cell_size` to .tile_set.tile_size.
- Transformed `Tween` instantiation to direct instantiation with new instances.
- Updated the keyword list to upgrade more terms.

