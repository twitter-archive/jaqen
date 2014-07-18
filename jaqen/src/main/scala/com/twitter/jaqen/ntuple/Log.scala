package com.twitter.jaqen.ntuple

import java.io.PrintWriter
import java.io.FileOutputStream

/**
 * hacky way of getting a log of what's happening in the macro
 */
object Log {
  val out = new PrintWriter(new FileOutputStream(System.getProperty("user.home") + "/macro.log", true), true)

  def apply(in: Any*) = out.println(in.map(String.valueOf(_)).mkString(" "))

}