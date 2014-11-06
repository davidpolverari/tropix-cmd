;; GCC machine description for Intel 80386.
;; Copyright (C) 1988 Free Software Foundation, Inc.
;; Mostly by William Schelter.

;; This file is part of GNU CC.

;; GNU CC is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 1, or (at your option)
;; any later version.

;; GNU CC is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU CC; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.


;;- instruction definitions

;;- @@The original PO technology requires these to be ordered by speed,
;;- @@    so that assigner will pick the fastest.

;;- See file "rtl.def" for documentation on define_insn, match_*, et. al.

;;- When naming insn's (operand 0 of define_insn) be careful about using
;;- names from other targets machine descriptions.

;;- cpp macro #define NOTICE_UPDATE_CC in file tm.h handles condition code
;;- updates for most instructions.

;;- Operand classes for the register allocator:
;;- 'a' for eax
;;- 'd' for edx
;;- 'c' for ecx
;;- 'b' for ebx
;;- 'f' for anything in FLOAT_REGS
;;- 'r' any (non-floating-point) register
;;- 'q' regs that allow byte operations (A, B, C and D)
;;- 'A' A and D registers

;; the special asm out single letter directives following a '%' are:
;; 'z' mov%z1 would be movl, movw, or movb depending on the mode of operands[1]
;; 's' output a '*'
;; 'w' If the operand is a REG, it uses the mode size to determine the
;;      printing of the reg


;; Put tstsi first among test insns so it matches a CONST_INT operand.

