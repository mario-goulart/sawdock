## sawdock.jl

sawdock.jl provides some procedures to manipulate windows (dockapps)
in a way to emulate a Windowmaker-like dock under the Sawfish window
manager.

### How to use it

Add the following code to your `.sawfishrc` file:

    (require 'sawdock)

Specify the dockapps windows names and dockapps' position in the dock
by setting the sawdock-dockapps variable. For example:

    (setq sawdock-dockapps
      '((0 "bubblemon")
        (1 "wmcube")
        (2 "wmCalClock")
        (3 "wmmixer")
        (4 "wmpinboard")))

Specify the position of the dock on the screen by setting the variable
sawdock-position. For example:

    (setq sawdock-position '(horizontal bottom left))

Execute the procedure to dock your dockapps in the right position:

    (sawdock-dock)

You can put these steps in your `.sawfishrc` file. You can also set or
change your configuration using `sawfish-client` in runtime.

You can use the `sawdock-toggle-hide-dock` procedure to hide/unhide
the dock.

### Appearance configuration

#### Dock color

You can set the `sawdock-background-color` variable to configure the
dock background color. The default color is `green`.

#### Dock border

The `sawdock-border-width` variable controls the dock border
width. Default = `4`.

#### Interactive procedures

* `sawdock-move-next-position`: Move the dock to the next position on the screen.

* `sawdock-move-previous-position`: Move the dock to the previous position on the screen.

* `sawdock-toggle-hide-dock`: Hide/unhide the dock.

* `sawdock-dock-horizontal-top-left`: Move the dock to the the top-left screen corner and make it horizontal.

* `sawdock-dock-horizontal-top-right`: Move the dock to the the top-right screen corner and make it horizontal.

* `sawdock-dock-horizontal-bottom-left`: Move the dock to the the bottom-left screen corner and make it horizontal.

* `sawdock-dock-horizontal-bottom-right`: Move the dock to the the bottom-right screen corner and make it horizontal.

* `sawdock-dock-vertical-top-left`: Move the dock to the the top-left screen corner and make it vertical.

* `sawdock-dock-vertical-top-right`: Move the dock to the the top-right screen corner and make it vertical.

* `sawdock-dock-vertical-bottom-left`: Move the dock to the the bottom-left screen corner and make it vertical.

* `sawdock-dock-vertical-bottom-right`: Move the dock to the the bottom-right screen corner and make it vertical.


### Screenshots

![screenshot1](http://parenteses.org/mario/img/utils/sawdock/sawdock-horizontal-bottom-right-thumb.png) [Bigger](http://parenteses.org/mario/img/utils/sawdock/sawdock-horizontal-bottom-right.png)

![screenshot2](http://parenteses.org/mario/img/utils/sawdock/sawdock-vertical-top-left-thumb.png) [Bigger](http://parenteses.org/mario/img/utils/sawdock/sawdock-vertical-top-left.png)
