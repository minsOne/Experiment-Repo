# DI Container

심볼 추출 스크립트

```shell
symbolfilePath="/tmp/symbolfile_$(uuidgen)"
find "/Users/minsone/Library/Developer/Xcode/DerivedData/Application-auochsgggifqpibkqmxzehdavstz/Build/Products/Test-iphonesimulator/FeaturesDemoApp.app"  -type f -exec file {} \; | grep -e "Mach-O 64-bit dynamically linked shared library arm64" -e "Mach-O 64-bit executable arm64" | awk '{print $1}' | tr -d ":" | xargs nm | awk '{print $3}' | xcrun swift-demangle > $symbolfilePath
cat $symbolfilePath | grep "protocol conformance descriptor for " | grep "DIContainer.Injectable" | sed -E "s/protocol conformance descriptor for (.*) : (.*) in .*/\1 : \2/g"
cat $symbolfilePath | grep "protocol conformance descriptor for " | grep "DIContainer.InjectionKey" | sed -E "s/protocol conformance descriptor for (.*) : (.*) in .*/\1 : \2/g"
cat $symbolfilePath | grep "protocol conformance descriptor for " | grep "DIContainer.InjectionType" | sed -E "s/protocol conformance descriptor for (.*) : (.*) in .*/\1 : \2/g"

cat $symbolfilePath | grep "protocol conformance descriptor for FeatureAuth.AuthService :" | grep -v "DIContainer" | sed -E "s/protocol conformance descriptor for (.*) : (.*) in .*/\1 : \2/g"
```

추후 개선시 참고자료
* https://github.com/devxoul/Pure
