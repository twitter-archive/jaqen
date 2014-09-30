package com.twitter.jaqen.ntuple.scalding

import com.twitter.scalding.typed.TypedPipe
import scala.reflect.macros.Context
import com.twitter.jaqen.ntuple.NTupleMacros

object NPipeMacros {

  def pipeMapImpl[T](c: Context)(pair: c.Expr[Any])(f: c.Expr[Any])(implicit wttt: c.WeakTypeTag[T]) = {
    import c.universe._
    val npipe = c.Expr[NPipe[T]](c.prefix.tree)
    reify {
      npipe.splice.tpipe.map(
          c.Expr[Function1[T,Any]](Function(
              List(ValDef(Modifiers(Flag.PARAM), newTermName("t"), TypeTree(), EmptyTree)),
              NTupleMacros.tupleMapImpl(c)(pair, Ident(newTermName("t")))(f)(wttt).tree
          )).splice)
    }
  }

  def pipeDiscardImpl[T](c: Context)(keys: c.Expr[Any]*)(implicit wttt: c.WeakTypeTag[T]) = {
    import c.universe._
    val npipe = c.Expr[NPipe[T]](c.prefix.tree)
    reify {
      npipe.splice.tpipe.map(
          c.Expr[Function1[T,Any]](Function(
              List(ValDef(Modifiers(Flag.PARAM), newTermName("t"), TypeTree(), EmptyTree)),
              NTupleMacros.tupleDiscardImpl(c)(keys, Ident(newTermName("t")))(wttt).tree
          )).splice)
    }
  }

  def pipeProjectImpl[T](c: Context)(keys: c.Expr[Any]*)(implicit wttt: c.WeakTypeTag[T]) = {
    import c.universe._
    val npipe = c.Expr[NPipe[T]](c.prefix.tree)
    reify {
      npipe.splice.tpipe.map(
          c.Expr[Function1[T,Any]](Function(
              List(ValDef(Modifiers(Flag.PARAM), newTermName("t"), TypeTree(), EmptyTree)),
              NTupleMacros.tupleProjectImpl(c)(keys, Ident(newTermName("t")))(wttt).tree
          )).splice)
    }
  }

}