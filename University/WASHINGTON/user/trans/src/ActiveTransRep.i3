(*
 * Copyright 1994-96 University of Washington
 * All rights reserved.
 * See COPYRIGHT file for a full description
 *
 * HISTORY
 * 13-Nov-96  Yasushi Saito (yasushi) at the University of Washington
 *	Added stats.
 * 26-Aug-96  Yasushi Saito (yasushi) at the University of Washington
 *	Recreated
 *)

INTERFACE ActiveTransRep;
IMPORT CheckPoint;
IMPORT Q;
IMPORT ActiveTrans;
IMPORT WAL;
IMPORT FastIntRefTbl;
IMPORT RefList;
IMPORT RefSeq;
IMPORT Buffer, BufferQ;
IMPORT TransT;
IMPORT Ctypes;

(* ActiveTrans is used by both StorageLocal and StorageProxy.
   StorageLocal uses all the fields defined here, but StorageProxy
   only uses "locks" and "waitingFor". This is not clean.

   The problem here is that I've combined the logging info and
   locking info into one type. (I think this is one case multiple
   inheritance is useful.)
   *)

REVEAL ActiveTrans.T = Q.T BRANDED OBJECT
  tr: TransT.T;
  firstLSN: WAL.LSN; (* The minimum log record that has to be retained in the
			log file. Used when truncating the log.
			This is actually the first UNDO record
			for generated by the transaction. If the transaction
			does not generate UNDO records(redo transaction or
			readonly transaction), then this field is
			LAST(WAL.LSN). *)
  lastLSN: WAL.LSN; (* Next record of the last log written by the
		       transaction. *)
  dirty: BOOLEAN; (* TRUE if transaction has ever written on storages *)
  needUndoLogScan: BOOLEAN; (* TRUE if any UNDO log has been emitted.
			       If this flag is TRUE, the transaction need
			       to scan the "undo" log to undo the effect of
			       transaction upon abort. *)
  state: CheckPoint.RState;
  dirtyPages: FastIntRefTbl.Default; (* used only on checkpoint and
					recovery. *)
  pages: BufferQ.T; (* List of pages modified by the transaction. *)
  
  (* Below are statistics. *)
  nPagesMapped: Ctypes.unsigned_int; (* # of pages mapped by the trans. *)
  nRedoLogBytes: Ctypes.unsigned_int; (* # of bytes modified by the trans *)
  nUndoLogBytes: Ctypes.unsigned_int; (* # of bytes modified by the trans *)
  nPagesModified: Ctypes.unsigned_int; (* # of bytes modified by the trans *)
  nPagesPagedIn: Ctypes.unsigned_int; (* # of bytes brought in by the pager *)
  nPagesPurged: Ctypes.unsigned_int; (* # of bytes purged out. *)
  
  (* Lock manager related info. *)
  locks: RefSeq.T; (* list of Lock.Ts acquired by this trans *)
  waitingFor: RefList.T; (* Used only in deadlock detection mode.
			    If this transaction is blocked to wait for
			    region(s) that are locked by
			    other transaction(s), then
			    this list holds all the transaction(s) that
			    caused this one to block *)

END;

TYPE BufferList = RECORD
  s: ARRAY [0 .. 31] OF Buffer.T;
  (* first 32 buffers are recorded in "s". *)
  rest: REF ARRAY OF Buffer.T;
  (* rest of the buffers are in "rest" *)
  n: CARDINAL;
  (* total # of buffers in both "s" and "rest". *)
END;

TYPE T = ActiveTrans.T;
CONST Brand = "ActiveTransRep";
  
END ActiveTransRep.
