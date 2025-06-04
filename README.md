# My dotfiles

## Content

This repo contains a collection of dotfiles and other related files that pose
the core of my system setup.

## Purpose

The main purpose of this repo is portability and backup of my own
configuration.

The repository can be cloned locally, relevant configuration files can be
replaced with symlinks to the dotfiles file.

If this setup should be helpful to anybody else, please feel
free to copy, suggest, do whatever you like with it.

## Container images

The Repository and related ghcr.io namespace contains container images that are
used by services defined in this repository.
See [here](container-images).

## Orchestration: tuning

The dotfiles configuration is set up with `tuning`.

Assuming that rust is set up, `cargo` being available, and the dotfiles
respository is cloned (recursively) to `~/.dotfiles`

```shell
cargo install tuning
tuning
```

## llama - local coding assistant

The vim setup uses neoai and a local llama-cpp server.
The server is started automatically, using systemd and podman.

The current setup uses iGPU accelerated inference on an _AMD Ryzen 7 PRO 7840U
w/ Radeon 780M Graphics_, but pure CPU inference is also possible.

## grub

```text
# Solarized dark, old-school network interface names
GRUB_CMDLINE_LINUX_DEFAULT="quiet vt.default_red=0x07,0xdc,0x85,0xb5,0x26,0xd3,0x2a,0xee,0x00,0xcb,0x58,0x65,0x83,0x6c,0x93,0xfd vt.default_grn=0x36,0x32,0x99,0x89,0x8b,0x36,0xa1,0xe8,0x2b,0x4b,0x6e,0x7b,0x94,0x71,0xa1,0xf6 vt.default_blu=0x42,0x2f,0x00,0x00,0xd2,0x82,0x98,0xd5,0x36,0x16,0x75,0x83,0x96,0xc4,0xa1,0xe3 mitigations=auto net.ifnames=0 biosdevname=0 acpi_backlight=vendor"
```

## Solarized Dark

I try to have solarized dark as universal color scheme.
Here's a reminder of the color configuration for copy pasting :)

| SOLARIZED | HEX     | 16/8 | TERMCOL   | XTERM | HEX     | `L*A*B`      | RGB           | HSB          | GNU screen |
|-----------|---------|------|-----------|-------|---------|--------------|---------------|--------------|------------|
| base03    | #002b36 | 8/4  | brblack   | 234   | #1c1c1c | `15,-12,-12` | `0,43,54`     | `193,100,21` | K          |
| base02    | #073642 | 0/4  | black     | 235   | #262626 | `20,-12,-12` | `7,54,66`     | `192,90,26`  | k          |
| base01    | #586e75 | 10/7 | brgreen   | 240   | #585858 | `45,-07,-07` | `88,110,117`  | `194,25,46`  | G          |
| base00    | #657b83 | 11/7 | bryellow  | 241   | #626262 | `50,-07,-07` | `101,123,131` | `195,23,51`  | Y          |
| base0     | #839496 | 12/6 | brblue    | 244   | #808080 | `60,-06,-03` | `131,148,150` | `186,13,59`  | B          |
| base1     | #93a1a1 | 14/4 | brcyan    | 245   | #8a8a8a | `65,-05,-02` | `147,161,161` | `180,9,63`   | C          |
| base2     | #eee8d5 | 7/7  | white     | 254   | #e4e4e4 | `92,-00,10`  | `238,232,213` | `44,11,93`   | w          |
| base3     | #fdf6e3 | 15/7 | brwhite   | 230   | #ffffd7 | `97,00,10`   | `253,246,227` | `44,10,99`   | W          |
| yellow    | #b58900 | 3/3  | yellow    | 136   | #af8700 | `60,10,65`   | `181,137,0`   | `45,100,71`  | y          |
| orange    | #cb4b16 | 9/3  | brred     | 166   | #d75f00 | `50,50,55`   | `203,75,22`   | `18,89,80`   | R          |
| red       | #d30102 | 1/1  | red       | 124   | #af0000 | `45,70,60`   | `211,1,2`     | `0,99,83`    | r          |
| magenta   | #d33682 | 5/5  | magenta   | 125   | #af005f | `50,65,-05`  | `211,54,130`  | `331,74,83`  | m          |
| violet    | #6c71c4 | 13/5 | brmagenta | 61    | #5f5faf | `50,15,-45`  | `108,113,196` | `237,45,77`  | M          |
| blue      | #268bd2 | 4/4  | blue      | 33    | #0087ff | `55,-10,-45` | `38,139,210`  | `205,82,82`  | b          |
| cyan      | #2aa198 | 6/6  | cyan      | 37    | #00afaf | `60,-35,-05` | `42,161,152`  | `175,74,63`  | c          |
| green     | #859900 | 2/2  | green     | 64    | #5f8700 | `60,-20,65`  | `133,153,0`   | `68,100,60`  | g          |
