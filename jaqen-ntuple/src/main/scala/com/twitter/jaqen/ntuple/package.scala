package com.twitter.jaqen

import scala.language.experimental.macros

package object ntuple {
  implicit class RichList[T] (val list: List[T]) {
    def nmap(pair: Any)(f: Any) = macro NTupleMacros.listMapImpl[T]
  }
}
