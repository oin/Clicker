**NOTE: [Karabiner-Elements](https://github.com/tekezo/Karabiner-Elements/) now allows you to directly [assign mouse buttons](https://github.com/oin/Clicker/issues/2), so it might be better to use it instead of Clicker.**

This small program listens to keyboard events and translates presses and releases of a specific key to presses and releases of a mouse button.
It has been tested on OS X 10.11 and macOS 10.12, but it should work from OS X 10.6 onwards.

[Grab a release](https://github.com/oin/Clicker/releases)

At the moment, _Clicker_ is very simple, works in the background (with minimal CPU usage), and has no user interface.
To exit it, please use _Activity Monitor_.

I wrote _Clicker_ to be able to use the CapsLock key as a left mouse button on macOS Sierra.
With previous operating systems, I'd use [Karabiner](https://pqrs.org/osx/karabiner/) with [Seil](https://pqrs.org/osx/karabiner/seil.html.en), but they don't work with macOS Sierra.
Sierra users must use [Karabiner-Elements](https://github.com/tekezo/Karabiner-Elements/), but there is no support for translating key presses to mouse button presses at the moment, so I wrote this part.

# How to use CapsLock as a left mouse button on macOS Sierra

First, install [Karabiner-Elements](https://github.com/tekezo/Karabiner-Elements/) and launch it.
Setup a _Simple Modification_ from key ``caps_lock`` to key ``application``.

Then, go to the _Keyboard_ section of the _System Preferences_ app, click the _Modifier keys…_ on the bottom right, and set the Caps Lock key to _No Action_.

At this point, any press of the CapsLock key will result in writing an invisible character corresponding to the _PC Application_ key, which isn't really useful.
You'll need _Clicker_ to turn virtual presses of the _PC Application_ key to virtual mouse clicks.

Launch the _Clicker_ application.
On the first launch, it'll probably ask that you [grant it accessibility features](https://support.apple.com/kb/PH21504) (_Security_ section of the _System Preferences_ app, _Confidentiality_ pane, _Accessibility_ subsection), and just quit.
Once you have done that, launch _Clicker_ again and you're done.

To always enable _Clicker_, I added it in the _Login Items_ pane of the _System Preferences_ app (section _Users and groups_).

# Changing to another key or to another mouse button

_Clicker_ could work with another key and another mouse button, but for now, you'll need to grab the source code and to recompile it with your settings (see comments near the beginning of method ``-[ClickerController init]``, in _ClickerController.m_).

Feel free to send issues and requests if you'd like this tool to support your use case.
