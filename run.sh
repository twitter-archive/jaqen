echo "compile"
mvn clean compile || exit 1
echo "run ntuple.TryNTuple"
scala -classpath jaqen/target/classes:jaqen-test/target/classes ntuple.TryNTuple
echo "run ntuple.DemoNTuple"
scala -classpath jaqen/target/classes:jaqen-test/target/classes ntuple.DemoNTuple
