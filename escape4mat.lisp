;;;; escape4mat.lisp

(in-package #:escape4mat)

;; The main function
(defun escape (s)
  (loop for tr in '(("~" . "~~")
                    ("\\" . "\\\\\\")
                    ("\"" . "\\\""))
        do (setf s (cl-ppcre:regex-replace-all (car tr) s (cdr tr)))
        finally (return s)))

(defparameter *test-file* #p"/tmp/escape4mat-test.lisp")

;; TODO(mihai): handle generation interruption (ex: "body" returning
;;              nil means the generation should stop)
(defmacro generate-texts (n &rest body)
  (let* ((get-sym (let ((tbl (make-hash-table)))
                    (lambda (i)
                      (let ((sym (gethash i tbl)))
                        (if sym
                            sym
                            (setf (gethash i tbl) (gensym)))))))
         (rv `(let ((it (make-array ,n)))
                ,@(loop for idx below n collect
                        `(setf (aref it ,idx) ,(funcall get-sym idx)))
                ,@body)))
    (loop for idx below n do
      (let ((sym (funcall get-sym idx)))
        (setf rv (append `(loop for ,sym below 256 do)
                         (list rv)))))
    rv))

(defmacro generate-tests (n &rest body)
  `(progn
     ,@(loop for idx from 1 to n collect `(generate-texts ,idx ,@body))))

(defun test ()
  (generate-tests 20
                  (let* ((text (map 'string #'code-char it))
                         (escaped (escape text)))
                    (format t "~a~%" text)
                    (with-open-file (f *test-file*
                                       :direction :output
                                       :if-exists :supersede)
                      (format f "(format nil \"~a\")" escaped))
                    (unless (string= text (with-open-file (f *test-file*) (eval (read f))))
                      (error (format nil "escape4mat is not working for ~a" it)))
                    (sleep 0.01))))
