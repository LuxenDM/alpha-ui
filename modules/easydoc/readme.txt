easydoc is intended to be an in-game manual provider similar to a 'CHM' file in design; plugins can provide keyword-searchable documents on their usage or how to play the game. The document renderer can also be embedded directly in a plugin's interface.

The following features are goals of the document renderer:

document body style options:
> alignment Left/Right/Center (repeatable, creates new section on change)
> background color

paragraph text with the following in-line style options:
> embedded hyperlink-style URLs
> font size
> font color

list text boxes
> numeric or bulleted with selectable bullet style

read-only tables
> embedded as direct numerically indexed json in document text

images
> resized to fit within document display

actionable objects
> document buttons, triggers navigation to linked page
> execution buttons, triggers lua code
> command buttons, triggers game commands