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


### To Implement
* repeatable cut and copy, must cut multiple lines in one chunk
* e
* gg and G
* s
* r
* .
* c and C
* u
* :w