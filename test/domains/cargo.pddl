(define (domain cargo)
  (:requirements :strips :typing)
  (:types cargo plane airport)
  (:predicates (at ?c - cargo ?a - airport)
               (in ?c - cargo ?p - plane))
  (:action load
      :parameters (?c - cargo ?p - plane ?a - airport)
      :precondition (and (at ?c ?a) (at ?p ?a))
      :effect (and (not (at ?c ?a)) (in ?c ?p)))
  (:action unload
      :parameters (?c - cargo ?p - plane ?a - airport)
      :precondition (and (in ?c ?p) (at ?p ?a))
      :effect (and (at ?c ?a) (not (in ?c ?p))))
  (:action fly
      :parameters (?p - plane ?from - airport ?to - airport)
      :precondition (at ?p ?from)
      :effect (and (not (at ?p ?from)) (at ?p ?to)))
)