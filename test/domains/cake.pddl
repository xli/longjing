(define (domain cake)
  (:predicates (have-cake) (eaten-cake))
  (:action eat
      :parameters ()
      :precondition (have-cake)
      :effect (and (not (have-cake)) (eaten-cake)))
  (:action bake
      :parameters ()
      :precondition (not (have-cake))
      :effect (have-cake))
)