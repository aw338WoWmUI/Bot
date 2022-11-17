# GMR AddOns

AddOns that work with GMR, GMR plugins and GMR profiles

## How to clone

```sh
git clone --recurse-submodules https://github.com/AkiKonani/GMRPluginsAndProfiles.git
```

## Dependencies

Some of the code requires one or multiple of the following addons:

* [Array](https://github.com/SanjoSolutions/LuaArray)
* [Object](https://github.com/SanjoSolutions/LuaObject)
* [Set](https://github.com/SanjoSolutions/LuaSet)

For the addons the dependencies are listed in the TOC file.

## AddOn installation

AddOns go into the regular WoW addons folder.

The add-ons can be symlinked with the `create_symbolic_links.template.bat` script:

1. Copy the `create_symbolic_links.template.bat` script to `create_symbolic_links.bat`
2. In the script: modify the path in line 3 to match the directory of the game installation (including "_retail_", "_classic_" or "_classic_era_").
3. Run the script as administrator (right click on the script and select "Run as administrator")
