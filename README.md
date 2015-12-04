# cl_format

This is an implementation of the Common Lisp FORMAT function for
Ruby. It will aim to be as complete as makes sense. FORMAT is
described fully in the
[HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Body/22_c.htm).

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
- [22.3.4: Printer Operations]
  (http://www.lispworks.com/documentation/HyperSpec/Body/22_cd.htm)
  (Omitted: ~W and the : modifier for ~A and ~S)
- [22.3.7.1: Go-To]
  (http://www.lispworks.com/documentation/HyperSpec/Body/22_cga.htm)
- [22.3.7.4: Iteration]
  (http://www.lispworks.com/documentation/HyperSpec/Body/22_cgd.htm)
  (except for specifying maximum iterations)
- [22.3.7.6: Recursive Processing]
  (http://www.lispworks.com/documentation/HyperSpec/Body/22_cgf.htm)
- [22.3.8: Miscellaneous Operations]
  (http://www.lispworks.com/documentation/HyperSpec/Body/22_ch.htm)
- [22.3.9.3: Ignored Newline]
  (http://www.lispworks.com/documentation/HyperSpec/Body/22_cic.htm)

## Usage

Generally, (format nil string arg-1 arg-2 ... arg-n) =>
string.cl_format(arg-1, arg-2, ..., arg-n).
