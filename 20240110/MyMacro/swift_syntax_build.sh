#!/bin/bash

SWIFT_SYNTAX_VERSION=$1
SWIFT_SYNTAX_NAME="swift-syntax"
SWIFT_SYNTAX_REPOSITORY_URL="https://github.com/apple/$SWIFT_SYNTAX_NAME.git"
SEMVER_PATTERN="^[0-9]+\.[0-9]+\.[0-9]+$"
WRAPPER_NAME="SwiftSyntaxWrapper"
CONFIGURATION="debug"
LIBRARY_NAME="lib$WRAPPER_NAME.a"
XCFRAMEWORK_NAME="$WRAPPER_NAME.xcframework"
ARCH_LIST=(
    "x86_64"
    "arm64"
)
UNIVERSAL_ARCH="arm64_x86_64"

#
# Verify input
#

if [ -z "$SWIFT_SYNTAX_VERSION" ]; then
    echo "Swift syntax version (git tag) must be supplied as the first argument"
    exit 1
fi

if ! [[ $SWIFT_SYNTAX_VERSION =~ $SEMVER_PATTERN ]]; then
    echo "The given version ($SWIFT_SYNTAX_VERSION) does not have the right format (expected X.Y.Z)."
    exit 1
fi

#
# Print input
#

cat << EOF

Input:
swift-syntax version to build:  $SWIFT_SYNTAX_VERSION

EOF

set -eux

#
# Clone package
#

git clone --branch $SWIFT_SYNTAX_VERSION --single-branch $SWIFT_SYNTAX_REPOSITORY_URL

#
# Add static wrapper product
#

sed -i '' -E "s/(products: \[)$/\1\n    .library(name: \"${WRAPPER_NAME}\", type: .static, targets: [\"${WRAPPER_NAME}\"]),/g" "$SWIFT_SYNTAX_NAME/Package.swift"

#
# Add target for wrapper product
#

sed -i '' -E "s/(targets: \[)$/\1\n    .target(name: \"${WRAPPER_NAME}\", dependencies: [\"SwiftCompilerPlugin\", \"SwiftSyntax\", \"SwiftSyntaxBuilder\", \"SwiftSyntaxMacros\", \"SwiftSyntaxMacrosTestSupport\"]),/g" "$SWIFT_SYNTAX_NAME/Package.swift"

#
# Add exported imports to wrapper target
#

WRAPPER_TARGET_SOURCES_PATH="$SWIFT_SYNTAX_NAME/Sources/$WRAPPER_NAME"

mkdir -p $WRAPPER_TARGET_SOURCES_PATH

tee $WRAPPER_TARGET_SOURCES_PATH/ExportedImports.swift <<EOF
@_exported import SwiftCompilerPlugin
@_exported import SwiftSyntax
@_exported import SwiftSyntaxBuilder
@_exported import SwiftSyntaxMacros
EOF

#
# Build the wrapper
#

for ARCH in ${ARCH_LIST[@]}; do
    swift build --package-path $SWIFT_SYNTAX_NAME --arch $ARCH -c $CONFIGURATION -Xswiftc -enable-library-evolution -Xswiftc -emit-module-interface
done

#
# Create XCFramework
#

LIBRARY_PATHS=""
for ARCH in ${ARCH_LIST[@]}; do
    LIBRARY_PATHS+=" $SWIFT_SYNTAX_NAME/.build/$ARCH-apple-macosx/$CONFIGURATION/$LIBRARY_NAME"
done

lipo -create $LIBRARY_PATHS -output $LIBRARY_NAME

xcodebuild -create-xcframework -library $LIBRARY_NAME -output $XCFRAMEWORK_NAME

MODULES=(
    "SwiftBasicFormat"
    "SwiftCompilerPlugin"
    "SwiftCompilerPluginMessageHandling"
    "SwiftDiagnostics"
    "SwiftIDEUtils"
    "SwiftOperators"
    "SwiftParser"
    "SwiftParserDiagnostics"
    "SwiftRefactor"
    "SwiftSyntax"
    "SwiftSyntaxBuilder"
    "SwiftSyntaxMacroExpansion"
    "SwiftSyntaxMacros"
    "SwiftSyntaxMacrosTestSupport"
    "_SwiftSyntaxTestSupport"
    "$WRAPPER_NAME"
)

for MODULE in ${MODULES[@]}; do
    PATH_TO_INTERFACE="${SWIFT_SYNTAX_NAME}/.build/x86_64-apple-macosx/${CONFIGURATION}/${MODULE}.build/${MODULE}.swiftinterface"
    cp "${PATH_TO_INTERFACE}" "${XCFRAMEWORK_NAME}/macos-${UNIVERSAL_ARCH}"
done

rm -rf $SWIFT_SYNTAX_NAME
rm -rf $LIBRARY_NAME
mkdir -p XCFramework
mv $XCFRAMEWORK_NAME XCFramework/$XCFRAMEWORK_NAME
