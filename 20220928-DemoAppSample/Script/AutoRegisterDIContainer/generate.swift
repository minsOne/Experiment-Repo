#!/usr/bin/env swift
import Foundation

let ls = Process()
ls.executableURL = URL(fileURLWithPath: "/bin/ls")
ls.arguments = ["-al"]
do{
  try ls.run()
} catch { //TODO: write catch for executing command
}