;;; unset "set fill-column
(global-unset-key "\C-xf")

;;;remap it to find-file
(global-set-key "\C-xf" 'find-file)

(setq magit-repository-directories '(("~/Projects" . 1) ("~/Projects/External" . 1))
      org-default-notes-file "~/Documents/org/inbox.org"
      org-directory "~/Documents/org"
      exec-path-from-shell-arguments '("-i"))

(provide 'init-local)
