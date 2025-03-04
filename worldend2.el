;;; worldend2.el --- Interface for WorldEnd2 Formatting  -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Nyx102

;; Author: Nyx102 <rehpotsirhc102@gmail.com>
;; Keywords: convenience, processes, tex

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This tool helps with the creation of PDFs and EPUBs for "WorldEnd2:
;; What Do You Do at the End of the World?  Could We Meet Again Once
;; More?" (or WorldEnd2 / Suka Moka for short) by providing a simple
;; interactive user interface for generating and viewing volumes.
;; You can find the volume text and Python tools responsible for the
;; backend functionality in the git repository:
;; <https://github.com/WorldEnd/worldend-formatting>.

;;; Code:



(provide 'worldend2)
(require 'virtualenvwrapper)
(require 'transient)

;; VARIABLES
(defvar worldend2-git-repo (expand-file-name "~/worldend-formatting")
  "Path to the git repository.")

(defvar worldend2-venv-name "worldend-formatting"
  "Name of the virtual environment.")

(defvar worldend2-default-pdf-view-method 'emacs
  "Default method for viewing the generated PDF.")

(defvar worldend2-default-epub-view-method 'emacs
  "Default method for viewing the generated EPUB.")

(defvar worldend2-pdf-generation-extra-args ""
  "Extra arguments for PDF generation.")

(defvar worldend2-epub-generation-extra-args ""
  "Extra arguments for EPUB generation.")

;; MAIN FUNCTIONS

;; PDF & EPUB Generation
(defun worldend2-generate-pdf (&optional vol-number extra-args)
  "Generate the PDF for the specified volume number with optional extra
arguments.  If called with the universal argument (C-u), it prompts for both
volume number and extra arguments."
  (interactive)
  (if (called-interactively-p 'interactive)
      (if (equal current-prefix-arg '(4))
          (progn
            (setq vol-number (read-number "Enter volume number: "))
            (setq extra-args (read-string "Enter extra arguments: ")))
        (setq vol-number (read-number "Enter volume number: "))))
  (if (or (not vol-number) (= vol-number 0))
      (message "You need to specify the volume number")
    (let* ((script-path (format "%s/Scripts/output_tex.py" worldend2-git-repo))
           (input-path (format "%s/Volumes/Volume_%02d/" worldend2-git-repo vol-number))
           (output-path (format "%s/Output_v%02d" worldend2-git-repo vol-number))
           (command (format "python \"%s\" \"%s\" \"%s\" %s"
                            script-path input-path output-path
                            (if extra-args extra-args worldend2-pdf-generation-extra-args))))
      (venv-workon worldend2-venv-name)
      (async-shell-command
       command
       "*WorldEnd2-PDF-compile-log*"
       "*WorldEnd2-PDF-compile-errors*")
      (venv-deactivate))))

(defun worldend2-generate-epub (&optional vol-number extra-args)
  "Generate the PDF for the specified volume number with optional extra
arguments.  If called with the universal argument (C-u), it prompts for both
volume number and extra arguments."
  (interactive)
  (if (called-interactively-p 'interactive)
      (if (equal current-prefix-arg '(4))
          (progn
            (setq vol-number (read-number "Enter volume number: "))
            (setq extra-args (read-string "Enter extra arguments: ")))
        (setq vol-number (read-number "Enter volume number: "))))
  (if (or (not vol-number) (= vol-number 0))
      (message "You need to specify the volume number")
    (let* ((script-path (format "%s/Scripts/output_epub.py" worldend2-git-repo))
           (input-path (format "%s/Volumes/Volume_%02d/" worldend2-git-repo vol-number))
           (output-path (format "%s/Output_v%02d" worldend2-git-repo vol-number))
           (command (format "python \"%s\" \"%s\" \"%s\" %s"
                            script-path input-path output-path
                            (if extra-args extra-args worldend2-epub-generation-extra-args))))
      (venv-workon worldend2-venv-name)
      (async-shell-command
       command
       "*WorldEnd2-EPUB-compile-log*"
       "*WorldEnd2-EPUB-compile-errors*")
      (venv-deactivate))))

;; Open the directory containing the git repository
(defun worldend2-goto-directory ()
  "Go to the directory of the WorldEnd2 git repository."
  (interactive)
  (dired worldend2-git-repo))

;; Python Virtual Environment
(defun worldend2-activate-venv ()
  "Activate the Python virtual environment for the WorldEnd2 git repository."
  (interactive)
  (venv-workon worldend2-venv-name))

(defun worldend2-deactivate-venv ()
  "Deactivate the Python virtual environment for the WorldEnd2 git repository."
  (interactive)
  (venv-deactivate))

;; PDF & EPUB Viewing
(defun worldend2-view-pdf (&optional vol-number program)
  "View the PDF for the specified volume number with optional PDF viewer.  If
called with the universal argument (C-u), it prompts for both volume number and
the PDF viewer."
  (interactive)
  (if (called-interactively-p 'interactive)
      (if (equal current-prefix-arg '(4))
          (progn
            (setq vol-number (read-number "Enter volume number: "))
            (setq program (read-string "Enter program: ")))
        (setq vol-number (read-number "Enter volume number: "))))
  (if (or (not vol-number) (= vol-number 0))
      (message "You need to specify the volume number")
    (let* ((file-path
            (format "%1$s/Output_v%2$02d/WorldEnd2_v%2$02d.pdf"
                    worldend2-git-repo
                    vol-number)))
      (if program
          (if (equal program 'emacs)
              (find-file file-path)
            (async-shell-command (format "%s \"%s\"" program file-path)))
        (if (equal worldend2-default-pdf-view-method 'emacs)
            (find-file file-path)
          (async-shell-command (format "%s \"%s\"" worldend2-default-pdf-view-method file-path)))))))

(defun worldend2-view-epub (&optional vol-number program)
  "View the EPUB for the specified volume number with optional EPUB viewer.  If
called with the universal argument (C-u), it prompts for both volume number and
the EPUB viewer."
  (interactive)
  (if (called-interactively-p 'interactive)
      (if (equal current-prefix-arg '(4))
          (progn
            (setq vol-number (read-number "Enter volume number: "))
            (setq program (read-string "Enter program: ")))
        (setq vol-number (read-number "Enter volume number: "))))
  (if (or (not vol-number) (= vol-number 0))
      (message "You need to specify the volume number")
    (let* ((file-path
            (format "%1$s/Output_v%2$02d/WorldEnd2_v%2$02d.epub"
                    worldend2-git-repo
                    vol-number)))
      (if program
          (if (equal program 'emacs)
              (find-file file-path)
            (async-shell-command (format "%s \"%s\"" program file-path)))
        (if (equal worldend2-default-epub-view-method 'emacs)
            (find-file file-path)
          (async-shell-command (format "%s \"%s\"" worldend2-default-epub-view-method file-path)))))))

;; TRANSIENT KEYBINDINGS

;; Helper Functions
(defun worldend2--with-volume-number (worldend2-function &optional args)
  "Helper function that prompts for volume number and passes any arguments to
the specified function."
  (interactive)
  (let ((vol-number (read-number "Enter volume number: ")))
    (if (= vol-number 0)
        (message "You need to specify the volume number")
      (funcall worldend2-function vol-number args))))

;; Main Menu
(transient-define-prefix worldend2-transient-menu ()
  "WorldEnd2 Formatting main menu."
  ["General Actions"
   ("w" "Go to Directory" worldend2-goto-directory)
   ("y" "Python Virtual Environment" worldend2--python-venv)]
  ["Content Creation"
   ;; ("p" "PDF" worldend2--generate-pdf)
   ;; ("e" "EPUB" worldend2--generate-pdf)
   ("g" "Generate PDF or EPUB" worldend2--generate)
   ("v" "View PDF or EPUB" worldend2--view)])

;; Python Virtual Environment
(transient-define-prefix worldend2--python-venv ()
  "WorldEnd2 Formatting submenu for controlling the Python virtual environment."
  ["Python Virtual Environment"
   ("a" "Activate Python venv" worldend2-activate-venv)
   ("d" "Deactivate Python venv" worldend2-deactivate-venv)])

;; PDF & EPUB Generation
(transient-define-prefix worldend2--generate ()
  "WorldEnd2 Formatting submenu for selecting PDF or EPUB generation."
  ["Generate PDF or EPUB"
   ("p" "PDF" worldend2--generate-pdf)
   ("e" "EPUB" worldend2--generate-epub)])

(transient-define-prefix worldend2--generate-pdf ()
  "WorldEnd2 Formatting submenu for generating PDF."
  ["Options"
   ("-b" "bleed size" "--bleed-size="
    :prompt "Enter bleed size: ")
   ("-g" "gutter size" "--gutter-size="
    :prompt "Enter gutter size: ")
   ("-v" "verbose" "--verbose")
   ("-x" "xelatex command" "--xelatex-command-line="
    :prompt "Enter xelatex command: ")
   ("-p" "print mode" "--print-mode")
   ("-F" "no front cover" "--no-front-cover")
   ("-B" "no back cover" "--no-back-cover")
   ("-G" "skip image generation" "--skip-image-generation")
   ("-I" "no images" "--no-images")]
  ["Help"
   ("h" "Print help" (lambda () (interactive) (worldend2-generate-pdf -1 "-h")))]
  [:class transient-columns
          ["Create"
           ("p" "Generate PDF" (lambda () (interactive)
                                 (worldend2--with-volume-number
                                  #'worldend2-generate-pdf
                                  (mapconcat
                                   'identity
                                   (transient-args transient-current-command) " "))))]
          ["Quick Generation Actions"
           ("v" "Verbose" (lambda () (interactive)
                            (worldend2--with-volume-number #'worldend2-generate-pdf "-v")))
           ("q" "Quick" (lambda () (interactive)
                          (worldend2--with-volume-number #'worldend2-generate-pdf "-G -I")))
           ("r" "Print" (lambda () (interactive)
                          (worldend2--with-volume-number #'worldend2-generate-pdf "-p")))
           ("d" "Debug" (lambda () (interactive)
                          (worldend2--with-volume-number #'worldend2-generate-pdf "-v -G -I")))]])

(transient-define-prefix worldend2--generate-epub ()
  "WorldEnd2 Formatting submenu for generating EPUB."
  ["Options"
   ("-v" "verbose" "--verbose")]
  ["Help"
   ("h" "Print help" (lambda () (interactive) (worldend2-generate-epub -1 "-h")))]
  [:class transient-columns
          ["Create"
           ("e" "Generate EPUB" (lambda () (interactive)
                                  (worldend2--with-volume-number
                                   #'worldend2-generate-epub
                                   (mapconcat
                                    'identity
                                    (transient-args transient-current-command) " "))))]
          ["Quick Generation Actions"
           ("v" "Verbose" (lambda () (interactive)
                            (worldend2--with-volume-number #'worldend2-generate-epub "-v")))]])

;; PDF & EPUB Viewing
(transient-define-prefix worldend2--view ()
  "WorldEnd2 Formatting submenu for selecting PDF or EPUB viewing."
  ["View PDF or EPUB"
   ("p" "PDF" worldend2--view-pdf)
   ("e" "EPUB" worldend2--view-epub)])

(transient-define-prefix worldend2--view-pdf ()
  "WorldEnd2 Formatting submenu for viewing PDF."
  ["Options"
   ("-p" "program" "--program=" :class transient-option :prompt "Enter program: ")]
  [:class transient-columns
          ["View"
           ("p" "View PDF" (lambda () (interactive)
                             (worldend2--with-volume-number
                              #'worldend2-view-pdf
                              (transient-arg-value
                               "--program="
                               (transient-args transient-current-command)))))]
          ["Quick View Options"
           ("m" "Emacs" (lambda () (interactive)
                          (worldend2--with-volume-number #'worldend2-view-pdf 'emacs)))
           ("z" "Zathura" (lambda () (interactive)
                            (worldend2--with-volume-number #'worldend2-view-pdf "zathura")))]])

(transient-define-prefix worldend2--view-epub ()
  "WorldEnd2 Formatting submenu for viewing EPUB."
  ["Options"
   ("-p" "program" "--program=" :class transient-option :prompt "Enter program: ")]
  [:class transient-columns
          ["View"
           ("e" "View EPUB" (lambda () (interactive)
                              (worldend2--with-volume-number
                               #'worldend2-view-epub
                               (transient-arg-value
                                "--program="
                                (transient-args transient-current-command)))))]
          ["Quick View Options"
           ("m" "Emacs" (lambda () (interactive)
                          (worldend2--with-volume-number #'worldend2-view-epub 'emacs)))
           ("c" "Calibre" (lambda () (interactive)
                            (worldend2--with-volume-number #'worldend2-view-epub "ebook-viewer")))]])
;;; worldend2.el ends here
