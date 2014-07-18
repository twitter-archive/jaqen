Jaqen
=====

A type-safe heterogenous Map or a Named field Tuple depending how you look at it.

"Speak the names and a man will do the rest"

## API: 
https://github.com/julienledem/Jaqen/blob/master/jaqen/src/main/scala/ntuple/NTuple.scala#L355

```
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
}
```

## try it:
```
mvn clean compile
scala -classpath jaqen/target/classes
```
Examples: 
```

import ntuple.NTuple._

val foo = "FOO"
val bar = 3

// maps
val map = Map("a" -> foo, "b" -> bar)
map + ("d" -> 3f)
val ma: String = map("a")
val mb: Int = map("b")
map("c")
map - "a"

// tuples
val tuple1 = (foo, bar)

val tuple1a: String = tuple1._1
val tuple1b: Int = tuple1._2
// or
val (tuple1a, tuple1b) = tuple1
 
// tuple with named fields!
val t1 = t('a -> foo, 'b -> bar)
t1.mkString
val t1a: String = t1('a)
val t1b: Int = t1('b)
t1('c) // error: t1 does not contain key: "c"
(t1 - 'b).mkString
val t2 = t1 + ('c -> 2)
t2 + ('c -> 3) // error: t2 already contains key c
(t2 -+ ('c -> 3)).mkString
// also a tuple
t1._1
t1._2
val (t1a, t1b) = t1.toTuple
t1.toMap

val empty = t()
val notempty = empty + ("A" -> foo)
notempty("A")

case class Person(val name: String, val age: Int)
val input = List(Person("John", 10), Person("Jack", 5))

case class PersonBirthYear(val name: String, val birthYear: Int)
input.map((in) => PersonBirthYear(in.name, 2014 - in.age)).filter(_.birthYear > 2005).map(_.name)

input.map((in) => (in.name, 2014 - in.age)).filter{ case (_, birthYear) => birthYear > 2005 }.map { case (name, _) => name }

input.map((in) => t('name -> in.name, 'birthYear -> (2014 - in.age))).filter(_('birthYear) > 2005).map(_('name))


```
Result:
```
scala> import ntuple.NTuple._
import ntuple.NTuple._

scala> 

scala> val foo = "FOO"
foo: String = FOO

scala> val bar = 3
bar: Int = 3

scala> 

scala> // maps

scala> val map = Map("a" -> foo, "b" -> bar)
map: scala.collection.immutable.Map[String,Any] = Map(a -> FOO, b -> 3)

scala> map + ("d" -> 3f)
res0: scala.collection.immutable.Map[String,Any] = Map(a -> FOO, b -> 3, d -> 3.0)

scala> val ma: String = map("a")
<console>:13: error: type mismatch;
 found   : Any
 required: String
       val ma: String = map("a")
                           ^

scala> val mb: Int = map("b")
<console>:13: error: type mismatch;
 found   : Any
 required: Int
       val mb: Int = map("b")
                        ^

scala> map("c")
java.util.NoSuchElementException: key not found: c
	at scala.collection.MapLike$class.default(MapLike.scala:228)
	at scala.collection.AbstractMap.default(Map.scala:58)
	at scala.collection.MapLike$class.apply(MapLike.scala:141)
	at scala.collection.AbstractMap.apply(Map.scala:58)
	at .<init>(<console>:14)
	at .<clinit>(<console>)
	at .<init>(<console>:7)
	at .<clinit>(<console>)
	at $print(<console>)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:601)
	at scala.tools.nsc.interpreter.IMain$ReadEvalPrint.call(IMain.scala:734)
	at scala.tools.nsc.interpreter.IMain$Request.loadAndRun(IMain.scala:983)
	at scala.tools.nsc.interpreter.IMain.loadAndRunReq$1(IMain.scala:573)
	at scala.tools.nsc.interpreter.IMain.interpret(IMain.scala:604)
	at scala.tools.nsc.interpreter.IMain.interpret(IMain.scala:568)
	at scala.tools.nsc.interpreter.ILoop.reallyInterpret$1(ILoop.scala:756)
	at scala.tools.nsc.interpreter.ILoop.interpretStartingWith(ILoop.scala:801)
	at scala.tools.nsc.interpreter.ILoop.command(ILoop.scala:713)
	at scala.tools.nsc.interpreter.ILoop.processLine$1(ILoop.scala:577)
	at scala.tools.nsc.interpreter.ILoop.innerLoop$1(ILoop.scala:584)
	at scala.tools.nsc.interpreter.ILoop.loop(ILoop.scala:587)
	at scala.tools.nsc.interpreter.ILoop$$anonfun$process$1.apply$mcZ$sp(ILoop.scala:878)
	at scala.tools.nsc.interpreter.ILoop$$anonfun$process$1.apply(ILoop.scala:833)
	at scala.tools.nsc.interpreter.ILoop$$anonfun$process$1.apply(ILoop.scala:833)
	at scala.tools.nsc.util.ScalaClassLoader$.savingContextLoader(ScalaClassLoader.scala:135)
	at scala.tools.nsc.interpreter.ILoop.process(ILoop.scala:833)
	at scala.tools.nsc.MainGenericRunner.runTarget$1(MainGenericRunner.scala:83)
	at scala.tools.nsc.MainGenericRunner.process(MainGenericRunner.scala:96)
	at scala.tools.nsc.MainGenericRunner$.main(MainGenericRunner.scala:105)
	at scala.tools.nsc.MainGenericRunner.main(MainGenericRunner.scala)


scala> map - "a"
res2: scala.collection.immutable.Map[String,Any] = Map(b -> 3)

scala> 

scala> // tuples

scala> val tuple1 = (foo, bar)
tuple1: (String, Int) = (FOO,3)

scala> 

scala> val tuple1a: String = tuple1._1
tuple1a: String = FOO

scala> val tuple1b: Int = tuple1._2
tuple1b: Int = 3

scala> // or

scala> val (tuple1a, tuple1b) = tuple1
tuple1a: String = FOO
tuple1b: Int = 3

scala>  
     | // tuple with named fields!

scala> val t1 = t('a -> foo, 'b -> bar)
t1: ntuple.NTuple2[String("a"),String,String("b"),Int] = (FOO,3)

scala> t1.mkString
res4: String = (a -> FOO, b -> 3)

scala> val t1a: String = t1('a)
t1a: String = FOO

scala> val t1b: Int = t1('b)
t1b: Int = 3

scala> t1('c) // error: t1 does not contain key: "c"
<console>:14: error: t1 does not contain key c
              t1('c) // error: t1 does not contain key: "c"
                ^

scala> (t1 - 'b).mkString
res6: String = (a -> FOO)

scala> val t2 = t1 + ('c -> 2)
t2: ntuple.NTuple3[String("a"),String,String("b"),Int,String("c"),Int(2)] = (FOO,3,2)

scala> t2 + ('c -> 3) // error: t2 already contains key c
<console>:15: error: t2 already contains key c
              t2 + ('c -> 3) // error: t2 already contains key c
                 ^

scala> (t2 -+ ('c -> 3)).mkString
res8: String = (a -> FOO, b -> 3, c -> 3)

scala> // also a tuple

scala> t1._1
res9: String = FOO

scala> t1._2
res10: Int = 3

scala> val (t1a, t1b) = t1.toTuple
t1a: String = FOO
t1b: Int = 3

scala> t1.toMap
res11: scala.collection.immutable.Map[Any,Any] = Map(a -> FOO, b -> 3)

scala> 

scala> val empty = t()
empty: ntuple.NTuple0 = ()

scala> val notempty = empty + ("A" -> foo)
notempty: ntuple.NTuple1[String("A"),String] = FOO

scala> notempty("A")
res12: String = FOO

scala> 

scala> case class Person(val name: String, val age: Int)
defined class Person

scala> val input = List(Person("John", 10), Person("Jack", 5))
input: List[Person] = List(Person(John,10), Person(Jack,5))

scala> 

scala> case class PersonBirthYear(val name: String, val birthYear: Int)
defined class PersonBirthYear

scala> input.map((in) => PersonBirthYear(in.name, 2014 - in.age)).filter(_.birthYear > 2005).map(_.name)
res13: List[String] = List(Jack)

scala> 

scala> input.map((in) => (in.name, 2014 - in.age)).filter{ case (_, birthYear) => birthYear > 2005 }.map { case (name, _) => name }
res14: List[String] = List(Jack)

scala> 

scala> input.map((in) => t('name -> in.name, 'birthYear -> (2014 - in.age))).filter(_('birthYear) > 2005).map(_('name))
res15: List[String] = List(Jack)
```