(define_insn "tstsi"
  [(set (cc0)
	(match_operand:SI 0 "general_operand" "rm"))]
  ""
  "*
{
  operands[1] = const0_rtx;
  if (REG_P (operands[0]))
    return AS1 (tst%L0,%0);
  return AS2 (cmp%L0,%1,%0);
}")

(define_insn "tsthi"
  [(set (cc0)
	(match_operand:HI 0 "general_operand" "rm"))]
  ""
  "*
{
  operands[1] = const0_rtx;
  if (REG_P (operands[0]))
    return AS1 (tst%W0,%0);
  return AS2 (cmp%W0,%1,%0);
}")

(define_insn "tstqi"
  [(set (cc0)
	(match_operand:QI 0 "general_operand" "qm"))]
  ""
  "*
{
  operands[1] = const0_rtx;
  if (REG_P (operands[0]))
    return AS1 (tst%B0,%0);
  return AS2 (cmp%B0,%1,%0);
}")

(define_insn "tstsf"
  [(set (cc0)
	(match_operand:SF 0 "general_operand" "rm,f"))
   (clobber (reg:SI 0))]
  "TARGET_80387"
  "*
{
  rtx xops[1];
  if (!FP_REG_P (operands[0]))
    fp_push_sf (operands[0]);
/*  fp_pop_level--; */
  xops[0] = FP_TOP;
  cc_status.flags |= CC_IN_80387;
  if (FP_REG_P (operands[0]) && ! top_dead_p (insn))
    output_asm_insn (\"ftst\;fnstsw	r0\;sahf\", xops);
  else
    output_asm_insn (\"ftst\;fstp	%0\;fnstsw	r0\;sahf\", xops);
  RETCOM (testsf);
}")

(define_insn "tstdf"
  [(set (cc0)
	(match_operand:DF 0 "general_operand" "rm,f"))
   (clobber (reg:SI 0))
   ]
  "TARGET_80387"
  "*
{
  rtx xops[1];
  if (!FP_REG_P (operands[0]))
    fp_push_df (operands[0]);
/*  fp_pop_level--; */
  xops[0] = FP_TOP;
  cc_status.flags |= CC_IN_80387;
  if (FP_REG_P (operands[0]) && ! top_dead_p (insn))
    output_asm_insn (\"ftst\;fnstsw	r0\;sahf\", xops);
  else
    output_asm_insn (\"ftst\;fstp	%0\;fnstsw	r0\;sahf\", xops);
  RETCOM (testdf);
}")

;;- compare instructions

;; Put cmpsi first among compare insns so it matches two CONST_INT operands.

(define_insn "cmpsi"
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "mr,ri")
		 (match_operand:SI 1 "general_operand" "ri,mr")))]
  ""
  "*
{
  if (REG_P (operands[1])
      || (!REG_P (operands[0]) && GET_CODE (operands[0]) != MEM))
    {
      cc_status.flags |= CC_REVERSED;
      return AS2 (cmp%L0,%0,%1);
    }
  return AS2 (cmp%L0,%1,%0);
}")

(define_insn "cmphi"
  [(set (cc0)
	(compare (match_operand:HI 0 "general_operand" "mr,ri")
		 (match_operand:HI 1 "general_operand" "ri,mr")))]
  ""
  "*
{
  if (REG_P (operands[1])
      || (!REG_P (operands[0]) && GET_CODE (operands[0]) != MEM))
    {
      cc_status.flags |= CC_REVERSED;
      return AS2 (cmp%W0,%0,%1);
    }
  return AS2 (cmp%W0,%1,%0);
}")

(define_insn "cmpqi"
  [(set (cc0)
	(compare (match_operand:QI 0 "general_operand" "qn,mq")
		 (match_operand:QI 1 "general_operand" "qm,nq")))]
  ""
  "*
{
  if (REG_P (operands[1])
      || (!REG_P (operands[0]) && GET_CODE (operands[0]) != MEM))
    {
      cc_status.flags |= CC_REVERSED;
      return AS2 (cmp%B0,%0,%1);
    }
  return AS2 (cmp%B0,%1,%0);
}")

(define_insn "cmpdf"
  [(set (cc0)
	(compare (match_operand:DF 0 "general_operand" "m,f*r,m,f,r,!*r")
		 (match_operand:DF 1 "general_operand" "m,m,f*r,r,f,*r")))
      (clobber (reg:SI 0))]
  "TARGET_80387"
  "*
{
  if (FP_REG_P (operands[0]))
    {
      rtx tem = operands[1];
      operands[1] = operands[0];
      operands[0] = tem;
      cc_status.flags |= CC_REVERSED;
    }
  if (! FP_REG_P (operands[1]))
    output_movdf (FP_TOP, operands[1]);
  output_movdf (FP_TOP, operands[0]);
/*  fp_pop_level--;
  fp_pop_level--; */
  cc_status.flags |= CC_IN_80387;
  return \"fcompp\;fnstsw	r0\;sahf\";
}")

(define_insn "cmpsf"
  [(set (cc0)
	(compare (match_operand:SF 0 "general_operand" "m,f*r,m,f,r,!*r")
		 (match_operand:SF 1 "general_operand" "m,m,f*r,r,f,*r")))
   (clobber (reg:SI 0))]
  "TARGET_80387"
  "*
{
  if (FP_REG_P (operands[0]))
    {
      rtx tem = operands[1];
      operands[1] = operands[0];
      operands[0] = tem;
      cc_status.flags |= CC_REVERSED;
    }
  if (! FP_REG_P (operands[1]))
    output_movsf (FP_TOP, operands[1]);
  output_movsf (FP_TOP, operands[0]);
/*  fp_pop_level--;
  fp_pop_level--; */
  cc_status.flags |= CC_IN_80387;
  return \"fcompp\;fnstsw	r0\;sahf\";
}")

;; logical compare
(define_insn ""
  [(set (cc0)
	(and:SI (match_operand:SI 0 "general_operand" "rm,ri")
		(match_operand:SI 1 "general_operand" "ri,rm")))]
  ""
  "*
{
  if (CONSTANT_P (operands[1]) || GET_CODE (operands[0]) == MEM)
    return AS2 (test%L0,%1,%0);
  return AS2 (test%L0,%0,%1);
}")

(define_insn ""
  [(set (cc0)
	(and:HI (match_operand:HI 0 "general_operand" "rm,ri")
		(match_operand:HI 1 "general_operand" "ri,rm")))]
  ""
  "*
{
  if (CONSTANT_P (operands[1]) || GET_CODE (operands[0]) == MEM)
    return AS2 (test%W0,%1,%0);
  return AS2 (test%W0,%0,%1);
}")

(define_insn ""
  [(set (cc0)
	(and:QI (match_operand:QI 0 "general_operand" "qm,qi")
		(match_operand:QI 1 "general_operand" "qi,qm")))]
  ""
  "*
{
  if (CONSTANT_P (operands[1]) || GET_CODE (operands[0]) == MEM)
    return AS2 (test%B0,%1,%0);
  return AS2 (test%B0,%0,%1);
}")

;; move instructions.
;; There is one for each machine mode,
;; and each is preceded by a corresponding push-insn pattern
;; (since pushes are not general_operands on the 386).

(define_insn ""
  [(set (match_operand:SI 0 "push_operand" "=<")
	(match_operand:SI 1 "general_operand" "g"))]
  ""
  "push%L0	%1")

;; General case of fullword move.
(define_insn "movsi"
  [(set (match_operand:SI 0 "general_operand" "=g,r")
	(match_operand:SI 1 "general_operand" "ri,m"))]
  ""
  "*
{
  rtx link;
  if (operands[1] == const0_rtx && REG_P (operands[0]))
    return \"clr%L0	%0\";
  if (operands[1] == const1_rtx
      && (link = find_reg_note (insn, REG_WAS_0, 0))
      /* Make sure the insn that stored the 0 is still present.  */
      && ! XEXP (link, 0)->volatil
      && GET_CODE (XEXP (link, 0)) != NOTE
      /* Make sure cross jumping didn't happen here.  */
      && no_labels_between_p (XEXP (link, 0), insn))
    /* Fastest way to change a 0 to a 1.  */
    return \"inc%L0	%0\";
  return \"mov%L0	%1,%0\";
}")

(define_insn ""
  [(set (match_operand:HI 0 "push_operand" "=<")
	(match_operand:HI 1 "general_operand" "g"))]
  ""
  "push%W0	%1")

(define_insn "movhi"
  [(set (match_operand:HI 0 "general_operand" "=g,r")
	(match_operand:HI 1 "general_operand" "ri,m"))]
  ""
  "*
{
  rtx link;
  if (operands[1] == const0_rtx && REG_P (operands[0]))
    return \"clr%W0	%0\";
  if (operands[1] == const1_rtx
      && (link = find_reg_note (insn, REG_WAS_0, 0))
      /* Make sure the insn that stored the 0 is still present.  */
      && ! XEXP (link, 0)->volatil
      && GET_CODE (XEXP (link, 0)) != NOTE
      /* Make sure cross jumping didn't happen here.  */
      && no_labels_between_p (XEXP (link, 0), insn))
    /* Fastest way to change a 0 to a 1.  */
    return \"inc%W0	%0\";
  return \"mov%W0	%1,%0\";
}")

;; emit_push_insn when it calls move_by_pieces
;; requires an insn to "push a byte".
;; But actually we use pushw, which has the effect of rounding
;; the amount pushed up to a halfword.
(define_insn ""
  [(set (match_operand:QI 0 "push_operand" "=<")
	(match_operand:QI 1 "general_operand" "q"))]
  ""
  "*
{
  operands[1] = gen_rtx (REG, HImode, REGNO (operands[1]));
  return \"push%W0	%1\";
}")

(define_insn "movqi"
  [(set (match_operand:QI 0 "general_operand" "=q,*r,m")
	(match_operand:QI 1 "general_operand" "*g,q,qi"))]
  ""
  "*
{
  rtx link;
  if (operands[1] == const0_rtx && REG_P (operands[0]))
    return \"clr%B0	%0\";
  if (operands[1] == const1_rtx
      && (link = find_reg_note (insn, REG_WAS_0, 0))
      /* Make sure the insn that stored the 0 is still present.  */
      && ! XEXP (link, 0)->volatil
      && GET_CODE (XEXP (link, 0)) != NOTE
      /* Make sure cross jumping didn't happen here.  */
      && no_labels_between_p (XEXP (link, 0), insn))
    /* Fastest way to change a 0 to a 1.  */
    return \"inc%B0	%0\";
  /* If mov%B0 isn't allowed for one of these regs, use mov%W0.  */
  if (NON_QI_REG_P (operands[0]) || NON_QI_REG_P (operands[1]))
    return (AS2 (mov%W0,%w1,%w0));
  return (AS2 (mov%B0,%1,%0));
}")

; I suspect nothing can ever match this ???
;(define_insn ""
;  [(set (match_operand:SF 0 "general_operand" "rm")
;	(match_operand:SF 1 "general_operand" "f"))
;   (clobber (reg:SF 8))]
;  ""
;  "*
;{
;  output_asm_insn ("???", operands);
;  fpop_sf (operands[0]);
;  RETCOM (movsf_clobber);
;}")

(define_insn ""
  [(set (match_operand:SF 0 "push_operand" "=<,<")
	(match_operand:SF 1 "general_operand" "gF,f"))]
  ""
  "*
{
  if (FP_REG_P (operands[1]))
    {
      rtx xops[3];
      xops[0] = AT_SP (SFmode);
      xops[1] = gen_rtx (CONST_INT, VOIDmode, 4);
      xops[2] = stack_pointer_rtx;
/*      fp_pop_level--; */
      output_asm_insn (AS2 (sub%L0,%1,%2), xops);
      if (top_dead_p (insn))
        output_asm_insn (\"fstp%S0	%0\", xops);
      else
        output_asm_insn (\"fst%S0	%0\", xops);
      RET;
    }
  return \"push%L0	%1\";
}")

(define_insn "movsf"
  ;; `rf' is duplicated in the second alternative
  ;; to make sure an optional reload is generated
  ;; for the memref in operand 0.  Otherwise
  ;; we could use too many hard regs.
  [(set (match_operand:SF 0 "general_operand" "=rf,mrf,!rm")
	(match_operand:SF 1 "general_operand" "mrf,rf,F"))]
  ""
  "*
{
  if (FP_REG_P (operands[1])
      && !FP_REG_P (operands[0])
      && !top_dead_p (insn))
    fp_store_sf (operands[0]);
  else
    output_movsf (operands[0], operands[1]);
  RETCOM (movsf);
}")

;;should change to handle the memory operands[1] without doing df push..
(define_insn ""
  [(set (match_operand:DF 0 "push_operand" "=<,<")
	(match_operand:DF 1 "general_operand" "gF,f"))]
  ""
  "*
{
  if (FP_REG_P (operands[1]))
    {
      rtx xops[3];
      xops[0] = AT_SP (DFmode);
      xops[1] = gen_rtx (CONST_INT, VOIDmode, 8);
      xops[2] = stack_pointer_rtx;
/*      fp_pop_level--; */
      output_asm_insn (AS2 (sub%L0,%1,%2), xops);
      if (top_dead_p(insn))
        output_asm_insn (\"fstp%Q0	%0\", xops);
      else
        output_asm_insn (\"fst%Q0	%0\", xops);
      RETCOM (pushdf);
    }
  else
    return output_move_double (operands);
}")

(define_insn "movdf"
  [(set (match_operand:DF 0 "general_operand" "=rmf,&fr,!rm")
	;; `rf' is duplicated in the second alternative
	;; to make sure that optional reloads are generated
	;; for the memory reference in operand 1.
	(match_operand:DF 1 "general_operand" "fr,mrf,F"))]
  ""
  "*
{
  if (FP_REG_P (operands[1])
      && ! FP_REG_P (operands[0])
      && ! top_dead_p (insn))
    fp_store_df (operands[0]);
  else
    output_movdf (operands[0], operands[1]);
  RETCOM (movdf);
}")

(define_insn ""
  [(set (match_operand:DI 0 "push_operand" "=<")
	(match_operand:DI 1 "general_operand" "roiF"))]
  ""
  "*
{
  return output_move_double (operands);
}")

(define_insn "movdi"
  [(set (match_operand:DI 0 "general_operand" "=&r,rm")
	(match_operand:DI 1 "general_operand" "m,riF"))]
  ""
  "*
{
   return output_move_double (operands);
}")

;; These go after the move instructions
;; because the move instructions are better (require no spilling)
;; when they can apply.  But these go before the add and subtract insns
;; because it is often shorter to use these when both apply.

;Lennart Augustsson <augustss@cs.chalmers.se>
;says this pattern just makes slower code:
;	pushl	%ebp
;	addl	$-80,(%esp)
;instead of
;	leal	-80(%ebp),%eax
;	pushl	%eax
;
;(define_insn ""
;  [(set (match_operand:SI 0 "push_operand" "=<")
;	(plus:SI (match_operand:SI 1 "general_operand" "%r")
;		 (match_operand:SI 2 "general_operand" "ri")))]
;  ""
;  "*
;{
;  rtx xops[4];
;  xops[0] = operands[0];
;  xops[1] = operands[1];
;  xops[2] = operands[2];
;  xops[3] = gen_rtx (MEM, SImode, stack_pointer_rtx);
;  output_asm_insn (\"push%z1	%1\", xops);
;  output_asm_insn (AS2 (add%z3,%2,%3), xops);
;  RET;
;}")

(define_insn ""
  [(set (match_operand:SI 0 "general_operand" "=g")
	(plus:SI (match_operand:SI 1 "general_operand" "0")
		 (const_int 1)))]
  ""
  "inc%L0	%0")

(define_insn ""
  [(set (match_operand:SI 0 "general_operand" "=g")
	(plus:SI (match_operand:SI 1 "general_operand" "0")
		 (const_int -1)))]
  ""
  "dec%L0	%0")

(define_insn ""
  [(set (match_operand:SI 0 "general_operand" "=g")
	(minus:SI (match_operand:SI 1 "general_operand" "0")
		  (const_int 1)))]
  ""
  "dec%L0	%0")

(define_insn ""
  [(set (match_operand:SI 0 "register_operand" "=r")
        (match_operand:QI 1 "address_operand" "p"))]
  ""
  "*
{
  CC_STATUS_INIT;
  /* Adding a constant to a register is faster with an add.  */
  if (GET_CODE (operands[1]) == PLUS
      && GET_CODE (XEXP (operands[1], 1)) == CONST_INT
      && rtx_equal_p (operands[0], XEXP (operands[1], 0)))
    {
      operands[1] = XEXP (operands[1], 1);
      return AS2 (add%L0,%1,%0);
    }
  return \"lea%L0	%a1,%0\";
}")

;;- conversion instructions
;;- NONE

;;- truncation instructions
(define_insn "truncsiqi2"
  [(set (match_operand:QI 0 "general_operand" "=q,m")
	(truncate:QI
	 (match_operand:SI 1 "general_operand" "qim,qn")))]
  ""
  "*
{
  if (CONSTANT_P (operands[1]) && GET_CODE (operands[1]) != CONST_INT)
    return \"mov%L0	%1,%k0\";
  return \"mov%B0	%b1,%0\";
}")

(define_insn "trunchiqi2"
  [(set (match_operand:QI 0 "general_operand" "=q,m")
	(truncate:QI
	 (match_operand:HI 1 "general_operand" "qim,qn")))]
  ""
  "*
{
  if (CONSTANT_P (operands[1]) && GET_CODE (operands[1]) != CONST_INT)
    return \"mov%W0	%1,%w0\";
  return \"mov%B0	%b1,%0\";
}")

(define_insn "truncsihi2"
  [(set (match_operand:HI 0 "general_operand" "=r,m")
	(truncate:HI
	 (match_operand:SI 1 "general_operand" "rim,rn")))]
  ""
  "*
{
  if (CONSTANT_P (operands[1]) && GET_CODE (operands[1]) != CONST_INT)
    return \"mov%L0	%1,%k0\";
  return \"mov%W0	%w1,%0\";
}")

;;- zero extension instructions
;; Note that the one starting from HImode comes before those for QImode
;; so that a constant operand will match HImode, not QImode.

(define_insn "zero_extendhisi2"
  [(set (match_operand:SI 0 "general_operand" "=r")
	(zero_extend:SI
	 (match_operand:HI 1 "general_operand" "rm")))]
  ""
  "movz%W0%L0	%1,%0")

(define_insn "zero_extendqihi2"
  [(set (match_operand:HI 0 "general_operand" "=r")
	(zero_extend:HI
	 (match_operand:QI 1 "general_operand" "qm")))]
  ""
  "movz%B0%W0	%1,%0")

(define_insn "zero_extendqisi2"
  [(set (match_operand:SI 0 "general_operand" "=r")
	(zero_extend:SI
	 (match_operand:QI 1 "general_operand" "qm")))]
  ""
  "movz%B0%L0	%1,%0")

;;- sign extension instructions
;; Note that the one starting from HImode comes before those for QImode
;; so that a constant operand will match HImode, not QImode.

/*
(define_insn "extendsidi2"
  [(set (match_operand:DI 0 "general_operand" "=a")
	(sign_extend:DI
	 (match_operand:SI 1 "general_operand" "a")))]
  ""
  "clq")
*/

;; Note that the i386 programmers' manual says that the opcodes
;; are named movsx..., but the assembler on Unix does not accept that.
;; We use what the Unix assembler expects.

(define_insn "extendhisi2"
  [(set (match_operand:SI 0 "general_operand" "=r")
	(sign_extend:SI
	 (match_operand:HI 1 "general_operand" "rm")))]
  ""
  "movs%W0%L0	%1,%0")

(define_insn "extendqihi2"
  [(set (match_operand:HI 0 "general_operand" "=r")
	(sign_extend:HI
	 (match_operand:QI 1 "general_operand" "qm")))]
  ""
  "movs%B0%W0	%1,%0")

(define_insn "extendqisi2"
  [(set (match_operand:SI 0 "general_operand" "=r")
	(sign_extend:SI
	 (match_operand:QI 1 "general_operand" "qm")))]
  ""
 "movs%B0%L0	%1,%0"
 )

;; Conversions between float and double.

(define_insn "extendsfdf2"
  [(set (match_operand:DF 0 "general_operand" "=fm,f,fm,fm")
	(float_extend:DF
	 (match_operand:SF 1 "general_operand" "m,0,f,!*r")))]
  "TARGET_80387"
  "*
{
  if (FP_REG_P (operands[0]))
    {
      output_movsf (operands[0], operands[1]);
      RET;
    }
  if (FP_REG_P (operands[1]))
    {
      if (top_dead_p (insn))
        fp_pop_df (operands[0]);
      else
        fp_store_df (operands[0]);
      RET;
    }
  output_movsf (FP_TOP, operands[1]);
  fp_pop_df (operands[0]);
  RETCOM (extendsfdf2);
}")

;; This cannot output into an f-reg because there is no way to be
;; sure of truncating in that case.
(define_insn "truncdfsf2"
  [(set (match_operand:SF 0 "general_operand" "=m,!*r")
	(float_truncate:SF
	 (match_operand:DF 1 "general_operand" "f,f")))]
  "TARGET_80387"
  "*
{
  if (top_dead_p (insn))
    fp_pop_sf (operands[0]);
  else
    fp_store_sf (operands[0]);
  RETCOM (truncdfsf2);
}")

;; Conversion between fixed point and floating point.
;; Note that among the fix-to-float insns
;; the ones that start with SImode come first.
;; That is so that an operand that is a CONST_INT
;; (and therefore lacks a specific machine mode).
;; will be recognized as SImode (which is always valid)
;; rather than as QImode or HImode. The 80387 would not know
;; what to do with the smaller sizes anyway. (I think).

(define_insn "floatsisf2"
  [(set (match_operand:SF 0 "general_operand" "=fm,fm")
	(float:SF (match_operand:SI 1 "general_operand" "m,!*r")))]
  "TARGET_80387"
  "*
{
/*  fp_pop_level++; */

  if (GET_CODE (operands[1]) != MEM)
    {
      rtx xops[2];
      output_asm_insn (\"push%L0	%1\", operands);
      operands[1] = AT_SP (SImode);
      output_asm_insn (\"fild%L0	%1\", operands);
      xops[0] = stack_pointer_rtx;
      xops[1] = gen_rtx (CONST_INT, VOIDmode, 4);
      output_asm_insn (AS2 (add%L0,%1,%0), xops);
    }
  else
    output_asm_insn (\"fild%L0	%1\", operands);

  if (! FP_REG_P (operands[0]))
    {
/*      fp_pop_level--; */
      return \"fstp%S0	%0\";
    }
  RET;
}")

(define_insn "floatsidf2"
  [(set (match_operand:DF 0 "general_operand" "=fm,fm")
	(float:DF (match_operand:SI 1 "general_operand" "m,!*r")))]
  "TARGET_80387"
  "*
{
/*  fp_pop_level++; */
  if (GET_CODE (operands[1]) != MEM)
    {
      rtx xops[2];
      output_asm_insn (\"push%L0	%1\", operands);
      operands[1] = AT_SP (SImode);
      output_asm_insn (\"fild%L0	%1\", operands);
      xops[0] = stack_pointer_rtx;
      xops[1] = gen_rtx (CONST_INT, VOIDmode, 4);
      output_asm_insn (AS2 (add%L0,%1,%0), xops);
    }
  else
    output_asm_insn (\"fild%L0	%1\", operands);
  if (! FP_REG_P (operands[0]))
    {
/*      fp_pop_level--; */
      return \"fstp%Q0	%0\";
    }
  RET;
}")

;; Convert a float to a float whose value is an integer.
;; This is the first stage of converting it to an integer type.

;; On the 387  truncating doub to an short integer shor can be performed:

;	fstcw	-4(%esp)  ;save cw
;	movw	-4(%esp),%ax
;	orw	$0x0c00,%ax  ;set rounding to chop towards zero
;	movw	%ax,-2(%esp) ;
;	fldcw	-2(%esp)     ;
;	fldl	doubl
;	fistpl	-12(%esp)    ;store the round value
;	fldcw	-4(%esp)     ;restore cw
;	movl	-12(%esp),%eax
;	movw	%ax,shor     ; move the result into shor.

;; but it is probably better to have a call, rather than waste this
;; space.  The last instruction would have been a movl if were
;; going to an int instead of a short.
;; For the moment we will go with the soft float for these.

/* These are incorrect since they don't set the rounding bits of CW flag.
   The proper way to do that is to make the function prologue save the CW
   and also construct the alternate CW value needed for these insns.
   Then these insns can output two fldcw's, referring to fixed places in
   the stack frame.

;; Convert a float whose value is an integer
;; to an actual integer.  Second stage of converting float to integer type.

(define_insn "fix_truncsfqi2"
  [(set (match_operand:QI 0 "general_operand" "=m,?*q")
	(fix:QI (fix:SF (match_operand:SF 1 "general_operand" "f,f"))))]
  "TARGET_80387"
  "*
{
  fp_pop_int (operands[0]);
  RET;
}")

(define_insn "fix_truncsfhi2"
  [(set (match_operand:HI 0 "general_operand" "=m,?*r")
	(fix:HI (fix:SF (match_operand:SF 1 "general_operand" "f,f"))))]
  "TARGET_80387"
  "*
{
  fp_pop_int (operands[0]);
  RET;
}")

(define_insn "fix_truncsfsi2"
  [(set (match_operand:SI 0 "general_operand" "=m,?*r")
	(fix:SI (fix:SF (match_operand:SF 1 "general_operand" "f,f"))))]
  "TARGET_80387"
  "*
{
  fp_pop_int (operands[0]);
  RET;
}")

(define_insn "fix_truncdfqi2"
  [(set (match_operand:QI 0 "general_operand" "=m,?*q")
	(fix:QI (fix:DF (match_operand:DF 1 "general_operand" "f,f"))))]

  "TARGET_80387"
 "*
{
  fp_pop_int (operands[0]);
  RET;
}")


(define_insn "fix_truncdfhi2"
  [(set (match_operand:HI 0 "general_operand" "=m,?*r")
	(fix:HI (fix:DF (match_operand:DF 1 "general_operand" "f,f"))))]
  "TARGET_80387"
  "*
{
  fp_pop_int (operands[0]);
  RET;
}")


(define_insn "fix_truncdfsi2"
  [(set (match_operand:SI 0 "general_operand" "=m,?*r")
	(fix:SI (fix:DF (match_operand:DF 1 "general_operand" "f,f"))))]
  "TARGET_80387"
  "*
{
  fp_pop_int (operands[0]);
  RET;
}")
*/


;;- add instructions
;;moved incl to above leal

(define_insn "addsi3"
  [(set (match_operand:SI 0 "general_operand" "=rm,r")
	(plus:SI (match_operand:SI 1 "general_operand" "%0,0")
		 (match_operand:SI 2 "general_operand" "ri,rm")))]
  ""
  "add%L0	%2,%0")

(define_insn ""
  [(set (match_operand:HI 0 "general_operand" "=g")
	(plus:HI (match_operand:HI 1 "general_operand" "0")
		 (const_int 1)))]
  ""
  "inc%W0	%0")

(define_insn "addhi3"
  [(set (match_operand:HI 0 "general_operand" "=rm,r")
	(plus:HI (match_operand:HI 1 "general_operand" "%0,0")
		 (match_operand:HI 2 "general_operand" "ri,rm")))]
  ""
  "add%W0	%2,%0")

(define_insn ""
  [(set (match_operand:QI 0 "general_operand" "=qm")
	(plus:QI (match_operand:QI 1 "general_operand" "0")
		 (const_int 1)))]
  ""
  "inc%B0	%0")

(define_insn "addqi3"
  [(set (match_operand:QI 0 "general_operand" "=m,q")
	(plus:QI (match_operand:QI 1 "general_operand" "%0,0")
		 (match_operand:QI 2 "general_operand" "qn,qmn")))]
  ""
  "add%B0	%2,%0")

;;had "fmF,m"

(define_insn "adddf3"
  [(set (match_operand:DF 0 "general_operand" "=f,m,f")
	(plus:DF (match_operand:DF 1 "general_operand" "%0,0,0")
		 (match_operand:DF 2 "general_operand" "m,!f,!*r")))]
  "TARGET_80387"
  "*FP_CALL (\"fadd%z0	%0\", \"fadd%z0	%0\", 2)")

(define_insn "addsf3"
  [(set (match_operand:SF 0 "general_operand" "=f,m,f")
	(plus:SF (match_operand:SF 1 "general_operand" "%0,0,0")
		 (match_operand:SF 2 "general_operand" "m,!f,!*r")))]
  "TARGET_80387"
  "*FP_CALL (\"fadd%z0	%0\", \"fadd%z0	%0\", 2)")

;;- subtract instructions

;;moved decl above leal

(define_insn "subsi3"
  [(set (match_operand:SI 0 "general_operand" "=rm,r")
	(minus:SI (match_operand:SI 1 "general_operand" "0,0")
		  (match_operand:SI 2 "general_operand" "ri,rm")))]
  ""
  "sub%L0	%2,%0")

(define_insn ""
  [(set (match_operand:HI 0 "general_operand" "=g")
	(minus:HI (match_operand:HI 1 "general_operand" "0")
		  (const_int 1)))]
  ""
  "dec%W0	%0")

(define_insn "subhi3"
  [(set (match_operand:HI 0 "general_operand" "=rm,r")
	(minus:HI (match_operand:HI 1 "general_operand" "0,0")
		  (match_operand:HI 2 "general_operand" "ri,rm")))]
  ""
  "sub%W0	%2,%0")

(define_insn ""
  [(set (match_operand:QI 0 "general_operand" "=qm")
	(minus:QI (match_operand:QI 1 "general_operand" "0")
		  (const_int 1)))]
  ""
  "dec%B0	%0")

(define_insn "subqi3"
  [(set (match_operand:QI 0 "general_operand" "=m,q")
	(minus:QI (match_operand:QI 1 "general_operand" "0,0")
		  (match_operand:QI 2 "general_operand" "qn,qmn")))]
  ""
  "sub%B0	%2,%0")

(define_insn "subdf3"
  [(set (match_operand:DF 0 "general_operand" "=f,m,f,f")
	(minus:DF (match_operand:DF 1 "general_operand" "0,0,0,m")
		  (match_operand:DF 2 "general_operand" "m,!f,!*r,*0")))]
  "TARGET_80387"
  "*FP_CALL (\"fsub%z0	%0\", \"fsubr%z0	%0\", 2)")


(define_insn "subsf3"
  [(set (match_operand:SF 0 "general_operand" "=f,m,f,f")
	(minus:SF (match_operand:SF 1 "general_operand" "0,0,0,m")
		  (match_operand:SF 2 "general_operand" "m,!f,!*r,*0")))]
  "TARGET_80387"
  "*FP_CALL (\"fsub%z0	%0\", \"fsubr%z0	%0\", 2)")

;;- multiply instructions

;(define_insn "mulqi3"
;  [(set (match_operand:QI 0 "general_operand" "=a")
;	(mult:QI (match_operand:QI 1 "general_operand" "%0")
;		 (match_operand:QI 2 "general_operand" "qm")))]
;  ""
;  "mulu%B0	%2,%0")

(define_insn "mulhi3"
  [(set (match_operand:HI 0 "general_operand" "=r,r")
	(mult:SI (match_operand:HI 1 "general_operand" "%0,rm")
		 (match_operand:HI 2 "general_operand" "g,i")))]
  ""
  "*
{
  if (GET_CODE (operands[1]) == REG
      && REGNO (operands[1]) == REGNO (operands[0])
      && (GET_CODE (operands[2]) == MEM
	  || GET_CODE (operands[2]) == REG))
    /* Assembler has weird restrictions.  */
    return AS2 (muls%W0,%2,%0);
  return AS3 (muls%W0,%2,%1,%0);
}")

(define_insn "mulsi3"
  [(set (match_operand:SI 0 "general_operand" "=r,r")
	(mult:SI (match_operand:SI 1 "general_operand" "%0,rm")
		 (match_operand:SI 2 "general_operand" "g,i")))]
  ""
  "*
{
  if (GET_CODE (operands[1]) == REG
      && REGNO (operands[1]) == REGNO (operands[0])
      && (GET_CODE (operands[2]) == MEM
	  || GET_CODE (operands[2]) == REG))
    /* Assembler has weird restrictions.  */
    return AS2 (muls%L0,%2,%0);
  return AS3 (muls%L0,%2,%1,%0);
}")

;; Turned off due to possible assembler bug.
;(define_insn "umulqi3"
;  [(set (match_operand:QI 0 "general_operand" "=a")
;	(umult:QI (match_operand:QI 1 "general_operand" "%0")
;		  (match_operand:QI 2 "general_operand" "qm")))]
;  ""
;  "mulu%B0	%2,%0")

;(define_insn "umulqihi3"
;  [(set (match_operand:HI 0 "general_operand" "=a")
;	(umult:HI (match_operand:QI 1 "general_operand" "%0")
;		  (match_operand:QI 2 "general_operand" "qm")))]
;  ""
;  "mulu%B0	%2,%0")

(define_insn "umulhi3"
  [(set (match_operand:HI 0 "general_operand" "=a")
	(umult:SI (match_operand:HI 1 "general_operand" "%0")
		  (match_operand:HI 2 "general_operand" "rm")))
   (clobber (reg:HI 1))]
  ""
  "mulu%W0	%2,%0")

(define_insn "umulsi3"
  [(set (match_operand:SI 0 "general_operand" "=a")
	(umult:SI (match_operand:SI 1 "general_operand" "%0")
		  (match_operand:SI 2 "general_operand" "rm")))
   (clobber (reg:SI 1))]
  ""
  "mulu%L0	%2,%0")

(define_insn "muldf3"
  [(set (match_operand:DF 0 "general_operand" "=f,m,f")
	(mult:DF (match_operand:DF 1 "general_operand" "%0,0,0")
		 (match_operand:DF 2 "general_operand" "m,!f,!*r")))]
  "TARGET_80387"
   "*FP_CALL (\"fmul%z0	%0\", \"fmul%z0	%0\", 2)
")

(define_insn "mulsf3"
  [(set (match_operand:SF 0 "general_operand" "=f,m,f")
	(mult:SF (match_operand:SF 1 "general_operand" "%0,0,0")
		 (match_operand:SF 2 "general_operand" "m,!f,!*r")))]
  "TARGET_80387"
  "*FP_CALL (\"fmul%z0	%0\", \"fmul%z0	%0\", 2)
")

;;- divide instructions
(define_insn "divdf3"
  [(set (match_operand:DF 0 "general_operand" "=f,m,f,f")
	(div:DF (match_operand:DF 1 "general_operand" "0,0,0,m")
		(match_operand:DF 2 "general_operand" "m,!f,!*r,*0")))]
  "TARGET_80387"
  "*FP_CALL (\"fdiv%z0	%0\", \"fdivr%z0	%0\", 2)
")

(define_insn "divsf3"
  [(set (match_operand:SF 0 "general_operand" "=f,m,f,f")
	(div:SF (match_operand:SF 1 "general_operand" "0,0,0,m")
		(match_operand:SF 2 "general_operand" "m,!f,!*r,*0")))]
  "TARGET_80387"
  "*FP_CALL (\"fdiv%z0	%0\", \"fdivr%z0	%0\", 2)
")

;; Divide and Remainder instructions.

;; Copy operands 1 and 2 to new registers, so that there's no 
;; danger that put_var_into_stack will mess up the sharing match_dup needs.
;; CSE will get rid of the extra pseudo regs.
;; No problem if not optimizing, since then only `register' vars
;; will get pseudo regs, and they aren't allowed to have address taken.

(define_expand "divmodsi4"
  [(parallel [(set (match_operand:SI 0 "general_operand" "=a")
		   (div:SI (match_operand:SI 1 "general_operand" "0")
			   (match_operand:SI 2 "general_operand" "rm")))
	      (set (match_operand:SI 3 "general_operand" "=&d")
		   (mod:SI (match_dup 1) (match_dup 2)))])]
  ""
  "
{
  extern int optimize;
  if (optimize)
    {
      if (GET_CODE (operands[1]) == REG && REG_USERVAR_P (operands[1]))
	operands[1] = copy_to_mode_reg (SImode, operands[1]);
      if (GET_CODE (operands[2]) == REG && REG_USERVAR_P (operands[2]))
	operands[2] = copy_to_mode_reg (SImode, operands[2]);
    }
}")

(define_expand "udivmodsi4"
  [(parallel [(set (match_operand:SI 0 "general_operand" "=a")
		   (udiv:SI (match_operand:SI 1 "general_operand" "0")
			    (match_operand:SI 2 "general_operand" "rm")))
	      (set (match_operand:SI 3 "general_operand" "=&d")
		   (umod:SI (match_dup 1) (match_dup 2)))])]
  ""
  "
{
  extern int optimize;
  if (optimize)
    {
      if (GET_CODE (operands[1]) == REG && REG_USERVAR_P (operands[1]))
	operands[1] = copy_to_mode_reg (SImode, operands[1]);
      if (GET_CODE (operands[2]) == REG && REG_USERVAR_P (operands[2]))
	operands[2] = copy_to_mode_reg (SImode, operands[2]);
    }
}")

(define_insn ""
  [(set (match_operand:SI 0 "general_operand" "=a")
	(div:SI (match_operand:SI 1 "general_operand" "0")
		(match_operand:SI 2 "general_operand" "rm")))
   (set (match_operand:SI 3 "general_operand" "=&d")
	(mod:SI (match_dup 1) (match_dup 2)))]
  ""
  "extlq\;divs%L0	%2")

(define_insn ""
  [(set (match_operand:SI 0 "general_operand" "=a")
	(udiv:SI (match_operand:SI 1 "general_operand" "0")
		(match_operand:SI 2 "general_operand" "rm")))
   (set (match_operand:SI 3 "general_operand" "=&d")
	(umod:SI (match_dup 1) (match_dup 2)))]
  ""
  "clr%L0	%3\;divu%L0	%2")

/*
;;this should be a valid double division which we may want to add

(define_insn ""
  [(set (match_operand:SI 0 "general_operand" "=a")
	(udiv:DI (match_operand:DI 1 "general_operand" "a")
		(match_operand:SI 2 "general_operand" "rm")))
   (set (match_operand:SI 3 "general_operand" "=d")
	(umod:SI (match_dup 1) (match_dup 2)))]
  ""
  "divu%L0	%2,%0")
*/

;;- and instructions

;; The `r' in `rm' for operand 3 looks redundant, but it causes
;; optional reloads to be generated if op 3 is a pseudo in a stack slot.

(define_insn "andsi3"
  [(set (match_operand:SI 0 "general_operand" "=rm,r")
	(and:SI (match_operand:SI 1 "general_operand" "%0,0")
		(match_operand:SI 2 "general_operand" "ri,rm")))]
  ""
  "and%L0	%2,%0")

(define_insn "andhi3"
  [(set (match_operand:HI 0 "general_operand" "=rm,r")
	(and:HI (match_operand:HI 1 "general_operand" "%0,0")
		(match_operand:HI 2 "general_operand" "ri,rm")))]
  ""
  "and%W0	%2,%0")

(define_insn "andqi3"
  [(set (match_operand:QI 0 "general_operand" "=m,q")
	(and:QI (match_operand:QI 1 "general_operand" "%0,0")
		(match_operand:QI 2 "general_operand" "qn,qmn")))]
  ""
  "and%B0	%2,%0")

/* I am nervous about these two.. add them later..
;I presume this means that we have something in say op0= eax which is small
;and we want to and it with memory so we can do this by just an
;andb m,%al  and have success.
(define_insn ""
  [(set (match_operand:SI 0 "general_operand" "=r")
	(and:SI (zero_extend:SI (match_operand:HI 1 "general_operand" "rm"))
		(match_operand:SI 2 "general_operand" "0")))]
  "GET_CODE (operands[2]) == CONST_INT
   && (unsigned int) INTVAL (operands[2]) < (1 << GET_MODE_BITSIZE (HImode))"
  "and%W0	%1,%0")

(define_insn ""
  [(set (match_operand:SI 0 "general_operand" "=q")
	(and:SI (zero_extend:SI (match_operand:QI 1 "general_operand" "qm"))
		(match_operand:SI 2 "general_operand" "0")))]
  "GET_CODE (operands[2]) == CONST_INT
   && (unsigned int) INTVAL (operands[2]) < (1 << GET_MODE_BITSIZE (QImode))"
  "and%L0	%1,%0")

*/



;;- Bit set (inclusive or) instructions

(define_insn "iorsi3"
  [(set (match_operand:SI 0 "general_operand" "=rm,r")
	(ior:SI (match_operand:SI 1 "general_operand" "%0,0")
		(match_operand:SI 2 "general_operand" "ri,rm")))]
  ""
  "or%L0	%2,%0")

(define_insn "iorhi3"
  [(set (match_operand:HI 0 "general_operand" "=rm,r")
	(ior:HI (match_operand:HI 1 "general_operand" "%0,0")
		(match_operand:HI 2 "general_operand" "ri,rm")))]
  ""
  "or%W0	%2,%0")

(define_insn "iorqi3"
  [(set (match_operand:QI 0 "general_operand" "=m,q")
	(ior:QI (match_operand:QI 1 "general_operand" "%0,0")
		(match_operand:QI 2 "general_operand" "qn,qmn")))]
  ""
  "or%B0	%2,%0")

;;- xor instructions

(define_insn "xorsi3"
  [(set (match_operand:SI 0 "general_operand" "=rm,r")
	(xor:SI (match_operand:SI 1 "general_operand" "%0,0")
		(match_operand:SI 2 "general_operand" "ri,rm")))]
  ""
  "eor%L0	%2,%0")

(define_insn "xorhi3"
  [(set (match_operand:HI 0 "general_operand" "=rm,r")
	(xor:HI (match_operand:HI 1 "general_operand" "%0,0")
		(match_operand:HI 2 "general_operand" "ri,rm")))]
  ""
  "eor%W0	%2,%0")

(define_insn "xorqi3"
  [(set (match_operand:QI 0 "general_operand" "=qm")
	(xor:QI (match_operand:QI 1 "general_operand" "%0")
		(match_operand:QI 2 "general_operand" "qn")))]
  ""
  "eor%B0	%2,%0")

;;- negation instructions
(define_insn "negsi2"
  [(set (match_operand:SI 0 "general_operand" "=rm")
	(neg:SI (match_operand:SI 1 "general_operand" "0")))]
  ""
  "neg%L0	%0")

(define_insn "neghi2"
  [(set (match_operand:HI 0 "general_operand" "=rm")
	(neg:HI (match_operand:HI 1 "general_operand" "0")))]
  ""
  "neg%W0	%0")

(define_insn "negqi2"
  [(set (match_operand:QI 0 "general_operand" "=qm")
	(neg:QI (match_operand:QI 1 "general_operand" "0")))]
  ""
  "neg%B0	%0")

(define_insn "negsf2"
  [(set (match_operand:SF 0 "general_operand" "=f,!m")
	(neg:SF (match_operand:SF 1 "general_operand" "0,0")))]
  "TARGET_80387"
  "*FP_CALL1 (\"fchs\")")

(define_insn "negdf2"
  [(set (match_operand:DF 0 "general_operand" "=f,!m")
	(neg:DF (match_operand:DF 1 "general_operand" "0,0")))]
  "TARGET_80387"
  "*FP_CALL1 (\"fchs\")")

;; Absolute value instructions

(define_insn "abssf2"
  [(set (match_operand:SF 0 "general_operand" "=f,!m")
	(abs:SF (match_operand:SF 1 "general_operand" "0,0")))]
  "TARGET_80387"
  "*FP_CALL1 (\"fabs\")")

(define_insn "absdf2"
  [(set (match_operand:DF 0 "general_operand" "=f,!m")
	(abs:DF (match_operand:DF 1 "general_operand" "0,0")))]
  "TARGET_80387"
  "*FP_CALL1 (\"fabs\")")

;;- one complement instructions
(define_insn "one_cmplsi2"
  [(set (match_operand:SI 0 "general_operand" "=rm")
	(not:SI (match_operand:SI 1 "general_operand" "0")))]
  ""
  "not%L0	%0")

(define_insn "one_cmplhi2"
  [(set (match_operand:HI 0 "general_operand" "=rm")
	(not:HI (match_operand:HI 1 "general_operand" "0")))]
  ""
  "not%W0	%0")

(define_insn "one_cmplqi2"
  [(set (match_operand:QI 0 "general_operand" "=qm")
	(not:QI (match_operand:QI 1 "general_operand" "0")))]
  ""
  "not%B0	%0")

;;- arithmetic shift instructions

(define_insn "ashlsi3"
  [(set (match_operand:SI 0 "general_operand" "=rm")
	(ashift:SI (match_operand:SI 1 "general_operand" "0")
		   (match_operand:SI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (asl%L0,%R0r1,%0);
  else if (REG_P (operands[1]) && GET_CODE (operands[2]) == CONST_INT
	   && INTVAL (operands[2]) == 1)
    return AS2 (add%L0,%1,%1);
  return AS2 (asl%L0,%2,%1);
}")

(define_insn "ashlhi3"
  [(set (match_operand:HI 0 "general_operand" "=rm")
	(ashift:HI (match_operand:HI 1 "general_operand" "0")
		   (match_operand:HI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (asl%W0,%R0r1,%0);
  else
    return AS2 (asl%W0,%2,%1);
}")

(define_insn "ashlqi3"
  [(set (match_operand:QI 0 "general_operand" "=qm")
	(ashift:QI (match_operand:QI 1 "general_operand" "0")
		   (match_operand:QI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (asl%B0,%R0r1,%0);
  else
    return AS2 (asl%B0,%2,%1);
}")

(define_insn "ashrsi3"
  [(set (match_operand:SI 0 "general_operand" "=rm")
	(ashiftrt:SI (match_operand:SI 1 "general_operand" "0")
		     (match_operand:SI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (asr%L0,%R0r1,%0);
  else
    return AS2 (asr%L0,%2,%0);
}")

(define_insn "ashrhi3"
  [(set (match_operand:HI 0 "general_operand" "=rm")
	(ashiftrt:HI (match_operand:HI 1 "general_operand" "0")
		     (match_operand:HI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (asr%W0,%R0r1,%0);
  else
    return AS2 (asr%W0,%2,%0);
}")

(define_insn "ashrqi3"
  [(set (match_operand:QI 0 "general_operand" "=qm")
	(ashiftrt:QI (match_operand:QI 1 "general_operand" "0")
		     (match_operand:QI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (asr%B0,%R0r1,%0);
  return
    AS2 (asr%B0,%2,%1);
}")

;;- logical shift instructions

(define_insn "lshlsi3"
  [(set (match_operand:SI 0 "general_operand" "=rm")
	(lshift:SI (match_operand:SI 1 "general_operand" "0")
		   (match_operand:SI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (lsl%L0,%R0r1,%0);
  else
    return AS2 (lsl%L0,%2,%1);
}")

(define_insn "lshlhi3"
  [(set (match_operand:HI 0 "general_operand" "=rm")
	(lshift:HI (match_operand:HI 1 "general_operand" "0")
		   (match_operand:HI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (lsl%W0,%R0r1,%0);
  else
    return AS2 (lsl%W0,%2,%1);
}")

(define_insn "lshlqi3"
  [(set (match_operand:QI 0 "general_operand" "=qm")
	(lshift:QI (match_operand:QI 1 "general_operand" "0")
		   (match_operand:QI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (lsl%B0,%R0r1,%0);
  else
    return AS2 (lsl%B0,%2,%1);
}")

(define_insn "lshrsi3"
  [(set (match_operand:SI 0 "general_operand" "=rm")
	(lshiftrt:SI (match_operand:SI 1 "general_operand" "0")
		     (match_operand:SI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (lsr%L0,%R0r1,%0);
  else
    return AS2 (lsr%L0,%2,%1);
}")

(define_insn "lshrhi3"
  [(set (match_operand:HI 0 "general_operand" "=rm")
	(lshiftrt:HI (match_operand:HI 1 "general_operand" "0")
		     (match_operand:HI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (lsr%W0,r1,%0);
  else
    return AS2 (lsr%W0,%2,%1);
}")

(define_insn "lshrqi3"
  [(set (match_operand:QI 0 "general_operand" "=qm")
	(lshiftrt:QI (match_operand:QI 1 "general_operand" "0")
		     (match_operand:QI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (lsr%B0,r1,%0);
  else
    return AS2 (lsr%B0,%2,%1);
}")

;;- rotate instructions

(define_insn "rotlsi3"
  [(set (match_operand:SI 0 "general_operand" "=rm")
	(rotate:SI (match_operand:SI 1 "general_operand" "0")
		   (match_operand:SI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (rol%L0,r1,%0);
  else
    return AS2 (rol%L0,%2,%1);
}")

(define_insn "rotlhi3"
  [(set (match_operand:HI 0 "general_operand" "=rm")
	(rotate:HI (match_operand:HI 1 "general_operand" "0")
		   (match_operand:HI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (rol%W0,r1,%0);
  else
    return AS2 (rol%W0,%2,%1);
}")

(define_insn "rotlqi3"
  [(set (match_operand:QI 0 "general_operand" "=qm")
	(rotate:QI (match_operand:QI 1 "general_operand" "0")
		   (match_operand:QI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (rol%B0,r1,%0);
  else
    return AS2 (rol%B0,%2,%1);
}")

(define_insn "rotrsi3"
  [(set (match_operand:SI 0 "general_operand" "=rm")
	(rotatert:SI (match_operand:SI 1 "general_operand" "0")
		     (match_operand:SI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (ror%L0,r1,%0);
  else
    return AS2 (ror%L0,%2,%1);
}")

(define_insn "rotrhi3"
  [(set (match_operand:HI 0 "general_operand" "=rm")
	(rotatert:HI (match_operand:HI 1 "general_operand" "0")
		     (match_operand:HI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (ror%W0,r1,%0);
  else
    return AS2 (ror%W0,%2,%1);
}")

(define_insn "rotrqi3"
  [(set (match_operand:QI 0 "general_operand" "=qm")
	(rotatert:QI (match_operand:QI 1 "general_operand" "0")
		     (match_operand:QI 2 "general_operand" "cI")))]
  ""
  "*
{
  if (REG_P (operands[2]))
    return AS2 (ror%B0,r1,%0);
  else
    return AS2 (ror%B0,%2,%1);
}")

;; Store-flag instructions.
;; These clear the cc_status because the output register
;; might be the same register previously tested.

(define_insn "seq"
  [(set (match_operand:QI 0 "general_operand" "=q")
	(eq (cc0) (const_int 0)))]
  ""
  "*
  CC_STATUS_INIT;
  return \"sete	%0\";
")

(define_insn "sne"
  [(set (match_operand:QI 0 "general_operand" "=q")
	(ne (cc0) (const_int 0)))]
  ""
  "*
  CC_STATUS_INIT;
  return \"setne	%0\";
")

(define_insn "sgt"
  [(set (match_operand:QI 0 "general_operand" "=q")
	(gt (cc0) (const_int 0)))]
  ""
  "*
  CC_STATUS_INIT;
  OUTPUT_JUMP (\"setg	%0\", \"seta	%0\", 0);
")

(define_insn "sgtu"
  [(set (match_operand:QI 0 "general_operand" "=q")
	(gtu (cc0) (const_int 0)))]
  ""
  "*
  CC_STATUS_INIT;
  return \"seta	%0\"; ")

(define_insn "slt"
  [(set (match_operand:QI 0 "general_operand" "=q")
	(lt (cc0) (const_int 0)))]
  ""
  "*
  CC_STATUS_INIT;
  OUTPUT_JUMP (\"setl	%0\", \"setb	%0\", \"sets	%0\"); ")

(define_insn "sltu"
  [(set (match_operand:QI 0 "general_operand" "=q")
	(ltu (cc0) (const_int 0)))]
  ""
  "*
  CC_STATUS_INIT;
  return \"setb	%0\"; ")

(define_insn "sge"
  [(set (match_operand:QI 0 "general_operand" "=q")
	(ge (cc0) (const_int 0)))]
  ""
  "*
  CC_STATUS_INIT;
  OUTPUT_JUMP (\"setge	%0\", \"setae	%0\", \"setns	%0\"); ")

(define_insn "sgeu"
  [(set (match_operand:QI 0 "general_operand" "=q")
	(geu (cc0) (const_int 0)))]
  ""
  "*
  CC_STATUS_INIT;
  return \"setae	%0\"; ")

(define_insn "sle"
  [(set (match_operand:QI 0 "general_operand" "=q")
	(le (cc0) (const_int 0)))]
  ""
  "*
  CC_STATUS_INIT;
  OUTPUT_JUMP (\"setle	%0\", \"setbe	%0\", 0);
")

(define_insn "sleu"
  [(set (match_operand:QI 0 "general_operand" "=q")
	(leu (cc0) (const_int 0)))]
  ""
  "*
  CC_STATUS_INIT;
  return \"setbe	%0\"; ")

;; Basic conditional jump instructions.
;; We ignore the overflow flag for signed branch instructions.

(define_insn "beq"
  [(set (pc)
	(if_then_else (eq (cc0)
			  (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "jeq	%l0")

(define_insn "bne"
  [(set (pc)
	(if_then_else (ne (cc0)
			  (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "jne	%l0")

(define_insn "bgt"
  [(set (pc)
	(if_then_else (gt (cc0)
			  (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "*OUTPUT_JUMP (\"jgt	%l0\", \"jhi	%l0\", 0)")

(define_insn "bgtu"
  [(set (pc)
	(if_then_else (gtu (cc0)
			   (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "jhi	%l0")

;; There is no jump insn to check for `<' on IEEE floats.
;; Page 17-80 in the 80387 manual says jb, but that's wrong;
;; jb checks for `not >='.  So swap the operands and do `>'.
(define_expand "blt"
  [(set (pc)
	(if_then_else (lt (cc0)
			  (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "
{
  extern rtx sequence_stack;
  rtx prev = XEXP (XEXP (sequence_stack, 1), 0);
  rtx body = PATTERN (prev);
  rtx comp;
  if (GET_CODE (body) == SET)
    comp = SET_SRC (body);
  else
    comp = SET_SRC (XVECEXP (body, 0, 0));

  if (GET_CODE (comp) == COMPARE
      ? GET_MODE_CLASS (GET_MODE (XEXP (comp, 0))) == MODE_FLOAT
      : GET_MODE_CLASS (GET_MODE (comp)) == MODE_FLOAT)
    {
      if (GET_CODE (comp) == COMPARE)
	{
	  rtx op0 = XEXP (comp, 0);
	  rtx op1 = XEXP (comp, 1);
	  XEXP (comp, 0) = op1;
	  XEXP (comp, 1) = op0;
	}
      else
	{
	  rtx new = gen_rtx (COMPARE, VOIDmode,
			     CONST0_RTX (GET_MODE (comp)), comp);
	  if (GET_CODE (body) == SET)
	    SET_SRC (body) = new;
	  else
	    SET_SRC (XVECEXP (body, 0, 0)) = new;
	}
      emit_insn (gen_bgt (operands[0]));
      DONE;
    }
}")

(define_insn ""
  [(set (pc)
	(if_then_else (lt (cc0)
			  (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "*OUTPUT_JUMP (\"jlt	%l0\", \"jlo	%l0\", \"jmi	%l0\")")

(define_insn "bltu"
  [(set (pc)
	(if_then_else (ltu (cc0)
			   (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "jlo	%l0")

(define_insn "bge"
  [(set (pc)
	(if_then_else (ge (cc0)
			  (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "*OUTPUT_JUMP (\"jge	%l0\", \"jhs	%l0\", \"jpl	%l0\")")

(define_insn "bgeu"
  [(set (pc)
	(if_then_else (geu (cc0)
			   (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "jhs	%l0")

;; See comment on `blt', above.
(define_expand "ble"
  [(set (pc)
	(if_then_else (le (cc0)
			  (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "
{
  extern rtx sequence_stack;
  rtx prev = XEXP (XEXP (sequence_stack, 1), 0);
  rtx body = PATTERN (prev);
  rtx comp;
  if (GET_CODE (body) == SET)
    comp = SET_SRC (body);
  else
    comp = SET_SRC (XVECEXP (body, 0, 0));

  if (GET_CODE (comp) == COMPARE
      ? GET_MODE_CLASS (GET_MODE (XEXP (comp, 0))) == MODE_FLOAT
      : GET_MODE_CLASS (GET_MODE (comp)) == MODE_FLOAT)
    {
      if (GET_CODE (comp) == COMPARE)
	{
	  rtx op0 = XEXP (comp, 0);
	  rtx op1 = XEXP (comp, 1);
	  XEXP (comp, 0) = op1;
	  XEXP (comp, 1) = op0;
	}
      else
	{
	  rtx new = gen_rtx (COMPARE, VOIDmode,
			     CONST0_RTX (GET_MODE (comp)), comp);
	  if (GET_CODE (body) == SET)
	    SET_SRC (body) = new;
	  else
	    SET_SRC (XVECEXP (body, 0, 0)) = new;
	}
      emit_insn (gen_bge (operands[0]));
      DONE;
    }
}")

(define_insn ""
  [(set (pc)
	(if_then_else (le (cc0)
			  (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "*OUTPUT_JUMP (\"jle	%l0\", \"jls	%l0\", 0) ")

(define_insn "bleu"
  [(set (pc)
	(if_then_else (leu (cc0)
			   (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "jls	%l0")

;; Negated conditional jump instructions.

(define_insn ""
  [(set (pc)
	(if_then_else (eq (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "jne	%l0")

(define_insn ""
  [(set (pc)
	(if_then_else (ne (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "jeq	%l0")

(define_insn ""
  [(set (pc)
	(if_then_else (gt (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "*OUTPUT_JUMP (\"jle	%l0\", \"jls	%l0\", 0) ")

(define_insn ""
  [(set (pc)
	(if_then_else (gtu (cc0)
			   (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "jls	%l0")

(define_insn ""
  [(set (pc)
	(if_then_else (lt (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "*OUTPUT_JUMP (\"jge	%l0\", \"jhs	%l0\", \"jpl	%l0\")
")

(define_insn ""
  [(set (pc)
	(if_then_else (ltu (cc0)
			   (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "jhs	%l0")

(define_insn ""
  [(set (pc)
	(if_then_else (ge (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "*OUTPUT_JUMP (\"jlt	%l0\", \"jlo	%l0\", \"jmi	%l0\")")

(define_insn ""
  [(set (pc)
	(if_then_else (geu (cc0)
			   (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "jlo	%l0")

(define_insn ""
  [(set (pc)
	(if_then_else (le (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "*OUTPUT_JUMP (\"jgt	%l0\", \"jhi	%l0\", 0)")

(define_insn ""
  [(set (pc)
	(if_then_else (leu (cc0)
			   (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "jhi	%l0")

;; Unconditional and other jump instructions
(define_insn "jump"
  [(set (pc)
	(label_ref (match_operand 0 "" "")))]
  ""
  "jmp	%l0")

(define_insn "tablejump"
  [(set (pc) (match_operand:SI 0 "general_operand" "rm"))
   (use (label_ref (match_operand 1 "" "")))]
  ""
  "*
{
  CC_STATUS_INIT;

  return \"jmp	%*%0\";
}")

/*
(define_insn ""
  [(set (pc)
	(if_then_else
	 (ne (compare (minus:HI (match_operand:HI 0 "general_operand" "c")
				(const_int 1))
		      (const_int -1))
	     (const_int 0))
	 (label_ref (match_operand 1 "" "g"))
	 (pc)))
   (set (match_dup 0)
	(minus:HI (match_dup 0)
		  (const_int 1)))]
  ""
  "loop	%l1")

(define_insn ""
  [(set (pc)
	(if_then_else
	 (ne (compare (const_int -1)
		      (minus:SI (match_operand:SI 0 "general_operand" "c")
				(const_int 1)))
	     (const_int 0))
	 (label_ref (match_operand 1 "" "g"))
	 (pc)))
   (set (match_dup 0)
	(minus:SI (match_dup 0)
		  (const_int 1)))]
  ""
  "loop	%l1")
*/

;; Call subroutine returning no value.
(define_insn "call"
  [(call (match_operand:QI 0 "indirect_operand" "m")
	 (match_operand:SI 1 "general_operand" "g"))]
  ;; Operand 1 not really used on the m68000.
  ""
  "*
{
  if (GET_CODE (operands[0]) == MEM
      && ! CONSTANT_ADDRESS_P (XEXP (operands[0], 0)))
    {
      operands[0] = XEXP (operands[0], 0);
      return \"call	%*%0\";
    }
  else
    return \"call	%0\";
}")

;; Call subroutine, returning value in operand 0
;; (which must be a hard register).
(define_insn "call_value"
  [(set (match_operand 0 "" "=rf")
	(call (match_operand:QI 1 "indirect_operand" "m")
	      (match_operand:SI 2 "general_operand" "g")))]
  ;; Operand 2 not really used on the m68000.
  ""
  "*
{
  if (GET_CODE (operands[1]) == MEM
      && ! CONSTANT_ADDRESS_P (XEXP (operands[1], 0)))
    {
      operands[1] = XEXP (operands[1], 0);
      output_asm_insn (\"call	%*%1\", operands);
    }
  else
    output_asm_insn (\"call	%1\", operands);

#ifndef FMTOWNS
  if (TARGET_80387)
#endif
    if (GET_MODE (operands[0]) == DFmode
	|| GET_MODE (operands[0]) == SFmode)
      {
  /*      fp_pop_level++; */
	/* pop if reg dead */
	if (!FP_REG_P (operands[0]))
	  abort ();
	if (top_dead_p (insn))
	  {
	    POP_ONE_FP;
	  }
      }
  RET;
}")

(define_insn "nop"
  [(const_int 0)]
  ""
  "nop")

;;- Local variables:
;;- mode:emacs-lisp
;;- comment-start: ";;- "
;;- eval: (set-syntax-table (copy-sequence (syntax-table)))
;;- eval: (modify-syntax-entry ?[ "(]")
;;- eval: (modify-syntax-entry ?] ")[")
;;- eval: (modify-syntax-entry ?{ "(}")
;;- eval: (modify-syntax-entry ?} "){")
;;- End:
