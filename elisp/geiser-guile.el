;; geiser-guile.el -- guile's implementation of the geiser protocols

;; Copyright (C) 2009 Jose Antonio Ortega Ruiz

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Start date: Sun Mar 08, 2009 23:03

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3 of the License, or
;; (at your option) any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Comentary:

;; Implementation of all required Elisp Geiser protocols for Guile.

;;; Code:

(require 'geiser-syntax)
(require 'geiser-custom)
(require 'geiser-base)
(require 'geiser-eval)
(require 'geiser-edit)
(require 'geiser)


;;; Customization:

(defgroup geiser-guile nil
  "Customization for Geiser's Guile flavour."
  :group 'geiser)

(defcustom geiser-guile-binary
  (cond ((eq system-type 'windows-nt) "guile.exe")
        ((eq system-type 'darwin) "guile")
        (t "guile"))
  "Name to use to call the Guile executable when starting a REPL."
  :type '(choice string (repeat string))
  :group 'geiser-guile)

(defcustom geiser-guile-load-path nil
  "A list of paths to be added to Guile's load path when it's
started."
  :type '(repeat file)
  :group 'geiser-guile)

(defcustom geiser-guile-init-file "~/.guile-geiser"
  "Initialization file with user code for the Guile REPL."
  :type 'string
  :group 'geiser-guile)

(defcustom geiser-guile-use-compiler-in-eval t
  "When enable, always use Guile's compiler to perform evaluation.
Recommended, since the compiler usually collects better metadata
than the interpreter."
  :type 'boolean
  :group 'geiser-guile)


;;; REPL support:

(defun geiser-guile-binary ()
  (if (listp geiser-guile-binary) (car geiser-guile-binary) geiser-guile-binary))

(defun geiser-guile-parameters ()
  "Return a list with all parameters needed to start Guile.
This function uses `geiser-guile-init-file' if it exists."
  (let ((init-file (and (stringp geiser-guile-init-file)
                        (expand-file-name geiser-guile-init-file))))
  `(,@(and (listp geiser-guile-binary) (cdr geiser-guile-binary))
    "-q" "-L" ,(expand-file-name "guile/" geiser-scheme-dir)
    ,@(apply 'append (mapcar (lambda (p) (list "-L" p)) geiser-guile-load-path))
    ,@(and init-file (file-readable-p init-file) (list "-l" init-file)))))

(defconst geiser-guile-prompt-regexp "^[^() \n]+@([^)]*?)> ")

(defun switch-to-guile (&optional ask)
  (interactive "P")
  (switch-to-geiser ask 'guile))

(defun run-guile ()
  "Run Geiser using Guile."
  (interactive)
  (run-geiser 'guile))


;;; Evaluation support:

(defun geiser-guile-geiser-procedure (proc)
  (let ((proc (intern (format "ge:%s"
                              (if (and geiser-guile-use-compiler-in-eval
                                       (eq proc 'eval))
                                  'compile
                                proc)))))
    `(@ (geiser emacs) ,proc)))

(defconst geiser-guile--module-re
  "(define-module +\\(([^)]+)\\)")

(defun geiser-guile-get-module (&optional module)
  (cond ((null module)
         (save-excursion
           (goto-char (point-min))
           (if (re-search-forward geiser-guile--module-re nil t)
               (geiser-guile-get-module (match-string-no-properties 1))
             :f)))
        ((listp module) module)
        ((stringp module)
         (or (ignore-errors (car (read-from-string module))) :f))
        (t :f)))

(defun geiser-guile-symbol-begin (module)
  (if module
      (max (save-excursion (beginning-of-line) (point))
           (save-excursion (skip-syntax-backward "^(>") (1- (point))))
    (save-excursion (skip-syntax-backward "^-()>") (point))))


;;; Error display
(defvar geiser-guile--file-cache (make-hash-table :test 'equal))

(defun geiser-guile--resolve-file (file)
  (when (and (stringp file) (not (string-equal file "unknown file")))
    (if (file-name-absolute-p file) file
      (or (gethash file geiser-guile--file-cache)
          (puthash file
                   (geiser-eval--send/result `(:eval ((:ge find-file) ,file)))
                   geiser-guile--file-cache)))))

(defconst geiser-guile--file-rx
  "^In \\([^\n:]+\\):\n *\\([[:digit:]]+\\|\\?\\):")

(defun geiser-guile--find-files ()
  (save-excursion
    (while (re-search-forward geiser-guile--file-rx nil t)
      (let ((file (match-string 1))
            (beg (match-beginning 1))
            (end (match-end 1))
            (line (string-to-number (or (match-string 2) "0"))))
        (let ((file (geiser-guile--resolve-file file)))
          (when file
            (geiser-edit--make-link beg end file line 0)))))))

(defun geiser-guile-display-error (module key msg)
  (when key
    (insert "Error: ")
    (geiser--insert-with-face (format "%s" key) 'bold)
    (newline 2))
  (when msg
    (let ((p (point)))
      (insert msg)
      (goto-char p)
      (geiser-guile--find-files)))
  t)


;;; Trying to ascertain whether a buffer is Guile Scheme:

(defun geiser-guile-guess ()
  "Return `t' if the current buffer looks like a Guile file."
  (listp (geiser-guile-get-module)))


(provide 'geiser-guile)
;;; geiser-guile.el ends here
