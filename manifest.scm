(use-modules (guix packages)
             (guix git-download)
             (guix build-system ruby)
             (gnu packages ruby)
             ((guix licenses)
              #:prefix license:))

(define-public ruby-hanna
  (package
    (name "ruby-hanna")
    (version "1.5.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jeremyevans/hanna")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0wnk13ahvrqc0viw5sx4fka6apksh7b87wlmv6ja4wj4j3dyjrhf"))))
    (build-system ruby-build-system)
    (native-inputs (list ruby-minitest-hooks ruby-minitest-global-expectations))
    (propagated-inputs (list ruby-rdoc))
    (synopsis
     "Simple, beautiful, and easy to browse RDoc generator")
    (description
     "Hanna is a RDoc generator designed with simplicity, beauty and ease of
browsing in mind.  This generator can also be configured to integrate
with RubyGems and Rake tasks.")
    (home-page "https://github.com/jeremyevans/hanna")
    (license license:expat)))

(concatenate-manifests (list (packages->manifest (list ruby-hanna))
                             (specifications->manifest (list "ruby@3.1"
                                                             "ruby-rubocop"))))
