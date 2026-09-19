# Real device, confirmed via lsblk on this exact desktop hardware (single
# 2TB NVMe). No encryption — physically secured desktop.
import ../../lib/disko-layout.nix { device = "/dev/nvme0n1"; luks = false; }
