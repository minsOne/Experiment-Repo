require 'xcodeproj'

def makeTestTarget(target, path)
  output = "\n    {"
  if !(path.include? "Application.xcodeproj")
    output += "\n      \"parallelizable\" : true,"
  end

  output += "\n      \"target\" : {"
  if path.include? "Application.xcodeproj"
    output += "\n        \"containerPath\" : \"container:Application.xcodeproj\","
  else
    output += "\n        \"containerPath\" : \"container:..\\/#{path.gsub("/", "\\/")}\","
  end
  output += "\n        \"identifier\" : \"#{target.uuid}\","
  output += "\n        \"name\" : \"#{target.name}\""
  output += "\n      }"
  output += "\n    },"

  return output
end
output = <<HEREDOC
{
  "configurations" : [
    {
      "id" : "36E28BCA-F3CC-4EBF-A90F-EE0B8DF0AA8A",
      "name" : "Configuration 1",
      "options" : {}
    }
  ],
  "defaultOptions" : {
    "commandLineArgumentEntries" : []
  },
  "testTargets" : [
HEREDOC

# cmd = "(cd $(git rev-parse --show-toplevel) && find Projects -type d -name '*.xcodeproj')"
cmd = "find . -type d -name '*.xcodeproj'"
value = `#{cmd}`

value.split(/\n+/).sort.each { |item|
  next if item.include? "DevelopTool"

  project_path = item
  project = Xcodeproj::Project.open(project_path)
  project.targets.each do |target|
    puts project_path#, target.product_type, target.name, target.uuid
    if target.product_type == "com.apple.product-type.bundle.unit-test"
      output += makeTestTarget(target, project_path)
    end
  end
}

output += "\n  ],
  \"version\" : 1
}
"

puts output