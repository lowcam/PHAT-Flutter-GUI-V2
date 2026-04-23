# PHAT CALC - Future Enhancements & Roadmap

This document outlines potential features and improvements to be implemented in future versions of the PHAT (Password Hashing Algorithm Tool).

---

## 🛡️ Security & Privacy
*   **Offline Mode (PWA)**: Implement Progressive Web App support to allow the tool to function entirely offline, ensuring sensitive data never has to leave the local environment.
*   **Zero-Persistence Mode**: A toggle to automatically wipe all fields (Input, Salt, Output) when the browser tab loses focus or is closed.
*   **Custom Auto-Clear Timer**: Allow users to configure the 30-second clipboard/UI clear window to their preference (e.g., 15s, 60s).

## 🚀 Advanced Functionality
*   **QR Code Generation**: Display the hashed output as a QR code for easy transfer to mobile devices/password managers via camera.
*   **File Checksum Utility**: Add a dedicated tab for hashing local files (drag-and-drop) to verify file integrity using SHA-256/512.
*   **Bulk Generation**: Allow users to provide a list of salts (e.g., a list of service names) to generate multiple distinct passwords simultaneously.
*   **Master Key Profiles**: Save "recipes" (algorithm choice + length + system) for different types of accounts without storing the actual master password or salt.

## ✨ User Experience (UX)
*   **Theming Options**: Add a "Light Mode" and a "System Default" theme toggle. Allow users to customize the primary accent color.
*   **Visual Feedback**: Implement a success animation for the "Copy" button (e.g., icon morphing from copy to checkmark).
*   **Keyboard Shortcuts**: Add support for `Ctrl+Enter` to calculate and `Ctrl+C` (when the output is generated) to copy.

## ⚙️ Technical Optimizations
*   **WebAssembly (WASM) Hashing**: Migrate heavy KDF logic (Argon2id) to WASM for near-native performance on high-memory settings.
*   **Internationalization (i18n)**: Support for multiple languages to expand the user base globally.
*   **Unit Testing**: Expand the test suite to include automated validation of hashing results against industry-standard test vectors.

---
*Documented on: 2026.01.23*
