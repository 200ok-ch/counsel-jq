;;; package -- Live preview of "jq" queries using counsel.
;;; Commentary:
;;;   Needs the "jq" binary and ivy/counsel installed.
;;; Code:

(defun jq-json (&optional query)
  "Call 'jq' with the QUERY with a default of '.'."
  (save-excursion
    (call-process-region
     (point-min)
     (point-max)
     "jq"
     nil
     "*jq-json*"
     nil
     "-M"
     (or query "."))))

(defun switch-to-minibuffer ()
  "Switch to minibuffer window."
  (if (active-minibuffer-window)
      (select-window (active-minibuffer-window))))

(defun counsel-jq-query-function (input)
  "Wrapper function passing INPUT over to jq-json."
  (save-excursion
    (switch-to-buffer "*jq-json*")
    (erase-buffer)
    (switch-to-buffer (other-buffer))
    (jq-json input)
    (switch-to-buffer "*jq-json*")
    (let ((s (split-string (buffer-string)  "\n")))
      (switch-to-buffer (other-buffer))
      (switch-to-minibuffer)
      s)))

(defun counsel-jq ()
  "Counsel interface for dynamically querying jq."
  (interactive)
  (ivy-read "search: " #'counsel-jq-query-function
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
