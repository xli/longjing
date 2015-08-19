(define (problem marsrover-strips-p1)
  (:domain marsrover-strips)
  (:objects x1 x2 x3 x4 x5 - x-axis
            y1 y2 y3 y4 y5 - y-axis)
  (:init (next x1 x2) (next x2 x3) (next x3 x4) (next x4 x5)
         (next y1 y2) (next y2 y3) (next y3 y4) (next y4 y5)
         (left north west)
         (left west south)
         (left south east)
         (left east north)
         (right north east)
         (right east south)
         (right south west)
         (right west north)
         (blocked x1 y2)
         (blocked x2 y2)
         (blocked x5 y2)
         (blocked x4 y2)
         (at x1 y1) (face north))
  (:goal (and (at x5 y4) (face south))))