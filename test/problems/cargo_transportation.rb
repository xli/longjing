def cargo_transportation_problem
  {
    # domain
    types: [:cargo, :plane, :airport],
    actions: [
      {
        name: :load,
        parameters: [[:c, :cargo], [:p, :plane], [:a, :airport]],
        precond: [
          [:at, :c, :a],
          [:at, :p, :a]
        ],
        effect: [
          [:-, :at, :c, :a],
          [:in, :c, :p]
        ]
      },
      {
        name: :unload,
        parameters: [[:c, :cargo], [:p, :plane], [:a, :airport]],
        precond: [
          [:in, :c, :p],
          [:at, :p, :a]
        ],
        effect: [
          [:at, :c, :a],
          [:-, :in, :c, :p]
        ]
      },
      {
        name: :fly,
        parameters: [[:p, :plane], [:from, :airport], [:to, :airport]],
        precond: [
          [:at, :p, :from]
        ],
        effect: [
          [:-, :at, :p, :from],
          [:at, :p, :to]
        ]
      }
    ],
    # problem
    objects: [
      [:c1, :cargo],
      [:c2, :cargo],
      [:p1, :plane],
      [:p2, :plane],
      [:sfo, :airport],
      [:jfk, :airport]
    ],
    init: [
      [:at, :c1, :sfo],
      [:at, :c2, :jfk],
      [:at, :p1, :sfo],
      [:at, :p2, :jfk],
    ],
    goal: [
      [:at, :c1, :jfk],
      [:at, :c2, :sfo]
    ],
    solution: [
      [:load, :c1, :p1, :sfo],
      [:load, :c2, :p2, :jfk],
      [:fly, :p1, :sfo, :jfk],
      [:unload, :c1, :p1, :jfk],
      [:fly, :p2, :jfk, :sfo],
      [:unload, :c2, :p2, :sfo]
    ]
  }
end
