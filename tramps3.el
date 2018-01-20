;;; tramps3.el --- Tramp-like access to s3

;; Copyright (C) 2018 Matt Usifer

;; Author: Matt Usifer <mattusifer@gmail.com>
;; Version: 0.1.0
;; Keywords: s3 tools
;; Homepage: https://github.com/mattusifer/tramps3

;; Tramps3 requires at least GNU Emacs 24.4

;; Tramps3 is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; Tramps3 is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Tramps3 provides an interface to Amazon S3 from within Emacs. Tramps3
;; is inspired by TRAMP, and strives to provide near-seamless access to
;; S3 from standard Emacs functions.

;;; Code:

(require 'tramps3-mode)

(defconst tramps3--minimal-emacs "24.4")

;; define the two entry points to tramps3 - tramps3-find-file and tramps3-save-file

(defun tramps3-find-file ()
  "Open tramps3 buffer at input-file. Will be a refreshed dired buffer if it is a directory."
  (interactive)
  (let* ((current-s3-base-path (if (is-tramps3-mode-active)
                                   (tramps3-local-path-to-s3-path default-directory)
                                 "s3://"))
         (current-s3-file-path (tramps3-completing-read current-s3-base-path "Find S3 file"))
         (current-local-base-path (tramps3-s3-path-to-local-path current-s3-base-path))
         (current-local-file-path (tramps3-s3-path-to-local-path current-s3-file-path)))
    (unless (tramps3-is-directory current-s3-file-path)
      (tramps3-s3-cp (tramps3-local-path-to-s3-path current-local-file-path) current-local-file-path))
    (tramps3-refresh-directory current-local-file-path)
    (find-file current-local-file-path)
    (tramps3-mode)))

(defun tramps3-save-file ()
  "Save input file to s3"
  (interactive)
  (let* ((current-s3-base-path (if (is-tramps3-mode-active)
                                   (tramps3-local-path-to-s3-path default-directory)
                                 "s3://"))
         (current-s3-file-path (tramps3-completing-read current-s3-base-path "Save S3 file"))
         (current-local-file-path (tramps3-s3-path-to-local-path current-s3-file-path)))
    (write-file current-local-file-path)
    (tramps3-s3-cp current-local-file-path current-s3-file-path)
    (tramps3-refresh-directory current-local-file-path)
    (find-file current-local-file-path)
    (tramps3-mode)))

(when (and after-init-time
           (version< emacs-version tramps3--minimal-emacs))
  (display-warning 'tramps3 (format "Tramps3 requires Emacs >= %s, you are using %s."
                                    tramps3--minimal-emacs emacs-version)))

(provide 'tramps3)
;;; tramps3.el ends here
