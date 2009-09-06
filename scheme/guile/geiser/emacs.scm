;; emacs.scm -- procedures for emacs interaction

;; Copyright (C) 2009 Jose Antonio Ortega Ruiz

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Start date: Sun Feb 08, 2009 18:39

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

;; Re-exports of procedures used by Emacs.

;;; Code:

(define-module (geiser emacs)
  #:re-export (ge:eval
               ge:compile
               ge:macroexpand
               ge:compile-file
               ge:load-file
               ge:autodoc
               ge:completions
               ge:module-completions
               ge:symbol-location
               ge:generic-methods
               ge:symbol-documentation
               ge:module-exports
               ge:module-location
               ge:callers
               ge:callees
               ge:find-file)
  #:use-module (geiser evaluation)
  #:use-module ((geiser modules) :renamer (symbol-prefix-proc 'ge:))
  #:use-module ((geiser completion) :renamer (symbol-prefix-proc 'ge:))
  #:use-module ((geiser xref) :renamer (symbol-prefix-proc 'ge:))
  #:use-module ((geiser doc) :renamer (symbol-prefix-proc 'ge:)))


;;; emacs.scm ends here
