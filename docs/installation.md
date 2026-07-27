# NixOS Installation Guide

This guide covers the steps needed to install NixOS using this configuration on a fresh machine. The config expects a btrfs filesystem with specific subvolumes.

## Prerequisites

- NixOS installer booted (USB or similar)
- Target disk identified (examples below use `/dev/nvme0n1` — adjust for your device)

## 1. Partition the Disk

Create a GPT partition table with two partitions: an EFI System Partition and a btrfs root partition.

```bash
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart primary 512MiB 100%
```

## 2. Format the Partitions

```bash
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.btrfs /dev/nvme0n1p2
```

## 3. Create Btrfs Subvolumes

The configuration expects exactly four subvolumes:

| Subvolume | Mount Point | Purpose |
|-----------|-------------|---------|
| `@root` | `/` | System root |
| `@home` | `/home` | User data |
| `@nix` | `/nix` | Nix store |
| `@snapshots` | `/.snapshots` | Snapper snapshots |

```bash
mount /dev/nvme0n1p2 /mnt

btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@snapshots

umount /mnt
```

## 4. Mount the Filesystem

Mount all subvolumes with the options expected by `hosts/meridian/hardware.nix`:

```bash
mount -o subvol=@root,compress=zstd,noatime /dev/nvme0n1p2 /mnt

mkdir -p /mnt/{home,nix,.snapshots,boot}

mount -o subvol=@home,compress=zstd,noatime /dev/nvme0n1p2 /mnt/home
mount -o subvol=@nix,compress=zstd,noatime /dev/nvme0n1p2 /mnt/nix
mount -o subvol=@snapshots,compress=zstd,noatime /dev/nvme0n1p2 /mnt/.snapshots
mount /dev/nvme0n1p1 /mnt/boot
```

## 5. Update UUIDs in hardware.nix

Get the real UUIDs for your partitions:

```bash
blkid /dev/nvme0n1p1  # EFI partition UUID
blkid /dev/nvme0n1p2  # Btrfs partition UUID
```

Edit `hosts/meridian/hardware.nix` and replace:
- `PLACEHOLDER-ROOT-UUID` with the UUID from `/dev/nvme0n1p2`
- `PLACEHOLDER-EFI-UUID` with the UUID from `/dev/nvme0n1p1`

## 6. Install NixOS

Clone or copy this configuration to `/mnt/etc/nixos` (or wherever your flake lives), then:

```bash
nixos-install --flake /path/to/flake#meridian
```

## Important Notes

- **Subvolume names must match exactly** — the config references `@root`, `@home`, `@nix`, and `@snapshots` by name in mount options.
- **Compression is applied at mount time** — `compress=zstd` tells btrfs to compress data on write. No special mkfs flag is needed.
- **The `/.snapshots` subvolume is required for snapper** — it stores timeline snapshots there. Snapper expects this to be a btrfs subvolume, not a regular directory.
- **No swap is configured** — `swapDevices` is empty in `hardware.nix`. Add a swap partition or swapfile separately if needed.
- **Non-critical mounts use `nofail`** — `/home`, `/nix`, and `/.snapshots` have `nofail` added by `modules/system/boot.nix`, so the system can still boot into a recovery state if those subvolumes fail to mount.
- **Kernel modules** — the hardware.nix file includes placeholder kernel modules (`nvme`, `xhci_pci`, `ahci`, etc.). After installation, run `nixos-generate-config --show-hardware-config` and update the `boot.initrd.availableKernelModules` list if your hardware differs.
