require 'securerandom'

def find_interface_type(key, path)
    cmd = <<HEREDOC
    cat #{path} | grep "property descriptor for #{key}.type :" | sed -E "s/.* : (.*)\\?/\\1/g"
HEREDOC
    value = `#{cmd}`
    # puts value
    return value.strip
end

def find_concreate_type(interface, path)
    cmd = <<HEREDOC
    cat #{path} | grep "#{interface}" | grep "protocol conformance descriptor for " | sed -E "s/protocol conformance descriptor for (.*) : .* in .*/\\1/g"
HEREDOC
    #puts cmd
    value = `#{cmd}`
    #puts value
    return value.strip
end

def generate_symbol(path)
    cmd = <<HEREDOC
    BUILD_APP_DIR=${BUILT_PRODUCTS_DIR}/${FULL_PRODUCT_NAME}
    find ${BUILD_APP_DIR} -type f -exec file {} \\; | grep -e "Mach-O 64-bit dynamically linked shared library arm64" | awk '{print $1}' | tr -d ":" | xargs nm | awk '{print $3}' | xcrun swift-demangle > #{path}
HEREDOC
    #puts cmd
    _ = `#{cmd}`
end

def find_keylist(path)
    cmd = <<HEREDOC
    cat #{path} | grep "protocol conformance descriptor for " | grep "DIContainer.InjectionKey" | sed -E "s/protocol conformance descriptor for (.*) : (.*) in .*/\\1/g"
HEREDOC
    #puts cmd
    value = `#{cmd}`
    # puts value
    return value
end

def makeContainer(hash)
    output = "// MARK: - Generated File From Scripts\n\n"

    import_list = ["import DIContainer\n"]
    for key in hash.keys do
        import_list.append("import #{key.split(".")[0]}\n")
        if !hash[key].empty?
            import_list.append("import #{hash[key].split(".")[0]}\n")
        end
    end

    for import in import_list.uniq.sort do
        output += import
    end

    output += "\nstruct ContainerRegisterService {\n"
    output += "    func register() {\n"
    output += "        Container {\n"

    hash.each do |key, value|
        if value.empty?
            output += "            Component(#{key}.self){ <#구현타입없음확인필요#> }\n"
        else
            output += "            Component(#{key}.self){ #{value}() }\n"
        end
        #output += "            Component(#{key.split(".")[1..-1].join('.')}.self){ <#구현타입없음확인필요#> }\n"
    end

    output += "        }.build()\n"
    output += "    }\n"
    output += "}\n"
    puts output
end

symbolfilePath="/tmp/symbolfile_#{SecureRandom.uuid}"

generate_symbol(symbolfilePath)

key_list = find_keylist(symbolfilePath).split("\n")
container = Hash.new

for key in key_list do
    #puts key
    container[key] = ""
    interface_type = find_interface_type(key, symbolfilePath)
    #puts interface_type
    concreate_type = find_concreate_type(interface_type, symbolfilePath)
    #puts concreate_type
    container[key] = concreate_type
end

#puts container

makeContainer(container)