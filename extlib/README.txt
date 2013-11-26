OCaml Extended standard Library - ExtLib.
=========================================
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

What is ExtLib ?
----------------

ExtLib is a set of additional useful functions and modules for OCaml.
Project page :
	http://code.google.com/p/ocaml-extlib
and you can join the mailing list here :
	http://lists.sourceforge.net/lists/listinfo/ocaml-lib-devel

People are encouraged to contribute and to report any bug or problem
they might have with ExtLib by using the mailing list.

Installation :
--------------

Unzip or untar in any directory and run

  make minimal=1 build install

This will build and install bytecode and native libraries.
On bytecode-only architecture run

  make minimal=1 all install

`minimal=1` will exclude from build several modules (namely Unzip UChar UTF8) potentially
conflicting with other well established OCaml libraries. If your code is expecting to find
these modules in extlib - omit this parameter during build to produce the full library.

Alternatively, run 

  ocaml install.ml

and follow the instructions.

Usage :
-------

Generate and read the documentation.

Contributors :
--------------

Nicolas Cannasse (ncannasse@motion-twin.com)
Brian Hurt (brian.hurt@qlogic.com)
Yamagata Yoriyuki (yori@users.sourceforge.net)
Janne Hellsten <jjhellst AT gmail DOT com>
Richard W.M. Jones <rjones AT redhat DOT com>
ygrek <ygrek AT autistici DOT org>

License :
---------

See LICENSE
