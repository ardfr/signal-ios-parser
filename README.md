# signal-ios-parser
Signal iOS SQLCipher parser with HTML reporting and attachment decryption

Signal iOS SQLCipher forensic parser for extracting messages, calls, and encrypted attachments from `Signal.sqlite`.

This tool decrypts the Signal iOS database using a valid 96-character SQLCipher key, generates structured forensic reports, produces a chat-style HTML view, and optionally decrypts associated encrypted attachments.

---

## Features

- Decrypts `Signal.sqlite` (SQLCipher)
- Extracts messages, threads, and call records
- Generates:
  - `signal_ios_messages.csv`
  - `signal_ios_forensic_report.html`
  - `signal_ios_chat_style_report.html`
- Decrypts AES-CBC encrypted attachments
- Verifies HMAC integrity (where applicable)
- Produces `attachment_decryption_log.csv`

---

## Usage
**signal_ios_parser.exe --db "<path_to_Signal.sqlite>" --key <96_hex_key> --out "<output_folder>"**

## Attachment Decryption

After report generation, the tool will prompt:
Enter full path to the attachments_files folder (or press Enter to skip)

If provided, the tool will:

- Automatically use the generated `signal_ios_messages.csv`
- Locate encrypted files using `attachment_local_path`
- Decrypt attachments
- Output decrypted files to: **<output_folder>\decrypted_attachments\****
