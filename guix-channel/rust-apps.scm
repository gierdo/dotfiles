(define-module (rust-apps)
  #:use-module (guix build-system cargo)
  #:use-module (guix utils)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages crates-io)
  #:use-module (gnu packages crates-graphics))

(define-public rust-wayland-server-0.27
  (package
    (name "rust-wayland-server")
    (version "0.27.0")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "wayland-server" version))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256
          (base32 "0sl3jgd7jx76f75ias5b30cd4644n3ibnvi797ql6mi94z03rk6v"))))
    (build-system cargo-build-system)
    (arguments
      `(#:skip-build?
        #t
        #:cargo-inputs
        (("rust-bitflags" ,rust-bitflags-1)
         ("rust-downcast-rs" ,rust-downcast-rs-1)
         ("rust-lazy-static" ,rust-lazy-static-1)
         ("rust-libc" ,rust-libc-0.2)
         ("rust-nix" ,rust-nix-0.17)
         ("rust-parking-lot" ,rust-parking-lot-0.10)
         ("rust-scoped-tls" ,rust-scoped-tls-1)
         ("rust-wayland-commons" ,rust-wayland-commons-0.27)
         ("rust-wayland-scanner" ,rust-wayland-scanner-0.27)
         ("rust-wayland-sys" ,rust-wayland-sys-0.27))))
    (home-page "https://github.com/smithay/wayland-rs")
    (synopsis
      "Bindings to the standard C implementation of the wayland protocol, server side.")
    (description
      "Bindings to the standard C implementation of the wayland protocol, server side.")
    (license license:expat)))

(define-public rust-wayland-protocols-0.27
  (package
    (name "rust-wayland-protocols")
    (version "0.27.0")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "wayland-protocols" version))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256
          (base32 "07bqz2y4him0qgj60wv4055wnxbd1siy66n27c4bb63vn5agrmpk"))))
    (build-system cargo-build-system)
    (arguments
      `(#:skip-build?
        #t
        #:cargo-inputs
        (("rust-bitflags" ,rust-bitflags-1)
         ("rust-wayland-client" ,rust-wayland-client-0.27)
         ("rust-wayland-commons" ,rust-wayland-commons-0.27)
         ("rust-wayland-scanner" ,rust-wayland-scanner-0.27)
         ("rust-wayland-server" ,rust-wayland-server-0.27))))
    (home-page "https://github.com/smithay/wayland-rs")
    (synopsis "Generated API for the officials wayland protocol extensions")
    (description "Generated API for the officials wayland protocol extensions")
    (license license:expat)))

(define-public rust-wayland-cursor-0.27
  (package
    (name "rust-wayland-cursor")
    (version "0.27.0")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "wayland-cursor" version))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256
          (base32 "0h8dnvsv4pb6gp10bdp6ng4v2bqy02b13gncr0w6yw1z39p397sk"))))
    (build-system cargo-build-system)
    (arguments
      `(#:skip-build?
        #t
        #:cargo-inputs
        (("rust-nix" ,rust-nix-0.17)
         ("rust-wayland-client" ,rust-wayland-client-0.27)
         ("rust-xcursor" ,rust-xcursor-0.3))))
    (home-page "https://github.com/smithay/wayland-rs")
    (synopsis "Bindings to libwayland-cursor.")
    (description "Bindings to libwayland-cursor.")
    (license license:expat)))

(define-public rust-wayland-scanner-0.27
  (package
    (name "rust-wayland-scanner")
    (version "0.27.0")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "wayland-scanner" version))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256
          (base32 "0a03qcx98v29fp6xk0n41wdvw2c1x97pcwml1d0djawkkl05c3q3"))))
    (build-system cargo-build-system)
    (arguments
      `(#:skip-build?
        #t
        #:cargo-inputs
        (("rust-proc-macro2" ,rust-proc-macro2-1)
         ("rust-quote" ,rust-quote-1)
         ("rust-xml-rs" ,rust-xml-rs-0.8))))
    (home-page "https://github.com/smithay/wayland-rs")
    (synopsis
      "Wayland Scanner for generating rust APIs from XML wayland protocol files. Intended for use with wayland-sys. You should only need this crate if you are working on custom wayland protocol extensions. Look at the crate wayland-client for usable bindings.")
    (description
      "Wayland Scanner for generating rust APIs from XML wayland protocol files.  Intended for use with wayland-sys.  You should only need this crate if you are working on custom wayland protocol extensions.  Look at the crate wayland-client for usable bindings.")
    (license license:expat)))

