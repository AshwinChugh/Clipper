# Clipper
![Clipper Logo](./Clipper_Images/ClipperLogo.png "Logo")

A macOS compact but powerful clipboard manager in your menu bar.

----
## Installation
### Manual Installation
The DMG Installer has been released on this github repository. You can download the installer alongside the source code under the Releases tab.

Or you can simply click [here](https://www.ashwinc.me). A Clipper.dmg file will be downloaded. Open it and move the application into your application folder. For optimal usage, enable Clipper to start when you log into your Mac.

### Automatic Installation
Currently working on getting Clipper on the Mac App Store for a more streamlined and seamless installation experience.

### Setting Clipper to Start at Login
1. Open System Preferences
2. Click on "Users and Groups"
3. Ensure that the current user is your account
4. Click on the "Login Items" button
   * This is located right next to the passwords button
5. Click on the '+' button located near the bottom of the window
6. Select Clipper
   * Ensure that you are located in the Applications directory (or the directory where you installed Clipper if you did not install Clipper in Applications)

---
## Requirements
Clipper will only run on macOS 12.0 (Monterey) or higher.

---
## Features
Clipper is a lightweight and powerful Clipboard Manager. A list of currently supported features is below:

### Automatic Updates
* Constant tracking and monitoring of changes to the system clipboard
* Instant UI updates for any new content copied to the clipboard

### Clipboard History
* Copy previously stored data
   * Data that was previously copied on the clipboard can be accessed and copied to the clipboard from Clipper
   * If the data is saved, content from previous sessions (shutdowns/restarts) can also be copied

### Persistence
* Persistence with Clipboard content.
   * Content saved (indicated by the yellow star) will persist across different sessions and application restarts
   * Restarting or shutting down your mac will NOT result in a loss of data that is saved
   * Note that non-saved data will be lost
* Sort between saved and non-saved data
   * Toggling the star button on the top-right corner of the popover will only display saved content.

### User Control
* Delete content on demand
   * Clicking delete on data will remove the item from Clipper's history
   * Note that this operation is irreversible -- Data deleted is data gone forever (until copied back onto the clipboard)
   * Deleting saved data will make Clipper automatically unsave and delete that data completely
   * You can not delete the latest item that is currently copied to your system Clipboard
      * Clipper will automatically add the item back when it checks for any changes on the system Clipboard

---
## Contributing

Clipper is open-source and free to any developers who are interested in making their own personal tweaks and modifications. If you are interested in contributing directly to this repository, feel free to contact me [here](https://www.ashwinc.me/#Contact).

Otherwise, developers are encouraged to fork this repository and design a version of Clipper that meets their desired expectations.

---
## Disclaimers
Clipper is currently in its Alpha build and is prone to various bugs and errors. If you are fortunate enough to encounter a bug, please create an issue on this repository or contact me [here](https://www.ashwinc.me/#Contact)!