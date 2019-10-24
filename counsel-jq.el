(defun jq-json (&optional input)
  (save-excursion
    (call-process-region
     (point-min)
     (point-max)
     "jq" 
     nil
     "*jq-json*"
     nil
     "-M"
     (or input "."))))  

(defun switch-to-minibuffer ()
  "Switch to minibuffer window."
  (if (active-minibuffer-window)
      (select-window (active-minibuffer-window))))


(defun counsel-search-function (input)
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
  "Ivy interface for dynamically querying jq."
  (interactive)
  (ivy-read "search: " #'counsel-search-function
            :action '(1
                      ("s" (lambda (x)
                             (split-window-below) 
                             (switch-to-buffer "*jq-json*"))
                             "show"))
            :initial-input "."
            :dynamic-collection t
            :caller 'counsel-jq))  
