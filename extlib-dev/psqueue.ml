(*
 * psq- an ocaml implementation of priority search queues.
 * Copyright (C) 2003 Brian Hurt
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *)

exception Empty

exception Not_found

exception Exists

(* Used by the modification routines to say what sort of balancing is
 * needed
 *)
type balance_t = NoBalance | Insert | Delete;;

(* Color of a node in a loser tree (used for balancing) *)
type color_t = Red | Black

(* Dominance of a node in a loser tree *)
type dominance_t = Left | Right

(* psq_ltree_t is the node of our basic loser tree (pennant tree) *)
type ('a, 'b) psq_ltree_t
	= Start
	| Loser of color_t                (* node color *)
	         * dominance_t            (* node dominance *)
	         * 'a                     (* loser key *)
	         * 'b                     (* loser data *)
	         * 'a                     (* search key *)
	         * ('a, 'b) psq_ltree_t   (* left subtree *)
	         * ('a, 'b) psq_ltree_t   (* right subtree *)



(* A winner tree is a topped loser tree- i.e. a loser tree with the
 * winner of the pennant.  Note that a winner tree is no longer a
 * priority search queue- a psq is a winner tree + the associated
 * comparison functions.  There are functions (eg psq_play) which
 * return a winner tree which do not return a psq.
 *)
type  ('a, 'b) psq_t
	= Void
	| Winner of 'a                      (* winner key *)
	          * 'b                      (* winner data *)
	          * ('a, 'b) psq_ltree_t    (* loser (pennant) tree *)
	          * 'a                      (* max search key *)


type ('a, 'b) t =
	{
		keycmp: 'a -> 'a -> int;
		pricmp: 'b -> 'b -> int;
		tree: ('a, 'b) psq_t
	}


let create kcmp pcmp = { keycmp = kcmp; pricmp = pcmp; tree = Void }


(* A psq_view is an 'unravelling' of a winner tree.  It undoes the
 * play which created the root node of the loser tree.  Mathematicians
 * are simple creatures, they count zero, one, many.  Zero and one
 * are exit conditions, generally- Many is the interesting case.  In
 * the Many case, we're splitting the winner tree into the two lesser
 * winner trees (each with one less level on their loser trees).
 *)
type ('a, 'b) psq_view
	= Zero
	| One  of 'a
	        * 'b
	| Many of color_t
	        * ('a, 'b) psq_t
	        * ('a, 'b) psq_t


(* Returns the maximum key of a winner tree. *)
let max_key q =
	match q with
		| Void -> raise Empty
		| Winner(_, _, _, k) -> k



(* finalize balancing.  This should be called only when we're sure we have
 * reached the true root of the loser tree.  If the true root is colored
 * red, due to balancing, we color it black.  We can only do this at the
 * true root because that's the only place where we can change the number
 * of blacks from the root to the leafs of all branchs at once.
 *)
let finalize a =
	match a with
		| Winner(w_key, d_data,
		         (Loser(Red, l_dom, l_key, l_data, l_skey, l_left,
		                l_right)), w_maxkey)
		->
			Winner(w_key, d_data,
			       (Loser(Black, l_dom, l_key, l_data, l_skey, l_left,
			              l_right)), w_maxkey)
		| _ -> a

(* Rotate the node left, which has the effect of shortening the right
 * branch and lengthening the left branch:
 *
 *      A                B
 *     / \              / \
 *    /   \            /   \
 *   C     B   ==>    A     D
 *        / \        / \
 *       E   D      C   E
 *
 * Note that we have to deal with updating the dominance, and we may
 * have to swap A and B (depending).  Also note that we may have
 * allocated a new B, so we pass the right child in instead of picking
 * it out of A.  Note also we pass in what color the new root and 
 * child nodes should be.
 *)
