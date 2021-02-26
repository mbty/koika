(*! Implementation of an address stack module !*)

Require Import Koika.Frontend Koika.Std.

Module Type StackInterface.
  Axiom reg_t            : Type.
  Axiom R                : reg_t -> type.
  Axiom r                : forall idx : reg_t, R idx.
  Axiom push             : UInternalFunction reg_t empty_ext_fn_t.
  Axiom FiniteType_reg_t : FiniteType reg_t.
  Axiom Show_reg_t       : Show reg_t.
End StackInterface.

Module StackF <: StackInterface.
  Definition capacity := 2.

  Inductive _reg_t := size.
  Definition reg_t := _reg_t.

  Definition R r :=
    match r with
    | size => bits_t 2
    end.

  Definition r reg : R reg :=
    match reg with
    | size => Bits.zero
    end.

  Definition push : UInternalFunction reg_t empty_ext_fn_t := {{
    fun push () : bits_t 1 =>
      let s0 := read0(size) in
      if (s0 == #(Bits.of_nat 2 2)) then (* overflow *)
        Ob~1
      else (
        write0(size, s0 + |2`d1|);
        Ob~0
      )
  }}.

  Instance Show_reg_t : Show reg_t := _.
  Instance FiniteType_reg_t : FiniteType reg_t := _.
End StackF.
