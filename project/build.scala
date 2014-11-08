import sbt._, Keys._

object JaqenBuildSettings {
  val paradiseVersion = "2.0.1"
  val buildSettings = Defaults.defaultSettings ++ Seq(
    organization := "com.twitter",
    version := "0.1.1-SNAPSHOT",
    scalacOptions ++= Seq("-deprecation"),
    scalaVersion := "2.11.4",
    crossScalaVersions := Seq("2.10.4", "2.11.4"),
    resolvers += Resolver.sonatypeRepo("snapshots"),
    resolvers += Resolver.sonatypeRepo("releases"),
    addCompilerPlugin(
      "org.scalamacros" % "paradise" % paradiseVersion cross CrossVersion.full
    ),
    libraryDependencies ++= Seq(
      "junit" % "junit" % "4.11" % "test",
      "org.scalatest" %% "scalatest" % "2.2.1" % "test"
    )
  )
}

object JaqenBuild extends Build {
  import JaqenBuildSettings._

  lazy val root: Project = Project(
    "root",
    file("."),
    settings = buildSettings ++ Seq(
      run <<= run in Compile in test
    )
  ) aggregate(ntuple, test)

  lazy val ntuple: Project = Project(
    "jaqen-ntuple",
    file("jaqen-ntuple"),
    settings = buildSettings ++ Seq(
      libraryDependencies <+= (scalaVersion)(
        "org.scala-lang" % "scala-reflect" % _
      ),
      libraryDependencies ++= (
        if (scalaVersion.value.startsWith("2.10"))
          List("org.scalamacros" %% "quasiquotes" % paradiseVersion)
        else Nil
      )
    )
  )

  lazy val test: Project = Project(
    "jaqen-test",
    file("jaqen-test"),
    settings = buildSettings
  ) dependsOn(ntuple)
}
