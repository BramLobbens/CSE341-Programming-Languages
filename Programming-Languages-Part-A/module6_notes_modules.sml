(**
Modules
**)
(* main purpose: hiding implementation details *)
(* signature MYLIB =
sig
    val my_fun : int -> int
    val foo : string -> string (* module will not compile *)
end

structure MyLib :> MYLIB = struct (* if given a signature MYLIB via :>,
                                    will only type check if type definition
                                   from signature is included *)
    fun my_fun x = x + 1
    fun doubler x = x * 2 (* Any binding not defined in the signature cannot be used outside the module *)
    val bar = "bar"
end *)

signature RATIONAL_A =
sig
    (*by exposing the datatype definition, clients can violate the invariant constraints we want
    e.g. calling Frac constructor directly instead of through make_frac -- see solution in B*)
    datatype rational = Whole of int | Frac of int*int
    exception BadFrac
    val make_frac : int * int -> rational
    val add : rational * rational -> rational
    val toString : rational -> string
end

signature RATIONAL_B =
sig
    type rational (* solution: type exposed, but not its definition  = abstract type *)
    exception BadFrac
    val make_frac : int * int -> rational
    val add : rational * rational -> rational
    val toString : rational -> string
end

signature RATIONAL_C =
sig
    type rational
    exception BadFrac
    val Whole : int -> rational (* exposing Whole wouldn't cause any issues for our invariant constraints,
                                and can actually export it as a function that returns a rational! *)
    val make_frac : int * int -> rational
    val add : rational * rational -> rational
    val toString : rational -> string
end

(* structure Rational1 :> RATIONAL_A = *)
structure Rational1 :> RATIONAL_B =
struct

(* Invariant 1: all denominators > 0
   Invariant 2: rationals kept in reduced form *)

  datatype rational = Whole of int | Frac of int*int
  exception BadFrac

(* gcd and reduce help keep fractions reduced,
   but clients need not know about them *)
(* they _assume_ their inputs are not negative *)
  fun gcd (x,y) =
       if x=y
       then x
       else if x < y
       then gcd(x,y-x)
       else gcd(y,x)

   fun reduce r =
       case r of
	   Whole _ => r
	 | Frac(x,y) =>
	   if x=0
	   then Whole 0
	   else let val d = gcd(abs x,y) in (* using invariant 1 *)
		    if d=y
		    then Whole(x div d)
		    else Frac(x div d, y div d)
		end

(* when making a frac, we ban zero denominators *)
   fun make_frac (x,y) =
       if y = 0
       then raise BadFrac
       else if y < 0
       then reduce(Frac(~x,~y))
       else reduce(Frac(x,y))

(* using math properties, both invariants hold of the result
   assuming they hold of the arguments *)
   fun add (r1,r2) =
       case (r1,r2) of
	   (Whole(i),Whole(j))   => Whole(i+j)
	 | (Whole(i),Frac(j,k))  => Frac(j+k*i,k)
	 | (Frac(j,k),Whole(i))  => Frac(j+k*i,k)
	 | (Frac(a,b),Frac(c,d)) => reduce (Frac(a*d + b*c, b*d))

(* given invariant, prints in reduced form *)
   fun toString r =
       case r of
	   Whole i => Int.toString i
	 | Frac(a,b) => (Int.toString a) ^ "/" ^ (Int.toString b)

end