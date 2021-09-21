(* Copyright (C) 1993, Digital Equipment Corporation           *)
(* All rights reserved.                                        *)
(* See the file COPYRIGHT for a full description.              *)

(* Last modified on Mon May 17 22:25:49 PDT 1993 by mjordan    *)

INTERFACE TypeTable;

IMPORT RefRefTbl;

TYPE
    T <: RefRefTbl.Default;

(* Assumes that the collector is prevented from moving references. *)

END TypeTable.
