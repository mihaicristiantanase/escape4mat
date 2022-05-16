;;;; escape4mat.asd

(asdf:defsystem #:escape4mat
  :description "Escape strings so that (string= text (format (escape4mat:escape text)))"
  :author "Mihai Cristian Tănase"
  :license  "MIT"
  :version "1.0.0"
  :serial t
  :depends-on (#:cl-ppcre)
  :components ((:file "package")
               (:file "escape4mat")))
