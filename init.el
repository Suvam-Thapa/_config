;; ============================================================
;; Package Setup -- anprtvwx
;; ============================================================
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))

(use-package gcmh
  :ensure t
  :config
  (gcmh-mode 1))

;; ============================================================
;; UI
;; ============================================================
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(fringe-mode 0)
(blink-cursor-mode 0)
(setq inhibit-startup-screen t)
(setq inhibit-startup-echo-area-message t)
(setq initial-scratch-message nil)
(setq frame-resize-pixelwise t)

;; ============================================================
;; Terminal Size
;; ============================================================
(add-to-list 'display-buffer-alist
             '("\\*compilation\\*"
               (display-buffer-reuse-window display-buffer-below-selected)
               (window-height . 25))) ;; <--- Set to exactly 15 lines tall

;; ============================================================
;; Modeline
;; ============================================================
(defun my-modeline-right ()
  (let* ((right (format-mode-line
                 `(" "
                   (:eval (when vc-mode
                            (propertize (string-trim vc-mode)
                                        'face 'font-lock-string-face)))
                   " "
                   (:eval (when (bound-and-true-p flymake-mode)
                            (flymake--mode-line-counters)))
                   "  %l:%c  ")))
         (space (propertize " "
                            'display `((space :align-to (- right ,(length right)))))))
    (concat space right)))

(setq-default mode-line-format
              '("%e"
                mode-line-front-space
                mode-line-mule-info
                mode-line-modified
		mode-line-remote
                "  "
                "%b"
                "  "
                "%m"
                (:eval (my-modeline-right))
                "  "
                mode-line-percent-position))

;; ============================================================
;; Line Numbers
;; ============================================================
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)
(setq display-line-numbers-type 'relative)
(setq display-line-numbers-width-start t)
(setq display-line-numbers-width 3) ;; fixed width, won't resize as line count grows

;; ============================================================
;; Dired
;; ============================================================
(setq dired-kill-when-opening-new-dired-buffer t)
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "q") 'kill-current-buffer))

;; ============================================================
;; Font
;; ============================================================
(set-face-attribute 'default nil
		    :font "CaskaydiaCove Nerd Font"
		    :height 160)

;; ============================================================
;; Scroll
;; ============================================================
(setq scroll-conservatively 101)
(setq scroll-margin 5)
(setq scroll-preserve-screen-position t)

