OCaml Extended standard Library - ExtLib
========================================

[![Build Status](https://img.shields.io/endpoint?url=https%3A%2F%2Fci.ocamllabs.io%2Fbadge%2Fygrek%2Focaml-extlib%2Fmaster&logo=ocaml)](https://ci.ocamllabs.io/github/ygrek/ocaml-extlib)
[![Build](https://github.com/ygrek/ocaml-extlib/actions/workflows/workflow.yml/badge.svg)](https://github.com/ygrek/ocaml-extlib/actions/workflows/workflow.yml)

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
Current goal is to maintain compatibility, new software is encouraged to not use extlib since stdlib
is now seeing many additions and improvements which make many parts of extlib obsolete.
For tail-recursion safety consider using other libraries e.g. containers.

Project page :
  https://github.com/ygrek/ocaml-extlib

Online API documentation :
  https://ygrek.org/p/extlib/doc/

Dependencies
------------

* `ocaml` >= 4.02
* `cppo` - enables conditional compilation to ensure compatibility with various OCaml versions

optional:
* `ocamlfind` >= 1.5.1 - for `make install`
* `dune` - for dune build

Installation
------------

`opam install extlib` or follow the manual instructions below.

Build with dune:

  `dune build`

or with Makefile:

```
make minimal=1 build
make install
```

This will build and install bytecode and native libraries.

On bytecode-only architecture run

```
make minimal=1 all
make install
```

`minimal=1` will exclude from build several modules (namely `Base64` `Unzip` `UChar` `UTF8`) potentially
conflicting with other well-established OCaml libraries. If your code is expecting to find
these modules in extlib - omit this parameter during build to produce the full library.

Usage
-----

Generate and read the documentation.

Release
-------

* Check for changes in stdlib (e.g. with `ocaml check_stdlib.ml`)
* Update sw_test_all target for new OCaml release
* `make sw_test_all`
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
