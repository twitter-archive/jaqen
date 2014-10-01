package com.twitter.jaqen.ntuple

import scala.language.experimental.macros
import scala.reflect.macros.Context
import scala.collection.IterableLike
import scala.collection.immutable.Iterable
import scala.reflect.internal.FlagSets
import scala.reflect.internal.Flags
import scala.reflect.internal.Symbols

object NTupleMacros {

  private def fail(c: Context)(message: String) = {
    import c.universe._
    c.abort(c.enclosingPosition, message)
  }

  private def keyName(c: Context)(key: c.Tree): Any = {
    import c.universe._
    key match {
      case Literal(Constant(v)) => v
      case Apply(Select(Select(Ident(scala), symbol), apply), List(Literal(Constant(key))))
                   if (apply.decodedName.toString == "apply" && scala.decodedName.toString == "scala")
                     => key
      case _ => fail(c)(show(key) + " is not a literal")
    }
  }

  private def keyNameToKeyType(c: Context)(name: Any): c.universe.Type = {
    import c.universe._
    import compat._
    ConstantType(Constant(name))
  }

  private def keyTypeToKeyName(c: Context)(t: c.Type) = {
    import c.universe._
    t match {
      case ConstantType(Constant(name)) => name
      case _ => fail(c)(showRaw(t) + " type is not understood")
    }
  }

  private def pairToKV(c: Context)(pair: c.Expr[Any]): (Any, c.universe.Tree) = {
    import c.universe._

    pair.tree match {
      // TODO: allow tuple2
      case Apply(
             TypeApply(Select(
                 Apply(
                     TypeApply(Select(Select(This(_), _), assoc), List(TypeTree())),
                     List(key)
                 ),
                 arrow
             ),
             List(TypeTree())),
             List(value)
          ) if (arrow.decodedName.toString == "->" &&
            (assoc.decodedName.toString == "any2ArrowAssoc" || assoc.decodedName.toString == "ArrowAssoc"))
             => (keyName(c)(key), value)
      // allow identifiers directly
      case value@Ident(name) => (name.decodedName.toString, value)
      // do we want magically named "expression" -> expression ?
//      case v => (show(v), v)
      case _ => fail(c)(show(pair.tree) + " is not a valid key-value pair")
    }
  }

  private def wttToParams(c: Context)(wtt: c.WeakTypeTag[_]) = {
    import c.universe._
    wtt.tpe match {
      case TypeRef(ThisType(ntuplePackage), nTupleName, parameters) if (nTupleName.fullName.contains("NTuple")) => parameters
      case _ => fail(c)(showRaw(wtt) + " is not an understood type")
    }
  }

  private def keys(c: Context)(params: List[c.universe.Type]) = {
    import c.universe._
    params
      .zipWithIndex
      .filter(_._2 % 2 == 0)
      .map((t) => keyTypeToKeyName(c)(t._1))
  }

  private def types(c: Context)(params: List[c.universe.Type]) = {
    import c.universe._
    params
      .zipWithIndex
      .filter(_._2 % 2 == 1)
      .map(_._1)
  }

  private def derefField(c: Context)(tree: c.universe.Tree, index: Int) = {
    import c.universe._
    Select(tree, newTermName("_" + (index + 1)))
  }

  private def classType(c: Context)(className: String, typeParams: List[c.universe.Type]) = {
    import c.universe._
    val rawType = c.mirror.staticClass(className).toType
    appliedType(rawType.typeConstructor, typeParams)
  }

  private def nTupleType(c: Context)(size: Int, typeParams: List[c.universe.Type]) = {
    classType(c)(classOf[NTuple[_]].getName() + size, typeParams)
  }

  private def newTuple(c: Context)(finalTypeParams: List[c.universe.Type], finalParams: List[c.universe.Tree]) = {
    import c.universe._
    try {
      val distinctKeys = keys(c)(finalTypeParams)
          .foldLeft(Set.empty[Any])(
              (agg, key) =>
                if (agg.contains(key))
                  fail(c)(show(c.prefix.tree) + " already contains key " + key)
                else
                  agg + key
          )
      if (distinctKeys.size != finalParams.size) {
        fail(c)("keys size does not match values size " + distinctKeys.size + " != " + finalParams.size)
      }
      val t = classType(c)(classOf[NTuple[_]].getName() + finalParams.size, finalTypeParams)
      c.Expr[Any](q"new $t(..$finalParams)")
    } catch {
      case e: scala.reflect.internal.MissingRequirementError => fail(c)("no NTuple of size " + finalParams.size)
    }
  }

  private def mkTypeParams(c: Context)(keys: Iterable[Any], types: Iterable[c.universe.Type]) = keys.zip(types).flatMap {
        case (key, value) => List(keyNameToKeyType(c)(key), value)
      }.toList

