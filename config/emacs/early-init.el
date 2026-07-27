;;; early-init.el --- Pre-GUI initialization -*- lexical-binding: t; -*-

;; ─── Performance: GC and file-name-handler ──────────────
(setq gc-cons-threshold 100000000)  ; 100 MB during startup
(setq read-process-output-max (* 1024 1024))  ; 1 MB for LSP
(defvar default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; Restore after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold 800000)
            (setq file-name-handler-alist default-file-name-handler-alist)))

;; ─── UI suppression (before frame creation) ─────────────
(setq inhibit-startup-message t)
(setq inhibit-startup-screen t)
(setq frame-inhibit-implied-resize t)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(horizontal-scroll-bars) default-frame-alist)

;; ─── Native comp warnings ───────────────────────────────
(setq native-comp-async-report-warnings-errors nil)

;; ─── Package archives ───────────────────────────────────
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

;; ─── Theme (load before first frame to prevent flash) ───
(setq custom-safe-themes t)
(require 'package)
(package-initialize)
(unless (package-installed-p 'doom-themes)
  (package-refresh-contents)
  (condition-case err
      (package-install 'doom-themes)
    (error
     (message "Failed to install doom-themes: %s" (error-message-string err)))))
(if (package-installed-p 'doom-themes)
    (load-theme 'doom-moonlight t)
  (load-theme 'modus-vivendi t)
  (message "Warning: doom-themes not available, using modus-vivendi fallback"))

(provide 'early-init)
;;; early-init.el ends here
