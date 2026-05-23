import Foundation

enum ScanError: Error, Equatable {
    case cameraUnavailable
    case permissionDenied
    case invalidQR(QRParseError)
}

extension ScanError {
    var userMessage: String {
        switch self {
        case .cameraUnavailable:
            return "Kamera tidak tersedia di perangkat ini."
        case .permissionDenied:
            return "Izin kamera ditolak. Buka Pengaturan untuk mengaktifkannya."
        case .invalidQR(let underlying):
            switch underlying {
            case .empty:
                return "Kode QR kosong. Silakan coba lagi."
            case .wrongFieldCount:
                return "Format QRIS tidak valid. Pastikan Anda memindai kode QRIS yang benar."
            case .unknownBank(let bank):
                return "Bank '\(bank)' belum didukung. Gunakan QRIS dari bank yang didukung."
            case .invalidTransactionId, .invalidMerchantName:
                return "Detail transaksi tidak lengkap pada kode QR ini."
            case .invalidAmount, .nonPositiveAmount:
                return "Nominal pada kode QR tidak valid."
            }
        }
    }
}
