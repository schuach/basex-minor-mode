;;; basex.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023 Stefan Schuh
;;
;; Author: Stefan Schuh <stefan.schuh@obvsg.at>
;; Maintainer: Stefan Schuh <stefan.schuh@obvsg.at>
;; Created: März 14, 2023
;; Modified: März 16, 2023
;; Version: 0.0.1
;; Keywords: processing languages xquery basex
;; Homepage: https://github.com/ss/basex
;; Package-Requires: ((emacs "28.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:
(require 'ob)

(defvar basex-xquery-preamble nil)
(defvar basex-db nil)
(defun basex-run-region (start end)
  "Runs the region as a basex-command.
If called non-interactively, start and end are used to determine the region."
  (interactive "r")
  (let ((cmd (concat "basex -i "
                     (or basex-db (read-string "Please enter a database name: " nil t (basex-get-db-names)))
                     " -q "
                     (shell-quote-argument (or basex-xquery-preamble ""))
                     "\ "
                     (shell-quote-argument (buffer-substring-no-properties start end)))))
    (if current-prefix-arg
        (async-shell-command-no-window cmd)
      (async-shell-command cmd))))

(defun basex-run-buffer ()
  "Run whole buffer as basex-command."
    (interactive)
  (basex-run-region (point-min) (point-max)))

(defun basex-run-src-block ()
  "Run org-src-block as basex-command."
  (interactive)
  (let ((head (org-babel-where-is-src-block-head)))
    (when head
      (save-excursion
        (goto-char head)
        (looking-at org-babel-src-block-regexp))
      (basex-run-region (match-beginning 5) (match-end 5)))))

(defun basex-run-line ()
  "Run current line as basex-command."
  (interactive)
  (basex-run-region (line-beginning-position) (line-end-position)))

(defun basex-get-db-names ()
  (interactive)
  (split-string (shell-command-to-string "basex 'db:list()'") "\n"))

(add-to-list 'auto-mode-alist '("\\.xq\\'" . xquery-mode))

(provide 'basex)
;;; basex.el ends here
