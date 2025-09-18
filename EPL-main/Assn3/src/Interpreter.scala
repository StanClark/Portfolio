package Assign3.Interpreter

import Assign3.Parser.Parser
import Assign3.Syntax.Syntax._
import Assign3.Typer.Typer
import Assign3.Bags.Bags.BagImpl
import scala.collection.immutable.ListMap

object Interpreter {

  // ======================================================================
  // Capture-avoiding substitution
  // ======================================================================

  val generator = SymGenerator()

  object SubstExpr extends Substitutable[Expr] {
    // swap y and z in e
    def swap(e: Expr, y: Variable, z: Variable): Expr =
      def go(e: Expr): Expr = e match {
        // Value must be closed
        case v: Value => v

        case Unit => Unit

        case Num(n) => Num(n)
        case Plus(e1, e2) => Plus(go(e1), go(e2))
        case Minus(e1, e2) => Minus(go(e1), go(e2))
        case Times(e1, e2) => Times(go(e1), go(e2))

        case Bool(b) => Bool(b)
        case Eq(e1, e2) => Eq(go(e1), go(e2))
        case Less(e1, e2) => Less(go(e1), go(e2))
        case IfThenElse(e, e1, e2) => IfThenElse(go(e), go(e1), go(e2))

        case Str(s) => Str(s)
        case Length(e) => Length(go(e))
        case Index(e1, e2) => Index(go(e1), go(e2))
        case Concat(e1, e2) => Concat(go(e1), go(e2))

        case Var(x) => Var(swapVar(x,y,z))
        case Let(x,e1,e2) => Let(swapVar(x,y,z),go(e1),go(e2))

        case Anno(e, ty) => Anno(go(e), ty)
        // case Inst(e, ty) => Inst(go(e), ty)

        case Pair(e1,e2) => Pair(go(e1),go(e2))
        case First(e) => First(go(e))
        case Second(e) => Second(go(e))

        case Lambda(x,e) => Lambda(swapVar(x,y,z),go(e))
        case Apply(e1,e2) => Apply(go(e1),go(e2))
        case Rec(f,x,e) => Rec(swapVar(f,y,z), swapVar(x,y,z), go(e))

        case Record(es) => Record(es.map((x, e) => (x, go(e))))
        case Proj(e, l) => Proj(go(e), l)

        case Variant(l, e) => Variant(l, go(e))
        case Case(e, cls) => Case(go(e), cls.map((l, entry) =>
          val (x, e) = entry
          (l, (swapVar(x,y,z), go(e)))))

        case Bag(es) => Bag(es.map(e => go(e)))
        case FlatMap(e1, e2) => FlatMap(go(e1), go(e2))
        case When(e1, e2) => When(go(e1), go(e2))
        case Sum(e1, e2) => Sum(go(e1), go(e2))
        case Diff(e1, e2) => Diff(go(e1), go(e2))
        case Comprehension(e, es) => Comprehension(go(e), es.map(e => go(e)))
        case Bind(x, e) => Bind(swapVar(x,y,z), go(e))
        case Guard(e) => Guard(go(e))
        case CLet(x, e) => CLet(swapVar(x,y,z), go(e))
        case Count(e1, e2) => Count(go(e1), go(e2))

        case LetPair(x1,x2,e1,e2) =>
          LetPair(swapVar(x1,y,z),swapVar(x2,y,z),go(e1),go(e2))
        case LetFun(f,ty,x,e1,e2) =>
          LetFun(swapVar(f,y,z),ty,swapVar(x,y,z),go(e1),go(e2))
        case LetRec(f,ty,x,e1,e2) =>
          LetRec(swapVar(f,y,z),ty,swapVar(x,y,z),go(e1),go(e2))
        case LetRecord(xs,e1,e2) =>
          LetRecord(xs.map((l,x) => (l, swapVar(x,y,z))),go(e1),go(e2))
        }
      go(e)

    ////////////////////
    // EXERCISE 4     //
    ////////////////////
    def subst(e1: Expr, e2: Expr, x: Variable): Expr = {
      sys.error("todo")
    }

  }
  import SubstExpr.{subst}


  
  // ======================================================================
  // Desugaring and Type Erasure
  // ======================================================================

    ////////////////////
    // EXERCISE 5     //
    ////////////////////
  def desugar(e: Expr): Expr = e match {
    // Value
    case v: Value =>
      sys.error("desugar: there shouldn't be any values here")

    case _ => sys.error("todo")
  }


  // ======================================================================
  // Primitive operations
  // ======================================================================

  object Value {
    // utility methods for operating on values
    def add(v1: Value, v2: Value): Value = (v1, v2) match
      case (NumV(v1), NumV(v2)) => NumV (v1 + v2)
      case _ => sys.error("arguments to addition are non-numeric")

