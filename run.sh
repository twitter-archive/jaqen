echo "compile"
mvn clean compile || exit 1
echo "run ntuple.TryNTuple"
scala -classpath jaqen-ntuple/target/classes:jaqen-test/target/classes com.twitter.jaqen.ntuple.TryNTuple
echo "run ntuple.DemoNTuple"
scala -classpath jaqen-ntuple/target/classes:jaqen-test/target/classes com.twitter.jaqen.ntuple.DemoNTuple
