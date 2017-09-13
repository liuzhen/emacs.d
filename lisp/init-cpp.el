(require 'rtags) ;; optional, must have rtags installed

                                        ; autocomplete headers
;(add-hook 'c++-mode-hook (lambda()
;                           (require 'auto-complete-c-headers)
;                           (setq ac-sources '(ac-source-clang ac-source-words-in-same-mode-buffers))
;                           (add-to-list 'ac-sources 'ac-source-c-headers)
;                           (setq achead:include-directories
;                                 (append achead:include-directories (c++-include-paths)))))

(defun gcc--include-paths-from-output (output)
  "Find the g++ include paths in OUTPUT.
The output lines contains the include paths between the following lines:
#include <...> search starts here:
...
End of search list"
  (let* ((lines (split-string output "\n"))
         ;; start-includes slices off everything before the section we're interested in
         (start-includes (cdr (member "#include <...> search starts here:" lines)))
         ;; The list of include paths is found by reversing the list, searching for the end,
         ;; leaving out (cdr) the string we search for, and reversing it back
         (includes (reverse (cdr (member "End of search list." (reverse start-includes))))))
                                        ; strip out whitespace
    (mapcar (lambda (x) (replace-regexp-in-string " " "" x)) includes)))


(defun c++-include-paths ()
  "Find the g++ include paths and return a list of strings."
  (gcc--include-paths-from-output (shell-command-to-string "gcc -v -xc++ /dev/null -fsyntax-only")))

(setq cmake-ide-flags-c++ (append '("-std=c++11")
                                  (mapcar (lambda (path) (concat "-I" path)) (c++-include-paths))))
(setq cmake-ide-flags-c '("-I/usr/include"))


(cmake-ide-setup)

(provide 'init-cpp)
