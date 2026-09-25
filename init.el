;; -*- lexical-binding: t; -*-

;; ===============================
;; Frame, Theme & Font Setup 
;; ===============================

(defun my/setup-frame-colors (frame)
  "Apply theme and faces when a graphical frame is created."
  (with-selected-frame frame
    (when (display-graphic-p frame)
      (load-theme 'gruvbox-light-soft t)
      (set-face-attribute 'default frame 
                          :font "CaskaydiaCove Nerd Font-14:weight=semi-bold"))))

(add-hook 'after-make-frame-functions #'my/setup-frame-colors)

;; ===============================
;; Garbage Collection
;; ===============================

(add-hook 'after-init-hook
          (lambda ()
            (setq gc-cons-threshold (* 32 1024 1024))
	    (setq gc-cons-percentage 0.1)))

;; ===============================
;; Package Setup -- anprtvwx
;; ===============================

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))

;; ===============================
;; UI
;; ===============================

(add-hook 'prog-mode-hook (lambda () (setq fill-column 110)))
(add-hook 'text-mode-hook (lambda () (setq fill-column 110)))

;; ===============================
;; Terminal Size
;; ===============================

(add-to-list 'display-buffer-alist
             '("\\*compilation\\*"
               (display-buffer-reuse-window display-buffer-below-selected)
               (window-height . 18)))

;; ===============================
;; Modeline
;; ===============================

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

;; ===============================
;; Dired
;; ===============================

(setq dired-kill-when-opening-new-dired-buffer t)

(defun dired-create-thing (name)
  "Create file or directory in Dired. Trailing slash = directory.
Automatically builds missing parent folders if you provide a nested path."
  (interactive "sCreate: ")
  (let* ((base-dir (dired-current-directory)) 
         (path (expand-file-name name base-dir)))
    (if (string-suffix-p "/" name)
        (make-directory path t)
      (let ((parent-dir (file-name-directory path)))
        (unless (file-exists-p parent-dir)
          (make-directory parent-dir t)))
      (make-empty-file path))
    (revert-buffer)                           
    (message "Created: %s" path)))

(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "+") #'dired-create-thing)
  (define-key dired-mode-map (kbd "q") 'kill-current-buffer)
  (define-key dired-mode-map (kbd "r") 'wdired-change-to-wdired-mode))

;; ===============================
;; Line Numbers
;; ===============================

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)
(setq display-line-numbers-type 'relative)
(setq display-line-numbers-width-start t)
(setq display-line-numbers-width 4)

;; ===============================
;; Scroll
;; ===============================

(setq scroll-conservatively 101)
(setq scroll-margin 5)
(setq scroll-preserve-screen-position t)

;; ===============================
;; LSP
;; ===============================

(use-package web-mode
  :ensure t
  :mode (("\\.html\\'"   . web-mode)
         ("\\.djhtml\\'" . web-mode))
  :config
  (setq web-mode-engines-alist '(("django" . "\\.html\\'")
                                 ("django" . "\\.djhtml\\'")))
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2)
  ;; You use smartparens, so turn off web-mode's own auto-pairing
  (setq web-mode-enable-auto-pairing nil))

(use-package emmet-mode
  :ensure t
  :hook ((tsx-ts-mode        . emmet-mode)
         (js-ts-mode         . emmet-mode)
         (web-mode          . emmet-mode)
         (css-mode           . emmet-mode))
  :config
  ;; Tell emmet-mode to treat Tree-sitter JSX/TSX modes as JSX
  (add-to-list 'emmet-jsx-major-modes 'tsx-ts-mode)
  (add-to-list 'emmet-jsx-major-modes 'js-ts-mode)

  ;; Ensure it uses className instead of class in JSX modes
  (setq emmet-expand-jsx-className? t))

;; Define sources for tree-sitter grammars
(setq treesit-language-source-alist
      '((typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (tsx        "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
        (css        "https://github.com/tree-sitter/tree-sitter-css")
        (json       "https://github.com/tree-sitter/tree-sitter-json")
        (html       "https://github.com/tree-sitter/tree-sitter-html")
	(python     "https://github.com/tree-sitter/tree-sitter-python")))

