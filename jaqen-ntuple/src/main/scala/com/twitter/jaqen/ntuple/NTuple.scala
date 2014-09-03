package com.twitter.jaqen.ntuple

import scala.language.experimental.macros
import NTupleMacros._

/**
 * A tuple where fields can be accessed by name
 *
 * @author Julien Le Dem
 */
trait NTuple[T <: NTuple[T]] {

  /**
   * returns the field named 'key' with the proper type
   * if key does not exist, a compilation error will occur
   * @param key a literal or a Symbol
   * example:
   * <code>
   * val tuple = t('a -> 1, 'b -> "2")
   * tuple('a)
   * => 1 (of type Int)
   * tuple('b)
   * => "2" (of type String)
   * </code>
   */
  def get(key: Any) = macro applyImp[T]
  /** @see get */
  def apply(key: Any) = macro applyImp[T]

  /**
   * adds a pair key -> value to the tuple
   * if key already exists, a compilation error will occur
   * key must be a literal or a symbol.
   * example: <code>
   * val tuple = t('a -> 1, 'b -> 2)
   * tuple + ('c -> 3)
   * => t('a -> 1, 'b -> 2, 'c -> 3)
   * </code>
   */
  def add(pair: (Any, Any)) = macro plusImpl[T]
  /** @see add */
  def +(pair: (Any, Any)) = macro plusImpl[T]

  /**
   * concats another NTuple to this one
   * if a key is defined in both tuples a compilation error will occur
   * <code>
   * val tuple1 = t('a -> 1, 'b -> 2)
   * val tuple2 = t('c -> 3, 'd -> 4)
   * tuple1 ++ tuple2
   * => t('a -> 1, 'b -> 2, 'c -> 3, 'd -> 4)
   * </code>
   */
  def concat[T2 <: NTuple[T2]](t: T2) = macro plusplusImpl[T,T2]
  /** @see concat */
  def ++[T2 <: NTuple[T2]](t: T2) = macro plusplusImpl[T,T2]

  /**
   * removes a key from the tuple
   * if key does not exist, a compilation error will occur
   * <code>
   * val tuple = t('a -> 1, 'b -> 2)
   * tuple - 'a
   * => t('b -> 2)
   * </code>
   */
  def remove(key: Any) = macro minusImpl[T]
  /** @see remove */
  def -(key: Any) = macro minusImpl[T]

  /**
   * takes a key -> value pair and replaces the existing key with the given value
   * if key does not exist, a compilation error will occur
   * example:
   * <code>
   * val tuple = t('a -> 1, 'b -> 2)
   * tuple -+ ('a -> 3)
   * => t('a -> 3, 'b -> 2)
   * </code>
   */
  def replace(pair: (Any, Any)) = macro replaceImpl[T]
  /** @see replace */
  def -+(pair: (Any, Any)) = macro replaceImpl[T]

  /**
   * prefixes all the key names with the given prefix.
   * useful to concatenate 2 tuples
   * example:
   * <code>
   * t('a -> 1, 'b -> 2).prefix("t")
   * => t('ta -> 1, 'tb -> 2)
   * </code>
   */
  def prefix(prefix: String) = macro prefixImpl[T]

  /**
   * takes a pair (inputs -> output) and a function
   * inputs: a tuple of the keys of the values to pass to the function
   * output: the key to set with the result
   * @returns the resulting tuple with the output key set with the result of the function
   * example:
   * <code>
   * val tuple = t('a -> 1, 'b -> 2)
   * tuple.map(('a, 'b) -> 'c) { (a: Int, b: Int) => a + b }
   * => t('a -> 1, 'b -> 2, 'c -> 3)
   * </code>
   */
  def map(pair: Any)(f: Any) = macro mapImpl[T]

  /**
   * @returns a string representation of this tuple
   * example:
   * <code>
   * t('a -> 1, 'b -> 2).mkString
   * (a -> 1, b -> 2)
   * </code>
   */
  def mkString = macro mkStringImpl[T]

  /**
   * converts this tuple to a Map.
   * @returns an immutable Map
   */
  def toMap = macro toMapImpl[T]
}

object NTuple {

  /**
   * creates a new NTuple from a list of key -> value pairs
   * the types of the values are preserved and will be returned accordingly when apply is called
   * if a key is defined twice a compilation error will occur
   * <code>
   * val tuple1 = t('a -> 1, 'b -> "2")
   * </code>
   */
  def t(pairs: Any*) = macro newTupleImpl

  implicit def nTupleToString[T <: NTuple[T]](ntuple: T): String = macro nTupleToStringImpl[T]

  implicit def listOfNTupleToRichList[T <: NTuple[T]](list: List[T]) = RichList[T](list)
}

case class RichList[T] (val list: List[T]) {
  def nmap(pair: Any)(f: Any) = macro listMapImpl[T]
}
