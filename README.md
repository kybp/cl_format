# cl_format

This is an implementation of the Common Lisp FORMAT function for
Ruby. It will aim to be as complete as makes sense. FORMAT is
described fully in the
[HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Body/22_c.htm).
In Common Lisp, if a : and @ modifier are both supplied, they can come
in either order, but ':@' is conventional. Currently, this
implementation requires the conventional order.

## Currently implemented:

- [22.3.1: Basic Output]
  (http://www.lispworks.com/documentation/HyperSpec/Body/22_ca.htm)
  (except for ~C modifiers)
- [22.3.2: Radix Control]
  (http://www.lispworks.com/documentation/HyperSpec/Body/22_cb.htm)
- [22.3.3.1: Fixed-Format Floating-Point]
  (http://www.lispworks.com/documentation/HyperSpec/Body/22_cca.htm)
- [22.3.3.4: Monetary Floating-Point]
  (http://www.lispworks.com/documentation/HyperSpec/Body/22_ccd.htm)
- [22.3.4.1: Aesthetic]
  (http://www.lispworks.com/documentation/HyperSpec/Body/22_cda.htm)
  (the : modifier is intentionally omitted)
- [22.3.4.2: Standard]
  (http://www.lispworks.com/documentation/HyperSpec/Body/22_cdb.htm)
  (the : modifier is intentionally omitted)
- [22.3.7.1: Go-To]
  (http://www.lispworks.com/documentation/HyperSpec/Body/22_cga.htm)
- [22.3.8: Miscellaneous Operations]
  (http://www.lispworks.com/documentation/HyperSpec/Body/22_ch.htm)
- [22.3.9.3: Ignored Newline]
  (http://www.lispworks.com/documentation/HyperSpec/Body/22_cic.htm)

## Usage

Generally, (format nil string arg-1 arg-2 ... arg-n) =>
string.cl_format(arg-1, arg-2, ..., arg-n).
