package Assign3.Typer

import Assign3.Syntax.Syntax._
import scala.collection.immutable.ListMap

object Typer {
  // ======================================================================
  // Part 1: Typechecking
  // ======================================================================

  val generator = SymGenerator()


  def isEqType(ty: Type): Boolean = ty match {
    case TyUnit | TyInt | TyString | TyBool => true
    case TyVariant(tys) => tys.forall((l, ty0) => isEqType(ty0))
    case TyPair(ty1, ty2) => isEqType(ty1) && isEqType(ty2)
    case _ => false
  }

    ////////////////////
    // EXERCISE 2     //
    ////////////////////
  def subtype(ty1: Type, ty2: Type): Boolean = (ty1, ty2) match {
    case (TyUnit, TyUnit) => true
    case (TyInt, TyInt) => true
    case (TyBool, TyBool) => true
    case (TyString, TyString) => true

    case (TyPair(t1, t2), TyPair(p1,p2)) =>
      if (subtype(t1,p2) & subtype(t2,p2)) true
      else false
    
    case (TyFun(in1, out1), TyFun(in2,out2)) =>
      if (subtype(in1,in2) & subtype(out1,out2)) true
      else false

    case (TyBag(t1), TyBag(t2)) => subtype(t1,t2)

    case (TyRecord(fields1), TyRecord(fields2)) =>
      fields2.forall{
        case(name1, ty1) =>
          fields1.get(name1) match {
            case Some(ty2) =>  subtype(ty1,ty2)
            case _ => false
          }
      }
    
    case (TyVariant(fields1), TyVariant(fields2)) =>
      fields1.forall{
        case(name1, ty1) =>
          fields2.get(name1) match {
            case Some(ty2) =>  subtype(ty1,ty2)
            case _ => false
            
          }
      }
    case _ => false
  }


    ////////////////////
    // EXERCISE 3     //
    ////////////////////
  // checking mode
  def tyCheck(ctx: Env, e: Expr, ty: Type): Unit = (e, ty) match {

    // pairs have both checking and inference modes
    case (Pair(e1, e2), TyPair(ty1, ty2)) =>
      tyCheck(ctx, e1, ty1)
      tyCheck(ctx, e2, ty2)
    
    case (IfThenElse(condition, e1,e2), ty) =>
      tyCheck(ctx, condition, TyBool)
      tyCheck(ctx, e1, ty)
      tyCheck(ctx, e2, ty)
    
    case (Let(x,e1,e2), ty) =>
      val e1Type = tyInfer(ctx, e1)
      tyCheck(ctx + (x -> e1Type), e2, ty)
    
    case (Lambda(x,e), TyFun(inTy, outTy)) =>
      tyCheck(ctx + (x -> inTy), e, outTy)
    
    case (Rec(f,x,e), TyFun(inTy, outTy)) =>
      tyCheck(ctx + (f -> TyFun(inTy,outTy)) + (x -> inTy), e, outTy)
    
    case (Record(es), TyRecord(tys)) =>
      if(tys.size <= es.size){
        for ((label, expr) <- es){
          if(tys.contains(label)){
            tyCheck(ctx, expr, tys(label))
          }
          else{
            tyInfer(ctx, expr)
          }
        }
      }
      else{
        sys.error("type record should not be longer than record")
      }
    
    case (Proj(e,l), t) =>
      tyCheck(ctx, e, TyRecord(ListMap(l -> t)))

    case (Variant(label, e), TyVariant(tys)) => //check tyvariant
      if (tys.contains(label)){
        val expectedType = tys.get(label)

        tyCheck(ctx, e, expectedType)
      }
      else{
        sys.error("variant label not found in Tyvariant")
      }
    
    case (Case(e, cls), t) =>
      tyInfer(ctx, e) match {
        case TyVariant(const) => 

      }
    case _ => sys.error("todo")
  }

