OCaml Extended standard Library - ExtLib.
=========================================

[![Build Status](https://travis-ci.org/ygrek/ocaml-extlib.svg?branch=master)](https://travis-ci.org/ygrek/ocaml-extlib)
[![Build status](https://ci.appveyor.com/api/projects/status/6a3t5iq7ljbd25iq?svg=true)](https://ci.appveyor.com/project/ygrek/ocaml-extlib/branch/master)

```
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version,,
 * with the special exception on linking described in file LICENSE.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
```

What is ExtLib ?
----------------

ExtLib is a set of additional useful functions and modules for OCaml.

Project page :
  https://github.com/ygrek/ocaml-extlib

Online API documentation :
  http://ygrek.org.ua/p/extlib/doc/

Dependencies
------------

* `cppo` - enables conditional compilation to ensure compatibility with various OCaml versions
* `ocamlfind >= 1.5.1` - provides bytes package

Installation
------------

Unzip or untar in any directory and run

  `make minimal=1 build install`

This will build and install bytecode and native libraries.
On bytecode-only architecture run

  `make minimal=1 all install`

`minimal=1` will exclude from build several modules (namely `Unzip` `UChar` `UTF8`) potentially
conflicting with other well established OCaml libraries. If your code is expecting to find
these modules in extlib - omit this parameter during build to produce the full library.

Usage
-----

Generate and read the documentation.

Release
-------

* Review `git log` and update CHANGES
* Update version in Makefile
* Commit
* `make release`
* upload tarball and make release on github
* opam publish

Contributors
------------

* Nicolas Cannasse <ncannasse@motion-twin.com>
* Brian Hurt <brian.hurt@qlogic.com>
* Yamagata Yoriyuki <yori@users.sourceforge.net>
* Markus Mottl <markus.mottl@gmail.com>
* Jesse Guardiani <jesse@wingnet.net>
* John Skaller <skaller@users.sourceforge.net>
* Bardur Arantsson <bardur@scientician.net>
* Janne Hellsten <jjhellst@gmail.com>
* Richard W.M. Jones <rjones@redhat.com>
* ygrek <ygrek@autistici.org>
* Gabriel Scherer <gabriel.scherer@gmail.com>
* Pietro Abate <pietro.abate@pps.jussieu.fr>

License
-------

See LICENSE
