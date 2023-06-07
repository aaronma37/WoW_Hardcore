# Hardcore Unlocked
A modification of the Hardcore addon which allows for variable rulesets.  This addon aims to improve performance and user experience by removing security and other memory/cpu intensive featuers from the original Hardcore addon. This addon will __not__ qualify you for the Hardcore community challenge.

## Roadmap
- 0.0.1b Removed security features, allow for custome rulesets, guild mandated rulesets
- 0.0.2b Strip down databases.  They are currently very large and we now have the data to get what we need with 10% of the dbs
- 0.0.3b Use native icons.  Lots of loading incurred via custom achievement icons
- 0.0.1  Add minimalism mode: turns off achievement tracking, deathlog recording (alerts will still work); Chat hyperlinks for rulesets
- 0.0.1+ Bug fixes for current acheivements.  Updated UI and customizations. Some additional fonts.

## Motivation and Demographic
- Enable players who do not want to follow the Solo-Self Found ruleset, to enjoy the Hardcore Addon features (Achievements, Death Alerts, Death log)
- Enable players to craft their own ruleset.  Players can activate their preferred ruleset from a collection of rules found in the main menu.
- Enable guilds to enforce their own ruleset.  Guilds can use officer notes to create a guild-wide ruleset.  Players in a guild with a guild-wide ruleset will have their addons automatically enable the rules in the guild-wide ruleset.
- Enable players who hit level 60 to follow their elite guild's ruleset.
- Players that prefer a minimal version of the Hardcore addon


## Features

### Variable Ruleset
Mix and match rules to cater to your Hardcore journey.  Join guilds with guild-wide rulesets to automatically participate.

### Guild Mandated Rulesets
Officers: Copy achievement code specified by `officer code` in the main menu in the guild information.  Players with this addon will automatically be assigned the matching ruleset.

### Removed Security Components
Rules in this addon function as guiderails and there is no "Failure" that can be appealed.  For example, the `No Auction House` rule will close the auction house if you attempt to open interact with the auctioneer, as opposed to applying a `failed` status to your character.  Security related warning text, verification tab, and verification status via inspection have been removed.

## Contributions

Please reachout to Yazpad (discord: lakai.#2409) to request additional rules/features/suggestions.  Feel free to copy or distribute (GNU GPLv3).  Feel free to make pull requests on github.
