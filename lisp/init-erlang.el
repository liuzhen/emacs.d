;;; package --- summary

;;; commentary:

;; suit both traditional lib path and rebar3-ish path

;;; code:

(ignore-errors
  (require-package 'erlang))

(when (package-installed-p 'erlang)
  (require 'erlang-start))

(require 'cl)

(defun erlang-get-library-path (prefix)
  "Get the erlang library path according to the PREFIX."
  (ignore-errors (mapcar (lambda (x) (concat x "/ebin")) (directory-files prefix "" "."))))

(defun erlang-library-path ()
  "Get the erlang library path without argument."
  (or (erlang-get-library-path "../_build/default/lib/")
      (erlang-get-library-path "../../../_build/default/lib/")))

(defun erlup-libs (libs)
  "Format the LIBS to a string."
  (mapcar (lambda (x) (concat "-I" x)) libs))

(defun erlup-paths (paths)
  "Format the PATHS to a string."
  (mapcar (lambda (x) (concat "-pa" x)) paths))

(defun erlup-file (node cookie source)
  "Erlup to the target NODE with COOKIE, SOURCE is in .erl."
  (let* ((tmp-dir temporary-file-directory)
         (command-erlc0 (list "erlc" "-o" tmp-dir))
         (command-erlc1 (append command-erlc0 (erlup-libs flycheck-erlang-include-path)))
         (command-erlc2 (append command-erlc1 (erlup-paths (erlang-library-path))))
         (command-erlc (append command-erlc2 (list "-Wall" source)))
         (beam-name (concat tmp-dir (file-name-base source) ".beam"))
         (command-erlup(list "erlup"
                             "-n" node
                             "-c" cookie
                             beam-name)))
    (shell-command (combine-and-quote-strings command-erlc))
    (shell-command (combine-and-quote-strings command-erlup))
    ))

(defun erlup-buffer ()
  "Erlup the current buffer."
  (interactive)
  (cl-loop for erlup-node in erlup-nodes
           collect (erlup-file
                    erlup-node
                    (if (boundp 'erlup-cookie)
                        erlup-cookie
                      "erlang")
                    (buffer-file-name))))

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
  (global-set-key (kbd "M-i") 'imenu)
  (global-set-key (kbd "C-c e") 'erlup-buffer))

(add-hook 'erlang-mode-hook 'erlang-after-load-hook)

(provide 'init-erlang)
;;; init-erlang ends here
