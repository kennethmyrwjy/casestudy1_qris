# QRIS Payment Demo App – Final Specification for iOS Interview

**Project Goal**  
Create a production-grade iOS demo application that reads Indonesia’s QRIS (QR payment system) and performs a complete transaction flow using only **local data** (no real internet or backend required). The app must demonstrate clean architecture, security best practices, performance optimization, accessibility, and banking-grade UX.

**QR Code Specification**  
Example QR Code string:  
`BNI.ID12345678.MERCHANT MOCK TEST.50000`

**Format** (4 blocks separated by `.`):
- Block 1 → Source bank (e.g., `BNI`)
- Block 2 → Transaction ID (e.g., `ID12345678`)
- Block 3 → Merchant name (e.g., `MERCHANT MOCK TEST`)
- Block 4 → Transaction amount (e.g., `50000`)

All QR parsing logic must handle the exact format above, including edge cases (malformed strings, wrong bank, insufficient balance, etc.).

## Features & User Stories (in Bahasa Indonesia)

### Feature: Halaman Utama
**Story:**
1. User dapat melihat saldo awal miliknya

### Feature: Scan QR
**Story:**
1. User dapat melakukan scanning QR code di atas melalui kamera
2. User dapat melihat detail transaksi QRIS:
   - Nama Merchant
   - Nominal transaksi
   - ID transaksi

### Feature: Pembayaran
**Story:**
1. User dapat melihat **konfirmasi sebelum membayar** dan informasi **payment berhasil** (tampilan seperti receipt)
2. User dapat melihat saldo berkurang setelah pembayaran sukses

### Feature: Riwayat Transaksi
**Story:**
1. User dapat melihat riwayat transaksi (nama merchant, nominal); **tambahan**: timestamp

## Extra Requirements
- **Graceful error handling** with user-friendly Bahasa Indonesia messages and retry options:
  - Insufficient balance
  - Invalid QR format
  - Camera permission denied
  - Any other edge cases
- All data (balance, transaction history) must be stored locally.
- App UI must be primarily in **Bahasa Indonesia**.

## Design Reference
- Follow the **design principles** of the reference banking app pictures that will be attached (colors, typography, card styles, button hierarchy, spacing, navigation patterns, etc.).
- The reference functionalities are not identical, but the visual style, layout, and feel must be closely matched to create a consistent “government banking app” experience.
- Maintain Apple Human Interface Guidelines (HIG) compliance while mirroring the reference aesthetic.
- Prioritize clarity, trust signals, and calm professional banking UX.

## Core Tech Stack
- **Language**: Swift 6.3 (latest stable)
- **UI Framework**: UIKit (iOS 26 SDK – latest version)
- **Architecture**: VIPER + Clean Architecture principles
- **Project Structure**: Modular architecture (multiple framework targets in one Xcode project)
- **Dependency Manager**: CocoaPods
- **Testing**: XCTest (Unit Tests)

## Key Frameworks & Libraries
- **AVFoundation** → Camera preview + real-time QR code scanning (native, hardware-accelerated)
- **Combine / async-await** → Reactive, non-blocking data flow and state updates
- **Keychain Services + Core Data** (or UserDefaults for simplicity) → Secure balance storage and transaction history
- **SnapKit** → Declarative Auto Layout
- **Alamofire** → Mock REST API calls (payment confirmation simulation)
- **SwiftLint** (optional, dev-only) → Enforce clean code

## Development Planning & Structure
**5 VIPER Modules** (each as a separate framework target):
1. **Core** – Shared models, QR parser, network layer (mock), utilities
2. **Home** – Balance display
3. **Scan** – Camera preview, QR parsing, detail view
4. **Payment** – Confirmation screen, success receipt, balance deduction
5. **History** – Transaction list with timestamp

**Performance Focus** (key differentiator):
- 60 fps camera preview with zero main-thread blocking
- Background processing for QR parsing, business logic, and mock API calls
- Minimal dependencies for fast launch and low resource usage
- Debounced scanning, immediate AVCaptureSession cleanup
- Instruments-optimized flows

**Accessibility** (mandatory for government banking context):
- Dynamic Type support everywhere
- High color contrast (matching reference but WCAG AA compliant)
- VoiceOver labels, hints, and traits on all interactive elements

## Why This Stack Creates Maximum Impact
- Satisfies **every single requirement** from the recruiter:
  - Swift + latest UIKit
  - VIPER (nilai plus)
  - CocoaPods
  - Modular/project-based architecture
  - Unit Tests
- Mirrors real banking app expectations (security, performance, REST-like flow, accessibility).
- Allows you to open the demo with:  
  > “I designed the entire stack around performance so the QR scan-to-payment flow feels instantaneous — exactly like a real banking app must be.”

## Quick Implementation Roadmap
1. Create Xcode project → Add 5 framework targets (modular structure).
2. Set up `Podfile` with the minimal pods listed above.
3. Implement VIPER in each module **starting with Scan** (most impressive technical part).
4. Add unit tests for QR parser first (edge cases: malformed string, wrong bank, insufficient balance, etc.).
5. Profile with Instruments early to prove 60 fps and low CPU usage.
6. Prepare a **2-minute demo script** that walks through the stack + one performance win + security/accessibility decisions.