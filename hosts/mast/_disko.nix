# Confirmed via `lsblk` on the physical machine during install.
# LUKS-encrypted (portable, real loss/theft exposure).
import ../../lib/disko-layout.nix { device = "/dev/nvme0n1"; luks = true; }
