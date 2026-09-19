# PLACEHOLDER device — assumes the single-NVMe-disk layout typical of this
# laptop generation. Confirm with `lsblk` on the physical machine before
# ever actually running disko against it. LUKS-encrypted (portable, real
# loss/theft exposure).
import ../../lib/disko-layout.nix { device = "/dev/nvme0n1"; luks = true; }
