package com.twitter.jaqen.ntuple.scalding

import scala.language.experimental.macros
import com.twitter.jaqen.ntuple.NTuple
import com.twitter.scalding.typed.TypedPipe
import com.twitter.jaqen.ntuple.scalding.NPipeMacros._

object NPipe {

  implicit def TypedPipeOfNTupleToNPipe[T <: NTuple[T]](pipe: TypedPipe[T]) = NPipe[T](pipe)

}

case class NPipe[T] (val tpipe: TypedPipe[T]) {
  type Type = T
  def nmap(pair: Any)(f: Any) = macro pipeMapImpl[T]
  def ndiscard(keys: Any*) = macro pipeDropImpl[T]
}