let rotate_left pricmp a b rootcol childcol =
	match a, b with

		(*
		 *      A                B
		 *     / \d             / \d
		 *    /   \            /   \
		 *   C     B   ==>    A     D  (no swap)
		 *        / \d       / \d
		 *       E   D      C   E
		 *
		 *)
		| Loser(_, Right, a_key, a_data, a_skey, c, _),
		  Loser(_, Right, b_key, b_data, b_skey, d, e)
		->
			Loser(rootcol, Right, b_key, b_data, b_skey,
			      Loser(childcol, Right, a_key, a_data, a_skey, c, d), e)


		(*
		 *      A                A
		 *     / \d             / \d
		 *    /   \            /   \
		 *   C     B   ==>    B     D   (swap required)
		 *       d/ \        / \d
		 *       E   D      C   E
		 *
		 *)
		(* Note that when we swap A and B, we don't swap search keys *)
		| Loser(_, Right, a_key, a_data, a_skey, c, _),
		  Loser(_, Left, b_key, b_data, b_skey, d, e)
		->
			Loser(rootcol, Right, a_key, a_data, b_skey,
			      Loser(childcol, Right, b_key, b_data, a_skey, c, d), e)


		(*
		 *      A                B
		 *    d/ \              / \d
		 *    /   \            /   \
		 *   C     B   ==>    A     D  (no swap)
		 *        / \d      d/ \
		 *       E   D      C   E
		 *
		 *)
		| Loser(_, Left, a_key, a_data, a_skey, c, _),
		  Loser(_, Right, b_key, b_data, b_skey, d, e)
		->
			Loser(rootcol, Right, b_key, b_data, b_skey,
			      Loser(childcol, Left, a_key, a_data, a_skey, c, d), e)


		(*
		 *      A                B            A
		 *    d/ \             d/ \         d/ \
		 *    /   \            /   \        /   \
		 *   C     B   ==>    A     D or   B     D (swap maybe)
		 *       d/ \       d/ \          / \d
		 *       E   D      C   E        C   E
		 *
		 *)
		| Loser(_, Left, a_key, a_data, a_skey, c, _),
		  Loser(_, Left, b_key, b_data, b_skey, d, e)
		->
			if ((pricmp a_data b_data) < 0) then
				(* swap required *)
				(* Note that when we swap A and B, we don't swap
				 * search keys
				 *)
				Loser(rootcol, Left, a_key, a_data, b_skey,
				      Loser(childcol, Right, b_key, b_data, a_skey, c, d), e)
			else
				(* no swap *)
				Loser(rootcol, Left, b_key, b_data, b_skey,
				      Loser(childcol, Left, a_key, a_data, a_skey, c, d), e)

		(* We should never hit this case- basically, this means we
		 * passed Start in as one of the two nodes, which is bad.
		 *)
		| _ -> assert false


(* Rotate the node right, which has the effect of shortening the left
 * branch and lengthening the right branch:
 *
 *       A              B
 *      / \            / \
 *     /   \          /   \
 *    B     C   ==>  D     A
 *   / \                  / \
 *  D   E                E   C
 *
 * Note that we have to deal with updating the dominance, and we may
 * have to swap A and B (depending).  Also note that we may have
 * allocated a new B, so we pass the left child in instead of picking
 * it out of A.  Note also we pass in what color the new root and child
 * nodes should be.
 *)
let rotate_right pricmp a b rootcol childcol =
	match a, b with

		(*
		 *       A              B
		 *     d/ \           d/ \
		 *     /   \          /   \
		 *    B     C   ==>  D     A    (no swap)
		 *  d/ \                 d/ \
		 *  D   E                E   C
		 *
		 *)
		| Loser(_, Left, a_key, a_data, a_skey, _, c),
		  Loser(_, Left, b_key, b_data, b_skey, d, e)
		->
			Loser(rootcol, Left, b_key, b_data, b_skey, d,
			      Loser(childcol, Left, a_key, a_data, a_skey, e, c))

		(*
		 *       A              A
		 *     d/ \           d/ \
		 *     /   \          /   \
		 *    B     C   ==>  D     B   (swap required)
		 *   / \d                d/ \
		 *  D   E                E   C
		 *
		 *)
		(* Note that when we swap A and B, we don't swap search keys *)
		| Loser(_, Left, a_key, a_data, a_skey, _, c),
		  Loser(_, Right, b_key, b_data, b_skey, d, e)
		->
			Loser(rootcol, Left, a_key, a_data, b_skey, d,
			      Loser(childcol, Left, b_key, b_data, a_skey, e, c))

		(*
		 *       A              B
		 *      / \d          d/ \
		 *     /   \          /   \
		 *    B     C   ==>  D     A    (no swap)
		 *  d/ \                  / \d
		 *  D   E                E   C
		 *
		 *)
		| Loser(_, Right, a_key, a_data, a_skey, _, c),
		  Loser(_, Left, b_key, b_data, b_skey, d, e)
		->
			Loser(rootcol, Left, b_key, b_data, b_skey, d,
			      Loser(childcol, Right, a_key, a_data, a_skey, e, c))

		(*
		 *       A              B             A
		 *      / \d           / \d          / \d
		 *     /   \          /   \         /   \
		 *    B     C   ==>  D     A   or  D     B  (swap maybe)
		 *   / \d                 / \d         d/ \
		 *  D   E                E   C         E   C
		 *
		 *)
		| Loser(_, Right, a_key, a_data, a_skey, _, c),
		  Loser(_, Right, b_key, b_data, b_skey, d, e)
		->
			if ((pricmp a_data b_data) < 0) then
				(* swap required *)
				(* Note that when we swap A and B, we don't swap
				 * search keys
				 *)
				Loser(rootcol, Right, a_key, a_data, b_skey, d,
				      Loser(childcol, Left, b_key, b_data, a_skey, e, c))
			else
				(* no swap *)
				Loser(rootcol, Right, b_key, b_data, b_skey, d,
				      Loser(childcol, Right, a_key, a_data, a_skey, e, c))

		| _ -> assert false



(* Balance a loser node.  As ugly as this routine is, it's still O(1).
 * Which is good, as we call it on every loser node as we ascend up the
 * loser tree.
 *)
let insert_left pricmp a =

	(* If we know we have a black root, we don't need to balance anymore *)

	match a with
		(*
		 * When any of the ? nodes are red:
		 *
		 *      B               R
		 *     / \             / \
		 *    /   \           /   \
		 *   R     R   ==>   B     B   (push down the black)
		 *  / \   / \       / \   / \
		 * ?   ? ?   ?     ?   ? ?   ?
		 *)
		| Loser(Black, a_dom, a_key, a_data, a_skey,
		        Loser(Red, b_dom, b_key, b_data, b_skey,
		             (Loser(Red, _, _, _, _, _, _) as d),
		             (Loser(Red, _, _, _, _, _, _) as e)),
		        Loser(Red, c_dom, c_key, c_data, c_skey,
		             (Loser(Red, _, _, _, _, _, _) as f),
		             (Loser(Red, _, _, _, _, _, _) as g)))
		->
			Insert,
			Loser(Red, a_dom, a_key, a_data, a_skey,
			      Loser(Black, b_dom, b_key, b_data, b_skey, d, e),
			      Loser(Black, c_dom, c_key, c_data, c_skey, f, g))

		(*
		 *       B              B
		 *      / \            / \
		 *     /   \          /   \
		 *    R     B  ==>   R     R
		 *   / \                  / \
		 *  R   B                B   B
		 *      (rotate root right)
		 *      (new root is black)
		 *)
		| Loser(Black, _, _, _, _,
		        (Loser(Red, _, _, _, _,
		               Loser(Red, _, _, _, _, _, _), _) as b),
		        ((Loser(Black,_,_,_,_,_,_)|Start) as c))
		->
			NoBalance, (rotate_right pricmp a b Black Red)

		(*
		 *       B                B              B
		 *      / \              / \            / \
		 *     /   \            /   \          /   \
		 *    R     B  ==>     R     B  ==>   R     R
		 *   / \              / \            / \   / \
		 *  B   R            R   B          B   B B   B
		 *     / \          / \
		 *    B   B        B   B
		 *     (rotate child left) (rotate root right)
		 *      (new root is red)  (new root is black)
		 *)
		| Loser(Black, _, _, _, _,
		        (Loser(Red, _, _, _, _,
		               ((Loser(Black,_,_,_,_,_,_)|Start) as d),
		               (Loser(Red, _, _, _, _, _, _) as e))
			     as b),
		        ((Loser(Black,_,_,_,_,_,_)|Start) as c))
		->
			NoBalance, (rotate_right pricmp a (rotate_left pricmp b e Red Red) 
			                         Black Red)

		(* Anything else, there are no violations. *)
		| _ -> Insert, a


(* Balance a loser node.  As ugly as this routine is, it's still O(1).
 * Which is good, as we call it on every loser node as we ascend up the
 * loser tree.
 *)
let insert_right pricmp a =

	(* If we know we have a black root, we don't need to balance anymore *)

	match a with
		(*
		 * When any of the ? nodes are red:
		 *
		 *      B               R
		 *     / \             / \
		 *    /   \           /   \
		 *   R     R   ==>   B     B   (push down the black)
		 *  / \   / \       / \   / \
		 * ?   ? ?   ?     ?   ? ?   ?
		 *)
		| Loser(Black, a_dom, a_key, a_data, a_skey,
		        Loser(Red, b_dom, b_key, b_data, b_skey,
		             (Loser(Red, _, _, _, _, _, _) as d),
		             (Loser(Red, _, _, _, _, _, _) as e)),
		        Loser(Red, c_dom, c_key, c_data, c_skey,
		             (Loser(Red, _, _, _, _, _, _) as f),
		             (Loser(Red, _, _, _, _, _, _) as g)))
		->
			Insert,
			Loser(Red, a_dom, a_key, a_data, a_skey,
			      Loser(Black, b_dom, b_key, b_data, b_skey, d, e),
			      Loser(Black, c_dom, c_key, c_data, c_skey, f, g))

		(*
		 *       B               B
		 *      / \             / \
		 *     /   \           /   \
		 *    B     R   ==>   R     R
		 *         / \       / \
		 *        B   R     B   B
		 *      (rotate root left)
		 *      (new node is black)
		 *)
		| Loser(Black, _, _, _, _,
		        ((Loser(Black,_,_,_,_,_,_)|Start) as c),
		        (Loser(Red, _, _, _, _, _,
		               Loser(Red, _, _, _, _, _, _)) as b))
		->
			NoBalance, (rotate_left pricmp a b Black Red)

		(*
		 *    B             B                B
		 *   / \           / \              / \
		 *  /   \         /   \            /   \
		 * B     R   ==> B     R    ==>   R     R
		 *      / \           / \        / \   / \
		 *     R   B         B   R      B   B B   B
		 *    / \               / \
		 *   B   B             B   B
		 *  (rotate child right) (rotate root left)
		 *   (new child is red)  (new root is black)
		 *)
		| Loser(Black, _, _, _, _,
		        ((Loser(Black,_,_,_,_,_,_)|Start) as c),
		        (Loser(Red, _, _, _, _,
		               (Loser(Red, _, _, _, _, _, _) as e), _) as b))
		->
			NoBalance, (rotate_left pricmp a (rotate_right pricmp b e Red Red) 
			                        Black Red)

		(* Anything else, there are no violations. *)
		| _ -> Insert, a


let rec delete_left pricmp = function

	(*     B          B
	 *    / \   =>   / \
	 *   R   ?      B   ?
	 *
	 * If the root of the left tree is red, we can simply color it black,
	 * restoring the black height requirement.
	 *)
	| Loser(Black, adom, akey, adata, askey, 
            Loser(Red, bdom, bkey, bdata, bskey, bleft, bright), aright)
	->
		NoBalance, Loser(Black, adom, akey, adata, askey,
		                 Loser(Black, bdom, bkey, bdata, bskey, bleft, bright),
		                 aright)

	(* case 1 *)
	(*      ?                ?
	 *     / \              / \
	 *    /   \            /   \
	 *   B     R   ==>    R     B
	 *        / \        / \
	 *       B   B      B   B
	 *
	 * A rotate left, then we need to recurse down a level.
	 *)
	| Loser(col, _, _, _, _,
	        (Loser(Black,_,_,_,_,_,_)|Start),
	        Loser(Red, _, _, _, _,
	              ((Loser(Black,_,_,_,_,_,_)|Start) as d),
	              (Loser(Black,_,_,_,_,_,_)|Start))) as b
	->
		begin
			match rotate_left pricmp b d col Red with
				| Loser(col, dom, key, data, skey, left, right) ->
					let bal, newleft = delete_left pricmp left in
					let newroot = Loser(col, dom, key, data, skey,
					                    newleft, right) in
					if bal = NoBalance then
						NoBalance, newroot
					else
						delete_left pricmp newroot
				| _ -> assert false
		end

	(* case 2 *)
	(*      B               B
	 *     / \             / \
	 *    /   \           /   \
	 *   B     B    ==>  B     R    And we need to move up the tree
	 *        / \             / \
	 *       B   B           B   B
	 *)
	| Loser(Black, adom, akey, adata, askey, aleft,
	        Loser(Black, bdom, bkey, bdata, bskey,
	              ((Loser(Black,_,_,_,_,_,_)|Start) as bleft),
	              ((Loser(Black,_,_,_,_,_,_)|Start) as bright)))
	->
		Delete, Loser(Black, adom, akey, adata, askey, aleft,
		              Loser(Red, bdom, bkey, bdata, bskey, bleft, bright))

	(*
	 *      R                 B
	 *     / \               / \
	 *    /   \             /   \
	 *   B     B    ==>    B     R    And the black is consumed
	 *        / \               / \
	 *       B   B             B   B
	 *)
	| Loser(Red, adom, akey, adata, askey, aleft,
	        Loser(Black, bdom, bkey, bdata, bskey,
	              ((Loser(Black,_,_,_,_,_,_)|Start) as bleft),
	              ((Loser(Black,_,_,_,_,_,_)|Start) as bright)))
	->
		NoBalance, Loser(Black, adom, akey, adata, askey, aleft,
		                 Loser(Red, bdom, bkey, bdata, bskey, bleft, bright))

	(* case 3 *)
	(*     ?              ?
	 *    / \            / \
	 *   /   \          /   \
	 *  B     B   ==>  B     B
	 *       / \              \
	 *      R   B              R
	 *                          \
	 *                           B
	 *
	 * Right child is rotated right, and we try again at this level.
	 *)
	| Loser(acol, adom, akey, adata, askey, aleft,
	        (Loser(Black,_,_,_,_,
                   (Loser(Red,_,_,_,_,_,_) as c),
	               (Loser(Black,_,_,_,_,_,_)|Start)) as b))
	->
		delete_left pricmp (Loser(acol, adom, akey, adata, askey, aleft,
		                          (rotate_right pricmp b c Black Red)))

	(* case 4 *)
	(*      ?                ?
	 *     / \              / \
	 *    /   \            /   \
	 *   B     B    ==>   B     B
	 *        / \        / \
	 *       ?   R      B   ?
	 *)
	| Loser(c, _, _, _, _, _, 
            Loser(Black, ddom, dkey, ddata, dskey, dleft,
                  Loser(Red, edom, ekey, edata, eskey, eleft, eright))) as b
	->
		NoBalance, (rotate_left pricmp b 
		            (Loser(Black, ddom, dkey, ddata, dskey, dleft,
		                  Loser(Black, edom, ekey, edata, eskey, 
		                        eleft, eright)))
		            c Black)

	| _ as a -> Delete, a


let rec delete_right pricmp = function

	(*     B          B
	 *    / \   =>   / \
	 *   ?   R      ?   B
	 *
	 * If the root of the right tree is red, we can simply color it black,
	 * restoring the black height requirement.
	 *)
	| Loser(Black, adom, akey, adata, askey, aleft,
	        Loser(Red, bdom, bkey, bdata, bskey, bleft, bright))
	->
		NoBalance, Loser(Black, adom, akey, adata, askey, aleft,
		      Loser(Black, bdom, bkey, bdata, bskey, bleft, bright))

	(* case 1 *)
	(*      ?                ?
	 *     / \              / \
	 *    /   \            /   \
	 *   R     B   ==>    B     R
	 *  / \                    / \
	 * B   B                  B   B
	 *
	 * A rotate right, then we need to recurse down a level.
	 *)
	| Loser(col, _, _, _, _,
	        (Loser(Red, _, _, _, _,
	              (Loser(Black, _, _, _, _, _, _)|Start),
	              (Loser(Black, _, _, _, _, _, _)|Start)) as d),
	        (Loser(Black, _, _, _, _, _, _)|Start)) as b
	->
		begin
			match rotate_right pricmp b d col Red with
				| Loser(col, dom, key, data, skey, left, right) ->
					let bal, newright = delete_right pricmp right in
					let newroot = Loser(col, dom, key, data, skey,
					                    left, newright) in
					if bal = NoBalance then
						NoBalance, newroot
					else
						delete_right pricmp newroot
				| _ -> assert false
		end

	(* case 2 *)
	(*      B               B
	 *     / \             / \
	 *    /   \           /   \
	 *   B     B    ==>  R     B    And we need to move up the tree
	 *  / \             / \
	 * B   B           B   B
	 *)
	| Loser(Black, adom, akey, adata, askey, 
	        Loser(Black, bdom, bkey, bdata, bskey,
	              ((Loser(Black,_,_,_,_,_,_)|Start) as bleft),
	              ((Loser(Black,_,_,_,_,_,_)|Start) as bright)),
	        aright)
	->
		Delete, Loser(Black, adom, akey, adata, askey,
		              Loser(Red, bdom, bkey, bdata, bskey, bleft, bright),
		              aright)

	(*
	 *      R                 B
	 *     / \               / \
	 *    /   \             /   \
	 *   B     B    ==>    R     B    And the black is consumed
	 *  / \               / \
	 * B   B             B   B
	 *)
	| Loser(Red, adom, akey, adata, askey,
	        Loser(Black, bdom, bkey, bdata, bskey,
	              ((Loser(Black,_,_,_,_,_,_)|Start) as bleft),
	              ((Loser(Black,_,_,_,_,_,_)|Start) as bright)),
	        aright)
	->
		NoBalance, Loser(Black, adom, akey, adata, askey,
		                 Loser(Red, bdom, bkey, bdata, bskey, bleft, bright),
		                 aright)

	(* case 3 *)
	(*      ?                  ?
	 *     / \                / \
	 *    /   \              /   \
	 *   B     B   ==>      B     B
	 *  / \                /
	 * B   R              R
	 *                   /
	 *                  B
	 *
	 * Left child is rotated left, and we try again at this level.
	 *)
	| Loser(acol, adom, akey, adata, askey, 
	        (Loser(Black,_,_,_,_,
	               (Loser(Black,_,_,_,_,_,_)|Start),
	               (Loser(Red,_,_,_,_,_,_) as c)) as b),
	        aright)
	->
		delete_left pricmp (Loser(acol, adom, akey, adata, askey,
		                          (rotate_left pricmp b c Black Red), aright))

	(* case 4 *)
	(*      ?                ?
	 *     / \              / \
	 *    /   \            /   \
	 *   B     B    ==>   B     B
	 *  / \                    / \
	 * R   ?                  ?   B
	 *)
	| Loser(c, _, _, _, _,  
            Loser(Black, ddom, dkey, ddata, dskey,
                  Loser(Red, edom, ekey, edata, eskey, eleft, eright), 
	              dright), _) 
	  as b
	->
		NoBalance, (rotate_left pricmp b 
		            (Loser(Black, ddom, dkey, ddata, dskey,
		                  Loser(Black, edom, ekey, edata, eskey, 
		                        eleft, eright), dright))
		            c Black)

	| _ as a -> Delete, a


(* Given two winner trees, play the two winners to create a single combined
 * winner tree.  It is assumed the all keys in a are less than any key in b.
 * We use this function to "knit" the tree together.  Note that we are given
 * the color of the new loser node we create.  When we are 'reknitting'
 * together a tree we've 'unravelled' (for the insertion, deletion, or
 * updating of an element, for example), the color is that of the loser
 * node we just destroyed.
 *)
let play pricmp dir c a b bal =
	let balance root =
		match bal, dir with
			| NoBalance, _ -> NoBalance, root
			| Insert, Left -> insert_left pricmp root
			| Insert, Right -> insert_right pricmp root
			| Delete, Left -> delete_left pricmp root
			| Delete, Right -> delete_right pricmp root
	in
	match a, b with
		| Void, Void -> bal, Void
		| Void, _ 
		-> 
			(if (bal = Delete) && (c = Red) then NoBalance else Delete), b
		| _, Void 
		-> 
			(if (bal = Delete) && (c = Red) then NoBalance else Delete), a
		| Winner(b_key, b_data, t, m),
		  Winner(b'_key, b'_data, t', m')
		->
			(* The interesting case- we need to play b and b'.  The winner
			 * is the element with the highest priority.  As a consolation
			 * prize, the loser gets to be the root of the loser tree
			 * (and a lifetime supply of rice-a-roni, both boxes!).
			 *)
			if ((pricmp b_data b'_data) <= 0) then
				let bal', root = balance (Loser(c, Right, b'_key,
				                                b'_data, m, t, t'))
				in
				bal', Winner(b_key, b_data, root, m')
			else
				let bal', root = balance (Loser(c, Left, b_key, b_data,
				                              m, t, t'))
				in
				bal', Winner(b'_key, b'_data, root, m')


(* Given a winner tree, create a psq_view of it.  This has the effect of
 * 'unravelling' one level of the original tree.  This is an O(1) operation.
 *)
let view_of q =
	match q with
		| Void -> Zero
		| Winner(b_key, b_data, Start, b_skey)
		->
			One(b_key, b_data)

		| Winner(b_key, b_data,
		         Loser(b'_color, Left, b'_key, b'_data, k, tl, tr), m)
		->
			Many(b'_color, Winner(b'_key, b'_data, tl, k),
			     Winner(b_key, b_data, tr, m))

		| Winner(b_key, b_data,
		         Loser(b'_color, Right, b'_key, b'_data, k, tl, tr), m)
		->
			Many(b'_color, Winner(b_key, b_data, tl, k),
			     Winner(b'_key, b'_data, tr, m))


(* psq_lookup and psq_contains both work the same way. *)

let search keycmp found notfound empty k q =
	let rec search_int q =
		match q with
			| Start -> notfound ()
			| Loser(_, _, k', data, skey, l, r) ->
				if ((keycmp k' k) == 0) then
					found data
				else
					if ((keycmp k' skey) <= 0) then
						search_int l
					else
						search_int r
	in
	match q with
		| Void -> empty ()
		| Winner(k', data, ltree, max) ->
			if ((keycmp k' k) == 0) then
				found data
			else if ((keycmp k' max) <= 0) then
				search_int ltree
			else
				notfound ()


let modify found notfound empty k q =
	let rec modify_int t =
		match (view_of t) with
			Zero -> notfound ()
			| One(b_key, b_data) ->
				if ((q.keycmp k b_key) == 0) then
					found b_key b_data 
				else
					begin
						let bal, b' = notfound () in
						match (b') with
							| Void -> bal, t
							| Winner(b'_key, _, _, _) ->
								if ((q.keycmp b'_key b_key) < 0) then
									play q.pricmp Left Red b' t bal
								else
									play q.pricmp Right Red t b' bal
					end
			| Many(c, tl, tr) ->
				if ((q.keycmp k (max_key tl)) <= 0) then
					let bal, newleft = modify_int tl in
					play q.pricmp Left c newleft tr bal
				else
					let bal, newright = modify_int tr in
					play q.pricmp Right c tl newright bal
	in
	match q.tree with
		| Void ->
			{
				keycmp = q.keycmp;
				pricmp = q.pricmp;
				tree = (empty ())
			}
		| _ ->
			let _, root = modify_int q.tree in
			{
				keycmp = q.keycmp;
				pricmp = q.pricmp;
				tree = (finalize root)
			}


(* Returns the highest priority element of a priority search queue in O(1) *)
let head q =
	match q.tree with
		Void -> raise Empty
		| Winner(_, b_data, _, _) -> b_data

let head_key q =
	match q.tree with
		Void -> raise Empty
		| Winner(b_key, _, _, _) -> b_key


(* Returns true is a priority search queue does not contain any elements,
 * false otherwise.
 *)
let is_empty q =
	match q.tree with
		Void -> true
		| Winner(_, _, _, _) -> false

(* Converts a priority search queue into a sorted list.  This is an O(n)
 * operation (um, duh!).  As it also allocates O(n) psq_views, it's not
 * the most efficient code on the planet.  Oh well.
 *)
let to_ord_list q =
	let rec to_ord_list_int q accum =
		match (view_of q) with
			Zero -> accum
			| One(b_key, b_data) -> (b_key, b_data) :: accum
			| Many(_, l, r) -> to_ord_list_int l
			                                  (to_ord_list_int r accum)
	in
	to_ord_list_int q.tree []


(* Given a key and a priority search queue, return either the data
 * associated with that key, or throw Not_found if the data is not
 * found, or throw Empty if the queue is empty.  Note that we have
 * rewritten this code to not have to allocate views.  I hate the idea
 * of a search function which allocates (just me).
 *)
let find k q =
	let found x = x
	and notfound () = raise Not_found
	and empty () = raise Empty
	in
		search q.keycmp found notfound empty k q.tree

let query k q =
	let found x = Some(x)
	and notfound () = None
	and empty () = None
	in
		search q.keycmp found notfound empty k q.tree


(* Given a key and a priority search queue, returns true if the key is
 * in the psq, false otherwise.
 *)
let contains k q =
	let found _ = true
	and notfound () = false
	and empty () = false
	in search q.keycmp found notfound empty k q.tree


(* precise priority changes *)
let adjust f k q =
	let found key data = NoBalance, Winner(key, (f data), Start, key)
	and notfound () = raise Not_found
	and empty () = raise Empty
	in
		modify found notfound empty k q


(* imprecise priority changes *)
let update f k q =
	let found key data = NoBalance, Winner(key, (f data), Start, key)
	and notfound () = NoBalance, Void
	and empty () = Void
	in
		modify found notfound empty k q


(* precise insertion *)
let add b_key b_data q =
	let found b'_key b'_data = raise Exists
	and notfound () = Insert, Winner(b_key, b_data, Start, b_key)
	and empty () = Winner(b_key, b_data, Start, b_key)
	in
		modify found notfound empty b_key q


(* imprecise insertion *)
let insert b_key b_data q =
	let found b'_key b'_data = (* update *)
			NoBalance, Winner(b_key, b_data, Start, b_key)
	and notfound () = Insert, Winner(b_key, b_data, Start, b_key)
	and empty () = Winner(b_key, b_data, Start, b_key)
	in
		modify found notfound empty b_key q


(* precise deletion *)
let remove k q =
	let found key data = Delete, Void
	and notfound () = raise Not_found
	and empty () = raise Empty
	in modify found notfound empty k q


(* imprecise deletion *)
let delete k q =
	let found key data = Delete, Void
	and notfound () = NoBalance, Void
	and empty () = Void
	in modify found notfound empty k q

let queue_to_string key2str data2str q =
	let rec loser2str buf l =
		let col2str col =
			match col with
				| Red -> Buffer.add_string buf "Red"
				| Black -> Buffer.add_string buf "Black"
		and dom2str dom =
			match dom with
				| Left -> Buffer.add_string buf "Left"
				| Right -> Buffer.add_string buf "Right"
		in
		match l with
			| Start -> Buffer.add_string buf "Start"
			| Loser(col, dom, key, data, skey, left, right) ->
				begin
					Buffer.add_string buf "Loser(";
					col2str col;
					Buffer.add_string buf ", ";
					dom2str dom;
					Buffer.add_string buf ", ";
					Buffer.add_string buf (key2str key);
					Buffer.add_string buf ", ";
					Buffer.add_string buf (data2str data);
					Buffer.add_string buf ", ";
					Buffer.add_string buf (key2str skey);
					Buffer.add_string buf ", ";
					loser2str buf left;
					Buffer.add_string buf ", ";
					loser2str buf right;
					Buffer.add_char buf ')'
				end
	in
	match q.tree with
		Void -> "Void"
		| Winner(key, data, tree, max) ->
			let buf = Buffer.create 4096 in
			begin
				Buffer.add_string buf "Winner(";
				Buffer.add_string buf (key2str key);
				Buffer.add_string buf ", ";
				Buffer.add_string buf (data2str data);
				Buffer.add_string buf ", ";
				loser2str buf tree;
				Buffer.add_string buf ", ";
				Buffer.add_string buf (key2str max);
				Buffer.add_char buf ')';
				Buffer.contents buf
			end


(* Delete the element with the highest priority from the priority
 * search queue.  This is an O(log n) operation.
 *)
let delete_head q =
	match q.tree with
		Void -> q
		| Winner(w_key, _, _, _) -> delete w_key q

(* Delete the element with the highest priority from the priority
 * search queue.  This is an O(log n) operation.
 *)
let remove_head q =
	match q.tree with
		Void -> q
		| Winner(w_key, _, _, _) -> remove w_key q


let to_pri_list q =
	let rec pri_merge a b accum =
		match (a, b) with
			([], []) -> (List.rev accum)
			| (_, []) -> (List.rev_append accum a)
			| ([], _) -> (List.rev_append accum b)
			| (((_, aelem) as anode) ::atail, ((_, belem) as bnode)::btail)
			->
				if ((q.pricmp aelem belem) <= 0) then
					pri_merge atail b (anode :: accum)
				else
					pri_merge a btail (bnode :: accum)
	in
	let rec to_pri_list_int node =
		match node with
			Start -> []
			| Loser(_, Left, key, elem, _, left, right) ->
				pri_merge ((key, elem) :: (to_pri_list_int left))
				           (to_pri_list_int right) []
			| Loser(_, Right, key, elem, _, left, right) ->
				pri_merge (to_pri_list_int left)
				          ((key, elem) :: (to_pri_list_int right)) []
	in 
	match q.tree with
		Void -> []
		| Winner(k, e, tree, _) ->
			(k, e) :: (to_pri_list_int tree)

