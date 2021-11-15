(define-module (postgresql-autodoc)
               #:use-module (guix utils)
               #:use-module ((guix licenses) #:prefix license:)
               #:use-module (guix packages)
               #:use-module (guix git-download)
               #:use-module (guix build-system gnu)
               #:use-module (gnu packages base)
               #:use-module (gnu packages perl)
               #:use-module (gnu packages web)
               #:use-module (gnu packages databases))

(define-public postgresql-autodoc
               (package
                 (name "postgresql-autodoc")
                 (version "80a6b150febb5c0c91f2daa433cc089ff1278841")
                 (source
                   (origin
                     (method git-fetch)
                     (uri (git-reference
                            (url "https://github.com/cbbrowne/autodoc")
                            (commit version)))
                     (file-name (git-file-name name version))
                     (sha256
                       (base32
                         "0ip1xy5qmm5hj392vxfs5fkgxgdv8d9kj7pp6p4x79npxczkxyzd"))))
                 (build-system gnu-build-system)
                 (arguments
                   '(#:phases
                     (modify-phases %standard-phases
                                    (delete 'configure)
                                    (delete 'check)
                                    (add-before 'install 'patch-prefix
                                                (lambda _
                                                  (substitute* (cons* "Makefile")
                                                               (("/usr/local") (assoc-ref %outputs "out")))
                                                  #t))
                                    (add-after 'install 'wrap-program
                                               (lambda* (#:key outputs #:allow-other-keys)
                                                        (let* ((out (assoc-ref outputs "out"))
                                                               (path (getenv "PERL5LIB")))
                                                          (wrap-program (string-append out "/bin/postgresql_autodoc")
                                                                        `("PERL5LIB" ":" prefix
                                                                          (,(string-append out "/lib/perl5/site_perl"
                                                                                           ":"
                                                                                           path)))))
                                                        #t))
                                    )))
                 (native-inputs
                   `(("which", which)))
                 (inputs
                   `(("perl" ,perl)
                     ("perl-html-template", perl-html-template)
                     ("perl-term-readkey", perl-term-readkey)
                     ("perl-dbd-pg", perl-dbd-pg)))
                 (home-page "https://github.com/cbbrowne/autodoc")
                 (synopsis "PostgreSQL Autodoc")
                 (description
                   "This is a utility which will run through PostgreSQL system tables and returns HTML, DOT, and several styles of XML which describe the database.")
                 (license license:bsd-3)))

