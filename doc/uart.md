# Register Definitions

| Address | Register Name       | Purpose                                                   |
|---------|----------------------|-----------------------------------------------------------|
| `0x00`  | Control              | Enables/disables UART and resets it.                      |
| `0x04`  | Mode                 | Sets baud rate, data bits, parity, etc.                   |
| `0x08`  | Status               | Indicates TX/RX readiness and error conditions.           |
| `0x0C`  | TX                   | Holds data for transmission (write-only).                 |
| `0x10`  | RX                   | Holds received data (read-only).                          |
| `0x14`  | Interrupt Enable     | Enables/disables specific interrupts.                     |
| `0x18`  | Interrupt Status     | Shows active interrupt conditions.                        |
| `0x1C`  | Interrupt Clear      | Clears specific interrupt flags after handling.           |
| `0x20`  | Interrupt Mask       | Temporarily suppresses specific interrupts from triggering the main interrupt line. |



