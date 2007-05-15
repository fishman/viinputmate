### To Ask Allan
* Can the cursor be set to block instead of line?
* Can I get access to the text buffer and manually manipulate it?
* What other properties can I bind to?
* How do I use the undo manager?


### Bugs
* cut and paste by line at the end of the file does not have a newline at the end of the string.
* movement by word does not behave like vi would for 'w'
* cut and paste does not work in visual mode like it should
* insertAbove & insertBelow do not autoindent
* insertAtBeginningOfLine moves all the way to the start of the line instead of the first non-whitespace character.
* command mode should pass through events when a message box has focus.


### To Implement
* repeatable cut and copy, must cut multiple lines in one chunk
* e
* gg
* s
* r
* .
* u
* :w
* s
* J
* 


### Implemented
#### Movement
* k - moveUp
* j - moveDown
* l - moveRight
* h - moveLeft
* w - moveWordRight
* b - moveWordLeft
* 0 - moveToBeginningOfLine
* $ - moveToEndOfLine
* #[movement] - move # number of times

#### Insert
* a - insertRight (not repeatable)
* i - insertLeft (not repeatable)
* o - insertBelow (not repeatable)
* O - insertAbove (not repeatable)

#### Cut
* d - cutSelection
* dd - cutLine (not repeatable)
* dl,x - cutRight (not repeatable)
* dh,X - cutLeft (not repeatable)
* dw - cutWordRight (not repeatable)
* db - cutWordLeft (not repeatable)
* d0 - cutToBeginningOfLine
* D,d$ - cutToEndOfLine

#### Copy
* y - copySelection
* yy - copyLine (not repeatable)
* yl - copyRight (not repeatable)
* yh - copyLeft (not repeatable)
* yw - copyWordRight (not repeatable)
* yb - copyWordLeft (not repeatable)
* y0 - copyToBeginningOfLine
* y$ - copyToEndOfLine

#### Change
* c - changeSelection
* cc - changeLine (not repeatable)
* cl - changeRight (not repeatable)
* ch - changeLeft (not repeatable)
* cw - changeWordRight (not repeatable)
* cb - changeWordLeft (not repeatable)
* c0 - changeToBeginningOfLine
* c$ - changeToEndOfLine

#### Paste
* P - pasteBefore (hacky near end of file)
* p - pasteAfter (hacky near end of file)

#### Scroll
* ctrl-e - scrollLineDown (not repeatable, doesn't keep caret in view)
* ctrl-y - scrollLineUp (not repeatable, doesn't keep caret in view)
* ctrl-f - scrollLineDown (not repeatable, doesn't keep caret in view)
* ctrl-b - scrollLineUp (not repeatable, doesn't keep caret in view)