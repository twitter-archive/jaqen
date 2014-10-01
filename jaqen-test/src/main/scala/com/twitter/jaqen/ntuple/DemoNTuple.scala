package com.twitter.jaqen.ntuple

import com.twitter.jaqen.ntuple.NTuple._

object DemoNTuple {
  def main(args: Array[String]) {
    val foo = "FOO"
    val bar = 3

    val map = Map("a" -> foo, "b" -> bar)
    val map2 = map + ("d" -> 3f)
    // type mismatch
//    val mapa: String = map("a")
    // type mismatch
//    val mapb: Int = map("b")
    // runtime error key not found: c
//    val mapc = map("c")

    // tuple with named fields!

    val empty = t()
    val notempty = empty + ("A" -> "B")
    val A = notempty("A")
//    val notempty2 = notempty + ("B" -> "D")

    val tuple = t("a" -> foo, 'b -> bar)
    val tuplea: String = tuple("a")
    val tupleas: String = tuple('a)
    val tupleb: Int = tuple("b")
    // tuple does not contain key: "c"
//    val tuplec = tuple("c")
    val tuplea2: String = tuple._1
    val tupleb2: Int = tuple._2

    val b = "FOOBAR"
    val tuple3 = t(b)
    println(tuple3('b))
//    val tuple4 = t(b + 3)

    case class Person(val name: String, val age: Int)

    val input = List(Person("John", 10), Person("Jack", 5))

    val r = input
      .map((in) => t(
          'name -> in.name,
          'laterAge -> (in.age + 10)
          )
      )
      .filter(_('laterAge) < 18)
      .map(_ + ('foo -> "bar"))

    println(r)
    println(r.head.mkString)

    val tinput = input.map((p) => t('name -> p.name, 'age -> p.age))

    val r2 = tinput
      .map((tu) => tu + ('concat -> (tu('name) + tu('age))))

    val r3 = tinput
      .map(_.map(('name, 'age) -> 'concat) ((s: String, i: Int) => s + i))

    val r5 = tinput.nmap(('name, 'age) -> 'concat)((s: String, i: Int) => s + i)

  }
}
