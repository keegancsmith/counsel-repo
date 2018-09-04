;;; counsel-repo.el --- Jump to repository using ivy -*- lexical-binding: t -*-

;; Copyright (C) 2018 Keegan Carruthers-Smith

;; Author: Keegan Carruthers-Smith <keegan.csmith@gmail.com>
;; URL: https://github.com/keegancsmith/counsel-repo
;; Version: 0.1.0
;; Package-Requires: ((emacs "25.1") (counsel "0.10.0"))
;; Keywords: ivy, counsel, vc

;;; Commentary:

;; Provides counsel-repo, which is an ivy-mode interface to quickly jumping to
;; a repository.  This tool depends on counsel-repo.  Install with:
;;
;;   go get github.com/keegancsmith/counsel-repo

;;; Code:

(require 'seq)
(require 'counsel)

(defgroup counsel-repo nil
  "Jump to repositories using ivy"
  :group 'ivy)

(defvar counsel-repo-srcpaths (or
                               (parse-colon-path (getenv "SRCPATHS"))
                               '("~/src"))
  "List of directory names to search.")

(defun counsel-repo-action-default (dir)
  "Open DIR in a buffer."
  (switch-to-buffer (find-file-noselect dir)))

(defvar counsel-repo-action #'counsel-repo-action-default
  "A function to call on selecting a repository path.
Default will open the directory in a buffer.  A common
alternative is to open the directory with ‘magit-status’.")

(defvar counsel-repo-history-input nil
  "Input history used by `ivy-read'.")

;;;###autoload
(defun counsel-repo (&optional initial)
  "Jump to a repository.

Will search for repositories under
‘counsel-repo-srcpaths’ (default $SRCPATHS or '~/src').  Depends
on https://github.com/keegancsmith/counsel-repo being installed
on your $PATH.

INITIAL will be used as the initial input, if given."
  (interactive)
  (counsel-require-program "counsel-repo")
  (ivy-set-prompt 'counsel-repo #'counsel-prompt-function-default)
  (let ((cands (split-string
                 (shell-command-to-string
                  (string-join (cons "counsel-repo" (mapcar #'shell-quote-argument (mapcar #'expand-file-name counsel-repo-srcpaths))) " "))
                 "\n"
                 t)))
    (ivy-read "Find repo" cands
              :initial-input initial
              :history 'counsel-repo-history-input
              :action (lambda (x)
                        (funcall counsel-repo-action
                          (car
                           (seq-filter #'file-directory-p
                                       (mapcar
                                        (lambda (srcdir)
                                          (expand-file-name (concat srcdir "/" x)))
                                        counsel-repo-srcpaths)))))
              :caller 'counsel-repo)))

(provide 'counsel-repo)

;;; counsel-repo.el ends here