;; Helper to auto-install missing grammars on startup
(defun my/ensure-treesit-grammars ()
  "Install tree-sitter grammars if they are not already installed."
  (interactive)
  (dolist (lang '(typescript tsx javascript css json html python))
    (unless (treesit-language-available-p lang)
      (treesit-install-language-grammar lang))))

;; Run the check on startup
(add-hook 'after-init-hook #'my/ensure-treesit-grammars)

;; --- Modern TypeScript & JavaScript Setup ---
(use-package typescript-ts-mode
  :mode (("\\.ts\\'"  . typescript-ts-mode)
         ("\\.tsx\\'" . tsx-ts-mode)
         ("\\.jsx\\'" . js-ts-mode))
  :init
  ;; Remap legacy modes to modern tree-sitter modes globally
  (add-to-list 'major-mode-remap-alist '(typescript-mode . typescript-ts-mode))
  (add-to-list 'major-mode-remap-alist '(js-mode         . js-ts-mode))
  (add-to-list 'major-mode-remap-alist '(javascript-mode . js-ts-mode)))

;; Python LSP (Ty) Helper
(defun language-server/python (&optional _interactive _project)
  "Find ty inside a uv-managed .venv, or run it via `uv` / `uvx`."
  (let* ((root (locate-dominating-file default-directory "pyproject.toml"))
         (ty-bin (and root (expand-file-name ".venv/bin/ty" root))))
    (cond
     ;; 1. Local uv venv has ty installed directly
     ((and ty-bin (file-executable-p ty-bin))
      (list ty-bin "server"))
     ;; 2. Run via project venv context using uv
     (root
      (list "uv" "run" "ty" "server"))
     ;; 3. Fallback: run transiently via uvx if outside a uv project
     (t (list "uvx" "ty" "server")))))

(add-to-list 'major-mode-remap-alist
	     '(python-mode . python-ts-mode))

(defun my/eglot-eldoc-setup ()
  (setq-local eldoc-documentation-strategy
	      'eldoc-documentation-compose-eagerly))

(use-package rust-mode
  :ensure t)

(use-package lua-mode
  :ensure t)

(use-package eglot
  :hook ((lua-mode . eglot-ensure)
	 (rust-mode . eglot-ensure)
	 (python-ts-mode . eglot-ensure)
	 (js-ts-mode            . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (tsx-ts-mode        . eglot-ensure)
	 (c-mode . eglot-ensure))

  :config
  (setq eglot-autoshutdown t
        eglot-events-buffer-size 0)

  (add-to-list 'eglot-server-programs
               '((typescript-ts-mode tsx-ts-mode js-mode js-jsx-mode)
		 . ("typescript-language-server" "--stdio")))
  
  (add-to-list 'eglot-server-programs
	       '(rust-mode .
			   ("systemd-run" "--user" "--scope" "--collect"
			    "-p" "MemoryHigh=1.2G"
			    "-p" "MemoryMax=1.4G"
			    "--" "rust-analyzer"
			    :initializationOptions
			    (:check (:command "check")
				    :numThreads 1))))

  (add-to-list 'eglot-server-programs
	       '(python-ts-mode . language-server/python))

  (setq eglot-ignored-server-capabilities '(:inlayHintProvider))

  (add-hook 'eglot-managed-mode-hook #'my/eglot-eldoc-setup)

  (define-key eglot-mode-map (kbd "C-c d") 'xref-find-definitions)
  (define-key eglot-mode-map (kbd "C-c h") 'eldoc-doc-buffer)
  (define-key eglot-mode-map (kbd "C-c n") 'xref-find-references)
  (define-key eglot-mode-map (kbd "C-c a") 'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c r") 'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c e") 'flymake-show-buffer-diagnostics))

(with-eval-after-load 'flymake
  (setq flymake-show-diagnostics-at-end-of-line nil)
  (setq flymake-indicator-type nil)           
  (setq flymake-margin-indicator-position nil)
  (setq flymake-fringe-indicator-position nil))

;; (advice-add 'flymake--highlight-line :after
;;             (lambda (diagnostic)
;;               (when-let* ((ov (flymake--diag-overlay diagnostic)))
;;                 (overlay-put ov 'before-string nil)))))


;; ===============================
;; Hooks
;; ===============================

(defvar my/corfu-was-on nil)
(defvar my/corfu-suppressed nil)

(add-hook 'multiple-cursors-mode-enabled-hook
          (lambda ()
            (unless my/corfu-suppressed
              (setq my/corfu-was-on corfu-mode)
              (setq my/corfu-suppressed t)
              (when corfu-mode (corfu-mode -1)))))

(add-hook 'multiple-cursors-mode-disabled-hook
          (lambda ()
            (when my/corfu-suppressed
              (setq my/corfu-suppressed nil)
              (when my/corfu-was-on (corfu-mode 1)))))

(defun project-root/cargo (dir)
  "Treat the nearest Cargo.toml as the project root, instead of falling back to VC root."
  (when-let* ((root (locate-dominating-file dir "Cargo.toml")))
    (cons 'transient root)))
(add-hook 'project-find-functions #'project-root/cargo -10)

(defun project-root/python (dir)
  "Treat the nearest pyproject.toml as the project root."
  (when-let* ((root (locate-dominating-file dir "pyproject.toml")))
    (cons 'transient root)))
(add-hook 'project-find-functions #'project-root/python -10)

(add-hook 'python-ts-mode-hook
          (lambda ()
            (setq-local compile-command
                        (concat "uv run python " (shell-quote-argument (buffer-file-name))))))

(add-hook 'c-mode-hook
          (lambda ()
            ;; Only override if there isn't a Makefile in the current directory
            (unless (file-exists-p "Makefile")
	      (setq-local compile-command
                          (concat "gcc -Wall -Wextra -Werror -O2 ")))))

;; ===============================
;; Tools
;; ===============================

;; --- Recentf: Recently Opened Files ---
(use-package recentf
  :ensure nil
  :init
  (recentf-mode 1)
  :config
  (setq recentf-max-saved-items 50
        recentf-max-menu-items 25
        recentf-save-file (locate-user-emacs-file "recentf")))

;; --- Sudo-Edit: Edit Files as Root ---
(use-package sudo-edit
  :ensure t
  :defer t)

;; --- Corfu: In-Buffer Completion Popup ---
(use-package corfu
  :ensure t
  :hook (after-init . global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.0)
  (corfu-auto-prefix 1)
  (corfu-cycle t)
  (corfu-left-margin-width 0.0)
  (corfu-right-margin-width 0.0))

;; --- Yasnippet: Code Snippet Expansion ---
(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

;; --- Yasnippet-Snippets: Bundled Snippet Collection ---
(use-package yasnippet-snippets
  :ensure t
  :defer t)

;; --- Cape: Completion At Point Extensions ---
(use-package cape
  :ensure t
  :init
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-abbrev)
  (add-hook 'completion-at-point-functions #'cape-history)
  (add-hook 'completion-at-point-functions #'cape-keyword))

;; --- Orderless: Advanced Filtering ---
(use-package orderless
  :ensure t
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides
        '((file (styles basic partial-completion))
          (eglot (styles orderless))
          (eglot-capf (styles orderless)))))

;; --- Avy: Jump to Visible Text by Char/Line ---
(use-package avy
  :ensure t)

;; --- Smartparens: Structured Pair Editing ---
(use-package smartparens
  :ensure t
  :config
  (require 'smartparens-config)
  (smartparens-global-mode 1)
  (setq sp-autowrap-region t))

;; --- Visual-Fill-Column: Centered, Wrapped Text ---
(use-package visual-fill-column
  :ensure t
  :defer t
  :hook ((text-mode . visual-fill-column-mode)
         (text-mode . visual-line-mode))
  :custom
  (visual-fill-column-width 110)
  (visual-fill-column-center-text nil))

;; --- Zoxide: Frecency-Based Directory Jumping ---
(use-package zoxide
  :ensure t)

;; --- Vertico: Vertical Minibuffer Completion ---
(use-package vertico
  :ensure t
  :hook (after-init . vertico-mode)
  :config
  (setq vertico-cycle t))

;; --- Vterm: Fast Terminal Emulator ---
(use-package vterm
  :ensure t
  :config
  (setq vterm-timer-delay 0.01)
  (setq vterm-max-scrollback 1000)
  (add-hook 'vterm-mode-hook
            (lambda ()
	      (buffer-disable-undo)
	      (display-line-numbers-mode -1)
	      (visual-line-mode -1)
	      (when (fboundp 'rainbow-mode) (rainbow-mode -1))
	      (when (fboundp 'rainbow-delimiters-mode) (rainbow-delimiters-mode -1))
	      (setq-local scroll-margin 0)
	      (setq-local scroll-conservatively 0)
	      (setq-local auto-hscroll-mode nil))))

;; --- Consult: Search & Navigate ---
(use-package consult
  :ensure t)

;; --- Multiple-Cursors: Simultaneous Multi-Point Editing ---
(use-package multiple-cursors
  :ensure t
  :config
  (define-key mc/keymap (kbd "C-g") #'mc/keyboard-quit))
(setq mc/always-run-for-all t)

;; --- Expand-Region: Semantic Selection Growth ---
(use-package expand-region
  :ensure t)

;; --- Magit: Git Interface ---
(use-package magit
  :ensure t
  :defer t)

;; --- Which-Key: Keybinding Hints ---
(use-package which-key
  :ensure t
  :config
  (setq which-key-idle-delay 0.4)
  (which-key-mode))

;; --- Rainbow-Mode: Colorize Color Codes ---
(use-package rainbow-mode
  :ensure t
  :hook ((prog-mode text-mode conf-mode) . rainbow-mode))

;; --- Rainbow-Delimiters: Colorize Nested Brackets ---
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

;; --- Marginalia: Rich Annotations ---
(use-package marginalia
  :ensure t
  :hook (after-init . marginalia-mode))

;; --- Apheleia: Format-on-Save ---
(use-package apheleia
  :ensure t
  :init
  (apheleia-global-mode +1)
  :config
  (add-to-list 'apheleia-mode-alist '(c-mode . clang-format))
  (add-to-list 'apheleia-mode-alist '(js-ts-mode . prettier))
  (add-to-list 'apheleia-mode-alist '(typescript-ts-mode . prettier))
  (add-to-list 'apheleia-mode-alist '(tsx-ts-mode . prettier))

  ;; Python
  (setf (alist-get 'ruff apheleia-formatters)
        '("sh" "-c" "uv run ruff check --fix --select I,F,E --stdin-filename \"$1\" - | uv run ruff format --stdin-filename \"$1\" -"
          "sh" filepath))
  (add-to-list 'apheleia-mode-alist '(python-ts-mode . ruff))

  ;; Django / HTML Formatting with djlint
  (setf (alist-get 'djlint apheleia-formatters)
	'("uv" "run" "djlint" "--reformat" "--format-js" "--format-css"
          "--profile" "django"
          "--indent" "3"
          "--max-line-length" "160"
          "-"))
  (add-to-list 'apheleia-mode-alist '(web-mode . djlint))
  
  ;; Override the default clang-format command to use a 110 column limit
  (setf (alist-get 'clang-format apheleia-formatters)
	'("clang-format"
          "-style={BasedOnStyle: LLVM, ColumnLimit: 110}"
          "-assume-filename"
          (or (apheleia-formatters-local-buffer-file-name)
	      (apheleia-formatters-mode-extension)
	      ".c")))

  ;; (setf (alist-get 'prettier apheleia-formatters)
  ;;       '("npx" "prettier" "--stdin-filepath" filepath 
  ;;         "--print-width" "100" 
  ;;         "--html-whitespace-sensitivity" "ignore"))
  (apheleia-global-mode +1))


;; ===============================
;; Binding Functions
;; ===============================

(defun rt/del_or_cut (&optional arg)
  "Kill the active region (save to clipboard) if it exists, 
otherwise delete the character at point without saving it."
  (interactive "P")
  (if (use-region-p)
      (kill-region (region-beginning) (region-end))
    (delete-char (or arg 1))))


(defun my/char-class (char)
  "Classify CHAR into word, whitespace, or punctuation blocks.
Underscores are treated as punctuation for granular editing."
  (cond ((string-match-p "[[:alnum:]]" (char-to-string char)) 'word) ; Removed "_"
        ((string-match-p "[[:space:]\n]" (char-to-string char)) 'whitespace)
        (t 'punctuation)))


(defun rt/forward_word (&optional arg)
  "Move forward to the end of the current contiguous class of characters.
Words and whitespaces are skipped as blocks; punctuation is traversed one by one."
  (interactive "^p")
  (or arg (setq arg 1))
  (dotimes (_ arg)
    (unless (eobp)
      (let ((class (my/char-class (char-after))))
        (forward-char 1)
        ;; Only loop/skip if the current block is NOT punctuation
        (while (and (not (eobp))
                    (not (eq class 'punctuation))
                    (eq class (my/char-class (char-after))))
          (forward-char 1))))))


(defun rt/backward_word (&optional arg)
  "Move backward to the beginning of the current contiguous class of characters.
Words and whitespaces are skipped as blocks; punctuation is traversed one by one."
  (interactive "^p")
  (or arg (setq arg 1))
  (dotimes (_ arg)
    (unless (bobp)
      (let ((class (my/char-class (char-before))))
        (backward-char 1)
        ;; Only loop/skip if the current block is NOT punctuation
        (while (and (not (bobp))
                    (not (eq class 'punctuation))
                    (eq class (my/char-class (char-before))))
          (backward-char 1))))))


;; 'word (aware of _,) 'symbol 
(defun rt/kill_symbol ()
  "Kill the entire symbol/variable under the cursor."
  (interactive)
  (if (thing-at-point 'symbol)
      (let ((bounds (bounds-of-thing-at-point 'symbol)))
        (kill-region (car bounds) (cdr bounds)))
    (message "No symbol at point")))


(defun rt/backward_kill_word (&optional arg)
  "Kill backward from the cursor to the start of the current character class block.
If inside vterm, passes the kill command directly to the terminal process."
  (interactive "p")
  (if (derived-mode-p 'vterm-mode)
      ;; Pass Ctrl+W to the underlying shell inside vterm
      (vterm-send-key "w" nil nil t)
    ;; Standard Emacs buffer behavior
    (or arg (setq arg 1))
    (dotimes (_ arg)
      (unless (bobp)
        (let* ((class (my/char-class (char-before)))
	       (end (point))
	       (start (cond
		       ((eq class 'punctuation) (1- (point)))
		       (t (save-excursion
                            (while (and (not (bobp))
                                        (eq class (my/char-class (char-before))))
			      (backward-char 1))
                            (point))))))
          (kill-region start end))))))


(defun rt/word_selection ()
  "Mark the current character block. Repeated presses expand the selection forward
chunk by chunk, perfectly respecting words and individual punctuation marks."
  (interactive)
  (if (use-region-p)
      ;; Case 1: Region is active -> Expand selection forward by one smart chunk
      (unless (eobp)
        (let ((class (my/char-class (char-after))))
          (forward-char 1)
          (while (and (not (eobp))
		      (not (eq class 'punctuation))
		      (eq class (my/char-class (char-after))))
            (forward-char 1))))
    ;; Case 2: No active region -> Select the initial chunk under the cursor
    (let* ((pt (point))
           (ch (char-after pt))
           ;; If  is at the end of a line, read the character right behind it
           (class (if (or (null ch) (eq ch ?\n))
		      (my/char-class (char-before pt))
                    (my/char-class ch)))
           (start (cond
                   ((eq class 'punctuation) pt)
                   (t (save-excursion
                        (while (and (not (bobp))
                                    (eq class (my/char-class (char-before))))
                          (backward-char 1))
                        (point)))))
           (end (cond
                 ((eq class 'punctuation) (min (point-max) (1+ pt)))
                 (t (save-excursion
		      (goto-char start)
		      (while (and (not (eobp))
                                  (eq class (my/char-class (char-after))))
                        (forward-char 1))
		      (point))))))
      (goto-char start)
      (push-mark nil t t)
      (goto-char end)
      (activate-mark))))


(defun rt/line_selection ()
  "Select the entire current line."
  (interactive)
  (beginning-of-line)
  (set-mark (point))
  (end-of-line))


(defun rt/sel_quotes ()
  "Mark inside quotes using Python-specific expansion in Python modes,
or standard inside-quote expansion in other modes."
  (interactive)
  (if (derived-mode-p 'python-mode 'python-ts-mode)
      (er/mark-inside-python-string)
    (er/mark-inside-quotes)))


(defun rt/nxt_line ()
  "Move down 4 lines at a time."
  (interactive)
  (forward-line 3))


(defun rt/pev_line ()
  "Move up 4 lines at a time."
  (interactive)
  (forward-line -3))


(defvar my/previous-selection-offset nil)


(defun rt/remember_sel ()
  "Remember the direction and length of the current selection."
  (interactive)
  (when (use-region-p)
    (setq my/previous-selection-offset
          (- (mark) (point)))))


(defun rt/restore_sel ()
  "Restore the previously remembered selection."
  (interactive)
  (when my/previous-selection-offset
    (set-mark (+ (point) my/previous-selection-offset))
    (activate-mark)))


;; (defalias 'cj_macro_forward
;; (kmacro "C-f C-x C-j C-x o m c / k e y <return> C-f C-x C-n C-f C-x C-k"))

;; (defalias 'cj_macro_backward
;; (kmacro "C-f C-x C-j C-x o m c / k e y <return> C-f C-x C-p C-f C-x C-k"))

(defalias 'cj_macro_forward
  (kmacro "C-f C-x C-j C-f C-x C-x C-f C-x C-n C-f C-x C-k"))

(defalias 'cj_macro_backward
  (kmacro "C-f C-x C-j C-f C-x C-x C-f C-x C-p C-f C-x C-k"))

;; End

;; ===============================
;; Repeat Map Wrapper
;; ===============================

(defun rt/forward_sexp_1 (&optional arg)
  (interactive "^p")
  (sp-forward-sexp arg))

(defun rt/backward_sexp_1 (&optional arg)
  (interactive "^p")
  (sp-backward-sexp arg))

(defun rt/forward_sexp_2 (&optional arg)
  (interactive "^p")
  (sp-forward-sexp arg))

(defun rt/backward_sexp_2 (&optional arg)
  (interactive "^p")
  (sp-backward-sexp arg))

;; ===============================
;; Keybindings
;; ===============================

;; kill words
(define-key override-global-map (kbd "C-d") #'rt/del_or_cut)
(define-key override-global-map (kbd "C-<backspace>") #'rt/backward_kill_word)

;; Save Files with/without confirmation
(define-key override-global-map (kbd "C-x s") 'save-buffer)
(define-key override-global-map (kbd "C-x C-s") 'save-some-buffers)

;; Find Find files/buffers
(define-key override-global-map (kbd "C-x C-f") 'zoxide-travel)
(define-key override-global-map (kbd "C-x f") 'recentf-open-files)
(define-key override-global-map (kbd "C-x C-d") 'dired-jump)

;; Move a word forward/backward
(define-key override-global-map (kbd "C-t") #'rt/forward_word)
(define-key override-global-map (kbd "C-e") #'rt/backward_word)  

;; Set Mark Visual
(define-key override-global-map (kbd "C-SPC") 'set-mark-command)

;; Swap C-l with C-f
(define-key override-global-map (kbd "C-l") 'forward-char)
(define-key override-global-map (kbd "C-v") 'recenter-top-bottom)

;; Cut
(define-key override-global-map (kbd "C-x C-x") 'kill-region)

;; Exchange C-x C-o and C-x o
(define-key override-global-map (kbd "C-x C-o") 'other-window)
(define-key override-global-map (kbd "C-x o") 'execute-extended-command)

;; Exchange C-x b with C-x C-b
(define-key override-global-map (kbd "C-x b") 'consult-buffer)
(define-key override-global-map (kbd "C-x C-b") 'consult-buffer)

;; ===============================
;; Prefix C-o (prefix_o)
;; ===============================

(define-key override-global-map (kbd "C-o") nil)
(define-prefix-command 'prefix_o)
(define-key override-global-map (kbd "C-o") 'prefix_o)

;; Copy
(define-key prefix_o (kbd "C-o") 'kill-ring-save)

;; Move Cursors to end/beginning
(define-key prefix_o (kbd "C-h") 'move-beginning-of-line)
(define-key prefix_o (kbd "C-l") 'move-end-of-line)

;; kill inner word
(define-key prefix_o (kbd "C-k") #'rt/kill_symbol)

;; Comment / visual too 
(define-key prefix_o (kbd "C-f") 'comment-line)

;; Jump pointer, mark end/beginning
(define-key prefix_o (kbd "C-j") 'exchange-point-and-mark)

;; Jump beginning/end
(define-key prefix_o (kbd "C-n") 'end-of-buffer)
(define-key prefix_o (kbd "C-p") 'beginning-of-buffer)

;; Better terminal
(define-key prefix_o (kbd "C-t") 'vterm)

;; Git
(define-key prefix_o (kbd "C-e") 'magit-status)

;; Compile
(define-key prefix_o (kbd "C-c") 'compile)

;; Jump to register
(define-key prefix_o (kbd "C-d") 'consult-register-store)
(define-key prefix_o (kbd "C-r") 'consult-register)

;; Clipboard
(define-key prefix_o (kbd "C-x") 'consult-yank-pop)

;; ===============================
;; Prefix C-f (prefix_f)
;; ===============================

(define-key override-global-map (kbd "C-f") nil)
(define-prefix-command 'prefix_f)
(define-key override-global-map (kbd "C-f") 'prefix_f)

;; mc/cycle through selections
(define-key prefix_f (kbd "C-x C-n")
	    (lambda () (interactive)
	      (when multiple-cursors-mode (mc/cycle-forward))))

(define-key prefix_f (kbd "C-x C-p")
	    (lambda () (interactive)
	      (when multiple-cursors-mode (mc/cycle-backward))))

(define-key prefix_f (kbd "C-x C-j") #'rt/remember_sel)
(define-key prefix_f (kbd "C-x C-k") #'rt/restore_sel)
(define-key prefix_f (kbd "C-x C-x") 'mc/keyboard-quit)
(define-key prefix_f (kbd "C-j") 'cj_macro_forward)
(define-key prefix_f (kbd "C-k") 'cj_macro_backward)

;; Faster visual selection ?
(define-key prefix_f (kbd "C-f") 'er/mark-symbol)
(define-key prefix_f (kbd "C-m") #'rt/word_selection)
(define-key prefix_f (kbd "C-l") #'rt/line_selection)

(define-key prefix_f (kbd "C-n") 'mc/mark-next-like-this)
(define-key prefix_f (kbd "C-p") 'mc/mark-previous-like-this)

;; Skip Selection
(define-key prefix_f (kbd "n") 'mc/skip-to-next-like-this)
(define-key prefix_f (kbd "p") 'mc/skip-to-previous-like-this)

;; Expand
(define-key prefix_f (kbd "C-o C-o") 'er/expand-region)
(define-key prefix_f (kbd "C-o C-l") 'er/mark-outside-pairs)
(define-key prefix_f (kbd "C-o C-n") #'rt/sel_quotes)
(define-key prefix_f (kbd "C-o C-r") 'er/mark-ts-node)

;; Smartparens
(define-key prefix_f (kbd "C-i C-s") 'sp-wrap-round)
(define-key prefix_f (kbd "C-i C-c") 'sp-wrap-curly)
(define-key prefix_f (kbd "C-i C-b") 'sp-wrap-square)
(define-key prefix_f (kbd "C-i C-u") 'sp-unwrap-sexp)
(define-key prefix_f (kbd "C-i C-r") 'sp-rewrap-sexp)
(define-key prefix_f (kbd "C-i C-k") 'sp-forward-slurp-sexp)
(define-key prefix_f (kbd "C-i C-h") 'sp-backward-slurp-sexp)
(define-key prefix_f (kbd "C-i C-j") 'sp-forward-barf-sexp)
(define-key prefix_f (kbd "C-i C-l") 'sp-backward-barf-sexp)
(define-key prefix_f (kbd "C-i C-n") 'sp-kill-whole-line)
(define-key prefix_f (kbd "C-i C-x") 'sp-kill-sexp)

;; FUS/FUN
(define-key prefix_f (kbd "C-u C-s") 'consult-line-multi)
(define-key prefix_f (kbd "C-u C-n") 'consult-ripgrep)
(define-key prefix_f (kbd "C-u C-u") 'avy-goto-char-timer)
(define-key prefix_f (kbd "C-u C-l") 'avy-goto-line)

;; ===============================
;; Repeat Mode
;; ===============================

(electric-pair-mode -1)
(repeat-mode 1)
(setq repeat-check-key nil)

(defvar repeat_selection
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "m")   #'rt/word_selection)
    map))

(defvar exp_fb
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "n")   #'rt/nxt_line)
    (define-key map (kbd "p")   #'rt/pev_line)
    (define-key map (kbd "l")   #'rt/forward_sexp_1)
    (define-key map (kbd "h")   #'rt/backward_sexp_1)
    map))

(defvar bouncy_words
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "t")   #'rt/forward_sexp_2)
    (define-key map (kbd "e")   #'rt/backward_sexp_2)
    map))

(defvar bouncy_node 
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "r")   'er/mark-ts-node)
    map))

(defvar ix_words 
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "x")   'sp-kill-sexp)
    (define-key map (kbd "n")   'sp-kill-whole-line)
    map))

;; Ix_words
(put 'sp-kill-sexp 'repeat-map 'ix_words)
(put 'sp-kill-whole-line 'repeat-map 'ix_words)

;; Repeat_Selection
(put #'rt/word_selection 'repeat-map 'repeat_selection)

;; Bouncy_Node
(put 'er/mark-ts-node 'repeat-map 'bouncy_node)

;; Bouncy_Words
(put #'rt/backward_word 'repeat-map 'bouncy_words)
(put #'rt/forward_word 'repeat-map 'bouncy_words)
(put #'rt/forward_sexp_2 'repeat-map 'bouncy_words)
(put #'rt/backward_sexp_2 'repeat-map 'bouncy_words)

;; Exp_Fb
(put 'next-line 'repeat-map 'exp_fb)
(put 'previous-line 'repeat-map 'exp_fb)
(put #'rt/nxt_line 'repeat-map 'exp_fb)
(put #'rt/pev_line 'repeat-map 'exp_fb)
(put #'rt/forward_sexp_1 'repeat-map 'exp_fb)
(put #'rt/backward_sexp_1 'repeat-map 'exp_fb)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(apheleia avy cape consult corfu emmet-mode expand-region
	      gruvbox-theme magit marginalia multiple-cursors
	      orderless rainbow-delimiters rainbow-mode rust-mode
	      smartparens vertico visual-fill-column vterm
	      yasnippet-snippets zoxide)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
