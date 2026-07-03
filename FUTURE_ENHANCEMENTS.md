# PHAT CALC - Future Enhancements & Roadmap

This document outlines potential features and improvements to be implemented in future versions of the PHAT (Password Hashing Algorithm Tool).

---

## Completed Enhancements
*   **Zero-Persistence Mode**: Implemented automatic wiping of all fields (Input, Salt, Output) when the application loses focus or is backgrounded.
*   **Theming Options**: Added a high-contrast Light Mode and a dynamic theme toggle.
*   **WebAssembly (WASM) Hashing**: Migrated heavy KDF logic (Argon2id) to WASM for near-native performance in the browser.
*   **Unit & Integration Testing**: Expanded the test suite to include automated validation of hashing results and UI state integrity.
*   **Memory Hardening**: Implemented low-level byte array (`Uint8List`) handling with explicit zero-filling (wiping) of sensitive data in memory.
*   **Entropy Education**: Added an interactive guide in the Info Drawer to help users understand bit-strength and security levels.

## Security & Privacy
*   **Biometric Locking**: Add optional Fingerprint/FaceID authentication (via `local_auth`) to view generated outputs or open the app.
*   **Input Entropy Meter**: Implement a real-time strength meter for the *Master Secret* (input text) to help users choose stronger base passwords.
*   **Offline Mode (PWA)**: Enhance Progressive Web App support to ensure the tool functions 100% offline without any external network dependencies.
*   **Custom Auto-Clear Timer**: Allow users to configure the 30-second clipboard/UI clear window to their preference (e.g., 15s, 60s).

## Advanced Functionality
*   **Master Key Profiles**: Save "recipes" (algorithm choice + length + system) for different types of accounts without storing the actual master password or salt.
*   **Character Set Templates**: Add a post-processing step to ensure the output meets specific site requirements (e.g., "Must contain at least one symbol").
*   **QR Code Generation**: Display the hashed output as a QR code for easy transfer to mobile devices/password managers via camera.
*   **File Checksum Utility**: Add a dedicated tab for hashing local files (drag-and-drop) to verify file integrity using SHA-256/512.
*   **Bulk Generation**: Allow users to provide a list of salts (e.g., a list of service names) to generate multiple distinct passwords simultaneously.

## User Experience (UX)
*   **Haptic Feedback**: Add subtle vibrations (via `HapticFeedback`) when calculating, copying, or generating salts for a more tactile feel.
*   **Visual Feedback**: Implement a success animation for the "Copy" button (e.g., icon morphing from copy to checkmark).
*   **Keyboard Shortcuts**: Add support for `Ctrl+Enter` to calculate and `Ctrl+C` (when the output is generated) to copy.
*   **Internationalization (i18n)**: Support for multiple languages to expand the user base globally.

---
*Updated on: 2026.04.23*
