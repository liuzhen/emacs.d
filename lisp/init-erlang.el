;;; package --- summary

;;; commentary:

;; suit both traditional lib path and rebar3-ish path

;;; code:

(ignore-errors
  (require-package 'erlang))

(when (package-installed-p 'erlang)
  (require 'erlang-start))

(defun erlang-get-library-path (prefix)
  "Get the erlang library path according to the PREFIX."
  (ignore-errors (mapcar (lambda (x) (concat x "/ebin")) (directory-files prefix "" "."))))

(defun erlang-library-path ()
  "Get the erlang library path without argument."
  (or (erlang-get-library-path "../_build/default/lib/")
      (erlang-get-library-path "../../../_build/default/lib/")))

(defun erlang-after-load-hook ()
  "Define the erlang hook."
  (interactive)
  (setq flycheck-erlang-include-path (list "../include/" "../../include/" "../../"))
  (set (make-local-variable 'flycheck-erlang-library-path) (erlang-library-path))
  (setq erlang-root-dir "/usr/local/opt/erlang/lib/erlang")
  (setq exec-path (cons "/usr/local/bin" exec-path))
  (setq erlang-electric-commands '(erlang-electric-comma
                                   erlang-electric-gt
                                   erlang-electric-newline
                                   erlang-electric-semicolon))
  (require 'erlang-start)
  (global-set-key (kbd "M-i") 'imenu))

(add-hook 'erlang-mode-hook 'erlang-after-load-hook)

(provide 'init-erlang)
;;; init-erlang ends here