    def subtract(v1: Value, v2: Value): Value = (v1, v2) match
      case (NumV(v1), NumV(v2)) => NumV (v1 - v2)
      case _ => sys.error("arguments to subtraction are non-numeric")

    def multiply(v1: Value, v2: Value): Value = (v1, v2) match
      case (NumV(v1), NumV(v2)) => NumV (v1 * v2)
      case _ => sys.error("arguments to multiplication are non-numeric")

    def eq(v1: Value, v2: Value): Value = (v1, v2) match
      case (NumV(v1), NumV(v2)) => BoolV (v1 == v2)
      case (BoolV(v1), BoolV(v2)) => BoolV (v1 == v2)
      case (StringV(v1), StringV(v2)) => BoolV (v1 == v2)
      case (PairV(v11, v12), PairV(v21, v22)) => BoolV (v11 == v21 && v12 == v22)
      case (VariantV(l1, v1), VariantV(l2, v2)) => BoolV (l1 == l2 && v1 == v2)
      // no comparision for bags and records currently
      case _ => sys.error("arguments to = are not comparable")

    def less(v1: Value, v2: Value): Value = (v1, v2) match
      case (NumV(v1), NumV(v2)) => BoolV (v1 < v2)
      case _ => sys.error("arguments to < are not comparable")

    def length(v: Value): Value = v match
      case StringV(v1) => NumV(v1.length)
      case _ => sys.error("argument to length is not a string")

    def index(v1: Value, v2: Value): Value = (v1, v2) match
      case (StringV(v1), NumV(v2)) => StringV(v1.charAt(v2).toString)
      case _ => sys.error("arguments to index are not valid")

    def concat(v1: Value, v2: Value): Value = (v1, v2) match
      case (StringV(v1), StringV(v2)) => StringV(v1 ++ v2)
      case _ => sys.error("arguments to concat are not strings")
  }



  // ======================================================================
  // Evaluation
  // ======================================================================

    ////////////////////
    // EXERCISE 6     //
    ////////////////////
  def eval (e : Expr): Value = e match {
    // Value
    case v: Value => v

    case _ => sys.error("todo")
  }

  /////////////////////////////////////////////////////////
  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
  // THE REST OF THIS FILE SHOULD NOT NEED TO BE CHANGED //
  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
  /////////////////////////////////////////////////////////
  
  // ======================================================================
  // Some simple programs
  // ======================================================================

  // The following examples illustrate how to embed Frog source code into
  // Scala using multi-line comments, and parse it using parser.parseStr.

  // Example 1: the swap function
  def example1: Expr = parser.parseStr("""
    let swap = \ x . (snd(x), fst(x)) in
    swap(42,17)
    """)

  val parser = new Parser

  // ======================================================================
  // Main
  // ======================================================================

  object Main {
    def typecheck(ast: Expr):Type =
      Typer.tyInfer(ListMap(), ast);

    def evaluate(ast: Expr):Value =
      eval(ast)

    def showResult(ast: Expr) = {
      println("AST:  " + ast.toString + "\n")

      try {
        print("Type Checking...");
        val ty = typecheck(ast);
        println("Done!");
        println("Type of Expression: " + ty.toString + "\n") ;
      } catch {
          case e:Throwable => println("Error: " + e)
      }
      try {
        println("Desugaring...");
        val core_ast = desugar(ast);
        println("Done!");
        println("Desugared AST: " + core_ast.toString + "\n") ;

        println("Evaluating...");
        println("Result: " + evaluate(core_ast))
      } catch {
        case e:Throwable => {
          println("Error: " + e)
          println("Evaluating raw AST...");
          println("Result: " + evaluate(ast))
        }
      }
    }

    def start(): Unit = {
      println("Welcome to Frog! (V1.0, October 22, 2024)");
      println("Enter expressions to evaluate, :load <filename.fish> to load a file, or :quit to quit.");
      println("This REPL can only read one line at a time, use :load to load larger expressions.");
      repl()
    }

    def repl(): Unit = {
      print("Frog> ");
      val input = scala.io.StdIn.readLine();
      if(input == ":quit") {
        println("Goodbye!")
      }
      else if (input.startsWith(":load")) {
        try {
          val ast = parser.parse(input.substring(6));
          showResult(ast)
        } catch {
          case e:Throwable => println("Error: " + e)
        }
        repl()
      } else {
        try {
          val ast = parser.parseStr(input);
          showResult(ast)
        } catch {
          case e:Throwable => println("Error: " + e)
        }
        repl()
      }
    }
  }

  def main( args:Array[String] ):Unit = {
    if(args.length == 0) {
      Main.start()
    } else {
      try {
        print("Parsing...");
        val ast = parser.parse(args.head)
        println("Done!");
        Main.showResult(ast)
      } catch {
        case e:Throwable => println("Error: " + e)
      }
    }
  }

}
