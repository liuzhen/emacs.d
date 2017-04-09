;;; package --- summary

;;; commentary:

;; suit both traditional lib path and rebar3-ish path

;;; code:

(ignore-errors
  (require-package 'erlang))

(when (package-installed-p 'erlang)
  (require 'erlang-start))

(require 'cl)

(defun erlup-libs-of (prefix)
  "Get the erlang library path according to the PREFIX."
  (ignore-errors (mapcar (lambda (x) (concat x "/ebin"))
                         (directory-files prefix "" "."))))

(defun erlup-libs ()
  "Get the erlang library path without argument."
  (or (erlup-libs-of "../_build/default/lib/")
      (erlup-libs-of "../../../_build/default/lib/")))

(defun erlup-includes ()
  "Format the includes to a string."
  (mapcar (lambda (x) (concat "-I" x))
          (list "../include/"
                "../../include/"
                "../../")))

(defun erlup-code-paths (paths)
  "Format the PATHS to a string."
  (mapcar (lambda (x) (concat "-pa" x)) paths))

(defun erlup-beam (tmp-dir source)
  "Format the beam name with TMP-DIR and SOURCE."
  (concat tmp-dir
          (file-name-base source)
          ".beam"))

(defun erlup-erlc (tmp-dir)
  "Set up the main command with TMP-DIR."
  (list "erlc" "-o" tmp-dir))

(defun erlup-erlc-lager ()
  "Set up the lager related config."
  (append (list "+{parse_transform, lager_transform}")
          (list  "+{lager_truncation_size, 1024}")))

(defun erlup-erlc-wall (source)
  "Set up Wall for SOURCE."
  (list "-Wall" source))

(defun erlup-erlup (node cookie beam)
  "Format the command of erlup with NODE, COOKIE, BEAM."
  (list "erlup" "-n" node "-c" cookie beam))

(defun erlup-compile (source)
  "Compile SOURCE to temporary file directory."
  (let ((tmp-dir temporary-file-directory))
    (let* ((cmd-erlc (-flatten (list (erlup-erlc tmp-dir)
                                     (erlup-includes)
                                     (erlup-code-paths (erlup-libs))
                                     (erlup-erlc-lager)
                                     (erlup-erlc-wall source))))
           (cmd (combine-and-quote-strings cmd-erlc)))
      (message "Compiling %s..." source)
      (shell-command cmd))))

(defun erlup-up (node cookie source)
  "Erlup to the target NODE with COOKIE, SOURCE is in .erl."
  (let ((tmp-dir temporary-file-directory))
    (let* ((cmd-erlup (erlup-erlup node
                                   cookie
                                   (erlup-beam tmp-dir source)))
           (cmd (combine-and-quote-strings cmd-erlup)))
      (shell-command cmd))))

(defun erlup-buffer ()
  "Erlup the current buffer."
  (interactive)

  (erlup-compile (buffer-file-name))

  (cl-loop for erlup-node in erlup-nodes
           collect (erlup-up
                    erlup-node
                    (if (boundp 'erlup-cookie)
                        erlup-cookie
                      "erlang")
                    (buffer-file-name))))

(defun erlang-after-load-hook ()
  "Define the erlang hook."
  (interactive)

  (global-set-key (kbd "M-i") 'imenu)
  (global-set-key (kbd "C-c C-e") 'erlup-buffer)

  (require 'flycheck-rebar3)
  (flycheck-rebar3-setup)

  (require 'edts-start))



;;;
(add-hook 'erlang-mode-hook 'erlang-after-load-hook)

(provide 'init-erlang)
;;; init-erlang ends here
