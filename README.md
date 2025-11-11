<a href="resources/collage.jpg"><img src="resources/collage.jpg" width="600px"></a><br />
<sub>A collage of screenshots showing KOReader with Project: Title installed demonstrating a variety of possible display settings.</sub><br />
<sup>The books used are from the Standard Ebooks collection and the text visible is part of their cover design, not overlaid by this plugin.</sup> 

## A new view for KOReader
Project: Title is a plugin made by two people who love KOreader but wanted to expand upon the Cover Browser plugin. We desired an interface that would blend in with the very best that commercial eReaders have. Something that would make the time between books, looking for that next read, as pleasant as possible.

## Features
* **A Speedy Title Bar**: Thinner with more functionality — adding Favorites, History, Open Last Book, and Up Folder buttons to help you get exactly where you need as fast as possible.

* **A Fresh Book Listing**: New fonts, new text, new icons for books without covers and unsupported files. An optional variable-length progress bar that shows the relative size of each book. Books are presented in a tasteful, distinct manner that adjusts to the screen size and how many items are on screen.

* **A Fitting Folder**: Folders no longer show slashes in their names, and instead are shown your choice of cover image, thumbnails, or a generic icon. The arrow to move up a folder has been moved up into the title bar, to give more space for your books.

* **An Informative Footer**: Shows the page controls and your choice of either the current folder or a device status bar showing time, wifi, battery, and frontlight states. The location of the page controls can be set to either the lower right or the lower left.

* **A Matching Book Status Page**: The default book status page (available as a screensaver) have been updated to show the book's description and your current progress, as well as having its design updated to match the new book listings. A setting is available to restore the original one, if desired. 

* **Endless Customization through User Patches**: We made this plugin to be what we want it to be so we can't implement everyone's feature requests or suggestions. However, we have tried to make it very easy to modify through what KOReader calls "user patches". There are already many available and if you want to learn a little Lua you can even make your own. 

* **A Few Nice Extras**: Autoscan for new books on USB eject, make list and grid items larger or smaller with gestures (pinch/spread), a trophy icon to mark finished books, and displaying the tags/keywords for books in list mode.

## Who this (hopefully) is for:
* Kobo device owners. We designed this on two Kobos (Aura One, Sage) so we feel pretty confident about the experience there.
* Jailbroken Kindle owners. Version 2025.04v1 added support and we've seen and heard from many Kindle owners running this plugin.
* Android owners. As of version 2025.04v2, the Android edition of KOReader is supported.
* Owners of Pocketbook, Boox, Bigme and more. These readers should work just as well now, too.
* People with tidy EPUB/PDF libraries. We make sure every EPUB we sync has a title, author, series and cover image, so we designed around books always having that metadata. (We recommend Calibre for this.)
* Readers who like browsing for their next book and being able to see how long a book is before starting it.

## Who this (probably) is not for:
* KOReader users who prefer a barebones UI. If you are happy picking your next read from a list of filenames then KOReader already does this extremely well! However, a "filenames only" display mode is included as of version 2025.08v3.5, if you want to use the other aspects of the plugin but stick to a simple listing of files.
* KOReader users who are completely happy with Cover Browser. The changes we've made are 90% style based, and if you don't see anything here that you like, then stick with what you know and like!

## Installation
[Step-by-Step Install Guide](../../wiki/Installation)

## Instructions and Other Documentation

**Documentation:**

[Documentation Wiki Page](../../wiki/Documentation)

**User patch info and links:**

[User Patch Wiki Page](../../wiki/User-Patches-for-Project-Title)

**To configure Calibre to add page counts to books:**

[Calibre Page Counts Wiki Page](../../wiki/Configure-Calibre-Page-Counts)


**Easy Uninstall:**

To disable: Open the plugins menu, enable Cover Browser, then restart your device.

To completely remove: Delete the projecttitle.koplugin folder from `koreader/plugins/`. Delete the `koreader/fonts/source/` folder to remove the additional fonts, and the `koreader/icons/` folder to remove the additional icons.

## Credits
All code here started life as the Cover Browser plugin, written by @poire-z and other members of the KOReader team. The additional changes made here were done by @joshuacant and @elfbutt and all [contributors](../../graphs/contributors)

## Licenses
The code is licensed under the same terms as KOReader itself, AGPL-3.0. The license information for any additional files (fonts, images, etc) is located in licenses.txt
