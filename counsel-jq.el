;;; counsel-jq.el --- Live preview of "jq" queries using counsel -*- lexical-binding: t -*-
;;; Version: 1.1.0
;;; Author: Alain M. Lafon <alain@200ok.ch)
;;; Package-Requires: ((swiper "0.12.0") (ivy "0.12.0") (emacs "24.1"))
;;; Keywords: convenience, data, matching
;;; URL: https://github.com/200ok-ch/counsel-jq
;;; Commentary:
;;;   Needs the "jq" binary installed.
;;; Code:

(require 'swiper)

(defcustom counsel-jq-json-buffer-mode 'js-mode
  "Major mode for the resulting `counsel-jq-buffer' buffer."
  :type '(function)
  :require 'counsel-jq
  :group 'counsel-jq)

(defcustom counsel-jq-command "jq"
  "Command for `counsel-jq'.")

(defcustom counsel-jq-buffer "*jq-json*"
  "Buffer for the `counsel-jq' query results.")

(defun counsel-jq-json (&optional query)
  "Call 'jq' with the QUERY with a default of '.'."
  (with-current-buffer
      ;; The user entered the `counsel-jq` query in the minibuffer.
      ;; This expression uses the most recent buffer ivy-read was
      ;; invoked from.
      (ivy-state-buffer ivy-last)
    (call-process-region
     (point-min)
     (point-max)
     counsel-jq-command
     nil
     counsel-jq-buffer
     nil
     "-M"
     (or query "."))))

(defun counsel-jq-query-function (input)
  "Wrapper function passing INPUT over to `counsel-jq-json'."
  (when (get-buffer counsel-jq-buffer)
      (with-current-buffer counsel-jq-buffer
        (funcall counsel-jq-json-buffer-mode)
        (erase-buffer)))
  (counsel-jq-json input)
  (setq ivy--old-cands
        (split-string
         (replace-regexp-in-string
          "\n$" ""
          (with-current-buffer counsel-jq-buffer
            (buffer-string))) "\n")))

;;;###autoload
(defun counsel-jq ()
  "Counsel interface for dynamically querying jq.
Whenever you're happy with the query, hit RET and the results
will be displayed to you in the buffer in `counsel-jq-buffer'."
  (interactive)
  (ivy-read "jq query: " #'counsel-jq-query-function
            :action #'(1
                      ("s" (lambda (_)
                             (display-buffer counsel-jq-buffer))
                             "show"))
            :initial-input "."
            :dynamic-collection t
            :caller 'counsel-jq))


(provide 'counsel-jq)

;;; counsel-jq.el ends here
