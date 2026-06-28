;;; lena-theme.el --- Port of elenapan's "lena" Neovim colorscheme -*- lexical-binding: t; -*-

;; Source palette: https://github.com/elenapan/dotfiles/blob/master/config/nvim/colors/lena.vim
;; ("lena.vim - Vim color scheme based on noctu")
;;
;; Install:
;;   1. Save this file as ~/.emacs.d/themes/lena-theme.el
;;   2. (add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
;;   3. (load-theme 'lena t)

(deftheme lena
  "Dark theme ported from elenapan's lena.vim Neovim colorscheme.")

(let* ((bg          "#101319")
       (bg-alt      "#171b24")
       (fg          "#f4f3ee")
       (fg-dim      "#dddbcf")
       (grey        "#3a435a")   ; comments / line numbers
       (red         "#e34f4f")   ; cursor / visual-selection accents
       (red-dark    "#de2b2b")   ; errors
       (orange      "#de642b")   ; functions / search bg
       (orange-lt   "#e37e4f")
       (blue        "#3f8cde")   ; keywords / types
       (blue-mid    "#5599e2")   ; conditionals
       (indigo      "#5679e3")   ; strings / titles
       (indigo-dk   "#3e66e0")   ; numbers / directories
       (cyan        "#56b7c8")   ; spell-cap / git-add
       (teal        "#69bfce")   ; booleans / done
       (violet      "#885ac4")   ; constants / special
       (purple      "#956dca")  ; visual bg / operators
       (pale-silver "#9bb0c4")
       (clay        "#d3a894")
       (pale        "#FFDE96")
       (sage        "#6bd381")) ;muted

  (custom-theme-set-faces
   'lena

   ;; Core
   `(default ((t (:background ,bg :foreground ,fg))))
   `(cursor ((t (:background ,red))))
   `(region ((t (:background ,purple :foreground ,bg-alt))))
   `(highlight ((t (:background ,bg-alt))))
   `(hl-line ((t (:background ,bg-alt))))
   `(fringe ((t (:background ,bg))))
   `(vertical-border ((t (:foreground ,bg-alt))))
   `(window-divider ((t (:foreground ,bg-alt))))
   `(shadow ((t (:foreground ,grey))))
   `(minibuffer-prompt ((t (:foreground ,indigo :weight bold))))
   `(link ((t (:foreground ,blue :underline t))))
   `(link-visited ((t (:foreground ,violet :underline t))))

   ;; Line numbers
   `(line-number ((t (:foreground ,grey :background ,bg :weight bold))))
   `(line-number-current-line ((t (:foreground ,indigo :background ,bg-alt :weight bold))))

   ;; Mode line
   `(mode-line ((t (:foreground ,fg :background ,bg-alt :box nil))))
   `(mode-line-inactive ((t (:foreground ,grey :background ,bg :box nil))))
   `(mode-line-buffer-id ((t (:foreground ,indigo :weight bold))))
   `(header-line ((t (:foreground ,fg :background ,bg-alt))))

   ;; Search / paren matching
   `(isearch ((t (:foreground ,bg-alt :background ,orange))))
   `(lazy-highlight ((t (:foreground ,bg-alt :background ,violet))))
   `(show-paren-match ((t (:foreground ,fg :background ,bg :underline t))))
   `(show-paren-mismatch ((t (:foreground ,fg :background ,red-dark))))

   ;; Font-lock (syntax highlighting)
   `(font-lock-comment-face ((t (:foreground ,grey :weight bold))))
   `(font-lock-comment-delimiter-face ((t (:foreground ,grey :weight bold))))
   `(font-lock-string-face ((t (:foreground ,indigo :weight bold))))
   `(font-lock-doc-face ((t (:foreground ,teal))))
   `(font-lock-keyword-face ((t (:foreground ,blue :weight bold))))
   `(font-lock-builtin-face ((t (:foreground ,blue))))
   `(font-lock-function-name-face ((t (:foreground ,orange :weight bold))))
   `(font-lock-variable-name-face ((t (:foreground ,fg))))
   `(font-lock-type-face ((t (:foreground ,blue))))
   `(font-lock-constant-face ((t (:foreground ,violet))))
   `(font-lock-negation-char-face ((t (:foreground ,purple))))
   `(font-lock-preprocessor-face ((t (:foreground ,orange :weight bold))))
   `(font-lock-warning-face ((t (:foreground ,red-dark :weight bold))))
   `(font-lock-number-face ((t (:foreground ,indigo-dk :weight bold))))
   `(font-lock-operator-face ((t (:foreground ,purple :weight bold))))

   ;; Errors / diagnostics (flymake / flycheck / eglot)
   `(error ((t (:foreground ,red-dark :weight bold))))
   `(warning ((t (:foreground ,blue-mid :weight bold))))
   `(success ((t (:foreground ,teal :weight bold))))
   `(flymake-error ((t (:underline (:style wave :color ,red-dark)))))
   `(flymake-warning ((t (:underline (:style wave :color ,blue-mid)))))
   `(flymake-note ((t (:underline (:style wave :color ,cyan)))))
   `(flycheck-error ((t (:underline (:style wave :color ,red-dark)))))
   `(flycheck-warning ((t (:underline (:style wave :color ,blue-mid)))))
   `(flycheck-info ((t (:underline (:style wave :color ,cyan)))))

   ;; Diff / VC
   `(diff-added ((t (:foreground ,cyan))))
   `(diff-removed ((t (:foreground ,red))))
   `(diff-changed ((t (:foreground ,blue-mid))))
   `(diff-hl-insert ((t (:foreground ,cyan :background ,bg))))
   `(diff-hl-delete ((t (:foreground ,red-dark :background ,bg))))
   `(diff-hl-change ((t (:foreground ,indigo-dk :background ,bg))))

   ;; Completion popups (company / corfu)
   `(company-tooltip ((t (:foreground ,fg-dim :background ,bg-alt))))
   `(company-tooltip-selection ((t (:foreground ,purple :background ,bg-alt))))
   `(company-tooltip-common ((t (:foreground ,orange))))
   `(company-scrollbar-bg ((t (:background ,bg-alt))))
   `(company-scrollbar-fg ((t (:background ,fg))))
   `(corfu-default ((t (:foreground ,fg-dim :background ,bg-alt))))
   `(corfu-current ((t (:foreground ,purple :background ,bg-alt))))

   ;; Org mode
   `(org-level-1 ((t (:foreground ,blue :weight bold))))
   `(org-level-2 ((t (:foreground ,orange :weight bold))))
   `(org-level-3 ((t (:foreground ,red-dark :weight bold))))
   `(org-level-4 ((t (:foreground ,indigo-dk :weight bold))))
   `(org-level-5 ((t (:foreground ,cyan :weight bold))))
   `(org-level-6 ((t (:foreground ,violet :weight bold))))
   `(org-todo ((t (:foreground ,red :weight bold))))
   `(org-done ((t (:foreground ,teal :weight bold))))
   `(org-link ((t (:foreground ,blue :underline t))))
   `(org-block ((t (:foreground ,teal :background ,bg))))
   `(org-code ((t (:foreground ,teal))))

   ;; Markdown
   `(markdown-header-face ((t (:foreground ,blue-mid :weight bold))))
   `(markdown-link-face ((t (:foreground ,blue :weight bold :underline t))))
   `(markdown-code-face ((t (:foreground ,teal))))
   `(markdown-list-face ((t (:foreground ,orange :weight bold))))

   ;; Misc UI
   `(trailing-whitespace ((t (:background ,red))))
   `(tab-bar ((t (:background ,bg-alt :foreground ,grey))))
   `(tab-bar-tab ((t (:background ,bg-alt :foreground ,fg))))
   `(which-key-key-face ((t (:foreground ,orange :weight bold))))
   `(which-key-command-description-face ((t (:foreground ,fg)))) ;; Fixed: Parenthesis removed here

   ;; Rainbow Delimiters (Nested Brackets)
   `(rainbow-delimiters-depth-1-face ((t (:foreground ,blue))))
   `(rainbow-delimiters-depth-2-face ((t (:foreground ,purple))))
   `(rainbow-delimiters-depth-3-face ((t (:foreground ,orange-lt))))
   `(rainbow-delimiters-depth-4-face ((t (:foreground ,clay))))
   `(rainbow-delimiters-depth-5-face ((t (:foreground ,sage))))
   `(rainbow-delimiters-depth-6-face ((t (:foreground ,cyan))))
   `(rainbow-delimiters-depth-7-face ((t (:foreground ,indigo))))
   `(rainbow-delimiters-depth-8-face ((t (:foreground ,pale-silver))))
   `(rainbow-delimiters-depth-9-face ((t (:foreground ,clay))))
   `(rainbow-delimiters-unmatched-face ((t (:foreground ,red-dark :background ,bg-alt :weight bold)))))) 

(provide-theme 'lena)

;;; lena-theme.el ends here
