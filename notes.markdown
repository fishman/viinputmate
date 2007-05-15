### To Ask Allan
* Can the cursor be set to block instead of line?
* Can I get access to the text buffer and manually manipulate it?
* What other properties can I bind to besides line and column?
* How do I use the undo manager?


### Bugs
* cut and paste by line at the end of the file does not have a newline at the end of the string.
* insertAbove & insertBelow do not autoindent
* insertAtBeginningOfLine moves all the way to the start of the line instead of the first non-whitespace character.
* command mode should pass through events when a message box has focus.


### To Implement
* repeatable cut and copy, must cut multiple lines in one chunk
* gg
* s
* r
* .
* u
* :w
* s
* J


### Implemented
#### Movement
* k - moveUp
* j - moveDown
* l - moveForward
* h - moveBackward
* w - moveWordForward
* b - moveWordBackward
* e - moveToEndOfWord
* 0 - moveToBeginningOfLine
* $ - moveToEndOfLine
* #[movement] - move # number of times

#### Insert
* a - insertForward (not repeatable)
* i - insertBackward (not repeatable)
* o - insertBelow (not repeatable)
* O - insertAbove (not repeatable)

#### Cut
* d - cutSelection
* dd - cutLine (not repeatable)
* dl,x - cutForward (not repeatable)
* dh,X - cutBackward (not repeatable)
* dw - cutWordForward (not repeatable)
* db - cutWordBackward (not repeatable)
* de - cutToEndOfWord (not repeatable)
* d0 - cutToBeginningOfLine
* D,d$ - cutToEndOfLine

#### Copy
* y - copySelection
* yy - copyLine (not repeatable)
* yl - copyForward (not repeatable)
* yh - copyBackward (not repeatable)
* yw - copyWordForward (not repeatable)
* yb - copyWordBackward (not repeatable)
* ye - copyToEndOfWord (not repeatable)
* y0 - copyToBeginningOfLine
* y$ - copyToEndOfLine

#### Change
* c - changeSelection
* cc - changeLine (not repeatable)
* cl - changeForward (not repeatable)
* ch - changeBackward (not repeatable)
* cw - changeWordForward (not repeatable)
* cb - changeWordBackward (not repeatable)
* ce - changeToEndOfWord (not repeatable)
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




