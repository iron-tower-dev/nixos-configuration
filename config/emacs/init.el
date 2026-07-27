;;; init.el --- Main configuration -*- lexical-binding: t; -*-

;; ─── Package system bootstrap ───────────────────────────
(require 'package)
(unless package--initialized (package-initialize))
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; ─── General Settings ───────────────────────────────────
(use-package emacs
  :ensure nil
  :config
  ;; Indentation
  (setq-default tab-width 4)
  (setq-default indent-tabs-mode nil)
  (setq-default standard-indent 4)

  ;; Line numbers (relative) in prog and text modes
  (setq display-line-numbers-type 'relative)
  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  (add-hook 'text-mode-hook #'display-line-numbers-mode)

  ;; No wrapping in prog-mode
  (add-hook 'prog-mode-hook (lambda () (setq truncate-lines t)))

  ;; Window splitting preferences
  (setq split-height-threshold nil)
  (setq split-width-threshold 80)

  ;; Scroll margin
  (setq scroll-margin 8)

  ;; Disable backup/autosave/lockfiles
  (setq make-backup-files nil)
  (setq auto-save-default nil)
  (setq create-lockfiles nil)

  ;; Clipboard integration (default on pgtk, explicit for clarity)
  (setq select-enable-clipboard t)

  ;; Fringe width
  (set-fringe-mode '(8 . 8))

  ;; Misc
  (setq ring-bell-function 'ignore)
  (setq use-short-answers t)
  (setq confirm-kill-emacs 'y-or-n-p)

  ;; Yank highlight (pulse)
  (defun pulse-yank-advice (&rest _)
    "Briefly highlight the yanked region."
    (when (region-active-p)
      (pulse-momentary-highlight-region (region-beginning) (region-end))))
  (advice-add 'yank :after #'pulse-yank-advice)
  (advice-add 'yank-pop :after #'pulse-yank-advice))

;; ─── Persistent Undo ────────────────────────────────────
(use-package emacs
  :ensure nil
  :config
  ;; Built-in undo with undo-no-redo behavior
  (setq undo-no-redo t)
  ;; Save undo history to disk
  (setq undo-tree-history-directory-alist nil)  ; not using undo-tree
  ;; We rely on vundo for visualization + Emacs native undo
  )

;; ─── Leader Key ─────────────────────────────────────────
(use-package emacs
  :ensure nil
  :config
  (defvar leader-map (make-sparse-keymap) "Leader key prefix map.")
  (define-key global-map (kbd "C-SPC") nil)  ; free C-SPC
  (keymap-global-set "M-SPC" leader-map)

  ;; In GUI frames, bind SPC as leader in non-insert contexts
  ;; Using a minor mode that activates in non-editing contexts
  (define-minor-mode leader-mode
    "Minor mode for SPC as leader key."
    :global t
    :keymap (let ((map (make-sparse-keymap)))
              (define-key map (kbd "SPC") leader-map)
              map))

  ;; Disable leader-mode in minibuffer
  (add-hook 'minibuffer-setup-hook (lambda () (leader-mode -1)))
  (add-hook 'minibuffer-exit-hook (lambda () (leader-mode 1)))

  ;; ─── Keybindings ────────────────────────────────────────
  ;; leader d — delete without kill ring
  (define-key leader-map (kbd "d") 'delete-region)

  ;; C-c in minibuffer aborts
  (define-key minibuffer-local-map (kbd "C-c") 'abort-recursive-edit)

  ;; C-c deactivates region in normal buffers
  (global-set-key (kbd "C-c C-c")
                  (lambda () (interactive) (deactivate-mark)))

  ;; leader r — search and replace with symbol at point
  (define-key leader-map (kbd "r")
              (lambda ()
                (interactive)
                (let ((sym (thing-at-point 'symbol t)))
                  (if sym
                      (query-replace sym (read-string
                                          (format "Replace '%s' with: " sym)))
                    (call-interactively 'query-replace)))))

  ;; leader X — make file executable
  (define-key leader-map (kbd "X")
              (lambda ()
                (interactive)
                (when buffer-file-name
                  (shell-command (concat "chmod +x " (shell-quote-argument buffer-file-name)))
                  (message "Made %s executable" (file-name-nondirectory buffer-file-name)))))

  ;; C-d / C-u — half-page scroll + recenter
  (global-set-key (kbd "C-d")
                  (lambda () (interactive)
                    (scroll-up-command (/ (window-height) 2))
                    (recenter)))
  (global-set-key (kbd "C-u")
                  (lambda () (interactive)
                    (scroll-down-command (/ (window-height) 2))
                    (recenter)))

  ;; leader f — format via eglot
  (define-key leader-map (kbd "f")
              (lambda ()
                (interactive)
                (if (bound-and-true-p eglot--managed-mode)
                    (eglot-format-buffer)
                  (message "No language server active for formatting")))))

;; ─── Vundo (undo tree visualizer) ────────────────────────
(use-package vundo
  :commands vundo
  :init
  (define-key leader-map (kbd "u") 'vundo)
  :config
  (setq vundo-glyph-alist vundo-unicode-symbols))

;; ─── Completion: Vertico + Orderless + Marginalia ────────
(use-package vertico
  :init (vertico-mode)
  :config
  (setq vertico-cycle t)
  (setq vertico-count 15))

(use-package orderless
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrides
        '((file (styles partial-completion)))))

(use-package marginalia
  :init (marginalia-mode))

;; ─── Consult (search/navigation commands) ───────────────
(use-package consult
  :init
  ;; leader pf — project find file
  (define-key leader-map (kbd "pf") 'consult-find)
  ;; leader ps — project grep (symbol at point as initial)
  (define-key leader-map (kbd "ps")
              (lambda ()
                (interactive)
                (consult-ripgrep nil (thing-at-point 'symbol t))))
  ;; leader vh — help search
  (define-key leader-map (kbd "vh") 'consult-info)
  ;; leader xx — project diagnostics
  (define-key leader-map (kbd "xx") 'consult-flymake)
  :config
  (setq consult-narrow-key "<")
  ;; Use project.el for project root detection
  (setq consult-project-function
        (lambda (_may-prompt)
          (when-let ((project (project-current)))
            (project-root project)))))

;; ─── Eglot (built-in LSP) ──────────────────────────────
(use-package eglot
  :ensure nil
  :hook ((go-ts-mode . eglot-ensure)
         (rust-ts-mode . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (tsx-ts-mode . eglot-ensure)
         (js-mode . eglot-ensure)
         (lua-mode . eglot-ensure))
  :config
  ;; lua-language-server: recognize vim global (for Neovim lua configs)
  (setq-default eglot-workspace-configuration
                '(:lua (:diagnostics (:globals ["vim"]))))
  ;; Disable event logging for performance
  (fset #'jsonrpc--log-event #'ignore))

;; ─── Treesit + treesit-auto ─────────────────────────────
(use-package treesit-auto
  :config
  (setq treesit-auto-install 'prompt)
  ;; Remap major modes to tree-sitter equivalents
  (treesit-auto-add-to-auto-mode-alist '(go rust typescript tsx
                                          javascript html css
                                          json bash dockerfile))
  (global-treesit-auto-mode))

(use-package treesit
  :ensure nil
  :config
  ;; Maximum decoration level
  (setq treesit-font-lock-level 4))

;; ─── Dired (file explorer) ───────────────────────────────
(use-package dired
  :ensure nil
  :commands dired
  :bind (("-" . (lambda ()
                  (interactive)
                  (dired-jump)))
         :map leader-map
         ("-" . (lambda ()
                  (interactive)
                  (if-let ((project (project-current)))
                      (dired (project-root project))
                    (dired-jump)))))
  :config
  (setq dired-listing-switches "-lah --group-directories-first")
  (setq dired-kill-when-opening-new-dired-buffer t)
  (add-hook 'dired-mode-hook #'dired-omit-mode)
  ;; Toggle dotfiles with C-x M-o (dired-omit-mode toggle)
  (setq dired-omit-files "^\\.[^.].*"))

;; ─── Magit (Git porcelain) ──────────────────────────────
(use-package magit
  :commands (magit-status magit-diff-buffer-file)
  :init
  (define-key leader-map (kbd "gg")
              (lambda ()
                (interactive)
                (magit-status)
                (delete-other-windows)))
  (define-key leader-map (kbd "gd") 'magit-diff-buffer-file))

;; ─── Diff-HL (git gutter indicators) ────────────────────
(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (text-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (setq diff-hl-draw-borders nil)
  (diff-hl-flydiff-mode 1))

;; ─── Electric Pair Mode (auto-close delimiters) ─────────
(use-package elec-pair
  :ensure nil
  :init (electric-pair-mode 1))

;; ─── Surround (embrace.el) ──────────────────────────────
(use-package embrace
  :bind (("C-," . embrace-commander))
  :init
  (define-key leader-map (kbd "sa") 'embrace-add)
  (define-key leader-map (kbd "sd") 'embrace-delete)
  (define-key leader-map (kbd "sc") 'embrace-change))

;; ─── Global Statusline (single mode-line) ────────────────
(use-package emacs
  :ensure nil
  :config
  ;; Suppress mode-line in non-active windows
  (setq-default mode-line-format
                '("%e"
                  mode-line-front-space
                  " "
                  ;; Buffer name
                  mode-line-buffer-identification
                  "  "
                  ;; Major mode
                  "(" mode-name ")"
                  "  "
                  ;; VC branch (git)
                  (vc-mode vc-mode)
                  "  "
                  ;; Eglot status
                  mode-line-misc-info
                  mode-line-end-spaces))

  ;; Hide mode-line in inactive windows (simulate global statusline)
  (defun set-inactive-modeline ()
    "Use a minimal separator for inactive windows."
    (dolist (win (window-list))
      (unless (eq win (selected-window))
        (with-selected-window win
          (setq-local mode-line-format '(" "))))))
  (add-hook 'window-configuration-change-hook #'set-inactive-modeline)
  (add-hook 'buffer-list-update-hook #'set-inactive-modeline))

(provide 'init)
;;; init.el ends here