;; ============================================================
;; Theme
;; ============================================================
(add-to-list 'custom-theme-load-path "~/.config/emacs/themes/")
(load-theme 'lena t)

;; ============================================================
;; LSP
;; ============================================================
(defun language-server/jedi (&optional _interactive _project)
  "Use the jedi-language-server inside .py_venv if found upward from this buffer, else fall back to PATH."
  (let* ((venv-root (locate-dominating-file default-directory ".py_venv"))
         (bin (and venv-root
                   (expand-file-name ".py_venv/bin/jedi-language-server" venv-root))))
    (if (and bin (file-executable-p bin))
        (list bin)
      (list "jedi-language-server"))))

(use-package rust-mode
  :ensure t)
(use-package lua-mode
  :ensure t)

(use-package eglot
  :hook ((lua-mode . eglot-ensure)
	 (rust-mode . eglot-ensure)
	 (python-mode . eglot-ensure))
  :config

  (add-to-list 'eglot-server-programs
               '(rust-mode .
			   ("systemd-run" "--user" "--scope" "--collect"
			    "-p" "MemoryHigh=1.2G"
			    "-p" "MemoryMax=1.4G"
			    "--"  "rust-analyzer"
			    :initializationOptions
			    (:check (:command "check")
				    :numThreads 1))))
  (add-to-list 'eglot-server-programs
               '(python-mode . language-server/jedi))  

  (setq eglot-ignored-server-capabilities '(:inlayHintProvider))

  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (setq-local eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)))
  (define-key eglot-mode-map (kbd "C-c d") 'xref-find-definitions)
  (define-key eglot-mode-map (kbd "C-c h") 'eldoc-doc-buffer)
  (define-key eglot-mode-map (kbd "C-c n") 'xref-find-references)
  (define-key eglot-mode-map (kbd "C-c a") 'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c r") 'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c e") 'flymake-show-buffer-diagnostics))

(with-eval-after-load 'flymake
  (setq flymake-show-diagnostics-at-end-of-line nil) ;; no inline text
  (setq flymake-indicator-type nil)            ;; no fringe/margin glyph at all
  (setq flymake-margin-indicator-position nil) ;; underline + modeline count only
  (setq flymake-fringe-indicator-position nil))

;; ============================================================
;; Hooks
;; ============================================================
(defun project-root/cargo (dir)
  "Treat the nearest Cargo.toml as the project root, instead of falling back to VC root."
  (when-let ((root (locate-dominating-file dir "Cargo.toml")))
    (cons 'transient root)))

(defun compilation/py-venv ()
  "If a `.py_venv' is found upward from this buffer, prepend its bin/ to
`compilation-environment' (buffer-locally), so `compile'/`recompile' resolve
python and other binaries from the venv instead of the system PATH."
  (when-let* ((venv-root (locate-dominating-file default-directory ".py_venv"))
              (venv-bin (expand-file-name ".py_venv/bin" venv-root)))
    (when (file-directory-p venv-bin)
      (setq-local compilation-environment
                  (list (concat "PATH=" venv-bin path-separator (getenv "PATH"))
                        (concat "VIRTUAL_ENV=" (expand-file-name ".py_venv" venv-root)))))))
(add-hook 'python-mode-hook
          (lambda ()
            (setq-local compile-command
                        (concat "python " (shell-quote-argument (buffer-file-name))))))

(add-hook 'python-mode-hook #'compilation/py-venv)
(add-hook 'project-find-functions #'project-root/cargo -10)

;; ============================================================
;; Tools
;; ============================================================
(use-package zoxide
  :ensure t)

(use-package vertico
  :ensure t
  :hook (after-init . vertico-mode))

(use-package vterm
  :ensure t
  :defer t
  :bind ("C-c t" . vterm)
  :config
  (setq vterm-timer-delay nil))

(use-package consult
  :ensure t)

(use-package orderless
  :ensure t
  :defer t 
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package multiple-cursors
  :ensure t
  :defer t
  :bind
  (("C-c m m" . mc/edit-lines)
   ("C-c m n" . mc/mark-next-like-this)
   ("C-c m p" . mc/mark-previous-like-this)
   ("C-c m a" . mc/mark-all-like-this)))

(use-package magit
  :ensure t
  :defer t
  :bind ("C-c g" . magit-status))

(use-package which-key
  :ensure t
  :defer 1
  :config
  (which-key-mode))

(use-package rainbow-mode
  :ensure t
  :hook (prog-mode . rainbow-mode))

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package marginalia
  :ensure t
  :hook (after-init . marginalia-mode))

(use-package apheleia
  :ensure t
  :hook (python-mode . apheleia-mode)
  :config
  (apheleia-global-mode +1))

(use-package corfu
  :ensure t
  :hook (after-init . global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0)
  (corfu-auto-prefix 1)
  (corfu-cycle t)
  (corfu-left-margin-width 0.0)
  (corfu-right-margin-width 0.0))

;; ============================================================
;; Keybindings
;; ============================================================
;; Defining new key functions
(defun smart/delete (&optional arg)
  "Delete the active region if it exists, otherwise delete the character at point."
  (interactive "P")
  (if (use-region-p)
      (delete-region (region-beginning) (region-end))
    (delete-char (or arg 1))))

(defun my/char-class (char)
  (cond ((string-match-p "[[:alnum:]_]" (char-to-string char)) 'word)
        ((string-match-p "[[:space:]\n]" (char-to-string char)) 'whitespace)
        (t 'punctuation)))

(defun smart/forward-word (&optional arg)
  "Move forward to the end of the current contiguous class of characters (Word, Punctuation, or Whitespace)."
  (interactive "^p")
  (or arg (setq arg 1))
  (dotimes (_ arg)
    (unless (eobp)
      (let ((class (my/char-class (char-after))))
        (forward-char 1)
        (while (and (not (eobp))
                    (eq class (my/char-class (char-after))))
          (forward-char 1))))))

(defun smart/backward-word (&optional arg)
  "Move backward to the beginning of the current contiguous class of characters."
  (interactive "^p")
  (or arg (setq arg 1))
  (dotimes (_ arg)
    (unless (bobp)
      (let ((class (my/char-class (char-before))))
        (backward-char 1)
        (while (and (not (bobp))
                    (eq class (my/char-class (char-before))))
          (backward-char 1))))))

;; 'word (aware of _,) 'symbol 
(defun smart/kill-inner-word ()
  "Kill the entire symbol/variable under the cursor."
  (interactive)
  (if (thing-at-point 'symbol)
      (let ((bounds (bounds-of-thing-at-point 'symbol)))
        (kill-region (car bounds) (cdr bounds)))
    (message "No symbol at point")))

(defun smart/backward-kill-word (&optional arg)
  "Kill the entire word or whitespace block under the cursor (backward-initiated).
For punctuation, kills only the immediate character behind the cursor."
  (interactive "p")
  (or arg (setq arg 1))
  (dotimes (_ arg)
    (unless (bobp)
      (let* ((class (my/char-class (char-before)))
             ;; If punctuation, just grab the single char behind point. Otherwise, find block start.
             (start (cond
                     ((eq class 'punctuation) (1- (point)))
                     (t (save-excursion
                          (while (and (not (bobp))
                                      (eq class (my/char-class (char-before))))
                            (backward-char 1))
                          (point)))))
             ;; If punctuation, anchor right at point. Otherwise, find block end.
             (end (cond
                   ((eq class 'punctuation) (point))
                   (t (save-excursion
                        (while (and (not (eobp))
                                    (eq class (my/char-class (char-after))))
                          (forward-char 1))
                        (point))))))
        (kill-region start end)))))
;; End

;; Save Files with/without confirmation
(global-set-key (kbd "C-x s") 'save-buffer)
(global-set-key (kbd "C-x C-s") 'save-some-buffers)         
;; Find Find files/buffers
(global-set-key (kbd "C-x C-f") 'consult-fd)                
(global-set-key (kbd "C-x f") 'find-file)                   
(global-set-key (kbd "C-x b") 'consult-buffer)              
;; Move a word forward/backward
(global-set-key (kbd "C-t") 'smart/forward-word)                  
(global-set-key (kbd "C-e") 'smart/backward-word)                 
;; Set Mark Visual
(global-set-key (kbd "C-SPC") 'set-mark-command)
;; Swap C-l with C-f
(global-set-key (kbd "C-l") 'forward-char)
(global-set-key (kbd "C-f") 'recenter-top-bottom)
;; Prefix key C-o
(global-set-key (kbd "C-o") nil)
(define-prefix-command 'prefix_o)
(global-set-key (kbd "C-o") 'prefix_o)
(with-eval-after-load 'compile
  ;; Unset C-o in compilation mode so it falls back to global prefix map
  (define-key compilation-mode-map (kbd "C-o") nil))
;; Move Cursors to end/beginning
(define-key prefix_o (kbd "C-h") 'move-beginning-of-line)
(define-key prefix_o (kbd "C-l") 'move-end-of-line)
(define-key prefix_o (kbd "C-n") 'exchange-point-and-mark)  
;; kill words
(global-set-key (kbd "C-d") 'smart/delete)
(define-key prefix_o (kbd "C-j") 'smart/backward-kill-word)
(define-key prefix_o (kbd "C-k") 'smart/kill-inner-word)
;; Comment / visual too 
(define-key prefix_o (kbd "C-f") 'comment-line)
;; Faster Dir travel
(define-key prefix_o (kbd "C-p") 'zoxide-travel)
;; Better terminal
(define-key prefix_o (kbd "C-t") 'vterm)
;; Copy Cut
(define-key prefix_o (kbd "C-o") 'kill-ring-save)    ;; Copy
(global-set-key (kbd "C-x C-x") 'kill-region)        ;; Cut
;; Compile
(global-set-key (kbd "C-c c") 'compile)
(global-set-key (kbd "C-v") 'execute-extended-command)      ;; extended command ":"

(electric-pair-mode 1)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