(define-public rust-wayland-sys-0.27
  (package
    (name "rust-wayland-sys")
    (version "0.27.0")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "wayland-sys" version))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256
          (base32 "0sf2xl3lvf8ibln07av43is8zzp5g5saqifb5bx7sivlnjxzzplb"))))
    (build-system cargo-build-system)
    (arguments
      `(#:skip-build?
        #t
        #:cargo-inputs
        (("rust-dlib" ,rust-dlib-0.4)
         ("rust-lazy-static" ,rust-lazy-static-1)
         ("rust-libc" ,rust-libc-0.2)
         ("rust-pkg-config" ,rust-pkg-config-0.3))))
    (home-page "https://github.com/smithay/wayland-rs")
    (synopsis
      "FFI bindings to the various libwayland-*.so libraries. You should only need this crate if you are working on custom wayland protocol extensions. Look at the crate wayland-client for usable bindings.")
    (description
      "FFI bindings to the various libwayland-*.so libraries.  You should only need this crate if you are working on custom wayland protocol extensions.  Look at the crate wayland-client for usable bindings.")
    (license license:expat)))

(define-public rust-wayland-commons-0.27
  (package
    (name "rust-wayland-commons")
    (version "0.27.0")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "wayland-commons" version))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256
          (base32 "1wcm3f2jyq8kk71nagc0nk3fblvimlszy8af3f3dvafmd8ryjwp9"))))
    (build-system cargo-build-system)
    (arguments
      `(#:skip-build?
        #t
        #:cargo-inputs
        (("rust-nix" ,rust-nix-0.17)
         ("rust-once-cell" ,rust-once-cell-1)
         ("rust-smallvec" ,rust-smallvec-1)
         ("rust-wayland-sys" ,rust-wayland-sys-0.27))))
    (home-page "https://github.com/smithay/wayland-rs")
    (synopsis
      "Common types and structures used by wayland-client and wayland-server.")
    (description
      "Common types and structures used by wayland-client and wayland-server.")
    (license license:expat)))

(define-public rust-wayland-client-0.27
  (package
    (name "rust-wayland-client")
    (version "0.27.0")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "wayland-client" version))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256
          (base32 "1r4a0v8k16hw64aw1fqa56a2m95mlf4klvl1nmzzdmnnpkpjyw5b"))))
    (build-system cargo-build-system)
    (arguments
      `(#:skip-build?
        #t
        #:cargo-inputs
        (("rust-bitflags" ,rust-bitflags-1)
         ("rust-downcast-rs" ,rust-downcast-rs-1)
         ("rust-libc" ,rust-libc-0.2)
         ("rust-nix" ,rust-nix-0.17)
         ("rust-scoped-tls" ,rust-scoped-tls-1)
         ("rust-wayland-commons" ,rust-wayland-commons-0.27)
         ("rust-wayland-scanner" ,rust-wayland-scanner-0.27)
         ("rust-wayland-sys" ,rust-wayland-sys-0.27))))
    (home-page "https://github.com/smithay/wayland-rs")
    (synopsis
      "Bindings to the standard C implementation of the wayland protocol, client side.")
    (description
      "Bindings to the standard C implementation of the wayland protocol, client side.")
    (license license:expat)))

(define-public rust-smithay-client-toolkit-0.10
  (package
    (name "rust-smithay-client-toolkit")
    (version "0.10.0")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "smithay-client-toolkit" version))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256
          (base32 "17jjzadzs1mxvi35134fhc36r3d97rph57dmh23iprdl87ng1z5b"))))
    (build-system cargo-build-system)
    (arguments
      `(#:skip-build?
        #t
        #:cargo-inputs
        (("rust-andrew" ,rust-andrew-0.3)
         ("rust-bitflags" ,rust-bitflags-1)
         ("rust-byteorder" ,rust-byteorder-1)
         ("rust-calloop" ,rust-calloop-0.6)
         ("rust-dlib" ,rust-dlib-0.4)
         ("rust-lazy-static" ,rust-lazy-static-1)
         ("rust-log" ,rust-log-0.4)
         ("rust-memmap" ,rust-memmap-0.7)
         ("rust-nix" ,rust-nix-0.17)
         ("rust-wayland-client" ,rust-wayland-client-0.27)
         ("rust-wayland-cursor" ,rust-wayland-cursor-0.27)
         ("rust-wayland-protocols" ,rust-wayland-protocols-0.27))))
    (home-page "https://github.com/smithay/client-toolkit")
    (synopsis "Toolkit for making client wayland applications.")
    (description "Toolkit for making client wayland applications.")
    (license license:expat)))

