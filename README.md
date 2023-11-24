# Content

This repo contains a collection of dotfiles and other related files that pose
the core of my system setup.

# Purpose

The main purpose of this repo is portability and backup of my own
configuration.

The repository can be cloned locally, relevant configuration files can be replaced with symlinks to the dotfiles file.

If this setup should be helpful to anybody else, please feel
free to copy, suggest, do whatever you like with it.

# Orchestration: tuning

The dotfiles configuration is set up with `tuning`.

Assuming that rust is set up, `cargo` being available, and the dotfiles
respository is cloned (recursively) to `~/.dotfiles`

```
$ cargo install tuning
$ tuning
```

## llama - local coding assistant

The vim setup uses neoai and a local llama-cpp server.
The server is started automatically, using systemd and podman.

It expects the [13B codellama instruct
model](https://huggingface.co/TheBloke/CodeLlama-13B-Instruct-GGUF) at
`~/.cache/llama/models/codellama-13B-instruct.gguf`

## Git credential store

```
sudo apt-get install libsecret-1-dev
cp -r /usr/share/doc/git/contrib/credential/libsecret ./
cd libsecret
make
sudo cp git-credential-libsecret /usr/local/bin
```

## grub

```
# Solarized dark, old-school network interface names
GRUB_CMDLINE_LINUX_DEFAULT="quiet vt.default_red=0x07,0xdc,0x85,0xb5,0x26,0xd3,0x2a,0xee,0x00,0xcb,0x58,0x65,0x83,0x6c,0x93,0xfd vt.default_grn=0x36,0x32,0x99,0x89,0x8b,0x36,0xa1,0xe8,0x2b,0x4b,0x6e,0x7b,0x94,0x71,0xa1,0xf6 vt.default_blu=0x42,0x2f,0x00,0x00,0xd2,0x82,0x98,0xd5,0x36,0x16,0x75,0x83,0x96,0xc4,0xa1,0xe3 mitigations=auto net.ifnames=0 biosdevname=0 acpi_backlight=vendor"
```
