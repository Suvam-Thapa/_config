;; -*- lexical-binding: t; -*-

;; ============================================================
;; Performance & Memory
;; ============================================================

(setq gc-cons-threshold most-positive-fixnum)
(setq gc-cons-percentage 0.8)
(setq read-process-output-max (* 3 1024 1024))

;; ============================================================
;; File Name Handlers
;; ============================================================

(defvar my/saved-file-name-handler-alist  file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist
                  my/saved-file-name-handler-alist)))

;; ============================================================
;; Frame / UI
;; ============================================================

(setq default-frame-alist
      (append '((menu-bar-lines . 0)
                (tool-bar-lines . 0)
                (vertical-scroll-bars . nil)
                (horizontal-scroll-bars . nil))
              default-frame-alist))

(setq menu-bar-mode nil)
(setq tool-bar-mode nil)
(setq scroll-bar-mode nil)

(fringe-mode 0)
(blink-cursor-mode 0)

(setq frame-inhibit-implied-resize t)
(setq frame-resize-pixelwise t)
(setq window-resize-pixelwise t)

(setq inhibit-compacting-font-caches t)
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message user-login-name)
(setq initial-scratch-message nil)

;; ============================================================
;; Bidirectional Text
;; ============================================================

(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right
              bidi-inhibit-bpa t)

;; ============================================================
;; Native Compilation
;; ============================================================

(when (boundp 'native-comp-speed)
  (setq native-comp-speed 2))

(provide 'early-init)
