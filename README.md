# Autosave Frequency mod for Surviving Mars

This mod is used to reduce the time between autosaves, and to increase the number of autosave files kept.

By default, it sets the Autosave frequency to save at the beginning of every Sol, and will keep the 5 most recent autosave files.

## Mod Options

If you have ModConfig by Aneurin from [Steam](http://steamcommunity.com/sharedfiles/filedetails/?id=1340775972), [NexusMods](https://www.nexusmods.com/survivingmars/mods/28) or [Github](https://github.com/Aneurin/ModConfig) installed, the number of Sols and the number of files to keep are exposed as options that can be set.

### Autosave Interval

This is the number of Sols between autosaves, and can be set from 1 Sol to 10 Sols. When changing this value, the next autosave Sol is updated to the first one that is able to be evenly divided by the interval.

For example, if it is currently Sol 90 and the Autosave Interval is set to 4, the next Sol able to be divided by 4 is 92. So the next autosave would occur at Sol 92, then every 4 Sols (96, 100, etc) after that.

### Autosave Count

This is the total number of autosave files to keep. The oldest autosaves are removed if the number of autosaves would exceed this count. The number of files to keep can be set between 1 to 10.

## Translation

If you wish to add a translation for a language other than English, you can make a copy of the Locales/English.csv file with the name set to the language name (e.g. as Locales/French.csv).

Once you have translated the english strings in your new file into your language, send a pull request with the new language file and I'll happily include it in the mod.

## Acknowledgements

Thanks go particularly to ChoGGi for help with Locale Translation handling, to ChoGGi and SkiRich for their willingness to provide explanations when I asked questions in the Surviving Mars modding Discord, and to Aneurin for creating the ModConfig mod to make it easy for modders to provide configurable options in their mods.