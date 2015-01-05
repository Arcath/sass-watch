# Sass Watch [![Build Status](https://travis-ci.org/Arcath/sass-watch.svg)](https://travis-ci.org/Arcath/sass-watch)

Watches your [SASS] files and compiles them when you save!

## Watching a File

`alt-cmd-S` or `Sass Watch: Watch` brings up the confirm output screen where you specify the sass compiles to. Hit enter and thats it, Sass Watch will watch the file for changes and compile the css to the supplied output.

## Viewing Watchers

`Sass Watch: List` brings up a list of watchers. Select a watcher from the list and you will be given some details about the watcher, from here you can stop the watcher.

## Behind the Scenes

Sass Watch binds to the save event in [Atom] which saves running any kind of filesystem watcher and means that your file is only re-compiled if _you_ save it in Atom instead of anything on your system touching the file.

[SASS]: http://sass-lang.com/
[Atom]: http://atom.io
