#!/usr/bin/env sh

mint run swiftformat swiftformat --lint .
fastlane scan scheme Zakkuri