  private def keyIndex[T](c: Context)(key: c.Expr[Any], wtt: c.WeakTypeTag[T]) = {
    import c.universe._
    val kName = keyName(c)(key.tree)
    val params = wttToParams(c)(wtt)
    val r = keys(c)(params).zipWithIndex.collect {
          case (name, index) if (name == kName) => index
        }
    if (r.isEmpty) c.abort(c.enclosingPosition, show(c.prefix.tree) + " does not contain key " + kName)
    else if (r.size > 1) fail(c)("more than one result for key " + kName)
    r(0)
  }

  private def removeIndex[U](i:Int, l: Iterable[U]) = l.zipWithIndex.collect{ case (v, index) if index != i => v } toList

  def applyImp[T](c: Context)(key: c.Expr[Any])(implicit wttt: c.WeakTypeTag[T]) = {
    import c.universe._
    c.Expr[Any](derefField(c)(c.prefix.tree, keyIndex(c)(key, wttt)))
  }

  def plusplusImpl[T1,T2](c: Context)(t: c.Expr[T2])(implicit wttt1: c.WeakTypeTag[T1], wttt2: c.WeakTypeTag[T2]) = {
    import c.universe._
    val params1 = wttToParams(c)(wttt1)
    val params2 = wttToParams(c)(wttt2)

    val t1params = (0 until params1.size / 2) map ((i) => derefField(c)(c.prefix.tree, i))
    val t2params = (0 until params2.size / 2) map ((i) => derefField(c)(t.tree, i))

    newTuple(c)(params1 ++ params2, (t1params ++ t2params).toList)
  }

  def mkStringImpl[T](c: Context)(implicit wttt: c.WeakTypeTag[T]) = {
    import c.universe._
    val params = wttToParams(c)(wttt)

    val toStringParams = keys(c)(params).zipWithIndex.map {
      case (name, index) =>
        q"""
          ${ name.toString } +
          " -> " +
          ${ c.prefix.tree }.${ newTermName(s"_${ index + 1 }") }.toString
        """
    }

    c.Expr[String](
      q"""
        "(" + scala.List(..$toStringParams).mkString(", ") + ")"
      """
    )
  }

  def newTupleImpl(c: Context)(pairs: c.Expr[Any]*) = {
    import c.universe._
    val keyValues = pairs.toList.map(pairToKV(c)(_))

    val finalTypeParams = keyValues.flatMap {
      case (name, value) => List(keyNameToKeyType(c)(name), c.Expr[Any](value).actualType)
    }
    val finalParams = keyValues.map {
      case (name, value) => value
    }

    newTuple(c)(finalTypeParams, finalParams)
  }

  def plusImpl[T](c: Context)(pair: c.Expr[(Any, Any)])(implicit wttt: c.WeakTypeTag[T]) = {
    import c.universe._

    val (key, value) = pairToKV(c)(pair)
    val params = wttToParams(c)(wttt)

    val finalKeys = keys(c)(params) :+ key
    val finalTypes = types(c)(params) :+ c.Expr[Any](value).actualType

    val tparams = (0 until params.size / 2) map ((i) => derefField(c)(c.prefix.tree, i))
    val finalValues = (tparams :+ value).toList

    newTuple(c)(mkTypeParams(c)(finalKeys, finalTypes), finalValues)
  }

  def minusImpl[T](c: Context)(key: c.Expr[Any])(implicit wttt: c.WeakTypeTag[T]) = {
    import c.universe._
    val params = wttToParams(c)(wttt)
    val i = keyIndex(c)(key, wttt)
    val finalKeys = removeIndex(i, keys(c)(params))
    val finalTypes = removeIndex(i, types(c)(params))
    val finalValues = removeIndex(i, 0 until params.size / 2) map ((i) => derefField(c)(c.prefix.tree, i))
    newTuple(c)(mkTypeParams(c)(finalKeys, finalTypes), finalValues)
  }

  def replaceImpl[T](c: Context)(pair: c.Expr[(Any, Any)])(implicit wttt: c.WeakTypeTag[T]) = {
    import c.universe._

    val (key, value) = pairToKV(c)(pair)
    val params = wttToParams(c)(wttt)
    val i = keyIndex(c)(c.Expr[Any](Literal(Constant(key))), wttt)

    val finalKeys = removeIndex(i, keys(c)(params)) :+ key
    val finalTypes = removeIndex(i, types(c)(params)) :+ c.Expr[Any](value).actualType

    val tparams = removeIndex(i, 0 until params.size / 2) map ((i) => derefField(c)(c.prefix.tree, i))
    val finalValues = (tparams :+ value)

    newTuple(c)(mkTypeParams(c)(finalKeys, finalTypes), finalValues)
  }

