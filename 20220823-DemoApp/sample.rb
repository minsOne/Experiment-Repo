# FileName : generate_xctestplan.rb

require 'xcodeproj'

def makeTestTarget(target, path)
  output = "\n    {"
  output += "\n      \"parallelizable\" : true,"

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
    "testTimeoutsEnabled" : true
  },
  "testTargets" : [
HEREDOC

cmd = "find Projects -type d -name '*.xcodeproj'"
value = `#{cmd}`

value.split(/\n+/).sort.each { |item|
  project_path = item
  project = Xcodeproj::Project.open(project_path)
  project_path["Projects/"] = ""
  project.targets.each do |target|
    if target.product_type.include? "com.apple.product-type.bundle.unit-test" 
      output += makeTestTarget(target, project_path)
    elsif target.product_type.include? "com.apple.product-type.bundle.ui-testing"
      output += makeTestTarget(target, project_path)
    end
  end
}

output += "\n  ],
  \"version\" : 1
}
"

puts output

# "com.apple.product-type.bundle.ui-testing" 