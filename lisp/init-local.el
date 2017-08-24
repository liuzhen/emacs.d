;;; unset "set fill-column
(global-unset-key "\C-xf")

;;;remap it to find-file
(global-set-key "\C-xf" 'find-file)

(provide 'init-local)
