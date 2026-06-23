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
  :ensure t)

(add-to-list 'load-path "path-to-gcmh-here")
(gcmh-mode 1)

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
(setq display-line-numbers-width 4) ;; fixed width, won't resize as line count grows

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
		    :font "JetBrainsMono Nerd Font"
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
;; git clone https://github.com/Theory-of-Everything/everforest-emacs.git ~/.config/emacs/everforest-theme
(add-to-list 'custom-theme-load-path "~/.config/emacs/everforest-theme")
(load-theme 'everforest-hard-light t)
(set-face-attribute 'isearch-fail nil :background 'unspecified)

;; ============================================================
;; LSP
;; ============================================================
(use-package lua-mode
  :ensure t)
(use-package rust-mode
  :ensure t)

(use-package eglot
  :hook ((lua-mode . eglot-ensure)
	 (rust-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs
               '(rust-mode .
			   ("systemd-run" "--user" "--scope"
			    "-p" "MemoryHigh=1G"
			    "-p" "MemoryMax=1.6G"
			    "--"  "rust-analyzer"
			    :initializationOptions
			    (:check (:command "check")
				    :numThreads 1))))
  (setq eglot-ignored-server-capabilities '(:inlayHintProvider))
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (setq-local eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)))
  (define-key eglot-mode-map (kbd "C-c d") 'xref-find-definitions)
  (define-key eglot-mode-map (kbd "C-c r") 'xref-find-references)
  (define-key eglot-mode-map (kbd "C-c a") 'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c n") 'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c e") 'flymake-show-buffer-diagnostics))

(defun my/project-try-cargo (dir)
  "Treat the nearest Cargo.toml as the project root, instead of falling back to VC root."
  (when-let ((root (locate-dominating-file dir "Cargo.toml")))
    (cons 'transient root)))

(add-hook 'project-find-functions #'my/project-try-cargo -10)

(with-eval-after-load 'flymake
  (setq flymake-show-diagnostics-at-end-of-line nil) ;; no inline text
  (setq flymake-indicator-type nil)            ;; no fringe/margin glyph at all
  (setq flymake-margin-indicator-position nil) ;; underline + modeline count only
  (setq flymake-fringe-indicator-position nil))

;; ============================================================
;; Compilation
;; ============================================================
(require 'ansi-color)
(require 'compile)

(setq compilation-scroll-output t)

;; cargo (and most tools) auto-disable color when stdout isn't a tty,
;; which is what M-x compile gives them. Force it back on so there's
;; actually something for ansi-color to colorize below.
(setenv "CARGO_TERM_COLOR" "always")

(defun my/colorize-compilation-buffer ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region compilation-filter-start (point))))
(add-hook 'compilation-filter-hook #'my/colorize-compilation-buffer)

(add-hook 'rust-mode-hook
          (lambda ()
            (setq-local compile-command "cargo run")))

(global-set-key (kbd "C-c c") 'compile)

;; ============================================================
;; Tools
;; ============================================================
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

(use-package marginalia
  :ensure t
  :hook (after-init . marginalia-mode))

(use-package apheleia
  :ensure t
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
(global-set-key (kbd "C-x s") 'save-buffer)                 ;; save without confirmation 
(global-set-key (kbd "C-x C-s") 'save-some-buffers)         ;; save with confirmation 
(global-set-key (kbd "C-SPC") 'execute-extended-command)    ;; extended command ":"
(global-set-key (kbd "C-x C-o") 'exchange-point-and-mark)   ;; loop mark pointer 
(global-set-key (kbd "C-x C-f") 'set-fill-column)           ;; NK NK NK NK NK NK NK
(global-set-key (kbd "C-x f") 'find-file)                   ;; find-file dired
(global-set-key (kbd "C-x b") 'consult-buffer)              ;; better buffer
(global-set-key (kbd "C-t") 'forward-word)                  ;; move 1 word forward
(global-set-key (kbd "C-e") 'backward-word)                 ;; move 1 word backward
(global-set-key (kbd "C-v") 'set-mark-command)              ;; Mark visual
;; Swap C-l with C-f
(global-set-key (kbd "C-l") 'forward-char)
(global-set-key (kbd "C-f") 'recenter-top-bottom)
;; Prefix key C-o
(global-set-key (kbd "C-o") nil)
(define-prefix-command 'prefix_o)
(global-set-key (kbd "C-o") 'prefix_o)
(define-key prefix_o (kbd "h") 'move-beginning-of-line)
(define-key prefix_o (kbd "l") 'move-end-of-line)
(define-key prefix_o (kbd "C-o") 'kill-ring-save)    ;; Copy
(global-set-key (kbd "C-x C-x") 'kill-region)        ;; Cut

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
 '(completions-common-part ((t (:foreground "#f57d26" :weight bold))))
 '(completions-highlight ((t (:foreground "#f57d26" :weight bold))))
 '(corfu-current ((t (:background "#edf0cd" :foreground "#5c6a72" :weight bold))))
 '(corfu-default ((t (:background "#fffbef" :foreground "#5c6a72"))))
 '(orderless-match-face-0 ((t (:foreground "#f57d26" :weight bold))))
 '(orderless-match-face-1 ((t (:foreground "#f85552" :weight bold))))
 '(vertico-current ((t (:background "#edf0cd" :weight bold)))))