(define-public rust-users-0.8
  (package
    (name "rust-users")
    (version "0.8.1")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "users" version))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256
          (base32 "1dss2l4x3zgjq26mwa97aa5xmsb5z2x3vhhhh3w3azan284pvvbz"))))
    (build-system cargo-build-system)
    (arguments
      `(#:skip-build? #t #:cargo-inputs (("rust-libc" ,rust-libc-0.2))))
    (home-page "https://github.com/ogham/rust-users")
    (synopsis "Library for accessing Unix users and groups")
    (description "Library for accessing Unix users and groups")
    (license license:expat)))

(define-public rust-pam-sys-0.5
  (package
    (name "rust-pam-sys")
    (version "0.5.6")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "pam-sys" version))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256
          (base32 "0d14501d5vybjnzxfjf96321xa5wa36x1xvf02h02zq938qmhj6d"))))
    (build-system cargo-build-system)
    (arguments
      `(#:skip-build? #t #:cargo-inputs (("rust-libc" ,rust-libc-0.2))))
    (home-page "https://github.com/1wilkens/pam-sys.git")
    (synopsis
      "FFI wrappers for the Linux Pluggable Authentication Modules (PAM)")
    (description
      "FFI wrappers for the Linux Pluggable Authentication Modules (PAM)")
    (license (list license:expat license:asl2.0))))

(define-public rust-pam-0.7
  (package
    (name "rust-pam")
    (version "0.7.0")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "pam" version))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256
          (base32 "15rhp57pdb54lcx37vymcimimpd1ma90lhm10iq08710kjaxqazs"))))
    (build-system cargo-build-system)
    (arguments
      `(#:skip-build?
        #t
        #:cargo-inputs
        (("rust-libc" ,rust-libc-0.2)
         ("rust-pam-sys" ,rust-pam-sys-0.5)
         ("rust-users" ,rust-users-0.8))))
    (home-page "https://github.com/1wilkens/pam/")
    (synopsis "Safe Rust wrappers for PAM authentification")
    (description "Safe Rust wrappers for PAM authentification")
    (license (list license:expat license:asl2.0))))

(define-public rust-waylock-0.3
  (package
    (name "rust-waylock")
    (version "0.3.3")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "waylock" version))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256
          (base32 "14bqjiq8f1a0ifs4v9v4drhjp5mhk0zx96xnfvg5zmc7ki10x20a"))))
    (build-system cargo-build-system)
    (arguments
      `(#:cargo-inputs
        (("rust-clap" ,rust-clap-2)
         ("rust-humantime" ,rust-humantime-2)
         ("rust-log" ,rust-log-0.4)
         ("rust-pam" ,rust-pam-0.7)
         ("rust-serde" ,rust-serde-1)
         ("rust-smithay-client-toolkit" ,rust-smithay-client-toolkit-0.10)
         ("rust-toml" ,rust-toml-0.5)
         ("rust-users" ,rust-users-0.10))))
    (home-page "https://github.com/ifreund/waylock")
    (synopsis "A simple screenlocker for wayland compositors.")
    (description
      "This package provides a simple screenlocker for wayland compositors.")
    (license license:expat)))
