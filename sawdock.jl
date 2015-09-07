;;; sawdock.jl -- a simple dock for sawfish
;;
;; version 0.4
;;
;; Copyright (C) 2004 Mario Domenech Goulart
;;
;; Author: Mario Domenech Goulart <mario@inf.ufrgs.br>
;;
;;
;; This code is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 1, or (at your
;; option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;;
;; Commentary:
;;
;; sawdock.jl provides some functions to manipulate windows (dockapps) in
;; a way to emulate a Windowmaker-like dock.
;;
;; How to use it:
;;
;; Insert
;;
;;     (require 'sawdock)
;;
;; in your .sawfishrc file
;;
;; Specify the dockkapps window's name and dockapps' position in the dock
;; by setting the "sawdock-dockapps" variable. For example:
;;
;; (setq sawdock-dockapps
;;   '((0 "bubblemon")
;;     (1 "wmcube")
;;     (2 "wmCalClock")
;;     (3 "wmmixer")
;;     (4 "wmpinboard")))
;;
;; Specify the position of the dock on the screen by setting the variable
;; "sawdock-position". For example:
;;
;; (setq sawdock-position '(horizontal bottom left))
;;
;; Execute the function to dock your dockapps in the right position:
;;
;; (sawdock-dock)
;;
;; You can put this steps in your .sawfishrc file. You can also set or
;; change your configuration using sawfish-client in runtime.
;;
;; You can use the "sawdock-toggle-hide-dock" function to iconify all
;; dockapps.


(require 'rep.io.timers)
(require 'sawfish.wm.util.x)

(defvar sawdock-dockapps
  '((0 "bubblemon")
    (1 "wmcube")
    (2 "wmCalClock")
    (3 "wmmixer")
    (4 "wmifs")
    (5 "wmmp3")
    (6 "wmtictactoe")
    (7 "fishmon")
    (8 "wmpinboard")))

(defvar sawdock-wait-for 0
  "Time sawdock waits before grabbing the dockapps. It's useful in the
situations when sawfishrc is read before the dockapps can be started.")

(defvar sawdock-position '(vertical top left)
  "Position of the dock on the screen.")

(defconst sawdock-dockapp-size 64
  "Dockapp windows' dimensions.")

(defvar sawdock-background-color "green"
  "Dock background color")

(defvar sawdock-border-width 4
  "Dock border width")

(defconst sawdock-positions ((vertical top left)
			     (vertical top right)
			     (vertical bottom left)
			     (vertical bottom right)
			     (horizontal top left)
			     (horizontal top right)
			     (horizontal bottom left)
			     (horizontal bottom right)))

(defvar sawdock-window nil)

(defun sawdock-get-frame (side-border pole-border)
  "Returns a frame with the given borders."
	 `(((background . ,sawdock-background-color)
	    (height . ,sawdock-border-width)
	    (left-edge . ,(- -1 (+ sawdock-border-width (car side-border))))
	    (right-edge . ,(- -1 (+ sawdock-border-width (cdr side-border))))
	    (top-edge . ,(- -1 (+ sawdock-border-width (car pole-border))))
	    (class . top-border))
	   
	   ((background . ,sawdock-background-color)
	    (width . ,sawdock-border-width)
	    (left-edge . ,(- -1 (+ sawdock-border-width (car side-border))))
	    (top-edge . ,(- -1 (+ sawdock-border-width (car pole-border))))
	    (bottom-edge . ,(- -1 (+ sawdock-border-width (cdr pole-border))))
	    (class . left-border))
	   
	   ((background . ,sawdock-background-color)
	    (width . ,sawdock-border-width)
	    (right-edge . ,(- -1 (+ sawdock-border-width (cdr side-border))))
	    (top-edge . ,(- -1 (+ sawdock-border-width (car pole-border))))
	    (bottom-edge . ,(- -1 (+ sawdock-border-width (cdr pole-border))))
	    (class . right-border))
	   
	   ((background . ,sawdock-background-color)
	    (height . ,sawdock-border-width)
	    (left-edge . ,(- -1 (+ sawdock-border-width (car side-border))))
	    (right-edge . ,(- -1 (+ sawdock-border-width (cdr side-border))))
	    (bottom-edge . ,(- -1 (+ sawdock-border-width (cdr pole-border))))
	    (class . bottom-border))))


(defun sawdock-frame-dockapp (dockapp type)
  "Frame the given window. This function handles non-standard windows
dimensions, e.g. odd dimensions, such as 57x61 in order to construct an 
homogeneous dock."
  (let* ((win-dim (window-dimensions dockapp))
	 (side-border (let* ((width (car win-dim))
			     (half-border (quotient 
					   (- sawdock-dockapp-size width) 2)))
			(if (< (+ (* 2 half-border) width) sawdock-dockapp-size)
			    (cons (+ 1 half-border) half-border)
			  (cons half-border half-border))))
	 (pole-border (let* ((height (cdr win-dim))
			     (half-border (quotient 
					   (- sawdock-dockapp-size height) 2)))
			(if (< (+ (* 2 half-border) height) sawdock-dockapp-size)
			    (cons (+ 1 half-border) half-border)
			  (cons half-border half-border)))))
    (progn
      (window-put dockapp 'frame-style 'sawdock)
      (set-window-frame dockapp (sawdock-get-frame side-border pole-border)))))


(defun sawdock-dock()
  "Place the dockapps into a dock."
  (interactive)
  (add-frame-style 'sawdock 
		   (lambda (win type) (sawdock-frame-dockapp win type)))
  (make-timer sawdock-assembly-dock sawdock-wait-for))


(defun sawdock-move-next-position ()
  "Move the dock to the next position on the screen."
  (interactive)
  (if (= (car (member sawdock-position sawdock-positions))
	 (last sawdock-positions))
      (setq sawdock-position (car sawdock-positions))
    (setq sawdock-position 
	  (car (cdr (member sawdock-position sawdock-positions)))))
  (sawdock-assembly-dock))


(defun sawdock-move-previous-position ()
  "Move the dock to the previous position on the screen."
  (interactive)
  (if (= (car (member sawdock-position sawdock-positions))
	 (car sawdock-positions))
      (setq sawdock-position (last sawdock-positions))
    (setq sawdock-position 
	  (car (cdr (member sawdock-position 
			    (reverse sawdock-positions))))))
  (sawdock-assembly-dock))


(defun sawdock-toggle-hide-dock ()
  "Hide/unhide the dock."
  (interactive)
  (mapc (lambda (dockapp)
	  (let ((app (get-window-by-name (car (cdr dockapp)))))
	    (if (and (windowp app) (window-visible-p app))
		(hide-window app)
	      (show-window app))))
	sawdock-dockapps))


(defun sawdock-dock-horizontal-top-left ()
  "Move the dock to the the top-left screen corner and make it horizontal."
  (interactive)
  (setq sawdock-position '(horizontal top left))
  (sawdock-assembly-dock))

(defun sawdock-dock-horizontal-top-right ()
  "Move the dock to the the top-right screen corner and make it horizontal."
  (interactive)
  (setq sawdock-position '(horizontal top right))
  (sawdock-assembly-dock))

(defun sawdock-dock-horizontal-bottom-left ()
  "Move the dock to the the bottom-left screen corner and make it horizontal."
  (interactive)
  (setq sawdock-position '(horizontal bottom left))
  (sawdock-assembly-dock))

(defun sawdock-dock-horizontal-bottom-right ()
  "Move the dock to the the bottom-right screen corner and make it horizontal."
  (interactive)
  (setq sawdock-position '(horizontal bottom right))
  (sawdock-assembly-dock))

(defun sawdock-dock-vertical-top-left ()
  "Move the dock to the the top-left screen corner and make it vertical."
  (interactive)
  (setq sawdock-position '(vertical top left))
  (sawdock-assembly-dock))

(defun sawdock-dock-vertical-top-right ()
  "Move the dock to the the top-right screen corner and make it vertical."
  (interactive)
  (setq sawdock-position '(vertical top right))
  (sawdock-assembly-dock))

(defun sawdock-dock-vertical-bottom-left ()
  "Move the dock to the the bottom-left screen corner and make it vertical."
  (interactive)
  (setq sawdock-position '(vertical bottom left))
  (sawdock-assembly-dock))

(defun sawdock-dock-vertical-bottom-right ()
  "Move the dock to the the bottom-right screen corner and make it vertical."
  (interactive)
  (setq sawdock-position '(vertical bottom right))
  (sawdock-assembly-dock))


(defun sawdock-add-to-dock (app pos)
  "Place a single dockapp into the dock."
  (let ((xpos (car pos))
	(ypos (car (cdr pos))))
    (if (windowp app)
	(progn 
	  (mark-window-as-dock app)
	  (sawdock-frame-dockapp app nil)
	  (move-window-to app xpos ypos)))))


(defun sawdock-assembly-dock ()
  "Assembly the dock, placing each dockapp in its position, as defined
in the sawdock-dockapps variable."
  (mapc (lambda (dockapp)
	  (sawdock-add-to-dock 
	   (get-window-by-name (car (cdr dockapp)))
	   (sawdock-get-dockapp-position (car dockapp))))
	sawdock-dockapps))


(defun sawdock-get-dockapp-position (dockapp-id)
  "Get the position of the dockapp."
  (let ((orientation (nth 0 sawdock-position))
	(vertical-align (nth 1 sawdock-position))
	(horizontal-align (nth 2 sawdock-position)))
    (cond ((and (eq orientation 'vertical) 
		(eq vertical-align 'top)
		(eq horizontal-align 'left))
	   (list 0 (+ (* sawdock-dockapp-size dockapp-id) 
		      (* sawdock-border-width dockapp-id))))
	  
	  ((and (eq orientation 'vertical) 
		(eq vertical-align 'top)
		(eq horizontal-align 'right))
	   (list (- (screen-width) (+ sawdock-dockapp-size 
				      (+ 1 (* 2 sawdock-border-width))))
		 (+ (* sawdock-dockapp-size dockapp-id) 
		    (* sawdock-border-width dockapp-id))))

	  ((and (eq orientation 'vertical) 
		 (eq vertical-align 'bottom)
		 (eq horizontal-align 'left))
	   (list 0 (- (- (screen-height) 
			 (+ sawdock-border-width
			    (+ (* sawdock-dockapp-size dockapp-id)
			       (* sawdock-border-width (+ 1 dockapp-id)))))
		      sawdock-dockapp-size)))

	  ((and (eq orientation 'vertical) 
		 (eq vertical-align 'bottom)
		 (eq horizontal-align 'right))
	   (list  (- (screen-width) (+ sawdock-dockapp-size
				       (+ 1 (* 2 sawdock-border-width))))
		  (- (- (screen-height) 
			(+ sawdock-border-width
			   (+ (* sawdock-dockapp-size dockapp-id)
			      (* sawdock-border-width (+ 1 dockapp-id)))))
		     sawdock-dockapp-size)))

	  ;; Horizontal
	  ((and (eq orientation 'horizontal) 
		(eq vertical-align 'top)
		(eq horizontal-align 'left))
	   (list (+ (* sawdock-dockapp-size dockapp-id) 
		    (* sawdock-border-width dockapp-id)) 0))

	  ((and (eq orientation 'horizontal) 
		(eq vertical-align 'top)
		(eq horizontal-align 'right))
	   (list (- (screen-width) 
		    (+ (+ (* (+ 1 dockapp-id) sawdock-dockapp-size) 
		       (* sawdock-border-width (+ 1 dockapp-id))) 
		       sawdock-border-width)) 0))

	  ((and (eq orientation 'horizontal) 
		(eq vertical-align 'bottom)
		(eq horizontal-align 'left))
	   (list (+ (* sawdock-dockapp-size dockapp-id) 
		    (* sawdock-border-width dockapp-id))
		 (- (screen-height) 
		    (+ 1 (+ (* 2 sawdock-border-width) sawdock-dockapp-size)))))

	  ((and (eq orientation 'horizontal) 
		 (eq vertical-align 'bottom)
		 (eq horizontal-align 'right))
	   (list (- (screen-width) 
		    (+ (+ (* (+ 1 dockapp-id) sawdock-dockapp-size) 
		       (* sawdock-border-width (+ 1 dockapp-id))) 
		       sawdock-border-width))
		 (- (screen-height) 
		    (+ 1 (+ (* 2 sawdock-border-width) sawdock-dockapp-size)))))

	  (t (list nil nil)))))


(provide 'sawdock)