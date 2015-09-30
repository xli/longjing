(define (domain marsrover-strips)
  (:requirements :strips :typing)
  (:types direction number - object)
  (:constants north east south west - direction)
  (:predicates (next ?n1 ?n2 - number)
               (face ?d - direction)
               (at ?x - number ?y - number)
               (blocked ?x - number ?y - number)
               (left ?d1 ?d2 - direction)
               (right ?d1 ?d2 - direction))

  (:action turn-left
           :parameters (?from ?to - direction)
           :precondition (and (face ?from) (left ?from ?to))
           :effect (and
                   (not (face ?from))
                   (face ?to)))
  (:action turn-right
           :parameters (?from ?to - direction)
           :precondition (and (face ?from) (right ?from ?to))
           :effect (and
                   (not (face ?from))
                   (face ?to)))

  (:action move-north
           :parameters (?x - number ?y ?to_y - number)
           :precondition (and (face north)
                              (at ?x ?y)
                              (not (blocked ?x ?to_y))
                              (next ?y ?to_y))
           :effect (and (at ?x ?to_y) (not (at ?x ?y))))

  (:action move-east
           :parameters (?x ?to_x - number ?y - number)
           :precondition (and (face east)
                              (at ?x ?y)
                              (not (blocked ?to_x ?y))
                              (next ?x ?to_x))
           :effect (and (at ?to_x ?y) (not (at ?x ?y))))

  (:action move-south
           :parameters (?x - number ?y ?to_y - number)
           :precondition (and (face south)
                              (at ?x ?y)
                              (not (blocked ?x ?to_y))
                              (next ?to_y ?y))
           :effect (and (at ?x ?to_y) (not (at ?x ?y))))

  (:action move-west
           :parameters (?x ?to_x - number ?y - number)
           :precondition (and (face west)
                              (at ?x ?y)
                              (not (blocked ?to_x ?y))
                              (next ?to_x ?x))
           :effect (and (at ?to_x ?y) (not (at ?x ?y))))
)
