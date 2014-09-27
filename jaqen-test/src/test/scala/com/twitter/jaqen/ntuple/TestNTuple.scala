package com.twitter.jaqen.ntuple

import org.junit.runner.RunWith
import org.scalatest.FlatSpec
import org.scalatest.junit.JUnitRunner

@RunWith(classOf[JUnitRunner])
class TestNTuple extends FlatSpec {
  import NTuple._
  "ntuples" should "look like maps" in {
    val t1 = t("a" -> "b")
    assert(t1("a") === "b")
  }

  "empty ntuple" should "be of the correct type" in {
    val empty = t()
    assert(empty.getClass() === classOf[NTuple0])
  }

  "empty + pair" should "be the same as new tuple of pair" in {
    val value = "b"
    val emptyPlusPair = t() + ("a" -> value)
    val newNTuple = t("a" -> value)
    assert(emptyPlusPair("a") === newNTuple("a"))
  }

  "symbol and string" should "be the same" in {
    val t1 = t("a" -> "b")
    assert(t1('a) === "b")
    val t2 = t('a -> "b")
    assert(t1("a") === "b")
  }

  "ntuples" should "look like tuples" in {
    val t1 = t("a" -> "b", "b" -> "c")
    assert(t1._1 === "b")
    assert(t1._2 === "c")
  }

  "ntuples" should "map" in {
    val t1 = t("a" -> "b", "b" -> "c")
    val t2 = t1.map(('a, 'b) -> 'concat)((a: String, b: String) => a + b)
    assert(t2('concat) === "bc")
  }

  "mkString" should "look like a map" in {
    val s1 = "Map" + t("a" -> "FOO", "b" -> 3).mkString
    val s2 = Map("a" -> "FOO", "b" -> 3).toString
    assert(s1 === s2)
  }

  "toString" should "look like a tuple" in {
    val s1 = t("a" -> "FOO", "b" -> 3).toString
    val s2 = ("FOO", 3).toString
    assert(s1 === s2)
  }

  "nTuples" should "concat" in {
    val t1 = t("a" -> 1)
    val t2 = t("b" -> "bar")
    val t3 = t1 ++ t2
    assert(t3._1 === t1._1)
    assert(t3._2 === t2._1)
  }

  "toMap" should "produce a map" in {
    val m1 = t("a" -> "FOO", "b" -> 3).toMap
    val m2 = Map("a" -> "FOO", "b" -> 3)
    assert(m1 === m2)
  }

  "minus" should "remove that key" in {
    val t1 = t("a" -> "FOO", "b" -> 3)
    val t2 = t1 - "a"
    val t3 = t1 - "b"
    assert(t2._1 === t1._2)
    assert(t3._1 === t1._1)
  }

  "removeAll" should "remove all corresponding keys" in {
    val t1 = t("a" -> "FOO", "b" -> 3, "c" -> 5l)
    val t2 = t1.removeAll("a", "b")
    val t3 = t1.removeAll("b", "c")
    assert(t2._1 === t1._3)
    assert(t3._1 === t1._1)
  }

  "prefix" should "work" in {
    val t1 = t("a" -> "FOO", "b" -> 3)
    val t2 = t1.prefix("c")
    assert(t2("ca") === t1("a"))
    assert(t2("cb") === t1("b"))
  }

  "replace" should "work" in {
    val t1 = t("a" -> "FOO", "b" -> 3)
    val t2 = t1 -+ ("a" -> "BAR")
    val t3 = t1 -+ ("b" -> "BAZ")
    assert(t2("a") === "BAR")
    assert(t2("b") === 3)
    assert(t3("a") === "FOO")
    assert(t3("b") === "BAZ")
  }
}