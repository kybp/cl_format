# cl_format

This is an implementation of the Common Lisp FORMAT function for
Ruby. It will aim to be as complete as makes sense.

FORMAT is described fully in the
[HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Body/22_c.htm)
Currently section 22.3.1 of the HyperSpec is implemented except for ~C
modifiers. Fully implemented sections:

- [22.3.1](http://www.lispworks.com/documentation/HyperSpec/Body/22_ca.htm)
  (except for ~C modifiers)
- [22.3.2](http://www.lispworks.com/documentation/HyperSpec/Body/22_cb.htm)
- [22.3.7.1](http://www.lispworks.com/documentation/HyperSpec/Body/22_cga.htm)
- [22.3.9.3](http://www.lispworks.com/documentation/HyperSpec/Body/22_cic.htm)

Generally, (format nil string arg-1 arg-2 ... arg-n) =>
string.cl_format(arg-1, arg-2, ..., arg-n).