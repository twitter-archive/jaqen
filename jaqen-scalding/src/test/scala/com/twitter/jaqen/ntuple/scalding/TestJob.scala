package com.twitter.jaqen.ntuple.scalding

import com.twitter.jaqen.ntuple.NTuple._
import com.twitter.jaqen.ntuple.scalding.NPipe._
import com.twitter.scalding._
import com.twitter.scalding.typed.MemorySink
import org.junit.runner.RunWith
import org.scalatest.FlatSpec
import org.scalatest.junit.JUnitRunner
import com.twitter.scalding.TypedTsv

class TestJob(args: Args) extends Job(args) {

  val input = TypedPipe.from(List((1, 2), (2, 3)))

  input.map {
    case (a, b) => t('a -> a, 'b -> b)
  }
  .nmap(('a, 'b) -> 'c) { (a:Int, b:Int) => a + b }
  .ndiscard('a, 'b)
  .map((_('c)))
  .write(TypedTsv("output"))

}

@RunWith(classOf[JUnitRunner])
class TestNPipe extends FlatSpec {
  "ntuples" should "nmap on typed pipes" in {
    JobTest(new TestJob(_))
    .sink[(Int)](TypedTsv[(Int)]("output")) { outBuf =>
        val list = outBuf.toList
        if (list != List(3, 5)) {
          throw new RuntimeException("unexpected result: " + list)
        }
      }
    .run
    .finish
  }
}

