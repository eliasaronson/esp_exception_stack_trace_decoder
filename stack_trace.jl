# Using idf.py to parse errors so that mast be installed. Can be installed with
# AUR, otherwise you are on your own.

using Dates, Colors

function execute(cmd::Cmd)
    out = Pipe()
    err = Pipe()

    process = run(pipeline(ignorestatus(cmd), stdout=out, stderr=err))
    close(out.in)
    close(err.in)

    (
     stdout = String(read(out)),
     stderr = String(read(err)),
     code = process.exitcode
    )
end

function test_idf()
    success = true
    try execute(`idf.py`)
    catch
        success = false
    end

    if !success
        println("Needed program \"idf\" not found. Please install it or run \"source /opt/esp-idf/export.sh\" if already installed.")
        # println("idf not found. Running \"source /opt/esp-idf/export.sh\"")
        # execute(`source /opt/esp-idf/export.sh`)
        return false
    end

    println("Found \"idf\". Ready...")
    return true
end

# Looks for newst "arduino-sketch" folder in /tmp and returns first "*.elf"
# files found in it.
function find_elf_file(root_path = "/tmp")
    tmp_files = readdir(root_path)
    filter!(x -> occursin("arduino-sketch", x), tmp_files)

    n_files = length(tmp_files)
    if n_files < 1
        println("No \"*.elf\" file found. Exiting.")
        exit()
    end

    times = Array{DateTime}(undef, length(tmp_files))
    for i ∈ 1:n_files
        times[i] = Dates.unix2datetime(mtime(root_path * "/" * tmp_files[i]))
    end

    # Get newest sketch.
    skecth_folder = tmp_files[argmax(times)]

    tmp_files = readdir(root_path * "/" * skecth_folder)
    filter!(x -> occursin(".elf", x), tmp_files)

    res = root_path * "/" * skecth_folder * "/" * tmp_files[1]
    println("Found: ", res)
    return res
end

if !test_idf()
    exit()
end

function print_rgb(text, r, g, b)
    println("\e[1m\e[38;2;$r;$g;$b;249m", text)
end

elf_path = find_elf_file()
println("Input stack trace:")
stacks = split(readline(), " ");
print_rgb("\nTarce: ", 0, 0, 200)

filter!(x -> x != "Backtrace:", stacks)

for stack ∈ stacks
    adress = split(stack, ":")[1]
    res = execute(`xtensa-esp32-elf-addr2line -pfiaC -e $elf_path $adress`)
    res_split = split(res[1], ":")
    printstyled(res_split[1]; color = :blue)
    print(":")
    printstyled(join(res_split[2:end-1]); color = :cyan)
    print(":")
    printstyled(res_split[end]; color = :green)
end

println("Done.")
