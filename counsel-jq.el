;;; counsel-jq.el --- Live preview of "jq" queries using counsel -*- lexical-binding: t -*-
;;; Version: 1.0.0
;;; Author: Alain M. Lafon <alain@200ok.ch)
;;; Package-Requires: ((swiper "0.12.0") (ivy "0.12.0") (emacs "24.1"))
;;; Keywords: convenience, data, matching
;;; URL: https://github.com/200ok-ch/counsel-jq
;;; Commentary:
;;;   Needs the "jq" binary installed.
;;; Code:

(require 'swiper)

(defun counsel-jq-json (&optional query)
  "Call 'jq' with the QUERY with a default of '.'."
  (with-current-buffer
      ;; The user entered the `counsel-jq` query in the minibuffer.
      ;; This expression uses the most recent other buffer (see
      ;; https://www.gnu.org/software/emacs/manual/html_node/eintr/Switching-Buffers.html#fnd-2).
      (other-buffer (current-buffer) t)
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
  "Wrapper function passing INPUT over to `counsel-jq-json'."
  (when (get-buffer "*jq-json*")
      (with-current-buffer "*jq-json*"
        (erase-buffer)))
  (counsel-jq-json input)
  (split-string
   (with-current-buffer "*jq-json*"
     (buffer-string))  "\n"))

;;;###autoload
(defun counsel-jq ()
  "Counsel interface for dynamically querying jq. Whenever you're happy with the query, hit RET and the results will be displayed to you in the buffer *jq-json*."
  (interactive)
  (ivy-read "jq query: " #'counsel-jq-query-function
            :action #'(1
                      ("s" (lambda (x)
                             (split-window-below)
                             (switch-to-buffer "*jq-json*"))
                             "show"))
            :initial-input "."
            :dynamic-collection t
            :caller 'counsel-jq))


(provide 'counsel-jq)

;;; counsel-jq.el ends here
