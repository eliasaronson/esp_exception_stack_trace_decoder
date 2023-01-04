# ESP32/ESP8266 exception stack trace decoder
Julia script for decoding ESP32/ESP8266 exception stack traces with IDF.

This script first finds the newest Arduino sketch in the /tmp folder and looks for a .elf-file to match the stack trace to. It then reads an input with the stack trace and runs xtensa-esp32-elf-addr2line on each address.

## Dependencies
* [ESP-IDF](https://github.com/espressif/esp-idf)
* [Julia](https://julialang.org/)

ESP-IDF can be installed from the AUR on arch-based distros. Using yay it can be installed with:
```
yay -S esp-idf
```

## Running
Go to the directory of the cloned repo and just run the script. When prompted, paste the stack trace.

```
git clone https://github.com/eliasaronson/esp_exception_stack_trace_decoder.git
cd esp_exception_stack_trace_decoder
julia stack_trace.jl
```

Example:
![alt text](https://github.com/eliasaronson/esp_exception_stack_trace_decoder/blob/main/Example.png)
