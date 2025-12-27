# Buildroot External Tree for Kobo E-Readers

## Overview

This Buildroot external tree provides a custom Linux system for Kobo e-readers. The system is designed to run **alongside the existing Kobo system** and **with the existing bootloader and kernel** rather than replacing it entirely.

## Important Notes

### Dual System Operation

This system is intended to be used alongside the existing Kobo system because it **copies certain files from the stock Kobo system at first boot**. It does not completely replace the original Kobo firmware but provides an alternative boot option. This is because the new Kobo devices use Secure Boot.

### Device Support

**Currently supported devices:**
- **Kobo Clara Colour** (with Secure Boot)

⚠️ **Important:** The Kobo Clara Colour uses Secure Boot, which requires a **custom init script** to properly boot into this system. Make sure to use the appropriate init script for secure boot devices. Check [kobo-init](https://github.com/Spin42/kobo-init) for an example.

### Device Limitations

At this time, only the Kobo Clara Colour is supported. Support for other Kobo devices may be added in future releases.

## Contributing

Contributions and device support additions are welcome.
