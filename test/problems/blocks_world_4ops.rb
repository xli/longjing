# (define (domain blocksworld)
#   (:requirements :strips)
# (:predicates (clear ?x)
#              (on-table ?x)
#              (arm-empty)
#              (holding ?x)
#              (on ?x ?y))

# (:action pickup
#   :parameters (?ob)
#   :precondition (and (clear ?ob) (on-table ?ob) (arm-empty))
#   :effect (and (holding ?ob) (not (clear ?ob)) (not (on-table ?ob))
#                (not (arm-empty))))

# (:action putdown
#   :parameters  (?ob)
#   :precondition (holding ?ob)
#   :effect (and (clear ?ob) (arm-empty) (on-table ?ob)
#                (not (holding ?ob))))

# (:action stack
#   :parameters  (?ob ?underob)
#   :precondition (and (clear ?underob) (holding ?ob))
#   :effect (and (arm-empty) (clear ?ob) (on ?ob ?underob)
#                (not (clear ?underob)) (not (holding ?ob))))

# (:action unstack
#   :parameters  (?ob ?underob)
#   :precondition (and (on ?ob ?underob) (clear ?ob) (arm-empty))
#   :effect (and (holding ?ob) (clear ?underob)
#                (not (on ?ob ?underob)) (not (clear ?ob)) (not (arm-empty)))))
def blocks_world_4ops_problem
  {
    actions: [
      {
        name: :pickup,
        parameters: [:ob],
        precond: [[:clear, :ob],
                  [:on_table, :ob],
                  [:arm_empty]],
        effect: [[:holding, :ob],
                 [:-, :clear, :ob],
                 [:-, :on_table, :ob],
                 [:-, :arm_empty]]
      },
      {
        name: :putdown,
        parameters: [:ob],
        precond: [[:holding, :ob]],
        effect: [[:clear, :ob],
                 [:arm_empty],
                 [:on_table, :ob],
                 [:-, :holding, :ob]],
      },
      {
        name: :stack,
        parameters: [:ob, :underob],
        precond: [[:clear, :underob], [:holding, :ob]],
        effect: [[:arm_empty], [:clear, :ob], [:on, :ob, :underob],
                 [:-, :clear, :underob], [:-, :holding, :ob]]
      },
      {
        name: :unstack,
        parameters: [:ob, :underob],
        precond: [[:on, :ob, :underob], [:clear, :ob], [:arm_empty]],
        effect: [[:holding, :ob],
                 [:clear, :underob],
                 [:-, :on, :ob, :underob],
                 [:-, :clear, :ob],
                 [:-, :arm_empty]]
      }
    ],
    objects: [:b1, :b2, :b3, :b4, :b5, :b6],
    init: [
      [:arm_empty],
      [:on, :b1, :b3],
      [:on_table, :b2],
      [:on_table, :b3],
      [:on_table, :b4],
      [:on_table, :b5],
      [:on, :b6, :b2],
      [:clear, :b1],
      [:clear, :b4],
      [:clear, :b5],
      [:clear, :b6]
    ],
    goal: [
      [:on, :b1, :b4],
      [:on, :b3, :b1],
      [:on, :b4, :b6],
      [:on, :b5, :b3]
    ],
    solution: [
      [:pickup, :b4],
      [:stack, :b4, :b6],
      [:unstack, :b1, :b3],
      [:stack, :b1, :b4],
      [:pickup, :b3],
      [:stack, :b3, :b1],
      [:pickup, :b5],
      [:stack, :b5, :b3]]
  }
end
