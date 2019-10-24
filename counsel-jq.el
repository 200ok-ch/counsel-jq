;;; package -- Live preview of "jq" queries using counsel.
;;; Commentary:
;;;   Needs the "jq" binary and ivy/counsel installed.
;;; Code:

(defun jq-json (&optional query)
  "Call 'jq' with the QUERY with a default of '.'."
  (with-current-buffer
      ;; The user entered the `counsel-jq` query in the minibuffer.
      ;; This expression uses the most recent other buffer (see
      ;; https://www.gnu.org/software/emacs/manual/html_node/eintr/Switching-Buffers.html#fnd-2).
      (other-buffer (current-buffer) t)
    (message (concat "current buffer: " (buffer-name)))
    (call-process-region
     (point-min)
     (point-max)
     "jq"
     nil
     "*jq-json*"
     nil
     "-M"
     (or query "."))))

(defun counsel-jq-query-function (input)
  "Wrapper function passing INPUT over to jq-json."
  (message (concat "initial buffer: " (buffer-name)))
  (if (get-buffer "*jq-json*")
      (with-current-buffer "*jq-json*"
        (erase-buffer)))
  (jq-json input)
  (split-string
   (with-current-buffer "*jq-json*"
     (buffer-string))  "\n"))

(defun counsel-jq ()
  "Counsel interface for dynamically querying jq."
  (interactive)
  (ivy-read "jq query: " #'counsel-jq-query-function
            :action '(1
                      ("s" (lambda (x)
                             (split-window-below)
                             (switch-to-buffer "*jq-json*"))
                             "show"))
            :initial-input "."
            :dynamic-collection t
            :caller 'counsel-jq))


(provide 'counsel-jq)
;;; counsel-jq.el ends here
