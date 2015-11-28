# cl_format

This is an implementation of the Common Lisp FORMAT function for
Ruby. It will aim to be as complete as makes sense.

Currently section 22.3.1 of the HyperSpec is implemented except for ~C
modifiers, and all of section 22.3.2 and 22.3.7.1 are implemented.

Generally, (format nil string arg-1 arg-2 ... arg-n) =>
string.cl_format(arg-1, arg-2, ..., arg-n).