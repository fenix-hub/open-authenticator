# QRNative

Godot Engine 4.x GDExtension module exposing interfaces to encode and decode QRCodes in GDScript.

## Usage
```gdscript
func _ready() -> void:
    # Decoding
    var qr: Image = Image.load_from_file("res://qrcode.png")
    var qr_decode_result: QRDecodeResult = QRNative.decode_image(qr)
    if qr_decode_result.is_valid():
        print(qr_decode_result.get_content())
    
    # Encoding
    var qr_content: String = "This is the content of my QR Code!"
    var qr_code: Image = QRNative.encode_string(qr_content, 100, 100, 5)
    $QRCode.set_texture(ImageTexture.create_from_image(qr_code))
```

## Getting started / Building the extension

### VSCode Compilation (only applicable if you are using VSCode as your code editor)
For the initial build you can run the vscode task `initial-build-extension`. This compiles both godot-cpp and the extension. For all subsequent builds, you only need to run the task `build-extension`.

### Manual Compilation

To compile the extension you need to follow these steps:

1. Clone the extension recursively from this repository
```bash
# --recursive to automatically load the submodule godot-cpp
# The git adress can be found under the green "Code" dropdown menu
git clone --recursive (--GITHUB ADRESS--)
```

2. Make sure you are in the top level of the repository
```bash
pwd
.../qrnative
```

3. Go inside the godot-cpp folder
```bash
cd godot-cpp
```

4. Compile godot-cpp and generate bindings (only need to do this once when starting development or when there is an update of the submodule)
```bash
scons target=debug generate_bindings=yes
```

5. Go back to the top level of the directory
```bash
cd ..
```

6. Compile the extension
```bash
scons target=debug
```

## Resources
- [GDSummatorExample](https://github.com/paddy-exe/GDExtensionSummator) by @paddy-exe  
- [GDExtension](https://github.com/nathanfranke/gdextension) by @nathanfranke
