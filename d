commit c35c4de447b8ad8079da1446cc52610c7b0ca5e1
Author: julien <julien@twitter.com>
Date:   Fri Jul 18 13:01:59 2014 -0700

    initial contribution

diff --git a/.gitignore b/.gitignore
new file mode 100644
index 0000000..c4b73d1
--- /dev/null
+++ b/.gitignore
@@ -0,0 +1,21 @@
+*.class
+*.log
+
+# sbt specific
+.cache/
+.history/
+.lib/
+dist/*
+target/
+lib_managed/
+src_managed/
+project/boot/
+project/plugins/project/
+
+# Scala-IDE specific
+.scala_dependencies
+.worksheet
+.classpath
+.project
+.settings
+.cache
diff --git a/README.md b/README.md
index b483ad3..df3b474 100644
--- a/README.md
+++ b/README.md
@@ -1,2 +1,3 @@
-jaqen
+Jaqen
 =====
+
diff --git a/console.sh b/console.sh
new file mode 100644
index 0000000..4b8e4da
--- /dev/null
+++ b/console.sh
@@ -0,0 +1 @@
+scala -classpath jaqen/target/classes:jaqen-test/target/classes
diff --git a/jaqen-test/pom.xml b/jaqen-test/pom.xml
new file mode 100644
index 0000000..6560d98
--- /dev/null
+++ b/jaqen-test/pom.xml
@@ -0,0 +1,25 @@
+<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
+  <parent>
+    <groupId>com.twitter</groupId>
+    <artifactId>jaqen-parent</artifactId>
+    <relativePath>../pom.xml</relativePath>
+    <version>0.1.0-SNAPSHOT</version>
+  </parent>
+
+  <modelVersion>4.0.0</modelVersion>
+
+  <artifactId>jaqen-test</artifactId>
+  <packaging>jar</packaging>
+
+  <name>Jaqen tests</name>
+  <url>https://github.com/twitter/jaqen</url>
+
+  <dependencies>
+    <dependency>
+      <groupId>com.twitter</groupId>
+      <artifactId>jaqen</artifactId>
+      <version>${project.version}</version>
+    </dependency>
+  </dependencies>
+
+</project>
diff --git a/jaqen-test/src/main/scala/com/twitter/jaqen/ntuple/DemoNTuple.scala b/jaqen-test/src/main/scala/com/twitter/jaqen/ntuple/DemoNTuple.scala
new file mode 100644
index 0000000..4bbbc3a
--- /dev/null
+++ b/jaqen-test/src/main/scala/com/twitter/jaqen/ntuple/DemoNTuple.scala
@@ -0,0 +1,67 @@
+package com.twitter.jaqen.ntuple
+
+import com.twitter.jaqen.ntuple.NTuple._
+
+object DemoNTuple {
+  def main(args: Array[String]) {
+    val foo = "FOO"
+    val bar = 3
+
+    val map = Map("a" -> foo, "b" -> bar)
+    val map2 = map + ("d" -> 3f)
+    // type mismatch
+//    val mapa: String = map("a")
+    // type mismatch
+//    val mapb: Int = map("b")
+    // runtime error key not found: c
+//    val mapc = map("c")
+
+    // tuple with named fields!
+
+    val empty = t()
+    val notempty = empty + ("A" -> "B")
+    val A = notempty("A")
+//    val notempty2 = notempty + ("B" -> "D")
+
+    val tuple = t("a" -> foo, 'b -> bar)
+    val tuplea: String = tuple("a")
+    val tupleas: String = tuple('a)
+    val tupleb: Int = tuple("b")
+    // tuple does not contain key: "c"
+//    val tuplec = tuple("c")
+    val tuplea2: String = tuple._1
+    val tupleb2: Int = tuple._2
+
+    val b = "FOOBAR"
+    val tuple3 = t(b)
+    println(tuple3('b))
+//    val tuple4 = t(b + 3)
+
+    case class Person(val name: String, val age: Int)
+
+    val input = List(Person("John", 10), Person("Jack", 5))
+
+    val r = input
+      .map((in) => t(
+          'name -> in.name,
+          'laterAge -> (in.age + 10)
+          )
+      )
+      .filter(_('laterAge) < 18)
+      .map(_ + ('foo -> "bar"))
+
+    println(r)
+    println(r.head.mkString)
+
+    val tinput = input.map((p) => t('name -> p.name, 'age -> p.age))
+
+    val r2 = tinput
+      .map((tu) => tu + ('concat -> (tu('name) + tu('age))))
+
+    val r3 = tinput
+      .map(_.map(('name, 'age) -> 'concat) ((s: String, i: Int) => s + i))
+
+    val r5 = tinput.nmap(('name, 'age) -> 'concat)((s: String, i: Int) => s + i)
+
+  }
+}
\ No newline at end of file
diff --git a/jaqen-test/src/main/scala/com/twitter/jaqen/ntuple/TryNTuple.scala b/jaqen-test/src/main/scala/com/twitter/jaqen/ntuple/TryNTuple.scala
new file mode 100644
index 0000000..f190c47
--- /dev/null
+++ b/jaqen-test/src/main/scala/com/twitter/jaqen/ntuple/TryNTuple.scala
@@ -0,0 +1,114 @@
+package com.twitter.jaqen.ntuple
+
+import PrintExpr._
+import NTuple._
+
+class Foo {
+
+}
+
+object TryNTuple {
+  def main(args: Array[String]) {
+     println("mkString: " + t("a" -> "FOO", "b" -> 3).mkString)
+    val name = "foo"
+    // does not compile: name must be a literal
+//    val tuple0 = NTuple1.t(name, "bar")
+        val map = Map("a" -> 1, "b" -> "boo")
+    val ma = map("a")
+    val mb = map("b")
+    val map2 = map + ("a" -> 2)
+    val ma2 = map2("a")
+
+    // runtime error: key not found: c
+//    val mc = map("c")
+
+    val tuple00 = t("a" -> 1)
+    println('symbol.name)
+    val tuple000 = t('a -> 1)
+    val tuple001 = t("a" -> 1, "b" -> "bar")
+    println(t("a" -> 1, "b" -> "bar") + "")
+    println("" + t("a" -> 1, "b" -> "bar"))
+    val b001 = tuple001("b")
+    val a001 = tuple001('a)
+    // does not compile: tuple001 does not contain key "c"
+//    val c001 = tuple001("c")
+
+    val tuple01 = t("a" -> 1)
+    val a01 = tuple01("a")
+
+    val val1 = 1
+    val tuple1 = t("a" -> val1)
+    println(tuple1)
+
+    val v: Int = tuple1("a")
+    println(v)
+
+    // does not compile: name is not a literal
+//    val v1: Int = tuple1(name)
+
+    // does not compile: tuple1 does not contain key "b"
+//    val v2 = tuple1("b")
+
+    val tuple2 = t("a" -> 1, "b" -> "bar")
+    println(tuple2)
+
+    val v3 = tuple2("a")
+    println(v3)
+
+    val v4 = tuple2("b")
+    println(v4)
+
+    // does not compile: tuple2 does not contain key "c"
+//    val v5 = tuple2("c")
+    val b = "FOOBAR"
+    val tuple3 = t(b)
+    println(tuple3("b"))
+    println(tuple3('b))
+
+    // does not compile: ntuple.NTuple already contains key a
+//    val tuple4 = t('a->1, 'a->2)
+//    println(tuple4('a))
+
+    val tuple5 = t("a" -> 1)
+    val tuple6 = t("b" -> "bar")
+    val tuple7 = tuple5 ++ tuple6
+    println("tuple7.toString " + tuple7)
+    println("tuple7.mkString " + tuple7.mkString)
+    println("tuple7.toMap " + tuple7.toMap)
+    val m = t("b" -> "bar").toMap
+
+    // does not compile: tuple7 already contains key a
+//    val tuple8 = tuple7 ++ tuple1 ++ tuple7
+//restore //    val tuple8 = tuple7 ++ tuple1.prefix("t1.") ++ tuple7.prefix("t7.")
+//    println("tuple8 " + tuple8)
+//     println("tuple8 x 2 " + tuple8 ++ tuple8))
+
+    val tuple9 = t("a" -> 1).-("a")
+    println((tuple2 - 'b).mkString)
+    println((tuple2 - 'a).mkString)
+    println((tuple2 - 'a - "b").mkString)
+
+    println(tuple7.prefix("foo.").mkString)
+
+    val tuple10 = tuple7.prefix("foo.")
+
+    println(tuple10("foo.a"))
+    println(tuple7.prefix("foo.").apply("foo.a"))
+
+    println((t("a" -> 1) -+ ("a" -> 2)).mkString)
+
+    val tuple11 = t('a -> 1, 'b ->2)
+    val tuple12 = tuple11 + ('c -> (tuple11('a) + tuple11('b)))
+    val f = (a: Int, b: Int) => a + b
+//    printExpr((a: Int, b: Int) => a + b)
+
+//    printExpr(f)
+    val tuple13 = tuple11.map(('a, 'b) -> 'c) { (a: Int, b: Int) => a + b }
+//    val tuple14 = tuple11.map(('a, 'b) -> 'a) { (a: Int, b: Int) => a + b }
+    println(tuple13.mkString)
+
+    val tuple15 = t('a -> 1, 'b -> 2)
+    println("blah")
+
+  }
+}
diff --git a/jaqen/pom.xml b/jaqen/pom.xml
new file mode 100644
index 0000000..47971e6
--- /dev/null
+++ b/jaqen/pom.xml
@@ -0,0 +1,17 @@
+<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
+  <parent>
+    <groupId>com.twitter</groupId>
+    <artifactId>jaqen-parent</artifactId>
+    <relativePath>../pom.xml</relativePath>
+    <version>0.1.0-SNAPSHOT</version>
+  </parent>
+
+  <modelVersion>4.0.0</modelVersion>
+
+  <artifactId>jaqen</artifactId>
+  <packaging>jar</packaging>
+
+  <name>Jaqen</name>
+  <url>https://github.com/twitter/jaqen</url>
+
+</project>
diff --git a/jaqen/src/main/scala/com/twitter/jaqen/ntuple/Log.scala b/jaqen/src/main/scala/com/twitter/jaqen/ntuple/Log.scala
new file mode 100644
index 0000000..e407fb4
--- /dev/null
+++ b/jaqen/src/main/scala/com/twitter/jaqen/ntuple/Log.scala
@@ -0,0 +1,14 @@
+package com.twitter.jaqen.ntuple
+
+import java.io.PrintWriter
+import java.io.FileOutputStream
+
+/**
+ * hacky way of getting a log of what's happening in the macro
+ */
+object Log {
+  val out = new PrintWriter(new FileOutputStream(System.getProperty("user.home") + "/macro.log", true), true)
+
+  def apply(in: Any*) = out.println(in.map(String.valueOf(_)).mkString(" "))
+
+}
\ No newline at end of file
diff --git a/jaqen/src/main/scala/com/twitter/jaqen/ntuple/NTuple.scala b/jaqen/src/main/scala/com/twitter/jaqen/ntuple/NTuple.scala
new file mode 100644
index 0000000..f0bc63a
--- /dev/null
+++ b/jaqen/src/main/scala/com/twitter/jaqen/ntuple/NTuple.scala
@@ -0,0 +1,146 @@
+package com.twitter.jaqen.ntuple
+
+import scala.language.experimental.macros
+import NTupleMacros._
+
+/**
+ * A tuple where fields can be accessed by name
+ *
+ * @author Julien Le Dem
+ */
+trait NTuple[T <: NTuple[T]] {
+
+  /**
+   * returns the field named 'key' with the proper type
+   * if key does not exist, a compilation error will occur
+   * @param key a literal or a Symbol
+   * example:
+   * <code>
+   * val tuple = t('a -> 1, 'b -> "2")
+   * tuple('a)
+   * => 1 (of type Int)
+   * tuple('b)
+   * => "2" (of type String)
+   * </code>
+   */
+  def get(key: Any) = macro applyImp[T]
+  /** @see get */
+  def apply(key: Any) = macro applyImp[T]
+
+  /**
+   * adds a pair key -> value to the tuple
+   * if key already exists, a compilation error will occur
+   * key must be a literal or a symbol.
+   * example: <code>
+   * val tuple = t('a -> 1, 'b -> 2)
+   * tuple + ('c -> 3)
+   * => t('a -> 1, 'b -> 2, 'c -> 3)
+   * </code>
+   */
+  def add(pair: (Any, Any)) = macro plusImpl[T]
+  /** @see add */
+  def +(pair: (Any, Any)) = macro plusImpl[T]
+
+  /**
+   * concats another NTuple to this one
+   * if a key is defined in both tuples a compilation error will occur
+   * <code>
+   * val tuple1 = t('a -> 1, 'b -> 2)
+   * val tuple2 = t('c -> 3, 'd -> 4)
+   * tuple1 ++ tuple2
+   * => t('a -> 1, 'b -> 2, 'c -> 3, 'd -> 4)
+   * </code>
+   */
+  def concat[T2 <: NTuple[T2]](t: T2) = macro plusplusImpl[T,T2]
+  /** @see concat */
+  def ++[T2 <: NTuple[T2]](t: T2) = macro plusplusImpl[T,T2]
+
+  /**
+   * removes a key from the tuple
+   * if key does not exist, a compilation error will occur
+   * <code>
+   * val tuple = t('a -> 1, 'b -> 2)
+   * tuple - 'a
+   * => t('b -> 2)
+   * </code>
+   */
+  def remove(key: Any) = macro minusImpl[T]
+  /** @see remove */
+  def -(key: Any) = macro minusImpl[T]
+
+  /**
+   * takes a key -> value pair and replaces the existing key with the given value
+   * if key does not exist, a compilation error will occur
+   * example:
+   * <code>
+   * val tuple = t('a -> 1, 'b -> 2)
+   * tuple -+ ('a -> 3)
+   * => t('a -> 3, 'b -> 2)
+   * </code>
+   */
+  def replace(pair: (Any, Any)) = macro replaceImpl[T]
+  /** @see replace */
+  def -+(pair: (Any, Any)) = macro replaceImpl[T]
+
+  /**
+   * prefixes all the key names with the given prefix.
+   * useful to concatenate 2 tuples
+   * example:
+   * <code>
+   * t('a -> 1, 'b -> 2).prefix("t")
+   * => t('ta -> 1, 'tb -> 2)
+   * </code>
+   */
+  def prefix(prefix: String) = macro prefixImpl[T]
+
+  /**
+   * takes a pair (inputs -> output) and a function
+   * inputs: a tuple of the keys of the values to pass to the function
+   * output: the key to set with the result
+   * @returns the resulting tuple with the output key set with the result of the function
+   * example:
+   * <code>
+   * val tuple = t('a -> 1, 'b -> 2)
+   * tuple.map(('a, 'b) -> 'c) { (a: Int, b: Int) => a + b }
+   * => t('a -> 1, 'b -> 2, 'c -> 3)
+   * </code>
+   */
+  def map(pair: Any)(f: Any) = macro mapImpl[T]
+
+  /**
+   * @returns a string representation of this tuple
+   * example:
+   * <code>
+   * t('a -> 1, 'b -> 2).mkString
+   * (a -> 1, b -> 2)
+   * </code>
+   */
+  def mkString = macro mkStringImpl[T]
+
+  /**
+   * converts this tuple to a Map.
+   * @returns an immutable Map
+   */
+  def toMap = macro toMapImpl[T]
+}
+
+object NTuple {
+
+  /**
+   * creates a new NTuple from a list of key -> value pairs
+   * the types of the values are preserved and will be returned accordingly when apply is called
+   * if a key is defined twice a compilation error will occur
+   * <code>
+   * val tuple1 = t('a -> 1, 'b -> "2")
+   * </code>
+   */
+  def t(pairs: Any*) = macro newTupleImpl
+
+  implicit def nTupleToString[T <: NTuple[T]](ntuple: T): String = macro nTupleToStringImpl[T]
+
+  implicit def listOfNTupleToRichList[T <: NTuple[T]](list: List[T]) = RichList[T](list)
+}
+
+case class RichList[T] (val list: List[T]) {
+  def nmap(pair: Any)(f: Any) = macro listMapImpl[T]
+}
diff --git a/jaqen/src/main/scala/com/twitter/jaqen/ntuple/NTupleMacros.scala b/jaqen/src/main/scala/com/twitter/jaqen/ntuple/NTupleMacros.scala
new file mode 100644
index 0000000..31a147a
--- /dev/null
+++ b/jaqen/src/main/scala/com/twitter/jaqen/ntuple/NTupleMacros.scala
@@ -0,0 +1,364 @@
+package com.twitter.jaqen.ntuple
+
+import scala.language.experimental.macros
+import scala.reflect.macros.Context
+import scala.collection.IterableLike
+import scala.collection.immutable.Iterable
+import scala.reflect.internal.FlagSets
+import scala.reflect.internal.Flags
+import scala.reflect.internal.Symbols
+
+object NTupleMacros {
+
+  private def fail(c: Context)(message: String) = {
+    import c.universe._
+    c.abort(c.enclosingPosition, message)
+  }
+
+  private def keyName(c: Context)(key: c.Tree): Any = {
+    import c.universe._
+    key match {
+      case Literal(Constant(v)) => v
+      case Apply(Select(Select(Ident(scala), symbol), apply), List(Literal(Constant(key))))
+                   if (apply.decoded == "apply" && scala.decoded == "scala")
+                     => key
+      case _ => fail(c)(show(key) + " is not a literal")
+    }
+  }
+
+  private def keyNameToKeyType(c: Context)(name: Any): c.universe.Type = {
+    import c.universe._
+    ConstantType(Constant(name))
+  }
+
+  private def keyTypeToKeyName(c: Context)(t: c.Type) = {
+    import c.universe._
+    t match {
+      case ConstantType(Constant(name)) => name
+      case _ => fail(c)(showRaw(t) + " type is not understood")
+    }
+  }
+
+  private def `new`(c: Context)(t: c.Type, params: List[c.universe.Tree]) = {
+    import c.universe._
+    Apply(Select(New(TypeTree(t)), nme.CONSTRUCTOR), params)
+  }
+
+  private def pairToKV(c: Context)(pair: c.Expr[Any]): (Any, c.universe.Tree) = {
+    import c.universe._
+
+    pair.tree match {
+      // TODO: allow tuple2
+      case Apply(
+             TypeApply(Select(
+                 Apply(
+                     TypeApply(Select(Select(This(_), _), assoc), List(TypeTree())),
+                     List(key)
+                 ),
+                 arrow
+             ),
+             List(TypeTree())),
+             List(value)
+          ) if (arrow.decoded == "->" && assoc.decoded == "any2ArrowAssoc")
+             => (keyName(c)(key), value)
+      // allow identifiers directly
+      case value@Ident(name) => (name.decoded, value)
+      // do we want magically named "expression" -> expression ?
+//      case v => (show(v), v)
+      case _ => fail(c)(show(pair.tree) + " is not a valid key-value pair")
+    }
+  }
+
+  private def wttToParams(c: Context)(wtt: c.WeakTypeTag[_]) = {
+    import c.universe._
+    wtt.tpe match {
+      case TypeRef(ThisType(ntuplePackage), nTupleName, parameters) if (nTupleName.fullName.contains("NTuple")) => parameters
+      case _ => fail(c)(showRaw(wtt) + " is not an understood type")
+    }
+  }
+
+  private def keys(c: Context)(params: List[c.universe.Type]) = {
+    import c.universe._
+    params
+      .zipWithIndex
+      .filter(_._2 % 2 == 0)
+      .map((t) => keyTypeToKeyName(c)(t._1))
+  }
+
+  private def types(c: Context)(params: List[c.universe.Type]) = {
+    import c.universe._
+    params
+      .zipWithIndex
+      .filter(_._2 % 2 == 1)
+      .map(_._1)
+  }
+
+  private def derefField(c: Context)(tree: c.universe.Tree, index: Int) = {
+    import c.universe._
+    Select(tree, newTermName("_" + (index + 1)))
+  }
+
+  private def classType(c: Context)(className: String, typeParams: List[c.universe.Type]) = {
+    import c.universe._
+    val rawType = c.mirror.staticClass(className).toType
+    appliedType(rawType.typeConstructor, typeParams)
+  }
+
+  private def nTupleType(c: Context)(size: Int, typeParams: List[c.universe.Type]) = {
+    classType(c)(classOf[NTuple[_]].getName() + size, typeParams)
+  }
+
+  private def newTuple(c: Context)(finalTypeParams: List[c.universe.Type], finalParams: List[c.universe.Tree]) = {
+    import c.universe._
+    try {
+      val distinctKeys = keys(c)(finalTypeParams)
+          .foldLeft(Set.empty[Any])(
+              (agg, key) =>
+                if (agg.contains(key))
+                  fail(c)(show(c.prefix.tree) + " already contains key " + key)
+                else
+                  agg + key
+          )
+      if (distinctKeys.size != finalParams.size) {
+        fail(c)("keys size does not match values size " + distinctKeys.size + " != " + finalParams.size)
+      }
+      val t = classType(c)(classOf[NTuple[_]].getName() + finalParams.size, finalTypeParams)
+      c.Expr[Any](`new`(c)(t, finalParams))
+    } catch {
+      case e: scala.reflect.internal.MissingRequirementError => fail(c)("no NTuple of size " + finalParams.size)
+    }
+  }
+
+  private def mkTypeParams(c: Context)(keys: Iterable[Any], types: Iterable[c.universe.Type]) = keys.zip(types).flatMap {
+        case (key, value) => List(keyNameToKeyType(c)(key), value)
+      }.toList
+
+  private def keyIndex[T](c: Context)(key: c.Expr[Any], wtt: c.WeakTypeTag[T]) = {
+    import c.universe._
+    val kName = keyName(c)(key.tree)
+    val params = wttToParams(c)(wtt)
+    val r = keys(c)(params).zipWithIndex.collect {
+          case (name, index) if (name == kName) => index
+        }
+    if (r.isEmpty) c.abort(c.enclosingPosition, show(c.prefix.tree) + " does not contain key " + kName)
+    else if (r.size > 1) fail(c)("more than one result for key " + kName)
+    r(0)
+  }
+
+  private def removeIndex[U](i:Int, l: Iterable[U]) = l.zipWithIndex.collect{ case (v, index) if index != i => v } toList
+
+  def applyImp[T](c: Context)(key: c.Expr[Any])(implicit wttt: c.WeakTypeTag[T]) = {
+    import c.universe._
+    c.Expr[Any](derefField(c)(c.prefix.tree, keyIndex(c)(key, wttt)))
+  }
+
+  def plusplusImpl[T1,T2](c: Context)(t: c.Expr[T2])(implicit wttt1: c.WeakTypeTag[T1], wttt2: c.WeakTypeTag[T2]) = {
+    import c.universe._
+    val params1 = wttToParams(c)(wttt1)
+    val params2 = wttToParams(c)(wttt2)
+
+    val t1params = (0 until params1.size / 2) map ((i) => derefField(c)(c.prefix.tree, i))
+    val t2params = (0 until params2.size / 2) map ((i) => derefField(c)(t.tree, i))
+
+    newTuple(c)(params1 ++ params2, (t1params ++ t2params).toList)
+  }
+
+  def mkStringImpl[T](c: Context)(implicit wttt: c.WeakTypeTag[T]) = {
+    import c.universe._
+    val params = wttToParams(c)(wttt)
+
+    val toStringParams = keys(c)(params)
+            .zipWithIndex
+            .flatMap {
+              case (name, index) => List(
+                  Literal(Constant(name)),
+                  Literal(Constant(" -> ")),
+                  derefField(c)(c.prefix.tree, index),
+                  Literal(Constant(", "))
+              )
+            }.dropRight(1)
+
+    val list = c.Expr[List[Any]](Apply(Select(reify(List).tree, newTermName("apply")), toStringParams))
+
+    reify {
+      "(" + list.splice.mkString("") + ")"
+    }
+  }
+
+  def newTupleImpl(c: Context)(pairs: c.Expr[Any]*) = {
+    import c.universe._
+    val keyValues = pairs.toList.map(pairToKV(c)(_))
+
+    val finalTypeParams = keyValues.flatMap {
+      case (name, value) => List(keyNameToKeyType(c)(name), c.Expr[Any](value).actualType)
+    }
+    val finalParams = keyValues.map {
+      case (name, value) => value
+    }
+
+    newTuple(c)(finalTypeParams, finalParams)
+  }
+
+  def plusImpl[T](c: Context)(pair: c.Expr[(Any, Any)])(implicit wttt: c.WeakTypeTag[T]) = {
+    import c.universe._
+
+    val (key, value) = pairToKV(c)(pair)
+    val params = wttToParams(c)(wttt)
+
+    val finalKeys = keys(c)(params) :+ key
+    val finalTypes = types(c)(params) :+ c.Expr[Any](value).actualType
+
+    val tparams = (0 until params.size / 2) map ((i) => derefField(c)(c.prefix.tree, i))
+    val finalValues = (tparams :+ value).toList
+
+    newTuple(c)(mkTypeParams(c)(finalKeys, finalTypes), finalValues)
+  }
+
+  def minusImpl[T](c: Context)(key: c.Expr[Any])(implicit wttt: c.WeakTypeTag[T]) = {
+    import c.universe._
+    val params = wttToParams(c)(wttt)
+    val i = keyIndex(c)(key, wttt)
+    val finalKeys = removeIndex(i, keys(c)(params))
+    val finalTypes = removeIndex(i, types(c)(params))
+    val finalValues = removeIndex(i, 0 until params.size / 2) map ((i) => derefField(c)(c.prefix.tree, i))
+    newTuple(c)(mkTypeParams(c)(finalKeys, finalTypes), finalValues)
+  }
+
+  def replaceImpl[T](c: Context)(pair: c.Expr[(Any, Any)])(implicit wttt: c.WeakTypeTag[T]) = {
+    import c.universe._
+
+    val (key, value) = pairToKV(c)(pair)
+    val params = wttToParams(c)(wttt)
+    val i = keyIndex(c)(c.Expr[Any](Literal(Constant(key))), wttt)
+
+    val finalKeys = removeIndex(i, keys(c)(params)) :+ key
+    val finalTypes = removeIndex(i, types(c)(params)) :+ c.Expr[Any](value).actualType
+
+    val tparams = removeIndex(i, 0 until params.size / 2) map ((i) => derefField(c)(c.prefix.tree, i))
+    val finalValues = (tparams :+ value)
+
+    newTuple(c)(mkTypeParams(c)(finalKeys, finalTypes), finalValues)
+  }
+
+  def prefixImpl[T](c: Context)(prefix: c.Expr[String])(implicit wttt: c.WeakTypeTag[T]) = {
+    import c.universe._
+
+    val prefixString = keyName(c)(prefix.tree)
+    val params = wttToParams(c)(wttt)
+
+    val finalKeys = keys(c)(params).map((a) => prefixString + String.valueOf(a))
+    val finalTypes = types(c)(params)
+
+    val finalValues = (0 until params.size / 2) map ((i) => derefField(c)(c.prefix.tree, i))
+    newTuple(c)(mkTypeParams(c)(finalKeys, finalTypes), finalValues.toList)
+  }
+
+  def toMapImpl[T](c: Context)(implicit wttt: c.WeakTypeTag[T]) = {
+    import c.universe._
+    val params = wttToParams(c)(wttt)
+    val ts = types(c)(params)
+    val mapParams = keys(c)(params)
+            .zipWithIndex
+            .map {
+              case (name, index) =>
+                Apply(Select(reify(Tuple2).tree, newTermName("apply")),
+                    List(
+                        Literal(Constant(name)),
+                        derefField(c)(c.prefix.tree, index)
+                    )
+                )
+            }
+    c.Expr[Map[Any, Any]](Apply(Select(reify(Map).tree, newTermName("apply")), mapParams))
+  }
+
+  private def mapImpl0[T](c: Context)(pair: c.Expr[Any], tuple: c.universe.Tree)(f: c.Expr[Any])(implicit wttt: c.WeakTypeTag[T]) = {
+    import c.universe._
+    val params = wttToParams(c)(wttt)
+    val (sources, target) = pair.tree match {
+      case Apply(
+             TypeApply(
+               Select(
+                 Apply(
+                     TypeApply(Select(scalaPredef, assoc), List(TypeTree())),
+                     List(
+                         Apply(
+                             TypeApply(
+                                 Select(Select(Ident(scala), tupleClass), apply),
+                                 types
+                              ),
+                              sources
+                         )
+                     )
+                 ),
+                 arrow
+             ),
+             List(TypeTree())),
+             List(target)
+          ) if (arrow.decoded == "->"
+                && assoc.decoded == "any2ArrowAssoc"
+                && scala.decoded == "scala"
+                && tupleClass.decoded.startsWith("Tuple")
+                && apply.decoded == "apply")
+             => (sources, target)
+      case _ => fail(c)(show(pair.tree) + " is not a valid mapping")
+    }
+
+    val finalKeys = keys(c)(params) :+ keyName(c)(target)
+
+    val t = f.actualType match {
+      case TypeRef(
+            ThisType(scala),
+            function,
+            types) if (function.fullName.startsWith("scala.Function")) => types.last
+      case _ => fail(c)(show(f) + " is not a valid function")
+    }
+
+    val finalTypes = types(c)(params) :+ t
+
+    val tparams = (0 until params.size / 2) map ((i) => derefField(c)(tuple, i))
+    val fParams = sources map (keyName(c)(_)) map ((key) => derefField(c)(tuple, keyIndex(c)(c.Expr[Any](Literal(Constant(key))), wttt)))
+    val appF = Apply(Select(f.tree, newTermName("apply")), fParams)
+    val finalValues = (tparams :+ appF).toList
+    newTuple(c)(mkTypeParams(c)(finalKeys, finalTypes), finalValues)
+  }
+
+  def mapImpl[T](c: Context)(pair: c.Expr[Any])(f: c.Expr[Any])(implicit wttt: c.WeakTypeTag[T]) = {
+    import c.universe._
+    mapImpl0(c)(pair, c.prefix.tree)(f)(wttt)
+  }
+
+  def listMapImpl[T](c: Context)(pair: c.Expr[Any])(f: c.Expr[Any])(implicit wttt: c.WeakTypeTag[T]) = {
+    import c.universe._
+    val list = c.Expr[RichList[T]](c.prefix.tree)
+    reify {
+      list.splice.list.map(
+          c.Expr[Function1[T,Any]](Function(
+              List(ValDef(Modifiers(Flag.PARAM), newTermName("t"), TypeTree(), EmptyTree)),
+              mapImpl0(c)(pair, Ident(newTermName("t")))(f)(wttt).tree
+          )).splice)
+    }
+  }
+
+  def nTupleToStringImpl[T](c: Context)(ntuple: c.Expr[T])(implicit wttt: c.WeakTypeTag[T]) = {
+    import c.universe._
+    val params = wttToParams(c)(wttt)
+
+    val toStringParams = keys(c)(params)
+            .zipWithIndex
+            .flatMap {
+              case (name, index) => List(
+                  Literal(Constant(name)),
+                  Literal(Constant(" -> ")),
+                  derefField(c)(ntuple.tree, index),
+                  Literal(Constant(", "))
+              )
+            }.dropRight(1)
+
+    val list = c.Expr[List[Any]](Apply(Select(reify(List).tree, newTermName("apply")), toStringParams))
+
+    reify {
+      "(" + list.splice.mkString("") + ")"
+    }
+  }
+
+}
diff --git a/jaqen/src/main/scala/com/twitter/jaqen/ntuple/NTuples.scala b/jaqen/src/main/scala/com/twitter/jaqen/ntuple/NTuples.scala
new file mode 100644
index 0000000..553ff37
--- /dev/null
+++ b/jaqen/src/main/scala/com/twitter/jaqen/ntuple/NTuples.scala
@@ -0,0 +1,111 @@
+package com.twitter.jaqen.ntuple
+
+
+class NTuple0 extends NTuple[NTuple0] {
+  override def toString = "()"
+}
+
+object Generator {
+  def main(args: Array[String]) {
+
+    def ntimes(n :Int)(f: (Int) => String) = (for (i <- 1 to n) yield f(i)).mkString(", ")
+
+    def sig(i: Int) = "NTuple" + i + "[" + ntimes(i){(j) => s"N$j, T$j"} + "]"
+
+    for (i <- 1 to 22) {
+      println("class " + sig(i) + "(" + ntimes(i){(j) => s"val _$j: T$j"} + ") extends NTuple[" + sig(i) + "] {")
+      println("  def toTuple = (" + ntimes(i){"_"+_} + ")")
+      println("  override def toString = toTuple.toString")
+      println("}")
+    }
+  }
+}
+// classes bellow have been generated by the object Generator above
+class NTuple1[N1, T1](val _1: T1) extends NTuple[NTuple1[N1, T1]] {
+  def toTuple = (_1)
+  override def toString = toTuple.toString
+}
+class NTuple2[N1, T1, N2, T2](val _1: T1, val _2: T2) extends NTuple[NTuple2[N1, T1, N2, T2]] {
+  def toTuple = (_1, _2)
+  override def toString = toTuple.toString
+}
+class NTuple3[N1, T1, N2, T2, N3, T3](val _1: T1, val _2: T2, val _3: T3) extends NTuple[NTuple3[N1, T1, N2, T2, N3, T3]] {
+  def toTuple = (_1, _2, _3)
+  override def toString = toTuple.toString
+}
+class NTuple4[N1, T1, N2, T2, N3, T3, N4, T4](val _1: T1, val _2: T2, val _3: T3, val _4: T4) extends NTuple[NTuple4[N1, T1, N2, T2, N3, T3, N4, T4]] {
+  def toTuple = (_1, _2, _3, _4)
+  override def toString = toTuple.toString
+}
+class NTuple5[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5) extends NTuple[NTuple5[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5]] {
+  def toTuple = (_1, _2, _3, _4, _5)
+  override def toString = toTuple.toString
+}
+class NTuple6[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6) extends NTuple[NTuple6[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6)
+  override def toString = toTuple.toString
+}
+class NTuple7[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6, val _7: T7) extends NTuple[NTuple7[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6, _7)
+  override def toString = toTuple.toString
+}
+class NTuple8[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6, val _7: T7, val _8: T8) extends NTuple[NTuple8[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6, _7, _8)
+  override def toString = toTuple.toString
+}
+class NTuple9[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6, val _7: T7, val _8: T8, val _9: T9) extends NTuple[NTuple9[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6, _7, _8, _9)
+  override def toString = toTuple.toString
+}
+class NTuple10[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6, val _7: T7, val _8: T8, val _9: T9, val _10: T10) extends NTuple[NTuple10[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6, _7, _8, _9, _10)
+  override def toString = toTuple.toString
+}
+class NTuple11[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6, val _7: T7, val _8: T8, val _9: T9, val _10: T10, val _11: T11) extends NTuple[NTuple11[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11)
+  override def toString = toTuple.toString
+}
+class NTuple12[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6, val _7: T7, val _8: T8, val _9: T9, val _10: T10, val _11: T11, val _12: T12) extends NTuple[NTuple12[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12)
+  override def toString = toTuple.toString
+}
+class NTuple13[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6, val _7: T7, val _8: T8, val _9: T9, val _10: T10, val _11: T11, val _12: T12, val _13: T13) extends NTuple[NTuple13[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13)
+  override def toString = toTuple.toString
+}
+class NTuple14[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6, val _7: T7, val _8: T8, val _9: T9, val _10: T10, val _11: T11, val _12: T12, val _13: T13, val _14: T14) extends NTuple[NTuple14[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14)
+  override def toString = toTuple.toString
+}
+class NTuple15[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14, N15, T15](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6, val _7: T7, val _8: T8, val _9: T9, val _10: T10, val _11: T11, val _12: T12, val _13: T13, val _14: T14, val _15: T15) extends NTuple[NTuple15[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14, N15, T15]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15)
+  override def toString = toTuple.toString
+}
+class NTuple16[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14, N15, T15, N16, T16](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6, val _7: T7, val _8: T8, val _9: T9, val _10: T10, val _11: T11, val _12: T12, val _13: T13, val _14: T14, val _15: T15, val _16: T16) extends NTuple[NTuple16[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14, N15, T15, N16, T16]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16)
+  override def toString = toTuple.toString
+}
+class NTuple17[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14, N15, T15, N16, T16, N17, T17](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6, val _7: T7, val _8: T8, val _9: T9, val _10: T10, val _11: T11, val _12: T12, val _13: T13, val _14: T14, val _15: T15, val _16: T16, val _17: T17) extends NTuple[NTuple17[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14, N15, T15, N16, T16, N17, T17]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17)
+  override def toString = toTuple.toString
+}
+class NTuple18[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14, N15, T15, N16, T16, N17, T17, N18, T18](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6, val _7: T7, val _8: T8, val _9: T9, val _10: T10, val _11: T11, val _12: T12, val _13: T13, val _14: T14, val _15: T15, val _16: T16, val _17: T17, val _18: T18) extends NTuple[NTuple18[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14, N15, T15, N16, T16, N17, T17, N18, T18]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18)
+  override def toString = toTuple.toString
+}
+class NTuple19[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14, N15, T15, N16, T16, N17, T17, N18, T18, N19, T19](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6, val _7: T7, val _8: T8, val _9: T9, val _10: T10, val _11: T11, val _12: T12, val _13: T13, val _14: T14, val _15: T15, val _16: T16, val _17: T17, val _18: T18, val _19: T19) extends NTuple[NTuple19[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14, N15, T15, N16, T16, N17, T17, N18, T18, N19, T19]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19)
+  override def toString = toTuple.toString
+}
+class NTuple20[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14, N15, T15, N16, T16, N17, T17, N18, T18, N19, T19, N20, T20](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6, val _7: T7, val _8: T8, val _9: T9, val _10: T10, val _11: T11, val _12: T12, val _13: T13, val _14: T14, val _15: T15, val _16: T16, val _17: T17, val _18: T18, val _19: T19, val _20: T20) extends NTuple[NTuple20[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14, N15, T15, N16, T16, N17, T17, N18, T18, N19, T19, N20, T20]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20)
+  override def toString = toTuple.toString
+}
+class NTuple21[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14, N15, T15, N16, T16, N17, T17, N18, T18, N19, T19, N20, T20, N21, T21](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6, val _7: T7, val _8: T8, val _9: T9, val _10: T10, val _11: T11, val _12: T12, val _13: T13, val _14: T14, val _15: T15, val _16: T16, val _17: T17, val _18: T18, val _19: T19, val _20: T20, val _21: T21) extends NTuple[NTuple21[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14, N15, T15, N16, T16, N17, T17, N18, T18, N19, T19, N20, T20, N21, T21]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21)
+  override def toString = toTuple.toString
+}
+class NTuple22[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14, N15, T15, N16, T16, N17, T17, N18, T18, N19, T19, N20, T20, N21, T21, N22, T22](val _1: T1, val _2: T2, val _3: T3, val _4: T4, val _5: T5, val _6: T6, val _7: T7, val _8: T8, val _9: T9, val _10: T10, val _11: T11, val _12: T12, val _13: T13, val _14: T14, val _15: T15, val _16: T16, val _17: T17, val _18: T18, val _19: T19, val _20: T20, val _21: T21, val _22: T22) extends NTuple[NTuple22[N1, T1, N2, T2, N3, T3, N4, T4, N5, T5, N6, T6, N7, T7, N8, T8, N9, T9, N10, T10, N11, T11, N12, T12, N13, T13, N14, T14, N15, T15, N16, T16, N17, T17, N18, T18, N19, T19, N20, T20, N21, T21, N22, T22]] {
+  def toTuple = (_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21, _22)
+  override def toString = toTuple.toString
+}
\ No newline at end of file
diff --git a/jaqen/src/main/scala/com/twitter/jaqen/ntuple/PrintExpr.scala b/jaqen/src/main/scala/com/twitter/jaqen/ntuple/PrintExpr.scala
new file mode 100644
index 0000000..9a951b0
--- /dev/null
+++ b/jaqen/src/main/scala/com/twitter/jaqen/ntuple/PrintExpr.scala
@@ -0,0 +1,80 @@
+package com.twitter.jaqen.ntuple
+
+import scala.language.experimental.macros
+import scala.reflect.macros.Context
+
+/**
+ * to help debug macros.
+ * will print the expression
+ */
+object PrintExpr {
+
+  def printExpr(param: Any): Unit = macro impl
+
+  def printParamType(param: Any): Unit = macro printParamTypeImpl
+
+  def indent(level: Int): String = {
+    (0 to level).foldLeft("")((agg, v) => "  " + agg)
+  }
+
+  def format(s: String) = {
+
+      def indexOfDelim(s: String, delim: String): (Int, String) = (s.indexOf(delim), delim)
+
+      def removeLeadingSpaces(s: String): String = if (s.startsWith(" ")) removeLeadingSpaces(s.substring(1)) else s
+
+      def splitNextDelim(s: String) = {
+        val delims = (List("(", ")", ",").map(indexOfDelim(s, _)).filter {
+          case (index, delim) => index != -1
+        }).sortBy {
+          case (index, delim) => index
+        }
+        if (delims.isEmpty) None else {
+          val (index, delim) = delims.head
+          Some((delim, s.substring(0, index), removeLeadingSpaces(s.substring(index + 1))))
+        }
+      }
+
+      def format0(agg: String, s: String, level: Int): String = {
+        splitNextDelim(s) match {
+          case None => agg + s
+          case Some((delim, before, after)) => {
+            delim match {
+              case "(" => if (after.startsWith(")"))
+                format0(agg + before + "()", after.substring(1), level)
+              else
+                format0(agg + before + "(\n" + indent(level + 1), after, level + 1)
+              case ")" =>
+                format0(agg + before + "\n" + indent(level - 1) + ")", after, level - 1)
+              case "," =>
+                format0(agg + before + ",\n" + indent(level), after, level)
+            }
+          }
+        }
+      }
+      format0("", s, 0)
+  }
+
+  def impl(c: Context)(param: c.Expr[Any]): c.Expr[Unit] = {
+    import c.universe._
+    def lit(s: String) = c.Expr[String](Literal(Constant(s)))
+    reify {
+      println("               param: " + lit(show(param.tree)).splice)
+      println("           raw param: " + lit(format(showRaw(param.tree, true, false, true, false))).splice)
+      println("raw param actualType: " + lit(format(showRaw(param.actualType, true, false, true, false))).splice)
+    }
+  }
+
+  def printParamTypeImpl(c: Context)(param: c.Expr[Any]): c.Expr[Unit] = {
+    import c.universe._
+
+    def lit(s: Any) = c.Expr[String](Literal(Constant(format(showRaw(s, true, false, true, false)))))
+
+    reify {
+      println("param.actualType      raw: " + lit(param.actualType).splice)
+      println("param.actualType toString: " + lit(param.actualType.toString).splice)
+    }
+  }
+
+}
+
diff --git a/pom.xml b/pom.xml
new file mode 100644
index 0000000..2740fc2
--- /dev/null
+++ b/pom.xml
@@ -0,0 +1,118 @@
+<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
+  <modelVersion>4.0.0</modelVersion>
+
+  <groupId>com.twitter</groupId>
+  <artifactId>jaqen-parent</artifactId>
+  <version>0.1.0-SNAPSHOT</version>
+  <packaging>pom</packaging>
+
+  <name>Jaqen parent</name>
+  <url>https://github.com/twitter/jaqen</url>
+  <description>A type-safe heterogenous Map or a Named field Tuple depending how you look at it</description>
+
+  <scm>
+    <connection>scm:git:git@github.com:twitter/jaqen.git</connection>
+    <url>scm:git:git@github.com:twitter/jaqen.git</url>
+    <developerConnection>scm:git:git@github.com:twitter/jaqen.git</developerConnection>
+  </scm>
+
+  <licenses>
+    <license>
+      <name>The Apache Software License, Version 2.0</name>
+      <url>http://www.apache.org/licenses/LICENSE-2.0.txt</url>
+    </license>
+  </licenses>
+
+  <developers>
+    <developer>
+      <name>Julien Le Dem</name>
+      <email>julien@twitter.com</email>
+    </developer>
+  </developers>
+
+  <distributionManagement>
+    <snapshotRepository>
+      <id>sonatype-nexus-snapshots</id>
+      <name>Sonatype OSS</name>
+      <url>https://oss.sonatype.org/content/repositories/snapshots</url>
+    </snapshotRepository>
+    <repository>
+      <id>sonatype-nexus-staging</id>
+      <name>Nexus Release Repository</name>
+      <url>https://oss.sonatype.org/service/local/staging/deploy/maven2/</url>
+    </repository>
+  </distributionManagement>
+
+  <repositories>
+    <repository>
+      <id>sonatype-nexus-snapshots</id>
+      <url>https://oss.sonatype.org/content/repositories/snapshots</url>
+      <releases>
+        <enabled>false</enabled>
+      </releases>
+      <snapshots>
+        <enabled>true</enabled>
+      </snapshots>
+    </repository>
+    <repository>
+      <id>scala-tools.org</id>
+      <name>Scala-tools Maven2 Repository</name>
+      <url>http://scala-tools.org/repo-releases</url>
+    </repository>
+  </repositories>
+  
+  <pluginRepositories>
+    <pluginRepository>
+      <id>scala-tools.org</id>
+      <name>Scala-tools Maven2 Repository</name>
+      <url>http://scala-tools.org/repo-releases</url>
+    </pluginRepository>
+  </pluginRepositories>
+   
+
+  <properties>
+    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
+    <github.global.server>github</github.global.server>
+    <scala.version>2.10.4</scala.version>
+  </properties>
+
+  <modules>
+    <module>jaqen</module>
+    <module>jaqen-test</module>
+  </modules>
+
+  <dependencies>
+    <dependency>
+      <groupId>org.scala-lang</groupId>
+      <artifactId>scala-library</artifactId>
+      <version>${scala.version}</version>
+    </dependency>
+    <dependency>
+      <groupId>org.scala-lang</groupId>
+      <artifactId>scala-reflect</artifactId>
+      <version>${scala.version}</version>
+    </dependency>
+  </dependencies>
+
+  <build>
+    <plugins>
+      <plugin>
+        <groupId>org.scala-tools</groupId>
+        <artifactId>maven-scala-plugin</artifactId>
+        <version>2.15.2</version>
+        <executions>
+          <execution>
+            <goals>
+              <goal>compile</goal>
+              <goal>testCompile</goal>
+            </goals>
+          </execution>
+        </executions>
+        <configuration>
+          <scalaVersion>${scala.version}</scalaVersion>
+        </configuration>
+      </plugin>
+    </plugins>
+  </build>
+
+</project>
diff --git a/run.sh b/run.sh
new file mode 100644
index 0000000..12d5254
--- /dev/null
+++ b/run.sh
@@ -0,0 +1,6 @@
+echo "compile"
+mvn clean compile || exit 1
+echo "run ntuple.TryNTuple"
+scala -classpath jaqen/target/classes:jaqen-test/target/classes ntuple.TryNTuple
+echo "run ntuple.DemoNTuple"
+scala -classpath jaqen/target/classes:jaqen-test/target/classes ntuple.DemoNTuple
