;;; musixmatch.el --- Looking up songs from musixmatch
;; Copyright (C) 2013 Lars Magne Ingebrigtsen

;; Author: Lars Magne Ingebrigtsen <larsi@gnus.org>
;; Keywords: books

;; musixmatch.el is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 2, or (at your
;; option) any later version.

;;; Commentary:

;;; Code:

(defvar musixmatch-api-key nil)
(defvar musixmatch-url "http://api.musixmatch.com/ws/1.1/")

(require 'json)
(require 'cl)

(defun musixmatch-search (artist track)
  (url-retrieve
   (format "%strack.search?q_track=%s&q_artist=%s&f_has_lyrics=1&apikey=%s"
	   musixmatch-url track artist musixmatch-api-key)
   (lambda (&rest args)
     (when (search-forward "\n\n" nil t)
       (let ((data (cadar (json-read))))
	 (when (eq (car data) 'body)
	   (let* ((tracks (cdr (assq 'track_list data)))
		  (track-id (cdr (assq 'track_id (car (aref tracks 0))))))
	     (url-retrieve
	      (format "%strack.lyrics.get?track_id=%s&apikey=%s"
		      musixmatch-url track-id musixmatch-api-key)
	      (lambda (&rest args)
		(when (search-forward "\n\n" nil t)
		  (let* ((data (json-read))
			 (lyrics (cdr (assq 'lyrics_body (cadr (cadar data))))))
		    (pop-to-buffer "*lyrics*")
		    (erase-buffer)
		    (insert (replace-regexp-in-string "\r" ""
						      lyrics)))))))))))))

(provide 'musixmatch)

;;; musixmatch.el ends here