  // inference mode
  def tyInfer(ctx: Env, e: Expr): Type = e match {
    // Value
    case v:Value => sys.error("tyCheck: values should not appear at this stage")

    // Arithmetic
    case Unit => (TyUnit)
    case Num(_) => (TyInt)
    case Plus(e1, e2) =>
      tyCheck(ctx, e1, TyInt)
      tyCheck(ctx, e2, TyInt)
      (TyInt)
    case Minus(e1, e2) =>
      tyCheck(ctx, e1, TyInt)
      tyCheck(ctx, e2, TyInt)
      (TyInt)
    case Times(e1, e2) =>
      tyCheck(ctx, e1, TyInt)
      tyCheck(ctx, e2, TyInt)
      (TyInt)

    // Booleans
    case Bool(_) => (TyBool)
    case Eq(e1, e2) =>
      val ty = tyInfer(ctx,e1)
      if (!isEqType(ty)) {
        sys.error("tyCheck: cannot test equality of type " ++ ty.toString)
      }
      tyCheck(ctx, e2, ty)
      (TyBool)
    case Less(e1, e2) =>
      tyCheck(ctx, e1, TyInt)
      tyCheck(ctx, e2, TyInt)
      (TyBool)
    case IfThenElse(e, e1, e2) =>
      tyCheck(ctx, e, TyBool)
      val ty = tyInfer(ctx,e1)
      tyCheck(ctx, e2, ty)
      (ty)

    // Pairing
    case Pair(e1, e2) =>
      val ty1 = tyInfer(ctx, e1)
      val ty2 = tyInfer(ctx, e2)
      TyPair(ty1, ty2)
    case First(e) => tyInfer(ctx, e) match {
      case TyPair(ty1, _) => ty1
      case _ => sys.error("tyInfer: expected pair type")
    }
    case Second(e) => tyInfer(ctx, e) match {
      case TyPair(_, ty2) => ty2
      case _ => sys.error("tyInfer: expected pair type")
    }

    //String
    case Str(_) => (TyString)
    case Length(e) =>
      tyCheck(ctx, e, TyString)
      (TyInt)
    case Index(e1, e2) =>
      tyCheck(ctx, e1, TyString)
      tyCheck(ctx, e2, TyInt)
      (TyString)
    case Concat(e1,e2) =>
      tyCheck(ctx, e1, TyString)
      tyCheck(ctx, e2, TyString)
      (TyString)
    

    //Variables and let-bindings
    case Var(x) =>
      ctx.get(x) match {
        case Some(ty) => ty
        case None => sys.error("no type")
      }
    
    
    case Let(x, e1, e2) =>
      val ty = tyInfer(ctx, e1)

      val newCtx = ctx + (x -> ty)

      (tyInfer(newCtx, e2))

    case Anno(e, ty) =>
      tyCheck(ctx, e, ty)
      (ty)

    //Functions
    case Lambda(x,e) => // not sure this is needed
      val ty = tyInfer(ctx, e)
      val newCtx = ctx + (x -> ty)

      tyInfer(newCtx, e)
    
    case Apply(e1, e2) =>
      tyInfer(ctx, e1) match{
        case TyFun(param, output) =>
          tyCheck(ctx, e2, param)
          (param)
        case _ => sys.error("apply requires function")
      }
    
    //Records
    case Record(fields) =>
      val map = fields.map { case (label, expr) =>
        (label, tyInfer(ctx, expr))
      }

      TyRecord(map)
    
    case Proj(e,label) =>
      tyInfer(ctx, e) match{
        case TyRecord(es) =>
          es.get(label) match{
            case Some(ty) => ty
            case _ => sys.error("no such label")
          }
        case _ => sys.error("proj requires record")
          
      }
    
    case Variant(l, e) =>
      val ty = tyInfer(ctx,e)

      TyVariant(ListMap(l -> ty))
      

    case Case(e, cls) =>
      val varFields = tyInfer(ctx,e) match{
        case TyVariant(fields) => fields
        case _ => sys.error("Case expression requires variant as first param")
      }

      val head = cls.head
      val (fstlabel, (fstx, fstexp)) = head
      val fstType = varFields.getOrElse(fstlabel, sys.error(s"Label $fstlabel not found in variant fields"))

      val expectedType = tyInfer(ctx + (fstx -> fstType), fstexp)
      
      var cummContext = ctx

      cls.foreach{ case (label, (x, exp)) =>
        val xType = varFields.getOrElse(label, sys.error(s"Label $label not found in variant fields"))
        
        cummContext = cummContext + (x -> xType)
        // maybe should use check instead
        val foundType = tyInfer(cummContext + (x -> xType), exp) //tyInfer(ctx + (x -> xType), exp)

        if (!subtype(expectedType, foundType)){
          sys.error(s"unknown type constructor $label")
        }
        
      }

      expectedType
    //Bags
    case Bag(es) =>
      if (es.isEmpty) {
        sys.error("Cannot infer type for an empty bag")
      }
      val expectedType = tyInfer(ctx,es.head)

      es.foreach{e =>
        //val foundType = tyInfer(ctx,e)
        //if (!(expectedType == foundType)) { // Or `!subtype(expectedType, foundType)` if subtyping is desired
        //sys.error(s"Type mismatch: found $foundType, expected $expectedType for all elements in the bag.")
        //}

        tyCheck(ctx,e, expectedType)
      }

      TyBag(expectedType)
    
    case FlatMap(e1,e2) => //needs redone
      tyInfer(ctx, e1) match{
        case TyBag(t1) =>
          tyInfer(ctx, e2) match{
            case TyFun(t1, TyBag(returnTyp)) =>
              (TyBag(returnTyp))
          }
        case _ =>
          sys.error("expected bag type for flatmap first arg")
      }
    
    case Sum(e1,e2) =>
      val ty1 = tyInfer(ctx, e1) match{
        case TyBag(t) => TyBag(t)
        case _ => sys.error("expected bag type for first parameter of sum")
      }

      tyCheck(ctx, e2, ty1)

      (ty1)

    case Diff(e1, e2) =>
      val t1 = tyInfer(ctx, e1) match {
        case TyBag(t) => t
        case _ => sys.error("expected bag type for first parameter of diff")
      }

      tyCheck(ctx, e2, TyBag(t1))

      if(isEqType(t1)){
        (TyBag(t1))
      }else{
        sys.error(s"$t1 type does not support equality")
      }
    
    case Count(e1,e2) =>
      val t1 = tyInfer(ctx, e1) match {
        case TyBag(t) => t
        case _ => sys.error("expected bag type for first parameter of count")
      }

      tyCheck(ctx, e2, t1)

      if(isEqType(t1)){
        (TyInt)
      }else{
        sys.error(s"$t1 type does not support equality")
      }
    
    case Comprehension(returnExpr, es) =>
      var newCtx = ctx

      es.head match {
        case Guard(exp) =>
          tyCheck(ctx, exp, TyBool)
        
        case Bind(x, expr) =>
          tyInfer(ctx, expr) match {
            case TyBag(bagTy) =>
              newCtx = newCtx + (x -> bagTy)
            case _ => ("bag expected for bind")
          }
        
        case CLet(x, e) =>
          val exprType = tyInfer(ctx, e)
          newCtx = newCtx + (x -> exprType)
      }

      if (es.tail.length == 0) {
        TyBag(tyInfer(ctx, returnExpr))
      }else {
        tyInfer(ctx, Comprehension(returnExpr, es.tail))
      }
    
    case LetFun(f, TyFun(paramTy, returnTy), arg, e1, e2) =>
      tyCheck(ctx + (arg -> paramTy), e1, returnTy)

      tyInfer(ctx + (f -> TyFun(paramTy, returnTy)), e2)
      
    case LetRec(f, TyFun(paramTy, returnTy), arg, e1, e2) =>
      tyCheck(ctx + (f -> TyFun(paramTy, returnTy)) + (arg -> paramTy), e1, returnTy)
      tyInfer(ctx + (f -> TyFun(paramTy, returnTy)), e2)
    
    case LetPair(x,y,e1,e2) =>
      tyInfer(ctx, e1) match{
        case TyPair(t1,t2) =>
          tyInfer(ctx + (x -> t1) + (y -> t2), e2)
        case _ => sys.error("expected pair type for let pair")
      }
    
    case LetRecord(xs,e1,e2) =>
      var newCtx = ctx
      tyInfer(ctx, e1) match {
        case TyRecord(fields) => 
          for((label, fType) <- fields){
            newCtx = newCtx + (xs(label) -> fType)
          }
          tyInfer(newCtx, e2)

        case _ => sys.error("expected record type for 2nd param of LetRecord") 
      } 


    

    case _ => sys.error("todo")
  }
}