  def prefixImpl[T](c: Context)(prefix: c.Expr[String])(implicit wttt: c.WeakTypeTag[T]) = {
    import c.universe._

    val prefixString = keyName(c)(prefix.tree)
    val params = wttToParams(c)(wttt)

    val finalKeys = keys(c)(params).map((a) => prefixString + String.valueOf(a))
    val finalTypes = types(c)(params)

    val finalValues = (0 until params.size / 2) map ((i) => derefField(c)(c.prefix.tree, i))
    newTuple(c)(mkTypeParams(c)(finalKeys, finalTypes), finalValues.toList)
  }

  def toMapImpl[T](c: Context)(implicit wttt: c.WeakTypeTag[T]) = {
    import c.universe._
    val params = wttToParams(c)(wttt)
    val ts = types(c)(params)
    val mapParams = keys(c)(params).zipWithIndex.map {
      case (name, index) =>
        q"""
          (
            ${ Literal(Constant(name)) },
            ${ c.prefix.tree }.${ newTermName(s"_${ index + 1 }") }
          )
        """
    }

    c.Expr[Map[Any, Any]](q"Map[Any, Any](..$mapParams)")
  }

  private def mapImpl0[T](c: Context)(pair: c.Expr[Any], tuple: c.universe.Tree)(f: c.Expr[Any])(implicit wttt: c.WeakTypeTag[T]) = {
    import c.universe._
    val params = wttToParams(c)(wttt)
    val (sources, target) = pair.tree match {
      case Apply(
             TypeApply(
               Select(
                 Apply(
                     TypeApply(Select(scalaPredef, assoc), List(TypeTree())),
                     List(
                         Apply(
                             TypeApply(
                                 Select(Select(Ident(scala), tupleClass), apply),
                                 types
                              ),
                              sources
                         )
                     )
                 ),
                 arrow
             ),
             List(TypeTree())),
             List(target)
          ) if (arrow.decodedName.toString == "->"
                && (assoc.decodedName.toString == "any2ArrowAssoc" || assoc.decodedName.toString == "ArrowAssoc")
                && scala.decodedName.toString == "scala"
                && tupleClass.decodedName.toString.startsWith("Tuple")
                && apply.decodedName.toString == "apply")
             => (sources, target)
      case _ => fail(c)(show(pair.tree) + " is not a valid mapping")
    }

    val finalKeys = keys(c)(params) :+ keyName(c)(target)

    val t = f.actualType match {
      case TypeRef(
            ThisType(scala),
            function,
            types) if (function.fullName.startsWith("scala.Function")) => types.last
      case _ => fail(c)(show(f) + " is not a valid function")
    }

    val finalTypes = types(c)(params) :+ t

    val tparams = (0 until params.size / 2) map ((i) => derefField(c)(tuple, i))
    val fParams = sources map (keyName(c)(_)) map ((key) => derefField(c)(tuple, keyIndex(c)(c.Expr[Any](Literal(Constant(key))), wttt)))
    val appF = Apply(Select(f.tree, newTermName("apply")), fParams)
    val finalValues = (tparams :+ appF).toList
    newTuple(c)(mkTypeParams(c)(finalKeys, finalTypes), finalValues)
  }

  def mapImpl[T](c: Context)(pair: c.Expr[Any])(f: c.Expr[Any])(implicit wttt: c.WeakTypeTag[T]) = {
    import c.universe._
    mapImpl0(c)(pair, c.prefix.tree)(f)(wttt)
  }

  def listMapImpl[T](c: Context)(pair: c.Expr[Any])(f: c.Expr[Any])(implicit wttt: c.WeakTypeTag[T]) = {
    import c.universe._
    val list = c.Expr[RichList[T]](c.prefix.tree)

    reify {
      list.splice.list.map(
          c.Expr[Function1[T,Any]](Function(
              List(ValDef(Modifiers(Flag.PARAM), newTermName("t"), TypeTree(), EmptyTree)),
              mapImpl0(c)(pair, Ident(newTermName("t")))(f)(wttt).tree
          )).splice)
    }
  }

  def nTupleToStringImpl[T](c: Context)(ntuple: c.Expr[T])(implicit wttt: c.WeakTypeTag[T]) = {
    import c.universe._
    val params = wttToParams(c)(wttt)

    val toStringParams = keys(c)(params).zipWithIndex.map {
      case (name, index) =>
        q"""
          ${ name.toString } +
          " -> " +
          $ntuple.${ newTermName(s"_${ index + 1 }") }.toString
        """
    }

    c.Expr[String](
      q"""
        "(" + scala.List(..$toStringParams).mkString(", ") + ")"
      """
    )
  }
}
