# GMR AddOns

AddOns that work with GMR, GMR plugins and GMR profiles.

## Installation

### Cloning the respository

```sh
git clone --recurse-submodules https://github.com/AkiKonani/GMRPluginsAndProfiles.git
```

### Via symlinking

The add-ons can be symlinked with the `create_symbolic_links.template.bat` script.

With that, the add-ons can be updated via `git pull`.

#### Steps

1. Copy the `create_symbolic_links.template.bat` script to `create_symbolic_links.bat`
2. In the script: modify the path in line 3 to match the directory of the game installation (including "_retail_", "_classic_" or "_classic_era_").
3. Run the script as administrator (right click on the script and select "Run as administrator")

### Via copying

Copy all add-ons from `AddOns/` into the folder:

* For retail: `<game installation directory>/_retail_/Interface/AddOns/`
* For WotLK: `<game installation directory>/_classic_/Interface/AddOns/`
* For vanilla: `<game installation directory>/_classic_era_/Interface/AddOns/`
