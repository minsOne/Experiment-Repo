#!/usr/bin/env bash
set -euo pipefail

LOG_PATH="${1:-${TMPDIR}dismiss-probe-events.jsonl}"

ruby -rjson -e '
  path = ARGV[0]
  unless File.exist?(path)
    abort "log file not found: #{path}"
  end

  events = []
  File.readlines(path).each do |line|
    line = line.strip
    next if line.empty?
    events << JSON.parse(line)
  end

  puts "Loaded #{events.size} events from #{path}"
  if events.empty?
    puts "No events."
    exit
  end

  grouped = {}
  events.each do |e|
    next unless e["event"] == "viewDidDisappear"
    grouped[e["vcName"]] = e
  end

  puts ""
  puts "vcName\tisBeingDismissed\tisMovingFromParent\tviewWindowIsNil"
  grouped.keys.sort.each do |name|
    e = grouped[name]
    puts "#{name}\t#{e["isBeingDismissed"]}\t#{e["isMovingFromParent"]}\t#{e["viewWindowIsNil"]}"
  end
' "$LOG_PATH"
