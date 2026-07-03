# PHAT - Password Hashing Algorithm Tool
### GUI Flutter Version
**v 2026.04.23**

PHAT is a stateless password generation tool designed to create high-entropy, unique passwords from a single master secret and a site-specific salt. By using cryptographic hashing instead of a database, PHAT ensures your passwords are never stored, making it a "stateless" password manager.

## Key Features

*   **Multiple Algorithms**: Support for standard SHA-256, SHA-384, and SHA-512, as well as memory-hard Key Derivation Functions (KDFs) like **Argon2id** and **PBKDF2**.
*   **Flexible Encoding**: Output your passwords in **Hexadecimal**, **Base64**, or **Base58**.
*   **Length Restriction**: Fine-tune the output length (up to 128 characters) to meet specific site requirements.
*   **Entropy Meter**: Real-time strength estimation (in bits) to ensure your generated passwords meet high security standards.
*   **Theme Support**: Toggle between Dark and Light modes for comfortable use in any environment.
*   **High Performance**: Calculations are handled in background Isolates (and optimized via **Wasm** for Web) to keep the UI fluid.

## Security & Privacy

PHAT is built with a "Security First" philosophy:
*   **Stateless Operation**: No passwords, salts, or settings are ever stored on the device or in the cloud.
*   **Memory Hardening**: Sensitive data is handled using byte arrays (`Uint8List`) and is explicitly **zeroed out** of memory immediately after use.
*   **Auto-Clear**: The clipboard and UI results are automatically cleared after 30 seconds of inactivity.
*   **Background Protection**: The app automatically wipes all sensitive inputs and results if moved to the background or minimized.
*   **Modern Defaults**: Uses OWASP-recommended parameters (e.g., 600,000 iterations for PBKDF2).

## Technology Stack

*   **Framework**: Flutter (Dart)
*   **Web Target**: WebAssembly (WasmGC) for near-native cryptographic performance in the browser.
*   **Cryptography**: Powered by the `cryptography` and `crypto` packages.

## Build & Deployment

### Web (Wasm)
To build for the web with maximum performance:
```bash
flutter build web --wasm
```
*Note: Deployment on platforms like GitHub Pages requires the included `coi-serviceworker.js` to handle required security headers (COOP/COEP).*

### Testing
The project includes a comprehensive suite of unit and widget tests:
```bash
flutter test
```

## License & Credits

(C) 2026 Lorne Cammack, USA  
Released under **GNU Public License (GPL) v3**  
Email: [lowcam.socialvideo@gmail.com](mailto:lowcam.socialvideo@gmail.com)

---

*This project is provided as-is. Always ensure you remember your Master Secret and Salt, as they cannot be recovered if lost.*
