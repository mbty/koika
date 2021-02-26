(*! Implementation of an address stack module !*)

Require Import Koika.Frontend Koika.Std.

Module Type OhNoInterface.
  Axiom reg_t            : Type.
  Axiom R                : reg_t -> type.
  Axiom r                : forall idx : reg_t, R idx.
  Axiom break_verilator  : UInternalFunction reg_t empty_ext_fn_t.
  Axiom FiniteType_reg_t : FiniteType reg_t.
  Axiom Show_reg_t       : Show reg_t.
End OhNoInterface.

Module OhNoF <: OhNoInterface.
  Inductive _reg_t := state.
  Definition reg_t := _reg_t.

  Definition R r :=
    match r with
    | state => bits_t 1
    end.

  Definition r reg : R reg :=
    match reg with
    | state => Bits.zero
    end.

  Definition break_verilator : UInternalFunction reg_t empty_ext_fn_t := {{
    fun break_verilator () : bits_t 1 =>
      let st := read0(state) in
      if (st == Ob~0) then (* fail *)
        Ob~1
      else (
        write0(state, Ob~1);
        Ob~0
      )
  }}.

  Instance Show_reg_t : Show reg_t := _.
  Instance FiniteType_reg_t : FiniteType reg_t := _.
End OhNoF.
